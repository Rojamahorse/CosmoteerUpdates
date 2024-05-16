#include "../nebula_base.shader"

struct VERT_INPUT_NEBULA
{
	float4 location : POSITION;
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

VERT_OUTPUT_NEBULA vert(in VERT_INPUT_NEBULA input)
{
	VERT_OUTPUT_NEBULA output;
	output.location = mul(input.location, _transform);
	output.worldLoc = input.location.xy;
	output.color = _color;
	output.fadeAlpha = input.color.a;
	float4 tangent;
	tangent.xy = normalize(mul(float4(1, 0, 0, 0), _transform).xy * _viewportScale);
	tangent.zw = float2(1, 1);
	float3 lightNormal = float3(input.location.xy, 0) - _worldLightSource;
	lightNormal = normalize(lightNormal);
	lightNormal.y = -lightNormal.y;
	output.lightNormal = lightNormal;
	output.unexploredUV = mul(float4(input.location.xy, 0, 1), _unexploredWorldToUVTransform).xy;
	return output;
}

float2 _worldUVOffset;

PIX_OUTPUT pix(in VERT_OUTPUT_NEBULA input) : SV_TARGET
{
#ifdef GTE_PS_4_0_level_9_3
	float unexplored = 1 - _unexploredTexture.Sample(_unexploredTexture_SS, input.unexploredUV).a;
	
	if (unexplored <= 0)
		discard;
	
	float2 scrollingWorldLoc = input.worldLoc + float2(_gameTime * 500, _gameTime * 500);
	float2 scrollingWorldLoc2 = input.worldLoc - float2(_gameTime * 550, _gameTime * 550);
	float2 parallaxOffset = ((_parallaxLoc - input.worldLoc) * _parallaxIntensity) / (_camScale + max(0, _parallaxIntensity));

	float4 tex = _texture.Sample(_texture_SS, ((input.worldLoc + parallaxOffset) * _midTexScale * _worldUVScale* 0.25) + _worldUVOffset);
	float4 tex2 = _texture.Sample(_texture_SS, ((input.worldLoc + parallaxOffset) * _midTexScale * _worldUVScale) + _worldUVOffset);
	float4 tex3 = _texture.Sample(_texture_SS, ((input.worldLoc + parallaxOffset) * _microTexScale * _worldUVScale) + _worldUVOffset);

	float vTex1 = _noiseTex1.Sample(_noiseTex1_SS, scrollingWorldLoc * 0.000068).r;
	float vTex2 = _noiseTex1.Sample(_noiseTex1_SS, scrollingWorldLoc2 * 0.00011).r;
	float2 rotatingUVs = rotate(input.worldLoc, _gameTime * 0.0378);
	float vTex3 = _noiseTex1.Sample(_noiseTex1_SS, rotatingUVs * 0.0000356).r;
	float sine = sin(_gameTime * 0.18);
	float cosine = cos(_gameTime * 0.27);
	float2 waveUVs = float2(sine * 500 + input.worldLoc.x, cosine * 500 + input.worldLoc.y);
	float vTex4 = 1 - _noiseTex1.Sample(_noiseTex1_SS, waveUVs * 0.000452).r;
	
	float voronoiNoise = (1 - vTex1) * (1 - vTex2) * vTex3;

	float mask = 1 - tex.a;

	float lod2Transition = saturate(saturate((1 - _percentScale) - 0.97) * 40);
	voronoiNoise = voronoiNoise * 0.75 + (0.25 * (1 - tex2.a)) + (0.05 * (1 - tex3.a));
	voronoiNoise = voronoiNoise * (1 - (lod2Transition * tex3.a * vTex4));

	float forwards = saturate(mask - saturate(1 - (voronoiNoise * 2)));
	float backwards = saturate((1 - mask) - saturate((voronoiNoise - 0.5) * 2));
	float arc = min(forwards, backwards);

	float3 col = lerp(_color1.rgb, float3(1,1,1), arc);
	return float4(col, arc * input.fadeAlpha);
#endif
	return float4(0,0,0,0);
}