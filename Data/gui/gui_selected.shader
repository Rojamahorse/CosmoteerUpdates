#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float _clickTime;

static const float PULSE_TIME = 1.5;
static const float4 PULSE_FACTOR = float4(1, 1, 1, 1.3);

static const float CLICK_TIME = .25;
static const float4 CLICK_FACTOR = float4(1.3, 1.3, 1.3, 1);

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (ret.a <= 0)
		discard;

    // Pulse.
    {
        float t = wave(_time, PULSE_TIME);
        ret = lerp(ret, ret * PULSE_FACTOR, t);
    }

    // Click.
    {
        float t = inverseLerp(_clickTime + CLICK_TIME, _clickTime, _time);
        ret = lerp(ret, ret * CLICK_FACTOR, t);
    }

	return ret;
}