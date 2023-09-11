#define USE_DEFAULT_VERT_ATLAS
#define USE_DEFAULT_PIX_ATLAS
#define DISABLE_ROTATION
#define DISABLE_ANIMATION
#define ENABLE_CUSTOM_VERTEX_COLOR
#include "../../base_atlas.shader"

float4 _colorFluctuateLow = 255;
float4 _colorFluctuateHigh = 255;
float _fluctuateInterval;
float _flickerTime;

float4 getCustomVertexColor(in VERT_INPUT_ATLAS input)
{
	return input.color * _color * lerp(_colorFluctuateLow, _colorFluctuateHigh, wave(_flickerTime, _fluctuateInterval));
}