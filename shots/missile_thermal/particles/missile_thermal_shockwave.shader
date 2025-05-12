#include "./Data/common_effects/particles/base_particle.shader"

struct VERT_OUTPUT2
{
	float4 location : SV_POSITION;
	float2 normalizedLocation : POSITION0;
	float2 normalizedCenter : POSITION1;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

VERT_OUTPUT2 vert(in VERT_INPUT_PARTICLE input)
{
	float4 loc;
	loc.xy = input.center + rotate(input.offset * _baseSize * input.scale, input.rotation);
	loc.z = 0;
	loc.w = 1;

	VERT_OUTPUT2 output;
	output.location = mul(loc, _transform);
	output.normalizedLocation.x = (output.location.x + 1) / 2;
	output.normalizedLocation.y = (-output.location.y + 1) / 2;
	float4 center = mul(float4(input.center, 0, 1), _transform);
	output.normalizedCenter.x = (center.x + 1) / 2;
	output.normalizedCenter.y = (-center.y + 1) / 2;
	output.color = input.color * _color;
	output.uv = input.uv;
	return output;
}

float2 toPolarCoordinates(float2 uv)
{
	float2 centeredUVs = (uv - float2(0.5, 0.5)) * 2;
	float distance = length(centeredUVs);
	float angle = atan2(centeredUVs.y, centeredUVs.x);
	float2 polarUVs = float2(angle / TWO_PI, distance);
	/*
	float newX = frac(polarUVs.x);
	if (fwidth(polarUVs.x) - 0.0001 > fwidth(newX))
	{
		polarUVs.x = newX;
	}
	*/
	return polarUVs;
}

Texture2D _capturedBackBuffer;
SamplerState _capturedBackBuffer_SS;

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

float _shockwaveStrength;

PIX_OUTPUT pix(in VERT_OUTPUT2 input) : SV_TARGET
{
	//float2 centeredUVs = (input.uv * 2) - 1;
	
	//centeredUVs *= lerp(0.1, 1, 1 - input.color.b);
	//centeredUVs += float2(0.5, 0.5);
	
	float4 src = _texture.Sample(_texture_SS, input.uv);
	src.a *= input.color.a;
	if(src.a <= 0 || src.r <= 0)
		discard;

	float2 noiseScrollSpeed = float2(0, _gameTime * -0.8);
	
	float2 polarUVs = toPolarCoordinates(input.uv);
	
	polarUVs.x *= 10;
	polarUVs.y *= 4;
	
	polarUVs += noiseScrollSpeed;
	
	float4 noise = _noiseTexture.Sample(_noiseTexture_SS, polarUVs);
	
	float noiseCentered = (noise.r * 2) - 1;
	//float animationSpeed = 10;
	//float noiseAnimated = sin(noise.r + _gameTime * animationSpeed) * 5;
	
	float2 normal = input.normalizedLocation - input.normalizedCenter;
	float2 uv = input.normalizedLocation - normal * _shockwaveStrength * src.r * noise.r * lerp(0.1, 0.55, input.color.a);
	
	float4 ret = _capturedBackBuffer.Sample(_capturedBackBuffer_SS, uv);
	//ret.rgb += noise.r * input.color.rgb * src.r * 3;
	//ret.rgb += input.color.rgb * src.a * noise.r;
	
	//return float4(noiseAnimated, noiseAnimated, noiseAnimated, src.r);
	ret.a = src.r * input.color.a * 12; // Use red color channel as actual alpha. Weird, but whatever.
	return ret;
}
