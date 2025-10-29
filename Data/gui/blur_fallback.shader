#define USE_DEFAULT_VERT
#include "./Data/base.shader"

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float a = _texture.Sample(_texture_SS, input.uv).a;
    float t = inverseLerp(.2, .25, a);
    if(t <= 0)
        discard;
    input.color.a *= t;
	return input.color;
}