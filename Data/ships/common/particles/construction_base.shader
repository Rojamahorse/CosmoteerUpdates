#include "../../../base_atlas.shader"

struct VERT_INPUT_CONSTRUCTION
{
	float4 location : POSITION;
	float4 center : POSITION1;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float4 tangent : TANGENT0;
	float2 spriteUV : TEXCOORD6;
};
struct VERT_OUTPUT_CONSTRUCTION
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float4 tangent : TANGENT0;
	float2 spriteUV : TEXCOORD2;
	float2 noiseUV : POSITION0;
};

VERT_OUTPUT_CONSTRUCTION vert(in VERT_INPUT_CONSTRUCTION input)
{
	VERT_OUTPUT_CONSTRUCTION output;
	output.location = mul(input.location, _transform);
	output.color = input.color * _color;
	output.uv = input.uv;
	output.tangent.xy = normalize(mul(float4(input.tangent.xy, 0, 0), _transform).xy * _viewportScale);
	output.tangent.zw = input.tangent.zw;
	output.spriteUV = input.spriteUV;
	output.noiseUV = input.location.xy * 0.5;
	return output;
}


float calculateGradientForMask(float2 dir, float progress, float noiseTex, float2 spriteUV)
{
#ifdef GTE_PS_4_0_level_9_3
	float offsetProgress = ((1 - progress) * 2) - 1;
	float length = lerp(1, 0.25, progress);
	float2 shift = dir * offsetProgress * (1 / length);
	float2 pos = (spriteUV - float2(0.5, 0.5)) - shift;
	float dist = dot(pos, dir * length) + (0.5 * (1 - progress));
	float noise = (noiseTex * 2.3) + 1.4;
	float gradient = saturate(dist * noise);
	return gradient;
#else
	float offsetProgress = ((1 - progress) * 2) - 1;
	float2 shift = dir * offsetProgress;
	float2 uv = spriteUV;
	float2 pos = (uv - float2(0.5, 0.5)) - shift;
	float dist = dot(pos, dir);
	float noise = (noiseTex * 2.3) + 1.4;
	float gradient = saturate(dist * noise);
	return gradient;
#endif
}

float calculateGradientForDeltaMask(float progress, float noiseTex) 
{
	float gradient = saturate(progress * (1.26 + (noiseTex * 0.2)));
	return gradient;
}
