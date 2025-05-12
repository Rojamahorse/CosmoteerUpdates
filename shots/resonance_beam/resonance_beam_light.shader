#include "./Data/common_effects/base_beam.shader"

struct VERT_OUTPUT_BEAM
{
	float4 location : SV_POSITION;
	float4 screenLoc : POSITION0;
	float2 beamStart : POSITION1;
	float2 beamEnd : POSITION2;
	float thermalIntensity : POSITION3;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float2 screenUV : TEXCOORD1;
	float beamBeginU : TEXCOORD2;
	float beamEndU : TEXCOORD3;
};

float _extraBeginLength;
float _extraEndLength;

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
	VERT_OUTPUT_BEAM output;
	float widthDilation = saturate(((input.intensity - _beamBaseDilation) / _dilationPerPump) / _maxDilationPumps);
	float width = lerp(_minWidth, _maxWidth, widthDilation);
    input.vertexOffset.y *= width;
    float2 beamEnd;
    float extraBeginLength = _extraBeginLength * width;
    float extraEndLength = _extraEndLength * width;
    float4 vertexLoc = calculateWorldVertexLoc(input, beamEnd, extraBeginLength, extraEndLength);
	output.location = mul(vertexLoc, _transform);
	output.screenLoc = output.location;
	output.beamStart = mul(float4(input.beamStart.x, input.beamStart.y, 0, 1), _transform).xy;
	output.beamEnd = mul(float4(beamEnd.x, beamEnd.y, 0, 1), _transform).xy;
	output.thermalIntensity = pow(saturate(map(0, _maxAmplificationPumps * _amplificationPerPump, 0, 1, input.color.r - _beamBaseAmplification)), _ampVisualExponent);
	output.color = input.color;
    output.color.a *= pow(input.fadeAlpha, 2);
	output.uv = input.uv;
	output.screenUV.x = (output.location.x + 1) / 2;
	output.screenUV.y = (output.location.y - 1) / -2;
	float totalLength = input.length + extraBeginLength + extraEndLength;
	output.beamBeginU = extraBeginLength / totalLength;
	output.beamEndU = 1 - extraEndLength / totalLength;
	return output;
}

Texture2D _rampTexture;
SamplerState _rampTexture_SS;

float _litReflectiveStrength;
float _z;
float _litAdditiveStrength;
float _unlitAdditiveStrength;
float _unlitBeginLengthFade;
float _nrmlStrengthLimit;

PIX_OUTPUT pix(in VERT_OUTPUT_BEAM input) : SV_TARGET
{
	float2 originalUVs = input.uv;
	input.uv.x = input.uv.x >= input.beamEndU ?
		0.5 + inverseLerp(input.beamEndU, 1, input.uv.x) * 0.5 :
		inverseLerp(0, input.beamBeginU, input.uv.x) * 0.5;

    float4 c = _texture.Sample(_texture_SS, input.uv);
	if (c.a <= 0)
		discard;

	float2 a = input.screenLoc.xy - input.beamStart.xy;
	float2 b = input.beamEnd.xy - input.beamStart.xy;
	float numer = dot(a, b);
	float denom = dot(b, b);
	float t2 = clamp(numer / denom, 0, 1);

	float3 lightPos = float3((input.beamStart.xy + t2 * b), _z);

	float thermalIntensityFactor = lerp(0.1, 0.9, input.thermalIntensity);
	float colFactor = saturate((pow(c.a, 4) * 0.5) + (c.a * 0.5));
	float4 col = _rampTexture.Sample(_rampTexture_SS, float2(colFactor * thermalIntensityFactor * input.color.a, 0.5));
	
	float3 reflectColor = col.rgb;
	float3 nrml = multiplyAdditiveLightValue(reflectColor, input.screenUV, lightPos, input.screenLoc.xyz, _nrmlStrengthLimit);
    float t = length(nrml);

	float3 litColor = (_litReflectiveStrength * reflectColor + _litAdditiveStrength * col.rgb) * c.a;
	float3 unlitColor = _unlitAdditiveStrength * col.rgb * pow(c.a, 3) * saturate(originalUVs.x/(input.beamBeginU * _unlitBeginLengthFade));
	float3 ret = (t * litColor + (1 - t) * unlitColor) * input.color.a;
    return float4(ret, 1);
}