#include "nebula_base.shader"

struct VERT_INPUT_NEBULA
{
	float4 locationMin : POSITION;
	float4 locationMax : POSITION1;
	float4 color : COLOR0;
};

struct VERT_OUTPUT_NEBULA
{
	float4 location : SV_POSITION;
	float2 worldLoc : POSITION0;
	float4 color : COLOR0;
	float fadeAlpha : COLOR1;
	float2 unexploredUV : POSITION2;
};

float4x4 _unexploredWorldToUVTransform;
float _zoomT;

VERT_OUTPUT_NEBULA vert(in VERT_INPUT_NEBULA input)
{
	VERT_OUTPUT_NEBULA output;
	float4 loc = lerp(input.locationMin, input.locationMax, _zoomT);
	output.location = mul(loc, _transform);
	output.worldLoc = loc.xy;
	output.color = _color;
	output.fadeAlpha = input.color.a;
	output.unexploredUV = mul(float4(loc.xy, 0, 1), _unexploredWorldToUVTransform).xy;
	return output;
}

float4 _color1 = 255;
float4 _color2 = 255;

float2 _worldUVOffset;

PIX_OUTPUT pix(in VERT_OUTPUT_NEBULA input) : SV_TARGET
{
	float4 unpackedNormal;
	float detailNoise;

#ifdef GTE_PS_4_0_level_9_3
	#undef GTE_PS_4_0_level_9_3 // Force simple mode to skip calculating normals
	CreateNebulaBaseScrolling(input.worldLoc, _worldUVOffset, input.unexploredUV, input.fadeAlpha, _percentScale, unpackedNormal, detailNoise);
#else
	CreateNebulaBase(input.worldLoc, _worldUVOffset, input.unexploredUV, input.fadeAlpha, unpackedNormal, detailNoise);
#endif

	float3 col = lerp(_color1.rgb, _color2.rgb, detailNoise);
	return float4(col, unpackedNormal.a * input.color.a * input.fadeAlpha);
}