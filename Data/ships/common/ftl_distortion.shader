#define USE_DEFAULT_VERT_ATLAS
#define USE_DEFAULT_PIX_ATLAS
#define ENABLE_CUSTOM_VERTEX_WORLD_LOC
#define DISABLE_ROTATION
#define DISABLE_ANIMATION
#define ENABLE_SCREEN_UV
#define ENABLE_CUSTOM_PIXEL_COLOR
#define DISABLE_PIXEL_VERTEX_COLOR_SCALING
#include "../../base_atlas.shader"

float4 getCustomVertexWorldLoc(in VERT_INPUT_ATLAS input)
{
	return input.center + (input.location - input.center) * 1.25;
}

Texture2D _ftlBackground;
SamplerState _ftlBackground_SS;

Texture2D _warpTexture;
SamplerState _warpTexture_SS;

float4 getCustomPixelColor(in VERT_OUTPUT_ATLAS input)
{
	float a = _texture.Sample(_texture_SS, input.uv).a;
	float2 offset = (_warpTexture.Sample(_warpTexture_SS, input.screenUV).rg * 2 - 1) * .02;
	offset *= a * input.color.a;
	return _ftlBackground.Sample(_ftlBackground_SS, input.screenUV + offset);
}
