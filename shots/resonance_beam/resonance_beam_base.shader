#include "./Data/common_effects/base_beam.shader"

struct VERT_OUTPUT_BEAM
{
	float4 location : SV_POSITION;
    float length : POSITION2;
    float intensity : COLOR1;
	float dilation : COLOR2;
	float fadeAlpha : COLOR3;
	float2 uv : TEXCOORD0;
	float2 beamUV : TEXCOORD2;
	float2 screenUV : TEXCOORD3;
	float beamTime : TEXCOORD1;
	float2 screenDirection : POSITION3;
};

float _extraBeginLength;
float _extraEndLength;
float _endFadeLength;

float _camRotation;

float _beamBaseAmplification;
float _amplificationPerPump;
float _maxAmplificationPumps;
float _ampVisualExponent;

float _beamBaseDilation;
float _dilationPerPump;
float _maxDilationPumps;
float _visualDilationFactor;

float _minWidth;
float _maxWidth;

VERT_OUTPUT_BEAM vert(in VERT_INPUT_BEAM input)
{
	float baseDilation = ((input.intensity - _beamBaseDilation) / _dilationPerPump) / _maxDilationPumps;
	float width = lerp(_minWidth, _maxWidth, saturate(baseDilation));
	input.vertexOffset.y *= width;
	VERT_OUTPUT_BEAM output;
    float4 vertexLoc = calculateWorldVertexLoc(input, _extraBeginLength, _extraEndLength);
	output.location = mul(vertexLoc, _transform);
	output.intensity = pow(saturate(map(0, _maxAmplificationPumps * _amplificationPerPump, 0, 1, input.color.r - _beamBaseAmplification)), _ampVisualExponent);
	output.dilation = saturate(baseDilation * _visualDilationFactor);
	output.fadeAlpha = pow(input.fadeAlpha, 2);
	output.beamUV = float2(input.uv.x * input.length * 0.03, input.uv.y);
	output.uv = input.uv;
	output.length = input.length;
	output.beamTime = input.beamTime;
	output.screenUV.x = (output.location.x + 1) / 2;
	output.screenUV.y = (-output.location.y + 1) / 2;
	float2 direction = float2(1, 0);
	output.screenDirection = rotate(rotate(direction, input.direction), -_camRotation);
    output.screenDirection.y *= _viewportScale.x/_viewportScale.y;
	return output;
}

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

void CreateResonanceBeamBase(float2 inputUV, float inputBeamTime, float2 inputBeamUV, float inputIntensity, float inputDilation, out float beamCombined, out float beamCombinedHighlight, out float alphaGradient)
{
	float baseGradient = abs((inputUV.y - 0.5) * 2);  //generating a vertical cylinder gradient
	baseGradient = (1 - pow(baseGradient, 0.7)) * 0.53;
	alphaGradient = saturate(baseGradient * 5);
	baseGradient = baseGradient * baseGradient;

	float2 noiseUVs = float2((inputBeamTime * -0.43) + (inputBeamUV.x * 0.13), inputUV.y * 0.1);
	float2 noiseRG = _noiseTexture.Sample(_noiseTexture_SS, noiseUVs).rg;
	
	float noise = noiseRG.r;
	float noise2 = noiseRG.g;

	float sineSpeed = -0.53 * inputBeamTime;
	float sineFreq = lerp(37.9, 8, max(inputIntensity, inputDilation * 0.6)) * inputBeamUV.x;
	float sineNoiseModulation = lerp(1, 0.34 * (1- inputDilation), inputIntensity) * noise;
	float sineAmplitude = lerp(0.04, 0.11 + (inputDilation * 0.05), inputIntensity);
	float sineBase = sineSpeed + sineFreq + sineNoiseModulation;
	float sine1 = sin(sineBase) * sineAmplitude;
	float sine2 = sin(sineBase + (1.15 * PI)) * sineAmplitude * inputDilation;
	float2 sineUV1 = float2(inputBeamUV.x - (inputBeamTime * 1.83) - (noise2 * 0.07), (1 - inputUV.y) - sine1);
	float2 sineUV2 = float2(-inputBeamUV.x + (inputBeamTime * 2) + (noise2 * 0.07) + 0.33, inputUV.y + sine2);
	
	float sineBeam1 = _texture.Sample(_texture_SS, sineUV1).r;
	float sineBeam2 = _texture.Sample(_texture_SS, sineUV2).r;

	float colorScalar = lerp(0.5, 1, inputIntensity);
	beamCombined = (sineBeam1 + sineBeam2 + baseGradient) * colorScalar * 0.8;
	float highlightStrength = lerp(0, 0.2, saturate((inputIntensity * 2) - 1));
	beamCombinedHighlight = saturate(pow(sineBeam1 + sineBeam2 - baseGradient, 3) * 4) * (1 - baseGradient) * highlightStrength;
	beamCombined = min(saturate(pow(beamCombined, 0.69)), 0.92);
}