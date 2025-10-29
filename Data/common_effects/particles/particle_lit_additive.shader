#define USE_DEFAULT_VERT_PARTICLE
#define ENABLE_TANGENT
#define ENABLE_LIGHT_NORMAL
#include "base_particle.shader"

PIX_OUTPUT pix(in VERT_OUTPUT_PARTICLE input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	applyGlobalLightingAlphaInferredAdditive(ret, input.uv, input.tangent, input.lightNormal);
	if (ret.a <= 0)
		discard;
	return ret;
}
