#define USE_DEFAULT_VERT_ATLAS
#define USE_DEFAULT_PIX_ATLAS
#define ENABLE_TANGENT
#define ENABLE_CUSTOM_PIXEL_COLOR
#define DISABLE_PIXEL_VERTEX_COLOR_SCALING
#include "../../base_atlas.shader"

float4 getCustomPixelColor(in VERT_OUTPUT_ATLAS input)
{
	float4 nrml = loadRawNormals(input.uv);

#ifdef GTE_PS_4_0_level_9_3
	if (nrml.a <= 0)
		discard;
#endif

	nrml.rgb = colorToNormals(nrml.rgb);
	nrml *= input.color;
	nrml.rg = rotateFlipNormals(nrml.rg, input.tangent);
	nrml.rgb = normalsToColor(nrml.rgb);
	return nrml;
}
