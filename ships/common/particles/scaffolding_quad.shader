#define ENABLE_SHIP_COORDS
#define ENABLE_SCREEN_UV
#define USE_DEFAULT_VERT
#include "./Data/base_shipquad.shader"

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

float4 _hotColor = 255;
float4 _coldColor = 255;
float _normalIntensity;
float _intensity;

PIX_OUTPUT pix(in GEOM_OUTPUT input) : SV_TARGET
{
	float progress = input.color.r;
	float maskTex = _maskTexture.Sample(_maskTexture_SS, input.uv).a;
	if (maskTex <= 0)
		discard;

	float4 normalSample = _normalsTarget.Sample(_normalsTarget_SS, input.screenUV);
	float3 baseNormal = colorToNormals(normalSample.rgb);
	float3 normal = baseNormal;
	normal.z = _normalIntensity; //0.02 for ships, 0.2 for asteroids
	normal = normalize(normal);
	float heatFade = 1 - saturate((_gameTime - input.color.g) * 2);
	float edges = (1 - saturate(dot(normal, float3(0, 0, 1))));
	edges = saturate(edges - 0.9) * 10 * heatFade * maskTex * _intensity;

	float3 col = lerp(_coldColor.rgb, _hotColor.rgb, edges) * normalSample.a * maskTex * heatFade;
	
	col = col * ((0.8 * edges) + 0.2);

	return float4(col, 1);
}