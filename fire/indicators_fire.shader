#define USE_DEFAULT_VERT_ATLAS
#define USE_DEFAULT_PIX_ATLAS
#define ENABLE_CUSTOM_VERTEX_WORLD_LOC
#define DISABLE_ROTATION
#define ENABLE_SPRITE_UV
#define ENABLE_CUSTOM_PIXEL_COLOR
#define ENABLE_ROOF_ALPHA
#include "../base_atlas.shader"

float4x4 _invShipRotMatrix;

float4 getCustomVertexWorldLoc(in VERT_INPUT_ATLAS input)
{
	float4 offsetFromCenter = mul(input.location - input.center, _invShipRotMatrix);
	return input.center + offsetFromCenter;
}

float4 getCustomPixelColor(in VERT_OUTPUT_ATLAS input)
{
	float4 tex;
	float4 c;
	float outline;
	tex = _texture.Sample(_texture_SS, input.uv);
	c = lerp(float4(1, 0, 0, 1), float4(1, 0.75, 0, 1), tex.r);
	c.a *= tex.a;
	c *= 1 + wave(_time + input.uv.x, .5) * .5;
	outline = tex.b;
	float gradient = wave(pow(input.uv.y, 4) + _time, 1);
	outline *= 0.05 + (gradient * 0.95);
	c.rgb += float3(outline, outline, outline);
	c.a *= input.color.a;

	return c;
}