#include "./Data/base.shader"

// Renders a dashed circle where each whole U unit is one dash cell containing the full texture.
// As _t goes from 0 to 1, a new dash fades in and grows within the first half of each cell while the existing dash shrinks into the second half,
// so that at _t = 1 each cell contains two full dashes. This allows the dash count to double without dashes popping or scrolling.

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
	float2 uvDx = ddx(input.uv);
	float2 uvDy = ddy(input.uv);

	float u = input.uv.x - floor(input.uv.x);
	float t = _t / 2;
	float uScale;
	if(u < t)
	{
		input.uv.x = inverseLerp(0, t, u);
		input.color.a *= _t;
		uScale = 1 / t;
	}
	else
	{
		input.uv.x = inverseLerp(t, 1, u);
		uScale = 1 / (1 - t);
	}

	// Scale the U gradients to match the remapping so mip selection isn't thrown off by the discontinuities between cells.
	uvDx.x *= uScale;
	uvDy.x *= uScale;

	float4 ret = _texture.SampleGrad(_texture_SS, input.uv, uvDx, uvDy) * input.color;
	if(ret.a <= 0)
		discard;
	return ret;
}
