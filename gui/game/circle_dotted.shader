#include "./Data/base.shader"

float _innerRadius;
float _thickness;

VERT_OUTPUT vert(in VERT_INPUT input)
{
	float locLength = length(input.location.xy);
	float2 locNrm = input.location.xy / locLength;
	float2 newLoc = locNrm * (_innerRadius + (locLength - 1) * _thickness);

	VERT_OUTPUT output;
	output.location = mul(float4(newLoc, input.location.zw), _transform);
	output.color = input.color * _color;
	output.uv = input.uv;
	return output;
}

float _t;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float u = input.uv.x - floor(input.uv.x);
    float t = _t / 2;
    if(u <= t)
    {
        input.uv.x = inverseLerp(0, t, u);
        input.color.a *= _t;
    }
    else
    {
        input.uv.x = inverseLerp(t, 1, u);
    }

	float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	if(ret.a <= 0)
		discard;
	return ret;
}