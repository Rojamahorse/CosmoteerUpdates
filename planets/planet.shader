#include "./Data/base.shader"

VERT_OUTPUT vert(in VERT_INPUT input)
{
	VERT_OUTPUT output;
	output.location = mul(input.location, _transform);
	output.color = input.color * _color;
	output.uv = input.uv * 2 - float2(1, 1);
	return output;
}

float _spin;
float _diffuseDarkness;
float _diffuseDarknessExponent;
float _specularShine;
float _specularStrength;
float _planetTime;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	// Discard pixels outside of circle.
	float sqrX = input.uv.x * input.uv.x;
	float sqrY = input.uv.y * input.uv.y;
	if(sqrX + sqrY > 1)
		discard;

	// Calculate UV coordinates and sample source texture.
	float width = sqrt(1 - input.uv.y * input.uv.y);
	float sqishedU = (-acos(input.uv.x / width) / PI * 2 + 1);
	float2 uv = float2(
		(sqishedU + 1) / 4 + _planetTime * _spin,
		(asin(input.uv.y) / (PI/2) + 1) / 2);
	float4 ret = _texture.Sample(_texture_SS, uv) * input.color;

	// Calculate normal for use in diffuse and specular lighting.
	float3 planetNrml = float3(input.uv.x, input.uv.y, -sqrt(1 - sqrX - sqrY));
#ifdef GTE_PS_4_0_level_9_3
    float3 planetEast = cross(planetNrml, float3(0, -1, 0));
    float3 planetNorth = cross(planetNrml, planetEast);
    float3x3 tbn = float3x3(planetEast, planetNorth, planetNrml);
    float3 tsNrml = colorToNormals(_normalsTexture.Sample(_normalsTexture_SS, uv).rgb * input.color.rgb);
    float3 nrml = normalize(mul(tsNrml, tbn));
#else
    float3 nrml = planetNrml;
#endif

	// Apply diffuse lighting.
	float d = max(dot(-_lightNormal, nrml), 0);
	float diffuseFactor = _diffuseDarkness > 0 ?
		lerp(1 - _diffuseDarkness, 1, pow(abs(d), _diffuseDarknessExponent)) :
		lerp(1 + _diffuseDarkness, 1, pow(abs(1 - d), _diffuseDarknessExponent));
	ret.rgb *= diffuseFactor;

#ifdef GTE_PS_4_0_level_9_3
	// Apply specular lighting.
	float3 r = normalize(2 * d * nrml + _lightNormal);
	const float3 v = float3(0, 0, -1);
	float spec = max(pow(max(dot(r, v), 0), _specularShine) * _specularStrength, 0);
	ret.rgb += spec;
#endif

	return ret;
}
