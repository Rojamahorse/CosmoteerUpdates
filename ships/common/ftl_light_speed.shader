#define USE_DEFAULT_VERT_ATLAS
#define USE_DEFAULT_PIX_ATLAS
#define ENABLE_CUSTOM_VERTEX_WORLD_LOC
#define ENABLE_CUSTOM_PIXEL_COLOR
#include "../../base_atlas.shader"

float _cropLoc;
float _cropShipSize;
float2 _jumpDirNormal;

static const float SHIP_SIZE_FACTOR = .1;
static const float OFFSET_EXPONENT = 2.5;

float4 getCustomVertexWorldLoc(in VERT_INPUT_ATLAS input)
{
	float projX = sproj(input.location.xy, _jumpDirNormal);
	float projY = sproj(input.location.xy, perp(_jumpDirNormal));
	float cropSize = _cropShipSize * SHIP_SIZE_FACTOR;
	float offset = (projX - _cropLoc) / cropSize;
	if(offset < 0)
	{
		float newOffset = pow(abs(offset) + 1, OFFSET_EXPONENT) - 1;
		projX = _cropLoc + newOffset * cropSize * sign(offset);
	}

	float4 loc = input.location;
	loc.xy = projX * _jumpDirNormal + projY * perp(_jumpDirNormal);
	return loc;
}

float4 getCustomPixelColor(in VERT_OUTPUT_ATLAS input)
{
	float4 c = _color;
	c.a *= _texture.Sample(_texture_SS, input.uv).a;
	return c;
}
