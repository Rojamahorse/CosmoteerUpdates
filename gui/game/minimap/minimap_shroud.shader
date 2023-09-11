#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float4 _bgColor;
float4 _borderAddColor;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 mask = _texture.Sample(_texture_SS, input.uv);
	float4 bg = _bgColor;
	bg.a *= 1 - mask.a;

	float tBorder = min(1 - mask.a, mask.r);
	bg += _borderAddColor * tBorder;

	if (bg.a <= 0)
		discard;
	return bg * input.color;
}
