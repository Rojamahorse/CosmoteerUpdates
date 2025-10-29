#define USE_DEFAULT_VERT
#include "./Data/base.shader"

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	return float4(input.color.rgb, input.color.a * _texture.Sample(_texture_SS, input.uv).a);
}