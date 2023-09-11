#define USE_DEFAULT_VERT
#include "./Data/base.shader"

static const float BRIGHTNESS = 0.5;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 output = _texture.Sample(_texture_SS, input.uv);
	output.rgb = (output.r + output.g + output.b) / 3 * BRIGHTNESS;
	output *= input.color;
	if(output.a <= 0)
		discard;
	return output;
}
