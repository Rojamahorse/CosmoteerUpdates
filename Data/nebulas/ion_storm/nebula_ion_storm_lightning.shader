#include "../nebula_base.shader"

struct VERT_INPUT_NEBULA
{
	float4 locationMin : POSITION;
	float4 locationMax : POSITION1;
	float4 color : COLOR0;
};

struct VERT_OUTPUT_NEBULA
{
	float4 location : SV_POSITION;
	float2 worldLoc : POSITION0;
	float4 color : COLOR0;
	float3 lightNormal : NORMAL0;
	float fadeAlpha : COLOR1;
	float2 unexploredUV : POSITION2;
};

float4 _color1 = 255;

float3 _worldLightSource;
float4x4 _unexploredWorldToUVTransform;
float _zoomT;

VERT_OUTPUT_NEBULA vert(in VERT_INPUT_NEBULA input)
{
	VERT_OUTPUT_NEBULA output;
	float4 loc = lerp(input.locationMin, input.locationMax, _zoomT);
	output.location = mul(loc, _transform);
	output.worldLoc = loc.xy;
	output.color = _color;
	output.fadeAlpha = input.color.a;
	float4 tangent;
	tangent.xy = normalize(mul(float4(1, 0, 0, 0), _transform).xy * _viewportScale);
	tangent.zw = float2(1, 1);
	float3 lightNormal = float3(loc.xy, 0) - _worldLightSource;
	lightNormal = normalize(lightNormal);
	lightNormal.y = -lightNormal.y;
	output.lightNormal = lightNormal;
	output.unexploredUV = mul(float4(loc.xy, 0, 1), _unexploredWorldToUVTransform).xy;
	return output;
}

float2 _worldUVOffset;

Texture2D _noiseTex2;
SamplerState _noiseTex2_SS;

PIX_OUTPUT pix(in VERT_OUTPUT_NEBULA input) : SV_TARGET
{
#ifdef GTE_PS_4_0_level_9_3
	float unexplored = 1 - _unexploredTexture.Sample(_unexploredTexture_SS, input.unexploredUV).a;

	if (unexplored <= 0)
		discard;

	float4 unpackedNormal;
	float detailNoise;
	float percentScale = _percentScale * 0.7;
	
	CreateNebulaBaseScrolling(input.worldLoc, _worldUVOffset, input.unexploredUV, input.fadeAlpha, percentScale, unpackedNormal, detailNoise);

	float2 scrollingWorldLoc = input.worldLoc + float2(_gameTime * 500, _gameTime * 500);
	float2 scrollingWorldLoc2 = input.worldLoc - float2(_gameTime * 550, _gameTime * 550);
	
	float vTex1 = _noiseTex2.Sample(_noiseTex2_SS, scrollingWorldLoc * 0.000068).r;
	float vTex2 = _noiseTex2.Sample(_noiseTex2_SS, scrollingWorldLoc2 * 0.00011).r;
	float2 rotatingUVs = rotate(input.worldLoc, _gameTime * 0.0378);
	float vTex3 = _noiseTex2.Sample(_noiseTex2_SS, rotatingUVs * 0.0000356).r;
	float sine = sin(_gameTime * 0.18);
	float cosine = cos(_gameTime * 0.27);
	float2 waveUVs = float2(sine * 500 + input.worldLoc.x, cosine * 500 + input.worldLoc.y);
	float vTex4 = 1 - _noiseTex2.Sample(_noiseTex2_SS, waveUVs * 0.000452).r;

	float voronoiNoise = (1 - vTex1) * (1 - vTex2) * vTex3;

	float mask = 1 - unpackedNormal.a;
	float forwards = saturate(mask - saturate(1 - (voronoiNoise * 2)));
	float backwards = saturate((1 - mask) - saturate((voronoiNoise - 0.5) * 2));
	float arc = min(forwards, backwards);

	float3 col = lerp(_color1.rgb, float3(1,1,1), arc);
	return float4(col, arc * input.fadeAlpha * unexplored);
#endif
	return float4(0,0,0,0);
}