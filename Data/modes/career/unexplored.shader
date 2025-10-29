#define USE_DEFAULT_VERT
#include "./Data/base.shader"

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float u = input.uv.x * 2 - 1;
	float v = input.uv.y * 2 - 1;
	float dd = u*u + v*v;
	if(dd > 1)
		discard;

	float4 c = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (c.a <= 0)
		discard;

	c.a *= inverseLerp(1.0, 0.65, dd);

	c.rgb *= c.a;
	return c;
}