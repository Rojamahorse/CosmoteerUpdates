#include "base_beam.shader"

struct VERT_OUTPUT_BEAM
{
	float4 location : SV_POSITION;
	float4 screenLoc : POSITION0;
	float2 beamStart : POSITION1;
	float2 beamEnd : POSITION2;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float2 screenUV : TEXCOORD1;
	float beamBeginU : TEXCOORD2;
	float beamEndU : TEXCOORD3;
};

float _extraBeginLength;
float _extraEndLength;
VERT_OUTPUT_BEAM vert(in VERT_INPUT_BEAM input)
{
	VERT_OUTPUT_BEAM output;
    input.vertexOffset.y *= input.intensity;
    float2 beamEnd;
    float extraBeginLength = _extraBeginLength * input.intensity;
    float extraEndLength = _extraEndLength * input.intensity;
    float4 vertexLoc = calculateWorldVertexLoc(input, beamEnd, extraBeginLength, extraEndLength);
	output.location = mul(vertexLoc, _transform);
	output.screenLoc = output.location;
	output.beamStart = mul(float4(input.beamStart.x, input.beamStart.y, 0, 1), _transform).xy;
	output.beamEnd = mul(float4(beamEnd.x, beamEnd.y, 0, 1), _transform).xy;
	output.color = input.color * _color;
    output.color.a *= input.fadeAlpha;
	output.uv = input.uv;
	output.screenUV.x = (output.location.x + 1) / 2;
	output.screenUV.y = (output.location.y - 1) / -2;
	float totalLength = input.length + extraBeginLength + extraEndLength;
	output.beamBeginU = extraBeginLength / totalLength;
	output.beamEndU = 1 - extraEndLength / totalLength;
	return output;
}

float _litReflectiveStrength;
float _z;
float _litAdditiveStrength;
float _unlitAdditiveStrength;
float _nrmlStrengthLimit;

PIX_OUTPUT pix(in VERT_OUTPUT_BEAM input) : SV_TARGET
{
	input.uv.x = input.uv.x >= input.beamEndU ?
		0.5 + inverseLerp(input.beamEndU, 1, input.uv.x) * 0.5 :
		inverseLerp(0, input.beamBeginU, input.uv.x) * 0.5;

    float4 c = _texture.Sample(_texture_SS, input.uv) * input.color;
	if (c.a <= 0)
		discard;

	float2 a = input.screenLoc.xy - input.beamStart.xy;
	float2 b = input.beamEnd.xy - input.beamStart.xy;
	float numer = dot(a, b);
	float denom = dot(b, b);
	float t2 = clamp(numer / denom, 0, 1);

	float3 lightPos = float3((input.beamStart.xy + t2 * b), _z);

	float3 reflectColor = c.rgb;
	float3 nrml = multiplyAdditiveLightValue(reflectColor, input.screenUV, lightPos, input.screenLoc.xyz, _nrmlStrengthLimit);
    float t = length(nrml);

	float3 litColor = (_litReflectiveStrength * reflectColor + _litAdditiveStrength * c.rgb) * c.a;
	float3 unlitColor = _unlitAdditiveStrength * c.rgb * pow(c.a, 2);
	float3 ret = t * litColor + (1 - t) * unlitColor;
    return float4(ret, 1);
}