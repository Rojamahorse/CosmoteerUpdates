#include "./Data/base.shader"

VERT_OUTPUT vert(in VERT_INPUT input)
{
	VERT_OUTPUT output;
	output.location = mul(input.location, _transform);
	output.color = input.color;
	output.uv = input.uv;
	return output;
}

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 c = _texture.Sample(_texture_SS, input.uv) * _color;
	c.rgb *= input.color.rgb;
	c.a = lerp(c.a, _color.a, input.color.a);
	return c;
}
