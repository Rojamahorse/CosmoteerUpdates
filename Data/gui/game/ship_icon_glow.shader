#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float2 _direction;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	// https://github.com/Jam3/glsl-fast-gaussian-blur

    float2 off1 = float2(1.3846153846, 1.3846153846) * _direction;
	float2 off2 = float2(3.2307692308, 3.2307692308) * _direction;
	float4 blurColor = _texture.Sample(_texture_SS, input.uv) * 0.2270270270;
	blurColor += _texture.Sample(_texture_SS, input.uv + off1) * 0.3162162162;
	blurColor += _texture.Sample(_texture_SS, input.uv - off1) * 0.3162162162;
	blurColor += _texture.Sample(_texture_SS, input.uv + off2) * 0.0702702703;
	blurColor += _texture.Sample(_texture_SS, input.uv - off2) * 0.0702702703;

    return blurColor * input.color;
}
