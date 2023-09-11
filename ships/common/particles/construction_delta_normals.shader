#include "construction_base.shader"

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

PIX_OUTPUT pix(in VERT_OUTPUT_CONSTRUCTION input) : SV_TARGET
{
	float alpha = _texture.Sample(_texture_SS, input.uv).a;
	float4 nrml = loadRawNormals(input.uv);
#ifdef GTE_PS_4_0_level_9_3
	if (nrml.a <= 0)
		discard;
#endif
	nrml.rgb = colorToNormals(nrml.rgb);
	nrml.rg = rotateFlipNormals(nrml.rg, input.tangent);
	nrml.rgb = normalsToColor(nrml.rgb);

	float progress = input.color.r;
	progress = frac(min(progress * 4, 3.99));

	float2 dir = float2(-input.color.b, -input.color.a);
	float noise = _noiseTexture.Sample(_noiseTexture_SS, input.noiseUV).r;
	float gradient = calculateGradientForDeltaMask(progress, noise);

	float maskTex = alpha;
	float isolatedEdges = saturate(maskTex - 0.9);
	float mask = saturate(max(maskTex - (1 - gradient), isolatedEdges));

	mask = ceil(mask);
	nrml.a = mask;
	return nrml;
}