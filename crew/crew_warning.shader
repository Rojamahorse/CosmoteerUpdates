#define USE_DEFAULT_PIX
#include "./Data/base.shader"

static const float INTERVAL = 1.0;
static const float ALPHA1 = 1.0;
static const float ALPHA2 = 0.5;

VERT_OUTPUT vert(in VERT_INPUT input)
{
	VERT_OUTPUT output;
	output.location = mul(input.location, _transform);
	output.color = input.color * _color;
	output.color.a = lerp(ALPHA1, ALPHA2, wave(_time, INTERVAL));
	output.uv = input.uv;
	return output;
}