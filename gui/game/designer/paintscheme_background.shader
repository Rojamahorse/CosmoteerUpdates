#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float4 _roofBaseColor = 255;
Texture2D _roofBaseTexture;
SamplerState _roofBaseTexture_SS;
float2 _roofBaseTextureScale;
float4 _roofDecalColor1 = 255;
float4 _roofDecalColor2 = 255;
float4 _roofDecalColor3 = 255;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 texColor = _texture.Sample(_texture_SS, input.uv);
	float4 c = (1 - texColor.a) * _roofBaseColor + texColor.r * _roofDecalColor1 + texColor.g * _roofDecalColor2 + texColor.b * _roofDecalColor3;
	c.a = 1;

	float3 baseTex = (1 - (1 - _roofBaseTexture.Sample(_roofBaseTexture_SS, input.uv * 2 / _roofBaseTextureScale)) * _roofBaseColor.a).rgb;
	c.rgb *= baseTex;

	if(c.a <= 0)
		discard;

	return c;
}
