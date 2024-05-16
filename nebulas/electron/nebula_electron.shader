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
	float2 unexploredUV : POSITION1;
};

float4 _color1 = 255;
float4 _color2 = 255;
float4 _color3 = 255;
float4 _color4 = 255;
float4 _color5 = 255;

float3 _worldLightSource;
float4x4 _unexploredWorldToUVTransform;

Texture2D _noiseTex2;
SamplerState _noiseTex2_SS;

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
	float4 unpackedNormal;
	float detailNoise;
	
	CreateNebulaBase(input.worldLoc, _worldUVOffset, input.unexploredUV, input.fadeAlpha, unpackedNormal, detailNoise);

	float3 col = lerp(_color1.rgb, _color2.rgb, detailNoise);
#ifdef GTE_PS_4_0_level_9_3
	float macroScale = 0.01;
	float colShiftIntensity = 0.5;
	float colShift = saturate(sin(input.worldLoc.x * 0.01 * macroScale) * sin(input.worldLoc.y * 0.025 * macroScale)) * colShiftIntensity;

	col = lerp(col, _color3.rgb, colShift);

	float2 scrolling = float2(_gameTime * 0.1, _gameTime * 0.1);
	
	float vTex1 = 1 - _noiseTex2.Sample(_noiseTex2_SS, input.worldLoc * 0.0002 + scrolling).r;
	float vTex2 = 1 - _noiseTex2.Sample(_noiseTex2_SS, input.worldLoc * 0.000235 - scrolling).r;
	float vTex3 = 1 - _noiseTex2.Sample(_noiseTex2_SS, -input.worldLoc * 0.000056 + scrolling).r;
	float vTex4 = 1 - _noiseTex2.Sample(_noiseTex2_SS, -input.worldLoc * 0.000041 - scrolling).r;
	
	float3 dir = float3(rotate(float2(0, 0.2), vTex1 * TWO_PI), 0.8);
	float mask = 1 - saturate(dot(dir, unpackedNormal.xyz));
	float edgeMask = pow(saturate(mask * 4 * (1 - vTex3) * (1 - vTex4)), 2);
	float topMask = pow((1 - mask) * vTex1 * vTex2 * vTex3 * vTex4, 3);

	col += _color5.rgb * topMask * 1.5;
	col += _color4.rgb * edgeMask;
	
	applyGlobalLightingGeneratedNormals(col, unpackedNormal, input.lightNormal);
#endif
	return float4(col, unpackedNormal.a * input.color.a * input.fadeAlpha);
}