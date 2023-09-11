#pragma warning( disable : 3571 )

struct VERT_INPUT
{
	float4 location : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

struct VERT_OUTPUT
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

typedef float4 PIX_OUTPUT;

static const float PI = 3.14159265f;
static const float TWO_PI = PI * 2;
static const float HALF_PI = PI / 2;

cbuffer perFrame
{
	float2 _screenSize;
	float _time;
	float _gameTime;
	float2 _viewportScale;
}

float4x4 _transform;

Texture2D _texture;
SamplerState _texture_SS;
float4 _color = 255;

Texture2D _normalsXYTexture;
SamplerState _normalsXYTexture_SS;
Texture2D _normalsZATexture;
SamplerState _normalsZATexture_SS;
Texture2D _normalsTexture;
SamplerState _normalsTexture_SS;

Texture2D _stencilTarget;
SamplerState _stencilTarget_SS;

Texture2D _diffuseTarget;
SamplerState _diffuseTarget_SS;

Texture2D _normalsTarget;
SamplerState _normalsTarget_SS;

float wave(float t, float period)
{
	return (cos(t / period * TWO_PI) - 1) / -2;
}

float lerp(float from, float to, float t)
{
	t = min(max(t, 0), 1);
	return from + (to - from) * t;
}

float2 lerp(float2 from, float2 to, float t)
{
	t = min(max(t, 0), 1);
	return from + (to - from) * t;
}

float3 lerp(float3 from, float3 to, float t)
{
	t = min(max(t, 0), 1);
	return from + (to - from) * t;
}

float4 lerp(float4 from, float4 to, float t)
{
	t = min(max(t, 0), 1);
	return from + (to - from) * t;
}

float unclampedLerp(float from, float to, float t)
{
	return from + (to - from) * t;
}

float2 unclampedLerp(float2 from, float2 to, float t)
{
	return from + (to - from) * t;
}

float3 unclampedLerp(float3 from, float3 to, float t)
{
	return from + (to - from) * t;
}

float4 unclampedLerp(float4 from, float4 to, float t)
{
	return from + (to - from) * t;
}

float inverseLerp(float from, float to, float value)
{
	float t = (value - from) / (to - from);
	return min(max(t, 0), 1);
}

float2 rotate(float2 v, float radians)
{
	float cosRot = cos(radians);
	float sinRot = sin(radians);
	return float2(
		v.x * cosRot - v.y * sinRot,
		v.x * sinRot + v.y * cosRot);
}

float2 perp(float2 v)
{
	return float2(-v.y, v.x);
}

float2 vproj(float2 v1, float2 v2)
{
	return dot(v1, v2) / dot(v2, v2) * v2;
}

float sproj(float2 v1, float2 v2)
{
	return dot(v1, v2) / length(v2);
}

float wrap(float val, float interval)
{
	return frac(val / interval) * interval;
}

float clampWrapNegativeOnce(float val, float high)
{
	if(val >= 0)
		return min(val, high);
	else
		return max(val + high, 0);
}

float4 loadRawNormals(float2 uv)
{
	float4 nrmlXY = _normalsXYTexture.Sample(_normalsXYTexture_SS, uv);
	float4 nrmlZA = _normalsZATexture.Sample(_normalsZATexture_SS, uv);
	return float4(nrmlXY.a, nrmlXY.g, nrmlZA.g, nrmlZA.a);
}

float3 loadNormalsInferred(float2 uv)
{
	const float CENTER = 127.0 / 255.0;
	float4 c = _normalsTexture.Sample(_normalsTexture_SS, uv);
	float x = (c.a - CENTER) * 2;
	float y = (c.g - CENTER) * 2;
	float z = sqrt(1 - x*x - y*y);
	return float3(x, y, z);
}

float4 loadNormalsAlphaInferred(float2 uv)
{
	const float CENTER = 127.0 / 255.0;
	float4 c = _normalsTexture.Sample(_normalsTexture_SS, uv);
	float x = (c.r - CENTER) * 2;
	float y = (c.g - CENTER) * 2;
	float z = sqrt(1 - x*x - y*y);
	return float4(x, y, z, c.a);
}

float2 rotateFlipNormals(float2 nrml, float4 vertexTangent)
{
	nrml *= vertexTangent.zw;
	return float2(
		nrml.r * vertexTangent.x - nrml.g * vertexTangent.y,
		nrml.r * vertexTangent.y + nrml.g * vertexTangent.x);
}

float3 colorToNormals(float3 color)
{
	const float CENTER = 127.0 / 255.0;
	return (color - CENTER) * 2;
}

float3 normalsToColor(float3 normals)
{
	const float CENTER = 127.0 / 255.0;
	return normals / 2 + CENTER;
}

float getSpecular(float d)
{
	return pow(d, 1) * 0.25;
}

float3 multiplyAdditiveLightValue(inout float3 color, float2 screenUV, float3 screenLightSource, float3 screenPixelLoc, float nrmlStrengthLimit = 1.0)
{
	if(screenLightSource.z < 0)
		return float3(0, 0, 0);

	float3 diffuse = _diffuseTarget.Sample(_diffuseTarget_SS, screenUV).rgb;
	float3 lightNormal = normalize((screenLightSource - screenPixelLoc) * float3(_viewportScale, 1));
	float3 nrmlC = _normalsTarget.Sample(_normalsTarget_SS, screenUV).rgb;
    float3 nrml;
    if(nrmlC.r == 1 && nrmlC.g == 1 && nrmlC.b == 1) // If there is no normals texture, we will get a pure white color value.
        nrml = float3(0,0,0);
    else
        nrml = colorToNormals(nrmlC);
	float d = max(min(dot(lightNormal, nrml), nrmlStrengthLimit), 0);
	color *= d * diffuse + getSpecular(d);
	return nrml;
}

float3 _globalAmbientLight;
float3 _globalDiffuseLight;
float3 _globalMinDiffuseLight;
float3 _globalSpecularLight;
float3 _lightNormal;
void applyGlobalLighting(inout float4 color, float2 uv, float4 vertexTangent, float3 lightNormal)
{
	float3 original = color.rgb;

	// Ambient light.
	color.rgb *= _globalAmbientLight;

	// Diffuse & specular light.
	float4 nrmlColor = loadRawNormals(uv);
	float3 nrml = colorToNormals(nrmlColor.rgb) * nrmlColor.a;
	nrml.rg = rotateFlipNormals(nrml.rg, vertexTangent);
	float d = max(dot(float3(-lightNormal.x, lightNormal.yz), nrml), 0);
	color.rgb += max(_globalDiffuseLight * d, _globalMinDiffuseLight) * original;
	color.rgb += _globalSpecularLight * getSpecular(d);

	// Blend with non-lit value based on length of normal.
	float t = length(nrml);
	color.rgb = t * color.rgb + (1 - t) * original;
}
void applyGlobalLightingInferred(inout float4 color, float2 uv, float4 vertexTangent, float3 lightNormal)
{
	float3 original = color.rgb;

	// Ambient light.
	color.rgb *= _globalAmbientLight;

	// Diffuse & specular light.
	float3 nrml = loadNormalsInferred(uv);
	nrml.rg = rotateFlipNormals(nrml.rg, vertexTangent);
	float d = max(dot(float3(-lightNormal.x, lightNormal.yz), nrml), 0);
	color.rgb += _globalDiffuseLight * original * d;
	color.rgb += _globalSpecularLight * getSpecular(d);
}
void applyGlobalLightingAlphaInferred(inout float4 color, float2 uv, float4 vertexTangent, float3 lightNormal)
{
	float3 original = color.rgb;

	// Ambient light.
	color.rgb *= _globalAmbientLight;

	// Diffuse & specular light.
	float4 nrmlA = loadNormalsAlphaInferred(uv);
	float3 nrml = nrmlA.rgb * nrmlA.a;
	nrml.rg = rotateFlipNormals(nrml.rg, vertexTangent);
	float d = max(dot(float3(-lightNormal.x, lightNormal.yz), nrml), 0);
	color.rgb += _globalDiffuseLight * original * d;
	color.rgb += _globalSpecularLight * getSpecular(d);
}

void applyGlobalLightingAlphaInferredAdditive(inout float4 color, float2 uv, float4 vertexTangent, float3 lightNormal)
{
	float3 original = color.rgb;

	// Diffuse & specular light.
	float4 nrmlA = loadNormalsAlphaInferred(uv);
	float3 nrml = nrmlA.rgb * nrmlA.a;
	nrml.rg = rotateFlipNormals(nrml.rg, vertexTangent);
	float d = max(dot(float3(-lightNormal.x, lightNormal.yz), nrml), 0);
	color.rgb += _globalDiffuseLight * original * d;
	color.rgb += _globalSpecularLight * getSpecular(d);
}

float3 swapAllegianceColor(float3 pixel, float3 allegianceColor)
{
	if(pixel.g - max(pixel.r, pixel.b) > .05 && abs(pixel.r - pixel.b) < .25) // Replace green pixels with allegiance color.
	{
		float3 scaledAllegianceColor = allegianceColor * pixel.g;
		float desaturation = pixel.r / pixel.g; // works because pixel.r == pixel.b (approximately)
		float desaturationValue = max(scaledAllegianceColor.r, max(scaledAllegianceColor.g, scaledAllegianceColor.b));
		float3 desaturationColor = float3(desaturationValue, desaturationValue, desaturationValue);
		pixel = scaledAllegianceColor * (1 - desaturation) + desaturationColor * desaturation;
	}
	return pixel;
}

#ifdef USE_DEFAULT_VERT
VERT_OUTPUT vert(in VERT_INPUT input)
{
	VERT_OUTPUT output;
	output.location = mul(input.location, _transform);
	output.color = input.color * _color;
	output.uv = input.uv;
	return output;
}
#endif

#ifdef USE_DEFAULT_PIX
PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (ret.a <= 0)
		discard;
	return ret;
}
#endif