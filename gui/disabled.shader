#define USE_DEFAULT_VERT
#include "./Data/base.shader"

static const float3 COLOR = float3(94.0/255.0, 112.0/255.0, 128.0/255.0);

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 output;
	output.a = _texture.Sample(_texture_SS, input.uv).a;
	output.rgb = COLOR;
	output *= input.color;
	if(output.a <= 0)
		discard;
	return output;
}
