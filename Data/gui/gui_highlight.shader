#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float _highlightTime;
float _clickTime;

static const float HIGHLIGHT_TIME = .15;
static const float4 HIGHLIGHT_FACTOR = float4(1.3, 1.3, 1.3, 1);

static const float CLICK_TIME = .25;
static const float4 CLICK_FACTOR = float4(1.3, 1.3, 1.3, 1);

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (ret.a <= 0)
		discard;

    // Highlight.
    {
        float u = input.uv.x * (1024 / 128);
        u = u - floor(u);
        float t = (_time - _highlightTime) / HIGHLIGHT_TIME - u;
        t = clamp(t, 0, 1);
        t = wave(t, 1);
        ret = lerp(ret, ret * HIGHLIGHT_FACTOR, t);
    }

    // Click.
    {
        float t = inverseLerp(_clickTime + CLICK_TIME, _clickTime, _time);
        ret = lerp(ret, ret * CLICK_FACTOR, t);
    }

	return ret;
}