#define ENABLE_SHIP_COORDS
#define USE_DEFAULT_VERT
#include "./Data/base_shipquad.shader"

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

PIX_OUTPUT pix(in GEOM_OUTPUT input) : SV_TARGET
{
    float intensity = input.color.a;
    float noise1 = _noiseTexture.Sample(_noiseTexture_SS, input.shipLocation * 0.13).r;
    float mask = _maskTexture.Sample(_maskTexture_SS, input.uv).a;
    float2 dir = rotate(float2(1, 0), noise1 * TWO_PI * intensity) * 0.08;
    //float noise2 = _noiseTexture.Sample(_noiseTexture_SS, input.shipLocation * 0.81 + (noise1 * 0.8 * intensity)).r;
    float noise2 = _texture.Sample(_texture_SS, input.shipLocation * 0.09 + dir).r;
    
    //float intensity = input.color.a;
    
    //float baseCol = saturate(saturate(noise2 * noise1 * 1.2) * intensity + (intensity * 0.5)) * mask;
    float baseCol = saturate(saturate(noise2 * noise1 * 0.8) * intensity + (intensity * 0.75) * 0.8);



    float intensityPow = ((1 - intensity) * 10) + 0.8;
    baseCol = saturate(pow(baseCol, intensityPow));
    
    return float4(baseCol, baseCol, baseCol, baseCol * 0.9 * mask);
}