//#define USE_DEFAULT_VERT_PARTICLE
//#define ENABLE_WORLD_LOC
//#include "./Data/common_effects/particles/base_particle.shader"
#define USE_DEFAULT_VERT
#include "./Data/base.shader"

Texture2D _noiseTex1;
SamplerState _noiseTex1_SS;

Texture2D _noiseTex2;
SamplerState _noiseTex2_SS;

float4 _color1 = 255;
float _rotationSpeed = 1;
float _uvScale = 0.5;
float _translationSpeed = 0;

float3 UnpackInferredNormals(float2 normal)
{
	const float CENTER = 127.0 / 255.0;
	float x = (normal.x - CENTER) * 2;
	float y = (normal.y - CENTER) * 2;
	float z = sqrt(1 - x*x - y*y);
	return float3(x, y, z);
}

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float gameTime = _gameTime;
	
	float2 centeredUv = input.uv - 0.5;
	float2 uvCenterOffset = abs(centeredUv * 2);
	float uvCenterDistance = sqrt(pow(uvCenterOffset.x, 2) + pow(uvCenterOffset.y, 2));
	
	float fadeStart = 0.5;
	float fadeAlpha = map(fadeStart, 1, 1, 0, uvCenterDistance);
	
    float2 scrollingWorldLoc = input.uv.xy + float2(gameTime * 500, gameTime * 500);
	float2 scrollingWorldLoc2 = input.uv.xy - float2(gameTime * 550, gameTime * 550);
	
	float vTex1 = _noiseTex2.Sample(_noiseTex2_SS, scrollingWorldLoc * 0.000068).r;
	float vTex2 = _noiseTex2.Sample(_noiseTex2_SS, scrollingWorldLoc2 * 0.00011).r;
	float2 rotatingUVs = rotate(input.uv.xy, gameTime * 0.0378);
	float vTex3 = _noiseTex2.Sample(_noiseTex2_SS, rotatingUVs * 0.0000356).r;
	float sine = sin(gameTime * 0.18);
	float cosine = cos(gameTime * 0.27);
	float2 waveUVs = float2(sine * 500 + input.uv.x, cosine * 500 + input.uv.y);
	float vTex4 = 1 - _noiseTex2.Sample(_noiseTex2_SS, waveUVs * 0.000452).r;

	float voronoiNoise = (1 - vTex1) * (1 - vTex2) * vTex3;
	
	// Based off CreateNebulaBase
	float timeOffset = gameTime * _translationSpeed;
	float timeAngleOffset = gameTime * _rotationSpeed;
	float uvScale = _uvScale * 2;
	float2 movingUvs = rotate(centeredUv, timeAngleOffset) * uvScale + float2(timeOffset, timeOffset);
	float4 noise1 = _noiseTex1.Sample(_noiseTex1_SS, movingUvs);
	float4 baseNoise = _texture.Sample(_texture_SS, movingUvs);
	
	float baseNoise1 = min(baseNoise.a, 0.6);
	float midAlpha = saturate(pow(saturate(noise1.a * pow(1 - baseNoise1, 4)), baseNoise1));
	float baseAlpha = saturate(baseNoise1);
	float detailNoise = saturate(noise1.a * pow(1 - baseAlpha, 4));
	baseAlpha = min(saturate(pow(detailNoise, baseAlpha)), midAlpha);
	baseAlpha = pow(baseAlpha, 1 + (1 - fadeAlpha) * 2);
	
	if(baseAlpha <= 0)
		discard;
	
//	float3 normal1 = UnpackInferredNormals(baseNoise.rg);
//	float3 normal2 = UnpackInferredNormals(noise1.rg);
//	float3 finalNormal = normalize(float3(normal1.rg + normal2.rg, normal1.b * normal2.b));
//	
//	float4 unpackedNormal = float4(finalNormal, baseAlpha);
	float4 unpackedNormal = float4(0,0,1,baseAlpha);
	
	// End of CreateNebulaBase
	
	float baseVoronoi = 0;
	voronoiNoise = voronoiNoise * (1 - baseVoronoi) + baseVoronoi;
	
	float mask = 1 - unpackedNormal.a;
	float forwards = saturate(mask - saturate(1 - (voronoiNoise * 2)));
	float backwards = saturate((1 - mask) - saturate((voronoiNoise - 0.5) * 2));
	float arc = min(forwards, backwards);
	
	float3 col = lerp(_color1.rgb, float3(1,1,1), arc);
	return float4(col, arc * fadeAlpha * input.color.a);
}