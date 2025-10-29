#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float2 toPolarCoordinates(float2 uv)
{
	float2 centeredUVs = (uv - float2(0.5, 0.5)) * 2;
	float distance = length(centeredUVs);
	float angle = atan2(centeredUVs.y, centeredUVs.x);
	float2 polarUVs = float2(angle / TWO_PI, distance);
	/*
	float newX = frac(polarUVs.x);
	if (fwidth(polarUVs.x) - 0.0001 > fwidth(newX))
	{
		polarUVs.x = newX;
	}
	*/
	return polarUVs;
}

float _circleSegments;
float _thickness;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float2 polarUVs = toPolarCoordinates(input.uv);
	polarUVs.x *= _circleSegments;
	polarUVs.y = 1 - polarUVs.y;
	polarUVs.y *= _thickness;
	polarUVs.y = min(polarUVs.y, 0.9);
	polarUVs.y = max(polarUVs.y, 0);
	float4 ret = _texture.Sample(_texture_SS, polarUVs) * input.color;
	if (ret.a <= 0)
		discard;
	return ret;
}