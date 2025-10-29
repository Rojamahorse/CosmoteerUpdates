#define USE_DEFAULT_VERT
#include "./Data/base.shader"

#define GRAIN_STRENGTH 32

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (ret.a <= 0)
		discard;
	ret.rgb = max(ret.r, max(ret.g, ret.b));

	float x = (input.uv.x + 4.0) * (input.uv.y + 4.0) * _time;
	float grain = (fmod((fmod(x, 1.0) + 1.0) * (fmod(x, 123.0) + 1.0), 0.01) - 0.005) * GRAIN_STRENGTH;
	ret.rgb += grain;

	return ret;
}