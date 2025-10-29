#define USE_DEFAULT_VERT
#include "./Data/base.shader"

// https://www.shadertoy.com/view/4sBBDK

#define ANGLE 0.4
#define SCALE .5

float grayscale(in float3 col)
{
    return dot(col, float3(0.2126, 0.7152, 0.0722));
}

float dotScreen(in float2 uv, in float angle, in float scale)
{
    float2 p = (uv - 0.5) * _screenSize;
    float2 q = rotate(p, angle) * scale; 
	return sin(q.x) * sin(q.y) * 4.0;
}

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (ret.a <= 0)
		discard;

    float grey = grayscale(ret.rgb); 
    float ds = dotScreen(input.uv, ANGLE, SCALE);
    float val = grey * 10.0 - 5.0 + ds;
    ret.rgb = lerp(float3(41/255.0, 31/255.0, 18/255.0), float3(251/255.0, 246/255.0, 218/255.0), val);
	return ret;
}
