#include "./Data/base.shader"

struct VERT_INPUT_BLUR
{
	float4 location : POSITION;
	float2 uv : TEXCOORD0;
	float2 maskUV : TEXCOORD1;
};

struct VERT_OUTPUT_BLUR
{
	float4 location : SV_POSITION;
	float2 uv : TEXCOORD0;
	float2 maskUV : TEXCOORD1;
};

VERT_OUTPUT_BLUR vert(in VERT_INPUT_BLUR input)
{
	VERT_OUTPUT_BLUR output;
	output.location = mul(input.location, _transform);
	output.uv = input.uv;
    output.maskUV = input.maskUV;
	return output;
}

float2 _textureSize;
float2 _blurDirection;

Texture2D _mask;
SamplerState _mask_SS;

PIX_OUTPUT pix(in VERT_OUTPUT_BLUR input) : SV_TARGET
{
    float maskA = _mask.Sample(_mask_SS, input.maskUV).a;
    float t = inverseLerp(.2, .25, maskA);
    if(t <= 0)
        discard;

	// https://github.com/Jam3/glsl-fast-gaussian-blur

	float2 off1 = float2(1.3846153846, 1.3846153846) * _blurDirection * t;
	float2 off2 = float2(3.2307692308, 3.2307692308) * _blurDirection * t;
	float4 color = _texture.Sample(_texture_SS, input.uv) * 0.2270270270;
	color += _texture.Sample(_texture_SS, input.uv + (off1 / _textureSize)) * 0.3162162162;
	color += _texture.Sample(_texture_SS, input.uv - (off1 / _textureSize)) * 0.3162162162;
	color += _texture.Sample(_texture_SS, input.uv + (off2 / _textureSize)) * 0.0702702703;
	color += _texture.Sample(_texture_SS, input.uv - (off2 / _textureSize)) * 0.0702702703;
	return color;
}
