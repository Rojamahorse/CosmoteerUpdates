#include "base.shader"

struct VERT_INPUT_LIT
{
	float4 location : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float4 tangent : TANGENT0;
};
struct VERT_OUTPUT_LIT
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float4 tangent : TANGENT0;
};

VERT_OUTPUT_LIT vert(in VERT_INPUT_LIT input)
{
	VERT_OUTPUT_LIT output;
	output.location = mul(input.location, _transform);
	output.color = input.color * _color;
	output.uv = input.uv;
	output.tangent.xy = normalize(mul(float4(input.tangent.xy, 0, 0), _transform).xy * _viewportScale);
	output.tangent.zw = input.tangent.zw;
	return output;
}

PIX_OUTPUT pix(in VERT_OUTPUT_LIT input) : SV_TARGET
{
	float4 nrml = loadNormalsAlphaInferred(input.uv);
	if (nrml.a <= 0)
		discard;

	nrml *= input.color;
	nrml.rg = rotateFlipNormals(nrml.rg, input.tangent);
	nrml.rgb = normalsToColor(nrml.rgb);
	return nrml;
}
