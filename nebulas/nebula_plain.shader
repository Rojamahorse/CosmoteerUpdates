#include "./Data/base.shader"

struct VERT_INPUT_NEBULA
{
	float4 locationMin : POSITION;
	float4 locationMax : POSITION1;
	float4 color : COLOR0;
};

struct VERT_OUTPUT_NEBULA
{
	float4 location : SV_POSITION;
	float2 worldLoc : POSITION0;
	float4 color : COLOR0;
	float4 tangent : TANGENT0;
};

float _zoomT;

VERT_OUTPUT_NEBULA vert(in VERT_INPUT_NEBULA input)
{
	VERT_OUTPUT_NEBULA output;
	float4 loc = lerp(input.locationMin, input.locationMax, _zoomT);
	output.location = mul(loc, _transform);
	output.worldLoc = loc.xy;
	output.color = input.color * _color;
	output.tangent.xy = normalize(mul(float4(1, 0, 0, 0), _transform).xy * _viewportScale);
	output.tangent.zw = float2(1, 1);
	return output;
}

float2 _worldUVOffset;
float _worldUVScale;

Texture2D _unexploredTexture;
SamplerState _unexploredTexture_SS;
float4x4 _unexploredWorldToUVTransform;

PIX_OUTPUT pix(in VERT_OUTPUT_NEBULA input) : SV_TARGET
{
	float2 uv = (input.worldLoc + _worldUVOffset) * _worldUVScale;
	float4 ret = _texture.Sample(_texture_SS, uv) * input.color;

	float2 unexploredUV = mul(float4(input.worldLoc.x, input.worldLoc.y, 0, 1), _unexploredWorldToUVTransform);
	ret.a *= 1 - _unexploredTexture.Sample(_unexploredTexture_SS, unexploredUV).a;

	if (ret.a <= 0)
		discard;

	ret.a *= applyGlobalLightingInferredRetAlpha(ret, uv, input.tangent, _lightNormal);

	return ret;
}