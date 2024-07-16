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

float _midWaveScale;
float _midWaveStrength;
float _midWaveSpeed;
float _midScrollSpeed;

float _microWaveScale;
float _microWaveStrength;
float _microWaveSpeed;
float _microScrollSpeed;

void CreateNebulaBaseScrolling(float2 worldLoc, float2 worldUVOffset, float2 unexploredUV, float inputAlpha, float percentScale, out float4 unpackedNormal, out float detailNoise)
{
	float unexplored = 1 - _unexploredTexture.Sample(_unexploredTexture_SS, unexploredUV).a;
	
	if (unexplored <= 0)
		discard;

	float2 parallaxOffset = ((_parallaxLoc - worldLoc) * _parallaxIntensity) / (_camScale + max(0, _parallaxIntensity));
	
	float lod1Transition = saturate(saturate((1 - percentScale) - 0.9) * 11);
	float lod2Transition = 1 - saturate(saturate((1 - percentScale) - 0.99) * 115);
	float lodPingPong = max(saturate(lod1Transition * lod2Transition), _lodMaxBlend);
	float lodSwap = ceil((1 - _percentScale) - 0.98);
	float lodTexScale = lerp(_macroTexScale, _microTexScale, lodSwap);
	
	float2 midScaledUVs = worldLoc + (worldUVOffset * _midWaveScale) + float2(_gameTime * _midWaveSpeed, _gameTime * _midWaveSpeed);
	float2 macroScaledUVs = worldLoc + (worldUVOffset * 300000) + float2(_gameTime * 500, _gameTime * 500);
	float2 microScaledUVs = worldLoc + (worldUVOffset * _microWaveScale) + float2(_gameTime * _microWaveSpeed, _gameTime * _microWaveSpeed);
	float2 wavingUVs = float2(wave(midScaledUVs.y, _midWaveScale), wave(-midScaledUVs.x, _midWaveScale)) * _midWaveStrength;
	float2 wavingUVs2 = float2(wave(macroScaledUVs.y, 300000), wave(-macroScaledUVs.x, 300000)) * 0.01;
	float2 wavingUVs3 = float2(wave(microScaledUVs.y, _microWaveScale), wave(-microScaledUVs.x, _microWaveScale)) * _microWaveStrength;
	float2 wavingUVsLOD = lerp(wavingUVs2, wavingUVs3, lodSwap);
	
	float2 offsetWorldLoc = worldLoc + parallaxOffset;
	float2 scrollingWorldLoc = offsetWorldLoc + float2(-_gameTime * _midScrollSpeed, _gameTime * _midScrollSpeed);
	float2 scrollingWorldLoc2 = float2(offsetWorldLoc.y, -offsetWorldLoc.x) * 1.03 + float2(-_gameTime * _midScrollSpeed, -_gameTime * _midScrollSpeed);
	float2 scrollingWorldLoc3 = offsetWorldLoc + float2(_gameTime * _microScrollSpeed, _gameTime * _microScrollSpeed);
	float2 scrollingWorldLoc4 = float2(offsetWorldLoc.y, -offsetWorldLoc.x) * 1.03 + float2(-_gameTime * _microScrollSpeed, -_gameTime * _microScrollSpeed);
	
	float4 noise1 = _noiseTex1.Sample(_noiseTex1_SS, ((worldLoc + parallaxOffset) * _midTexScale * _noiseScaleFactor * _worldUVScale) + worldUVOffset);
	float4 lodNoise = _lodNoise.Sample(_lodNoise_SS, ((scrollingWorldLoc3) * lodTexScale * _worldUVScale) + worldUVOffset + wavingUVsLOD);
	float4 lodNoiseB = _lodNoise.Sample(_lodNoise_SS, ((scrollingWorldLoc4) * lodTexScale * _worldUVScale) + worldUVOffset + float2(wavingUVsLOD.y, -wavingUVsLOD.x));
	float4 baseNoise = _texture.Sample(_texture_SS, ((scrollingWorldLoc) * _midTexScale * _worldUVScale) + worldUVOffset + wavingUVs);
	float4 baseNoiseB = _texture.Sample(_texture_SS, ((scrollingWorldLoc2) * _midTexScale * _worldUVScale) + worldUVOffset + float2(wavingUVs.y, -wavingUVs.x));

	float combinedBaseNoise = 1 - saturate(pow((1 - baseNoise.a) * (1 - baseNoiseB.a) * 1.3, 0.8));
	float combinedLodNoise = 1 - saturate(pow((1 - lodNoise.a) * (1 - lodNoiseB.a) * 1.3, 0.8));
	float baseNoise1 = min(combinedBaseNoise, 0.6);
	float midAlpha = max(saturate(pow(saturate(noise1.a * pow(1 - baseNoise1, 4)), baseNoise1)), 1 - lodSwap);
	float baseNoise2 = min(combinedLodNoise, 0.6);
	float baseAlpha = saturate(lerp(baseNoise2, baseNoise1, lodPingPong));
	detailNoise = saturate(noise1.a * pow(1 - baseAlpha, 4));
	baseAlpha = min(saturate(pow(detailNoise, baseAlpha)), midAlpha) * unexplored;
	baseAlpha = pow(baseAlpha, 1 + (1- inputAlpha) * 2);

	if (baseAlpha <= 0)
		discard;
	
#ifdef GTE_PS_4_0_level_9_3
	
	float3 normal1a = UnpackInferredNormals(lodNoise.rg);
	float3 normal2a = UnpackInferredNormals(baseNoise.rg);
	float3 normal2b = UnpackInferredNormals(baseNoiseB.rg);

	float3 normal1b = normalize(float3(normal2a.rg + normal2b.rg, normal2a.b * normal2b.b));
	
	float3 normal1 = normalize(float3(normal1a.rg + normal1b.rg, normal1a.b * normal1b.b));
	normal1 = lerp(normal1, normal1b, lodPingPong);

	float3 normal2 = UnpackInferredNormals(noise1.rg);
	float3 finalNormal = normalize(float3(normal1.rg  + normal2.rg, normal1.b * normal2.b));
	
	unpackedNormal = float4(finalNormal, baseAlpha);
#else
	unpackedNormal = float4(0, 0, 1, baseAlpha);
#endif
}