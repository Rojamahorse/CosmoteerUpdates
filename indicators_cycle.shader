#define USE_DEFAULT_PIX_ATLAS
#define ENABLE_SPRITE_UV
#define ENABLE_CUSTOM_PIXEL_COLOR
#include "base_atlas.shader"

struct INDICATOR_INPUT
{
    float4 location : POSITION;
    float4 center : POSITION1;
    float4 tangent : TANGENT0;
    float4 color : COLOR0;
    float2 spriteUV : TEXCOORD6;
    VERT_ANIMATION_INFO animInfo;
    
    int cycleOffset : POSITION4;
    int cycleSiblingCount : POSITION5;
};

float _camScale;
float _maxScale;
float _cycleInterval;
float4x4 _invShipRotMatrix;

float4 _colorFluctuateLow = 255;
float4 _colorFluctuateHigh = 255;
float _fluctuateInterval;

float4 getCustomVertexWorldLoc(in INDICATOR_INPUT input)
{
    float4 offsetFromCenter = mul(input.location - input.center, _invShipRotMatrix);
    return input.center + offsetFromCenter * min(_camScale, _maxScale);
}

float getAlphaForCycle(in INDICATOR_INPUT input)
{
    float fullCycleDuration = input.cycleSiblingCount * _cycleInterval;
    float currentCycleTime = _time % fullCycleDuration;
    
    float spriteStartTime = input.cycleOffset * _cycleInterval;
    float spriteEndTime = spriteStartTime + _cycleInterval;
    
    return spriteStartTime <= currentCycleTime && currentCycleTime < spriteEndTime ? 1 : 0;
}

float4 getCustomPixelColor(in VERT_OUTPUT_ATLAS input)
{
	float4 c = _texture.Sample(_texture_SS, input.uv);
    c *= lerp(_colorFluctuateLow, _colorFluctuateHigh, wave(_time, _fluctuateInterval));
    return c;
}

VERT_OUTPUT_ATLAS vert(in INDICATOR_INPUT input)
{
    VERT_OUTPUT_ATLAS output;
    
    float4 localLoc = getCustomVertexWorldLoc(input);
    output.location = mul(localLoc, _transform);
    
    output.color = input.color;
    output.color.a *= getAlphaForCycle(input);
    
    output.uv = getAnimatedUVs(input.animInfo);
    output.spriteUV = input.spriteUV;
    
    return output;
}