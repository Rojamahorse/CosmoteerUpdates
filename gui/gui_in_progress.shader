#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float _rotSpeed;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 output = _texture.Sample(_texture_SS, input.uv);
	output *= input.color;

	float2 uv = input.uv * 2 - 1;
	uv = rotate(uv, _time * _rotSpeed * (PI*-2));
	output.a *= (atan2(uv.y, uv.x) + PI) / (PI*2);

	if(output.a <= 0)
		discard;
	return output;
}