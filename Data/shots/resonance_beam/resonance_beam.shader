#include "resonance_beam_base.shader"

Texture2D _rampTexture;
SamplerState _rampTexture_SS;

PIX_OUTPUT pix(in VERT_OUTPUT_BEAM input) : SV_TARGET
{
	float beamCombined;
	float beamCombinedHighlight;
	float alphaGradient;
	CreateResonanceBeamBase(input.uv, input.beamTime, input.beamUV, input.intensity, input.dilation, beamCombined, beamCombinedHighlight, alphaGradient);
	
	float3 col = _rampTexture.Sample(_rampTexture_SS, float2(beamCombined * input.fadeAlpha, 0.5)).rgb;
	col *= alphaGradient;
	col += float3(beamCombinedHighlight, beamCombinedHighlight, beamCombinedHighlight);
	col *= input.fadeAlpha;

	float endMask = saturate(min(input.uv.x, 1 - input.uv.x) * input.length / _endFadeLength);
	col *= endMask;

	return float4(col, 1);
}