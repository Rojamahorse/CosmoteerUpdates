#define USE_DEFAULT_VERT
#include "./Data/base_atlas.shader"

float calculateMipLevel(Texture2D tex, float2 uv)
{
	// https://stackoverflow.com/a/24531164

	float w, h;
	tex.GetDimensions(w, h);
	uv.x *= w;
	uv.y *= h;

	float2 dx = ddx(uv);
	float2 dy = ddy(uv);
	float deltaMaxSqr = min(dot(dx, dx), dot(dy, dy)); // Replaced max with min to solve pixelated decals when stretched.
	float mml = 0.5 * log2(deltaMaxSqr);
	return max(0, mml);
}

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float lod = calculateMipLevel(_texture, input.uv);
	float4 ret = _texture.SampleLevel(_texture_SS, input.uv, lod);

	ret.rgb *= input.color.rgb;
	ret.a = lerp(1 - ret.a, ret.a, input.color.a);
	if (ret.a <= 0)
		discard;
	return ret;
}