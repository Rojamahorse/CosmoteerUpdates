#include "resonance_beam_base.shader"

Texture2D _capturedBackBuffer;
SamplerState _capturedBackBuffer_SS;

PIX_OUTPUT pix(in VERT_OUTPUT_BEAM input) : SV_TARGET
{
	float beamCombined;
	float beamCombinedHighlight;
	float alphaGradient;
	CreateResonanceBeamBase(input.uv, input.beamTime, input.beamUV, input.intensity, input.dilation, beamCombined, beamCombinedHighlight, alphaGradient);
	
	float2 dd = float2(ddx(input.uv.x), ddy(input.uv.x));
	dd = normalize(dd) / length(dd) * float2(ddx(input.screenUV.x), ddy(input.screenUV.y));
	
	float2 screenDerivativesX = ddx(input.uv);
	float2 screenDerivativesY = ddy(input.uv);
	float screenSpaceScale = sqrt(dot(screenDerivativesX, screenDerivativesX) + dot(screenDerivativesY, screenDerivativesY));

	float endMask = saturate(min(input.uv.x, 1 - input.uv.x) * input.length / _endFadeLength);
	float2 distortionUVs = input.screenUV - (input.screenDirection * beamCombined  * endMask * input.fadeAlpha * 0.00005 / screenSpaceScale);
	float3 backBuffer = _capturedBackBuffer.Sample(_capturedBackBuffer_SS, distortionUVs).rgb;
	return float4(backBuffer, alphaGradient);
}