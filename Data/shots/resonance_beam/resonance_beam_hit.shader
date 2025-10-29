#include "./Data/base.shader"

struct VERT_INPUT_THERMAL_HIT
{
	float4 location : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float roofOpacity : TEXCOORD1;
	float randomTimeOffset : TEXCOORD2;
};
struct VERT_OUTPUT_THERMAL_HIT
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float2 noise1ScrollSpeed : TEXCOORD1;
	float2 noise2ScrollSpeed : TEXCOORD2;
	float roofOpacity : TEXCOORD3;
	float thermalIntensity : POSITION2;
};

Texture2D _noiseTexture2;
SamplerState _noiseTexture2_SS;

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

Texture2D _rampTexture;
SamplerState _rampTexture_SS;

float _beamBaseAmplification;
float _amplificationPerPump;
float _maxAmplificationPumps;
float _ampVisualExponent;


VERT_OUTPUT_THERMAL_HIT vert(in VERT_INPUT_THERMAL_HIT input)
{
	VERT_OUTPUT_THERMAL_HIT output;
	output.location = mul(input.location, _transform);
	output.color = input.color;
	output.uv = input.uv;
	output.thermalIntensity = pow(saturate(map(0, _maxAmplificationPumps * _amplificationPerPump, 0, 1, input.color.r - _beamBaseAmplification)), _ampVisualExponent);
	output.noise1ScrollSpeed = float2(0.1, -0.5) * (_gameTime + input.randomTimeOffset);
	output.noise2ScrollSpeed = float2(-0.083, -0.73) * (_gameTime + (input.randomTimeOffset * 2));
	output.roofOpacity = input.roofOpacity;
	return output;
}

float2 toPolarEggCoordinates(float2 uv)
{
	float2 centeredUVs = (uv - float2(0.5, 0.5)) * 2;
	float angle = atan2(centeredUVs.y, centeredUVs.x);

	float distance = length(centeredUVs);
	centeredUVs.x = centeredUVs.x + 1 * cos(angle);
	float eggFactor = -1.5;
	distance = lerp(distance * (0.25 + eggFactor * cos(angle)), distance, uv.x);

	float2 polarUVs = float2(angle / TWO_PI, distance);
	return polarUVs;
}

PIX_OUTPUT pix(in VERT_OUTPUT_THERMAL_HIT input) : SV_TARGET
{

	if (input.roofOpacity == 0)
	discard;
	
	float2 polarUVs = toPolarEggCoordinates(input.uv);
	float2 noise2UVs = input.noise2ScrollSpeed + (float2(1, 0.5) * polarUVs);
	
	float noise2 = _noiseTexture2.Sample(_noiseTexture2_SS, noise2UVs).r;
	float uvDistortion = ((noise2 * 2) - 1) * 0.26;
	float2 noise1UVs = input.noise1ScrollSpeed + (float2(1, 0.7) * polarUVs) + float2(uvDistortion, 0);
	float noise1 = _texture.Sample(_texture_SS, float2(noise1UVs.y, noise1UVs.x)).r;
	float2 half = float2(0.5, 0.5);
	float maskNoiseStrength = 0.29;
	float maskRotateFactor = (_gameTime + noise2) * -5;
	float2 maskUVs = rotate(input.uv - half, maskRotateFactor) + half;
	maskUVs = lerp(maskUVs, float2(noise2 * maskNoiseStrength, noise2 * maskNoiseStrength) + half, maskNoiseStrength);
	float mask = _maskTexture.Sample(_maskTexture_SS, maskUVs).a;
	
	float2 centeredUVs = (input.uv - half) * 2;
	float centerDot = (1 - abs(centeredUVs.x)) * (1 - abs(centeredUVs.y));
	centerDot = pow(saturate(centerDot * 1.05), 8);
	
	float originalMask = mask;
	mask = pow(mask, 4);
	float xMask = saturate(pow(input.uv.x * 2, 4));
	float colFactor = saturate(((1 - noise1) * mask) + mask + centerDot) * xMask;
	mask = saturate(mask * 3);

	float thermalIntensityFactor = lerp(0.35, 0.9, input.thermalIntensity);
	float4 col = _rampTexture.Sample(_rampTexture_SS, float2(colFactor * thermalIntensityFactor, 0.5));
	colFactor = pow(colFactor, 4) * pow(thermalIntensityFactor, 2);
	float3 colAdd = float3(colFactor * 0.2, colFactor * 0.3, colFactor * 0.3);
	return float4(((col.rgb * mask * xMask * 0.85) + colAdd) * input.roofOpacity * input.color.a, 1);
}