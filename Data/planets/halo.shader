#include "../base.shader"

VERT_OUTPUT vert(in VERT_INPUT input)
{
	VERT_OUTPUT output;
	output.location = mul(input.location, _transform);
	output.color = input.color * _color;
	output.uv = input.uv * 2 - float2(1, 1);
	return output;
}

float _diffuseDarkness;
float _haloOuterWidth;
float _haloInnerWidth;
float _haloAnimateSpeed;
float _planetTime;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float sqrX = input.uv.x * input.uv.x;
	float sqrY = input.uv.y * input.uv.y;
	float dist = sqrt(sqrX + sqrY);
	float haloMax = 1 - _haloOuterWidth;
	float haloMin = haloMax - _haloInnerWidth;
	if(dist > 1 || dist < haloMin)
		discard;

	float u = atan2(input.uv.y, input.uv.x) / TWO_PI;
	float v = _planetTime * _haloAnimateSpeed;
	float4 ret = _texture.Sample(_texture_SS, float2(u, v));
	if(ret.a > 0)
	{
		if(dist >= haloMax)
			ret.a = inverseLerp(haloMax + _haloOuterWidth * ret.a, haloMax, dist);
		else
			ret.a = inverseLerp(haloMax - _haloInnerWidth * ret.a, haloMax, dist);
	}

	float3 nrml = float3(input.uv.x, input.uv.y, -sqrt(1 - sqrX - sqrY));
	float diffuseFactor = lerp(1 - _diffuseDarkness, 1, dot(-_lightNormal, nrml));
	ret.rgb *= diffuseFactor;
	
	return ret * input.color;
}
