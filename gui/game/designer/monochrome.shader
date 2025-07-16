#define USE_DEFAULT_VERT
#define USE_DEFAULT_PIX
#include "./Data/base.shader"

//float4 _targetColor = 255;
//
//PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
//{
//	float4 col = _texture.Sample(_texture_SS, input.uv);
//	if (col.a <= 0)
//		discard;
//
////	float luminosity = (min(col.r, min(col.g, col.b)) + max(col.r, max(col.g, col.b))) / 2;
//	
////	luminosity = map(0, 1, 0.5, 1, luminosity);	
////	luminosity = pow(luminosity, 1);
//
////	return float4(_color.rgb * luminosity, col.a * _color.a);
//
//	float luma = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
//	luma = map(0, 0.5, 0, 1, luma);
//	return float4(_targetColor.rgb * luma, col.a * _targetColor.a);
//}