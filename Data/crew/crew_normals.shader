#include "base_crew.shader"

PIX_OUTPUT pix(in VERT_OUTPUT_ATLAS_CREW input) : SV_TARGET
{
	float4 nrml = loadRawNormals(input.uv);
	if (nrml.a <= 0)
		discard;

	nrml.rgb = colorToNormals(nrml.rgb);
	nrml *= _color;
	nrml.rg = rotateFlipNormals(nrml.rg, input.tangent);
	nrml.rgb = normalsToColor(nrml.rgb);
	return nrml;
}
