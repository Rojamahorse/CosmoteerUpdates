#if defined(GTE_PS_4_0) || defined(GTE_VS_4_0)
#define ANIM_UVS
#endif
#include "base_crew.shader"

PIX_OUTPUT pix(in VERT_OUTPUT_ATLAS_CREW input) : SV_TARGET
{
	float4 c = getDiffuseColor(input);
	applyGlobalLighting(c, input.uv, input.tangent, input.lightNormal);

#ifdef GTE_PS_4_0
	// Apply drop shadow beneath.
	float2 spriteUV = abs(input.uv - input.animUV) / input.animUVOffsetPerFrame % 1;
	float d = length(spriteUV * 2 - 1);
	float4 shadow = float4(0, 0, 0, max(1 - d, 0) * .25);
	c.rgb = c.rgb * c.a + shadow.rgb * (1 - c.a);
	c.a = c.a * (1 - shadow.a) + shadow.a;
#endif

	if(c.a <= 0)
		discard;
	return c;
}