#define ENABLE_SHIP_COORDS
#define ENABLE_SCREEN_UV
#define USE_DEFAULT_VERT
#include "./Data/base_shipquad.shader"

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

float4 _hotColor = 255;
float4 _coldColor = 255;
float _normalIntensity;

PIX_OUTPUT pix(in GEOM_OUTPUT input) : SV_TARGET
{
	float intensity = input.color.a;
	float mask = _maskTexture.Sample(_maskTexture_SS, input.uv).r * saturate(intensity * 2);
	if (mask <= 0)
		discard;

	const float TEX_SCALE = 0.2;

	float noiseTex = _texture.Sample(_texture_SS, input.shipLocation * TEX_SCALE).r;
	float baseNoise = saturate(pow(noiseTex, (1 - intensity) * (1 - intensity) * 20));
	baseNoise = saturate(baseNoise * (2 - intensity));

	float3 baseNormal = colorToNormals(_normalsTarget.Sample(_normalsTarget_SS, input.screenUV).rgb);
	float3 normal = baseNormal;
	normal.z = _normalIntensity; //0.02 for ships, 0.2 for asteroids
	normal = normalize(normal);
	float edges = saturate(dot(normal, float3(0, 0, 1)));

	float4 col = lerp(_coldColor, _hotColor, baseNoise);
	baseNoise = pow(baseNoise, edges);
	baseNoise = lerp(0, baseNoise, mask);

	col.rgb = col.rgb * baseNoise;
	col.r = saturate(col.r + (mask * 0.25));
	col.rgb *= length(baseNormal);

	return col;
}