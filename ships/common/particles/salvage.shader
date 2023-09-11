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

PIX_OUTPUT pix(in VERT_OUTPUT_SALVAGE input) : SV_TARGET
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