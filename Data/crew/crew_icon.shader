#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float4 _shirtColor = 255;
float4 _skinColor = 255;
float4 _hairColor = 255;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv);
	if (ret.a <= 0)
		discard;
	ret.rgb = _shirtColor.rgb * ret.g + _skinColor.rgb * ret.r + _hairColor.rgb * ret.b;
	ret.rgb *= input.color.rgb;
	return ret;
}
