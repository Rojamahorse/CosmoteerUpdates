//#define USE_DEFAULT_VERT
#include "./Data/common_effects/particles/base_particle.shader"

float4 _centerColor = 255;
float4 _outerColor = 255;
float4 _bloomColor = 255;


struct VERT_OUTPUT2
{
	float4 location : SV_POSITION;
	float2 normalizedLocation : POSITION0;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float4 tangent : TEXCOORD1;
};

VERT_OUTPUT2 vert(in VERT_INPUT input)
{
	VERT_OUTPUT2 output;
	output.location = mul(input.location, _transform);
	output.normalizedLocation.x = (output.location.x + 1) / 2;
	output.normalizedLocation.y = (-output.location.y + 1) / 2;
	output.color = input.color;
	output.uv = input.uv;
	
	float2 direction = float2(1, 0);
	output.tangent.xy = normalize(mul(float4(direction, 0, 0), _transform).xy * _viewportScale);
	output.tangent.zw = float2(1, 1);
	return output;
}

Texture2D _capturedBackBuffer;
SamplerState _capturedBackBuffer_SS;

PIX_OUTPUT pix(in VERT_OUTPUT2 input) : SV_TARGET
{
	float intensity = saturate(input.color.b * 0.1);
	float speed = _gameTime * 30;
	float sineWave = sin((input.uv.x * TWO_PI * 1.25) + speed);
	
	float endFade = 1 - (max(input.uv.x * 1.25 - 1, 0) * 4);
	float startFade = 1 - (min(input.uv.x - 0.1, 0) * -10);
	
	float y = fmod(input.uv.y, 1); //absolutely no idea why this is necessary
	float verticalGradient = 1 - abs(((y * 2) - 1) + 0.3 * sineWave);
	
	float2 dd = float2(ddx(input.uv.x), ddy(input.uv.x));
	dd = normalize(dd) / length(dd) * float2(ddx(input.normalizedLocation.x), ddy(input.normalizedLocation.y));
	
	float2 distortionDirection = perp(input.tangent.xy);
	float distortionBase = sineWave * verticalGradient * input.color.g * 0.5 * intensity;
	float2 distortion = distortionDirection * distortionBase * dd;
	float2 distortionUVs = input.normalizedLocation + distortion;
	
	float3 capturedColor = _capturedBackBuffer.Sample(_capturedBackBuffer_SS, distortionUVs).rgb;
	float3 absorbColor = float3(0.5, 1, 1.5);
	capturedColor += absorbColor * verticalGradient * 0.5 * input.color.g * intensity;

	return float4(capturedColor.rgb, verticalGradient * endFade * startFade * input.color.a);
}