#define USE_DEFAULT_VERT_ATLAS
#define USE_DEFAULT_PIX_ATLAS
#define ENABLE_CUSTOM_PIXEL_COLOR
#include "../../base_atlas.shader"

float4 getCustomPixelColor(in VERT_OUTPUT_ATLAS input)
{
	return float4(1, 1, 1, _texture.Sample(_texture_SS, input.uv).a);
}