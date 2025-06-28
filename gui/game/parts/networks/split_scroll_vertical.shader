#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float _speed;
float _splitV;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	input.uv.x += _time * _speed * (input.uv.y < _splitV ? 1 : -1);
	float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (ret.a <= 0)
		discard;
	return ret;
}