#define USE_DEFAULT_VERT_ATLAS
#define USE_DEFAULT_PIX_ATLAS
#define ENABLE_CUSTOM_VERTEX_WORLD_LOC
#define DISABLE_ROTATION
#define ENABLE_SPRITE_UV
#define ENABLE_CUSTOM_PIXEL_COLOR
#include "../../base_atlas.shader"

float _camScale;
float _maxScale;
float4x4 _invShipRotMatrix;

float4 getCustomVertexWorldLoc(in VERT_INPUT_ATLAS input)
{
	float4 offsetFromCenter = mul(input.location - input.center, _invShipRotMatrix);
	return input.center + offsetFromCenter * min(_camScale, _maxScale);
}

float4 _colorFluctuateLow = 255;
float4 _colorFluctuateHigh = 255;
float _fluctuateInterval;

float4 getCustomPixelColor(in VERT_OUTPUT_ATLAS input)
{
	float4 c = _texture.Sample(_texture_SS, input.uv);
    c *= lerp(_colorFluctuateLow, _colorFluctuateHigh, wave(_time, _fluctuateInterval));
    return c;
}
