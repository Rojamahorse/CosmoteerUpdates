#include "construction_base.shader"

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

float4 _hotColor = 255;
float4 _coldColor = 255;

PIX_OUTPUT pix(in VERT_OUTPUT_CONSTRUCTION input) : SV_TARGET
{
	float4 col = _texture.Sample(_texture_SS, input.uv);
	if (col.a <= 0.05)
	{
		discard;
	}

	float progress = input.color.r;
	progress = frac(min(progress * 4, 3.99));

	float noise = _noiseTexture.Sample(_noiseTexture_SS, input.noiseUV).r;
	float gradient = calculateGradientForDeltaMask(progress, noise);

	float hotEdgeSize = 0.5;
	float maskTex = col.a;
	float inverseMask = saturate(maskTex - (1 - (gradient - hotEdgeSize)));

	float isolatedEdges = saturate(maskTex - 0.9);

	float mask = saturate(max(maskTex - (1 - gradient), isolatedEdges));

	float hotEdge = 1 - ((1 / hotEdgeSize) * mask);
	mask = ceil(mask);
	inverseMask = ceil(1 - inverseMask);

	//hotEdge = saturate(inverseMask * mask * hotEdge * (1 - pow(progress, 4)));
	hotEdge = inverseMask * mask * hotEdge * (1 - (progress * progress * progress * progress)); //ugly but slightly fewer instructions compared to a pow
	hotEdge = saturate(hotEdge);

	float heatFade = 1 - saturate((_gameTime - input.color.g) * 2);
	hotEdge = hotEdge * heatFade;

	float3 addColor = lerp(_coldColor.rgb, _hotColor.rgb, hotEdge) * hotEdge;
	col.a = mask;
	applyGlobalLighting(col, input.uv, input.tangent, _lightNormal);

	col.rgb = col.rgb + addColor.rgb;
	return col;

}