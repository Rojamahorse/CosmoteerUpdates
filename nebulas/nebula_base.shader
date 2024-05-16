#include "./Data/base.shader"

float _camScale;

Texture2D _noiseTex1;
SamplerState _noiseTex1_SS;

Texture2D _lodNoise;
SamplerState _lodNoise_SS;

float2 _parallaxLoc;
float _parallaxIntensity;
float _percentScale;

Texture2D _unexploredTexture;
SamplerState _unexploredTexture_SS;

float3 UnpackInferredNormals(float2 normal)
{
	const float CENTER = 127.0 / 255.0;
	float x = (normal.x - CENTER) * 2;
	float y = (normal.y - CENTER) * 2;
	float z = sqrt(1 - x*x - y*y);
	return float3(x, y, z);
}

float _worldUVScale;
float _midTexScale;
float _microTexScale;
float _macroTexScale;
float _noiseScaleFactor;
float _lodMaxBlend;

void CreateNebulaBase(float2 worldLoc, float2 worldUVOffset, float2 unexploredUV, float inputAlpha, out float4 unpackedNormal, out float detailNoise)
{
	float unexplored = 1 - _unexploredTexture.Sample(_unexploredTexture_SS, unexploredUV).a;
	
	if (unexplored <= 0)
		discard;

	float2 parallaxOffset = ((_parallaxLoc - worldLoc) * _parallaxIntensity) / (_camScale + max(0, _parallaxIntensity));
	
	float lod1Transition = saturate(saturate((1 - _percentScale) - 0.9) * 11);
	float lod2Transition = 1 - saturate(saturate((1 - _percentScale) - 0.99) * 115);
	float lodPingPong = max(saturate(lod1Transition * lod2Transition), _lodMaxBlend);
	float lodSwap = ceil((1 - _percentScale) - 0.98);
	float lodTexScale = lerp(_macroTexScale, _microTexScale, lodSwap);

	float4 noise1 = _noiseTex1.Sample(_noiseTex1_SS, ((worldLoc + parallaxOffset) * _midTexScale * _noiseScaleFactor * _worldUVScale) + worldUVOffset);
	float4 lodNoise = _lodNoise.Sample(_lodNoise_SS, ((worldLoc + parallaxOffset) * lodTexScale * _worldUVScale) + worldUVOffset);
	float4 baseNoise = _texture.Sample(_texture_SS, ((worldLoc + parallaxOffset) * _midTexScale * _worldUVScale) + worldUVOffset);

	float baseNoise1 = min(baseNoise.a, 0.6);
	float midAlpha = max(saturate(pow(saturate(noise1.a * pow(1 - baseNoise1, 4)), baseNoise1)), 1 - lodSwap);
	float baseNoise2 = min(lodNoise.a, 0.6);
	float baseAlpha = saturate(lerp(baseNoise2, baseNoise1, lodPingPong));
	detailNoise = saturate(noise1.a * pow(1 - baseAlpha, 4));
	baseAlpha = min(saturate(pow(detailNoise, baseAlpha)), midAlpha) * unexplored;
	baseAlpha = pow(baseAlpha, 1 + (1- inputAlpha) * 2);

	if (baseAlpha <= 0)
		discard;
	
#ifdef GTE_PS_4_0_level_9_3
	
	float3 normal1a = UnpackInferredNormals(lodNoise.rg);
	float3 normal1b = UnpackInferredNormals(baseNoise.rg);

	float3 normal1 = normalize(float3(normal1a.rg + normal1b.rg, normal1a.b * normal1b.b));
	normal1 = lerp(normal1, normal1b, lodPingPong);

	float3 normal2 = UnpackInferredNormals(noise1.rg);
	float3 finalNormal = normalize(float3(normal1.rg  + normal2.rg, normal1.b * normal2.b));
	
	unpackedNormal = float4(finalNormal, baseAlpha);
#else
	unpackedNormal = float4(0, 0, 1, baseAlpha);
#endif
}