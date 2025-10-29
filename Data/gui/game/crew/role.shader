#define USE_DEFAULT_VERT
#include "./Data/base.shader"

Texture2D _shirtTexture;
SamplerState _shirtTexture_SS;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 baseColor = _texture.Sample(_texture_SS, input.uv);
	float4 shirtColor = _shirtTexture.Sample(_shirtTexture_SS, input.uv) * input.color;

	float4 c;
	c.rgb = baseColor.rgb * baseColor.a * (1 - shirtColor.a) + shirtColor.rgb * shirtColor.a;
	c.a = shirtColor.a * (1 - baseColor.a) + baseColor.a;

	if(c.a <= 0)
		discard;

	return c;
}
