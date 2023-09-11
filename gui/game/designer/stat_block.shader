#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float _lerpFrom;
float _lerpTo;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	if(input.uv.x > _lerpFrom)
		ret.a *= pow(inverseLerp(_lerpTo, _lerpFrom, input.uv.x), 2);
	if (ret.a <= 0)
		discard;
	return ret;
}
