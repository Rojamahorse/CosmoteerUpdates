#include "./Data/common_effects/base_beam.shader"

struct VERT_OUTPUT_BEAM
{
	float4 location : SV_POSITION;
    float length : POSITION3;
	float4 color : COLOR0;
    float intensity : COLOR1;
	float2 uv : TEXCOORD0;
	float beamTime : TEXCOORD1;
};

VERT_OUTPUT_BEAM vert(in VERT_INPUT_BEAM input)
{
    VERT_OUTPUT_BEAM output;
    float4 vertexLoc = calculateWorldVertexLoc(input);
	output.location = mul(vertexLoc, _transform);
    output.length = input.length;
	output.color = input.color * _color;
    output.color.a *= input.fadeAlpha;
    output.intensity = input.intensity;
	output.uv = input.uv;
	output.beamTime = input.beamTime;
	return output;
}

float _endCapSize;
float _startCapSize;
float _gradientPow;
float _gradientIntensity;

float4 _hotColor = 255;
float4 _coldColor = 255;
float4 _gradientColor = 255;

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

PIX_OUTPUT pix(in VERT_OUTPUT_BEAM input) : SV_TARGET
{
	float endCap = min((1 - input.uv.x) * input.length / _endCapSize, 1);
	float startCap = min((input.uv.x) * input.length / _startCapSize, 1);

	float gradientWidth = 4 * (1/saturate(input.color.a));
	float gradient =  1 - pow(abs((input.uv.y - 0.5) * 2 * gradientWidth), _gradientPow);

	float3 gradientColor = _gradientColor.rgb * gradient * _gradientIntensity;
	float4 tex = _texture.Sample(_texture_SS, input.uv);
	float3 col = lerp(_coldColor.rgb, _hotColor.rgb, tex.a) * endCap * startCap * input.color.a;
	col = saturate(col + gradientColor);

	return float4(col, tex.a * input.color.a);
}