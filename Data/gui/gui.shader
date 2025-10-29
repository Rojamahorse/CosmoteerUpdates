#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float _unhighlightTime;

static const float UNHIGHLIGHT_TIME = .2;
static const float4 UNHIGHLIGHT_FACTOR = float4(1.3, 1.3, 1.3, 1);

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (ret.a <= 0)
		discard;

    // Un-highlight.
    {
        float t = inverseLerp(_unhighlightTime + UNHIGHLIGHT_TIME, _unhighlightTime, _time);
        ret = lerp(ret, ret * UNHIGHLIGHT_FACTOR, t);
    }

	return ret;
}