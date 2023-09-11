#define USE_DEFAULT_VERT
#include "./Data/base.shader"

#define RESOLUTION_REDUCTION 2
#define DEPTH_REDUCTION 16

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float2 uv = (int2)(input.uv * _screenSize / RESOLUTION_REDUCTION + 0.5) * RESOLUTION_REDUCTION / _screenSize;
	float4 ret = _texture.Sample(_texture_SS, uv) * input.color;
	ret.g = (ret.r + ret.g + ret.b) / 3;
	ret.rb = 0;
	ret = (int4)(ret * 255 / DEPTH_REDUCTION + 0.5) * DEPTH_REDUCTION / 255.0;
	if (ret.a <= 0)
		discard;
	return ret;
}
