#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float4 _baseColor = 255;
float4 _glowColor = 255;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float4 texColor = _texture.Sample(_texture_SS, input.uv);
    float4 baseColor = float4(_baseColor.rgb * input.color.rgb, texColor.r * _baseColor.a * input.color.a);
    float4 glowColor = float4(_glowColor.rgb * input.color.rgb, texColor.g * _glowColor.a * input.color.a);
    
    float alpha = baseColor.a + glowColor.a * (1 - baseColor.a);
    float3 col = (baseColor.rgb * baseColor.a + glowColor.rgb * glowColor.a * (1 - baseColor.a)) / alpha;

    return float4(col, alpha);
}