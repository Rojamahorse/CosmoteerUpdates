#define USE_DEFAULT_VERT
#include "../base.shader"

float4 _dimColor;
float4 _borderAddColor;
float _blackAndWhiteFactor;

Texture2D _sightTarget;
SamplerState _sightTarget_SS;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 mask = _sightTarget.Sample(_sightTarget_SS, input.uv);
	float4 bg = _texture.Sample(_texture_SS, input.uv) * _dimColor;
	bg.a = 1 - mask.a;

	float tBorder = min(1 - mask.a, mask.r);
	bg += _borderAddColor * tBorder;

	if (bg.a <= 0)
		discard;
	return bg * input.color;
}
