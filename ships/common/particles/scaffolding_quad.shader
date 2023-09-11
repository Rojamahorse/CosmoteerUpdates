#include "./Data/base.shader"

struct VERT_INPUT_SALVAGE
{
	float4 location : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float2 shipLocation : TEXCOORD1;
};
struct VERT_OUTPUT_SALVAGE
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float2 shipLocation : TEXCOORD1;
	float2 screenUV : TEXCOORD2;
};

VERT_OUTPUT_SALVAGE vert(in VERT_INPUT_SALVAGE input)
{
	VERT_OUTPUT_SALVAGE output;
	output.location = mul(input.location, _transform);
	output.color = input.color;
	output.uv = input.uv;
	output.shipLocation = input.shipLocation;
	output.screenUV.x = (output.location.x + 1) / 2;
	output.screenUV.y = (-output.location.y + 1) / 2;
	return output;
}

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

float4 _hotColor = 255;
float4 _coldColor = 255;
float _normalIntensity;
float _intensity;

PIX_OUTPUT pix(in VERT_OUTPUT_SALVAGE input) : SV_TARGET
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