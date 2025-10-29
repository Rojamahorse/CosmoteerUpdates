#define USE_DEFAULT_VERT
#include "base.shader"

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float a = _texture.Sample(_texture_SS, input.uv).a;
	if (a <= 0)
		discard;

	float4 ret;
	ret.rgb = normalsToColor(float3(0, 0, 0));
	ret.a = a;
	return ret;
}