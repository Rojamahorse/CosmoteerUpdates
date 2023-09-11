#define USE_DEFAULT_VERT_ATLAS
#define ENABLE_TANGENT
#include "../../base_atlas.shader"

PIX_OUTPUT pix(in VERT_OUTPUT_ATLAS input) : SV_TARGET
{
	float a = _texture.Sample(_texture_SS, input.uv).a;
	if (a <= 0)
		discard;

	float4 ret;
	ret.rgb = normalsToColor(float3(0, 0, 0));
	ret.a = a;
	return ret;
}
