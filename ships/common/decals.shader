#define USE_DEFAULT_VERT
#include "./Data/base_atlas.shader"

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv);
	ret.rgb *= input.color.rgb;
	ret.a = lerp(1 - ret.a, ret.a, input.color.a);
	if (ret.a <= 0)
		discard;
	return ret;
}