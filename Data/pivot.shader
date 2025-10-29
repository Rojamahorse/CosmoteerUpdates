#define USE_DEFAULT_PIX
#include "base.shader"

struct PIVOT_VERT_INPUT
{
	float4 location : POSITION;
	float2 pivot : POSITION1;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

float _pivotRotate;
float _pivotScale;
VERT_OUTPUT vert(in PIVOT_VERT_INPUT input)
{
	input.location.xy = rotate((input.location.xy - input.pivot) * _pivotScale, _pivotRotate) + input.pivot;

	VERT_OUTPUT output;
	output.location = mul(input.location, _transform);
	output.color = input.color * _color;
	output.uv = input.uv;
	return output;
}