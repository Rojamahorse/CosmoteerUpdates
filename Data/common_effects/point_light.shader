#include "../base.shader"

struct VERT_OUTPUT_LIGHT
{
	float4 location : SV_POSITION;
	float4 screenLoc : POSITION1;
	float4 source : POSITION2;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float2 uv2 : TEXCOORD1;
};

float3 _pointLightSource;

VERT_OUTPUT_LIGHT vert(in VERT_INPUT input)
{
	VERT_OUTPUT_LIGHT output;
	output.location = mul(input.location, _transform);
	output.screenLoc = output.location;
	output.source = mul(float4(_pointLightSource, 1), _transform);
	output.color = input.color * _color;
	output.uv = input.uv;
	output.uv2.x = (output.location.x + 1) / 2;
	output.uv2.y = (output.location.y - 1) / -2;
	return output;
}

PIX_OUTPUT pix(in VERT_OUTPUT_LIGHT input) : SV_TARGET
{
	float dist = length(input.uv * 2 - 1);
	if(dist >= 1)
		discard;

	float4 ret = input.color;
	ret.rgb *= ret.a * (1 - dist * dist);
	ret.a = 0;

	multiplyAdditiveLightValue(ret.rgb, input.uv2, input.source.xyz, input.screenLoc.xyz);

	return ret;
}
