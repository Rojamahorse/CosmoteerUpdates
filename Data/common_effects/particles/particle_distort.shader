#define USE_DEFAULT_VERT_PARTICLE
#define ENABLE_TANGENT
#include "base_particle.shader"

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

float4 _color1;
float4 _color2;
float2 _noiseScale;
float _distortMultiplier;
float _erodeMultiplier;
float2 _scrollSpeed;

PIX_OUTPUT pix(in VERT_OUTPUT_PARTICLE input) : SV_TARGET
{
	float distortion = input.color.r;
	float erosion = input.color.g;
	float2 uvOffset = float2(input.color.b, input.color.b);
	
	float2 noiseUVs = (_noiseScale * input.uv) + (_scrollSpeed * _gameTime) + uvOffset;
	float4 noiseTex = _noiseTexture.Sample(_noiseTexture_SS, noiseUVs);

	float2 mainUVs = input.uv + (float2(0, noiseTex.r * distortion * _distortMultiplier));
	float4 tex = _texture.Sample(_texture_SS, mainUVs);
	
	float4 col = lerp(_color1, _color2, tex.r);
	float mask = pow(noiseTex.r, 1 + (erosion * _erodeMultiplier));
	mask = lerp(0, tex.r, mask) * input.color.a;
	col = col * mask;
	if (col.a <= 0)
		discard;
	return col;
}
