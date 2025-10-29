#define USE_DEFAULT_VERT
#include "./Data/base.shader"

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (ret.a <= 0)
		discard;

	ret.a *= 1 + pow(wave(-_time + input.uv.y, 2), 1) * 0.2;

	return ret;
}