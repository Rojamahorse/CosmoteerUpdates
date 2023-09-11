#define USE_DEFAULT_VERT_ATLAS
#define USE_DEFAULT_PIX_ATLAS
#define DISABLE_ROTATION
#define DISABLE_ANIMATION
#define ENABLE_CUSTOM_VERTEX_COLOR
#define ENABLE_CUSTOM_PIXEL_COLOR
#include "../../base_atlas.shader"

float4 _colorFluctuateLow = 255;
float4 _colorFluctuateHigh = 255;
float _fluctuateInterval;

float4 getCustomVertexColor(in VERT_INPUT_ATLAS input)
{
	return input.color * _color * lerp(_colorFluctuateLow, _colorFluctuateHigh, wave(_time, _fluctuateInterval));
}

float4 getCustomPixelColor(in VERT_OUTPUT_ATLAS input)
{
	float4 c = _texture.Sample(_texture_SS, input.uv);
	float r = max(c.r, max(c.g, c.b));
    float w = min(c.r, min(c.g, c.b));
    return float4(r, w, w, c.a);
}
