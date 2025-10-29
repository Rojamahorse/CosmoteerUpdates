#include "./Data/base.shader"

struct VERT_OUTPUT2
{
	float4 location : SV_POSITION;
	float4 worldLoc : POSITION0;
	float4 color : COLOR0;
	float3 uvq : TEXCOORD0;
};

VERT_OUTPUT2 vert(in VERT_INPUT input)
{
    float z = input.location.z;
    input.location.z = 0;

	VERT_OUTPUT2 output;
	output.location = mul(input.location, _transform);
	output.worldLoc = input.location;
	output.color = input.color * _color;
	output.uvq = float3(input.uv.x, input.uv.y, 1) * z;
	return output;
}

float2 _radioFromLoc;
float _radioFromRadius;
float2 _radioToLoc;
float _radioToRadius;
float _radioDist;
float _radioSpeed;

PIX_OUTPUT pix(in VERT_OUTPUT2 input) : SV_TARGET
{
    float2 uv = input.uvq.xy / input.uvq.z;

	float4 c = input.color;

	float fromDist = length(input.worldLoc.xy - _radioFromLoc);
    float toDist = length(input.worldLoc.xy - _radioToLoc);
	c.a *= inverseLerp(_radioFromRadius, _radioFromRadius + 3, fromDist);
	c.a *= inverseLerp(_radioToRadius, _radioToRadius + 3, toDist);
    c.a *= inverseLerp(_radioDist, _radioDist - 5, fromDist);
	c.a *= pow(wave(fromDist - _time * _radioSpeed, 5), 2);
    c.a *= sqrt(wave(uv.y, 1));

	return c;
}