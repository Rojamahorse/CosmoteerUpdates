#include "base_crew.shader"

PIX_OUTPUT pix(in VERT_OUTPUT_ATLAS_CREW input) : SV_TARGET
{
	float4 c = getDiffuseColor(input);
	if(c.a <= 0)
		discard;
	return c;
}
