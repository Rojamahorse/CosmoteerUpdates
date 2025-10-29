#define USE_DEFAULT_VERT_PARTICLE
#define ENABLE_SCREEN_LOC
#define ENABLE_SCREEN_CENTER
#define ENABLE_SCREEN_CENTER_Z
#define ENABLE_SCREEN_UV
#include "base_particle.shader"

float _z;
float _litReflectiveStrength;
float _litAdditiveStrength;
float _unlitAdditiveStrength;
float _emissiveStrength;

PIX_OUTPUT pix(in VERT_OUTPUT_PARTICLE input) : SV_TARGET
{
	float4 tex = _texture.Sample(_texture_SS, input.uv);
	float4 c = float4(tex.g, tex.g, tex.b, tex.a) * input.color;
	float3 emissive = float3(tex.r, tex.r, tex.r) * input.color.rgb * _emissiveStrength;
	if (c.a <= 0)
		discard;

	float3 reflectColor = c.rgb;
    input.screenCenter.z = _z;
	float3 nrml = multiplyAdditiveLightValue(reflectColor, input.screenUV, input.screenCenter.xyz, input.screenLoc.xyz);
    float t = length(nrml);

	float3 litColor = _litReflectiveStrength * reflectColor + _litAdditiveStrength * c.rgb;
	float3 unlitColor = _unlitAdditiveStrength * c.rgb;
	float3 ret = t * litColor + (1 - t) * unlitColor;
    return float4((ret + emissive) * c.a, 1);
}