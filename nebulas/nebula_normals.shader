#include "nebula_base.shader"

struct VERT_INPUT_NEBULA
{
	float4 location : POSITION;
	float4 color : COLOR0;
};

struct VERT_OUTPUT_NEBULA
{
	float4 location : SV_POSITION;
	float2 worldLoc : POSITION0;
	float4 color : COLOR0;
	float fadeAlpha : COLOR1;
	float2 unexploredUV : POSITION1;
	float4 tangent : TANGENT0;
};

float4x4 _unexploredWorldToUVTransform;

VERT_OUTPUT_NEBULA vert(in VERT_INPUT_NEBULA input)
{
	VERT_OUTPUT_NEBULA output;
	output.location = mul(input.location, _transform);
	output.worldLoc = input.location.xy;
	output.color = _color;
	output.tangent.xy = normalize(mul(float4(1, 0, 0, 0), _transform).xy * _viewportScale);
	output.tangent.zw = float2(1, 1);
	output.fadeAlpha = input.color.a;
	output.unexploredUV = mul(float4(input.location.xy, 0, 1), _unexploredWorldToUVTransform).xy;
	return output;
}

float2 _worldUVOffset;

PIX_OUTPUT pix(in VERT_OUTPUT_NEBULA input) : SV_TARGET
{
	float4 unpackedNormal;
	float detailNoise;
	
	CreateNebulaBase(input.worldLoc, _worldUVOffset, input.unexploredUV, input.fadeAlpha, unpackedNormal, detailNoise);

	unpackedNormal.rg = -unpackedNormal.rg;
	unpackedNormal.rg = rotateFlipNormals(unpackedNormal.rg, input.tangent);
	float3 nrml = normalsToColor(unpackedNormal.rgb);
	float a = pow(unpackedNormal.a, 0.3) * input.fadeAlpha;
	return float4(nrml, a);
}