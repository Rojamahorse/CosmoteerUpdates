#define USE_DEFAULT_VERT_PARTICLE
#define ENABLE_COLOR2
#define ENABLE_TANGENT
#include "base_particle.shader"

PIX_OUTPUT pix(in VERT_OUTPUT_PARTICLE input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv);
	ret.rgb = ret.rgb * input.color.rgb;
	ret.a = pow(ret.a, ((1 - input.color.a) * 30) + 1) * input.color2.a;
	if (ret.a <= 0)
		discard;
	return ret;
}
