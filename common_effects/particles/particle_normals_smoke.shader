#define USE_DEFAULT_VERT_PARTICLE
#define ENABLE_TANGENT
#define ENABLE_LIGHT_NORMAL
#include "base_particle.shader"

PIX_OUTPUT pix(in VERT_OUTPUT_PARTICLE input) : SV_TARGET
{
	float4 nrml = loadNormalsAlphaInferred(input.uv);
	if (nrml.a <= 0)
		discard;

	nrml.rgb *= input.color.rgb;
	nrml.a *= pow(input.color.a, 0.3);
	nrml.rg = rotateFlipNormals(nrml.rg, input.tangent);
	nrml.rgb = normalsToColor(nrml.rgb);
	return nrml;
}
