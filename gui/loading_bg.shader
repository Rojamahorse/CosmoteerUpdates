#define USE_DEFAULT_VERT
#include "./Data/base.shader"

#define PERIOD 4
#define POW 3
//#define RESOLUTION_REDUCTION 4

float4 getAltColor(in VERT_OUTPUT input)
{
	//float2 uv = (int2)(input.uv * _screenSize / RESOLUTION_REDUCTION + 0.5) * RESOLUTION_REDUCTION / _screenSize;
	float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	ret.g = ret.b;
	ret.b = ret.g;
	ret.r = ret.r;
	return ret;
}

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 base = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (base.a <= 0)
		discard;

	float4 alt = getAltColor(input);
	float t = pow(wave(_time - input.uv.x / 2 * PERIOD, PERIOD), POW);
	return lerp(base, alt, t);
}