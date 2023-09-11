#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float _transferDir;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 c = input.color;

    c.a *= wave(input.uv.x, 1);
    c.a *= pow(wave(input.uv.y, 1), .5);

    input.uv.x *= 2;
    input.uv.x += abs(input.uv.y * 2 - 1) / 5 * _transferDir;
    input.uv.x = wrap(input.uv.x - _time * _transferDir, 1);

    if(input.uv.x < .5)
        c.a = 0;

    return c;
}
