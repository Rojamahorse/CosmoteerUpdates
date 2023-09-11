#define USE_DEFAULT_PIX
#include "./Data/base.shader"

struct VERT_INPUT_CIRCLE
{
	float4 location : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

struct VERT_OUTPUT_CIRCLE
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

static const float INTERVAL = 1.0;
static const float ALPHA1 = 1.0;
static const float ALPHA2 = 0.5;

float _innerRadius;
float _thickness;
VERT_OUTPUT_CIRCLE vert(in VERT_INPUT_CIRCLE input)
{
	float locLength = length(input.location.xy);
	float2 locNrm = input.location.xy / locLength;
	float2 newLoc = locNrm * (_innerRadius + (locLength - 1) * _thickness);

	VERT_OUTPUT_CIRCLE output;
	output.location = mul(float4(newLoc, input.location.zw), _transform);
	output.color = input.color * _color;
	output.color.a = lerp(ALPHA1, ALPHA2, wave(_time, INTERVAL));
	output.uv = input.uv;
	return output;
}