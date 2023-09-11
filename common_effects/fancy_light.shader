#include "../base.shader"

struct VERT_INPUT2
{
	float4 location : POSITION;
	float4 center : POSITION1;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

struct VERT_OUTPUT2
{
	float4 location : SV_POSITION;
	float4 screenLoc : POSITION1;
	float4 screenCenter : POSITION2;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float2 screenUV : TEXCOORD1;
};

VERT_OUTPUT2 vert(in VERT_INPUT2 input)
{
	VERT_OUTPUT2 output;
	output.location = mul(input.location, _transform);
	output.screenLoc = output.location;
	output.screenCenter = mul(input.center, _transform);
	output.color = input.color * _color;
	output.uv = input.uv;
	output.screenUV.x = (output.location.x + 1) / 2;
	output.screenUV.y = (output.location.y - 1) / -2;
	return output;
}

float _litReflectiveStrength;
float _litAdditiveStrength;
float _unlitAdditiveStrength;

PIX_OUTPUT pix(in VERT_OUTPUT2 input) : SV_TARGET
{
	float4 c = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (c.a <= 0)
		discard;

	float3 reflectColor = c.rgb;
	float3 nrml = multiplyAdditiveLightValue(reflectColor, input.screenUV, input.screenCenter.xyz, input.screenLoc.xyz);
    float t = length(nrml);

	float3 litColor = _litReflectiveStrength * reflectColor + _litAdditiveStrength * c.rgb;
	float3 unlitColor = _unlitAdditiveStrength * c.rgb;
	float3 ret = t * litColor + (1 - t) * unlitColor;
    return float4(ret * c.a, 1);
}