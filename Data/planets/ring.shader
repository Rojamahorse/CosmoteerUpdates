#include "../base.shader"

VERT_OUTPUT vert(in VERT_INPUT input)
{
	VERT_OUTPUT output;
	output.location = mul(input.location, _transform);
	output.color = input.color * _color;
	output.uv = input.uv * 2 - float2(1, 1);
	return output;
}

float _diffuseDarkness;
float _diffuseDarknessExponent;
float _ringWidth;
float _sinTilt;
float _cosTilt;
float _shadowSphereRadius;
float _shadowLightRadius;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float originalV = input.uv.y;
	input.uv.y /= _sinTilt;
	float v = length(input.uv);
	if(v > 1 || v < 1 - _ringWidth)
		discard;

	float u = atan2(input.uv.y, input.uv.x) / (PI*2);
	v = inverseLerp(1 - _ringWidth, 1, v);
	float4 ret = _texture.Sample(_texture_SS, float2(u, v)) * input.color;

#ifdef GTE_PS_4_0_level_9_3
	// Sphere shadow method taken from: https://en.wikibooks.org/wiki/GLSL_Programming/Unity/Soft_Shadows_of_Spheres
	{
		float3 l = _lightNormal;
		float3 s = float3(
			input.uv.x,
			originalV,
			-input.uv.y * _cosTilt);
		float lenL = length(l);
		float lenS = length(s);
		float crossLenLS = length(cross(l, s));
		float dotLS = dot(l, s);
		float d = lenL * (asin(crossLenLS / (lenL * lenS)) - asin(_shadowSphereRadius / lenS));
		float dd = -d / _shadowLightRadius;
		float w = smoothstep(-1, 1, dd);
		float w2 = w * smoothstep(0, 0.2, dotLS / (lenL * lenS));
		float diffuseFactor = _diffuseDarkness > 0 ?
			lerp(1 - _diffuseDarkness, 1, pow(abs(1 - w2), _diffuseDarknessExponent)) :
			lerp(1 + _diffuseDarkness, 1, pow(abs(w2), _diffuseDarknessExponent));
		ret.rgb *= diffuseFactor;
	}
#endif

	return ret;
}
