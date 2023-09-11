#include "../base.shader"

struct VERT_INPUT_BEAM
{
	float4 beamStart : POSITION0;
    float2 vertexOffset : POSITION1;
    float direction : POSITION2;
    float length : POSITION3;
	float4 color : COLOR0;
    float intensity : COLOR1;
    float fadeAlpha : COLOR2;
	float2 uv : TEXCOORD0;
    float beamTime : TEXCOORD1;
};

float2 calculateWorldBeamEnd(float2 beamStart, float direction, float length, out float2 dir)
{
    sincos(direction, dir.y, dir.x);
    return beamStart + dir * length;
}
float2 calculateWorldBeamEnd(in VERT_INPUT_BEAM input, out float2 dir)
{
    sincos(input.direction, dir.y, dir.x);
    return input.beamStart.xy + dir * input.length;
}
float2 calculateWorldBeamEnd(in VERT_INPUT_BEAM input)
{
    float2 dir;
    return calculateWorldBeamEnd(input, dir);
}

float2 calculateWorldVertexLoc(float2 beamStart, float2 beamEnd, float2 dir, float length, float2 vertexOffset,
                               float extraBeginLength = 0, float extraEndLength = 0,
                               float extraBeginArc = 0, float extraEndArc = 0)
{
    float2 offsetFrom;
    float extraLength;
    float extraArc;
    if(vertexOffset.x > 0)
    {
        offsetFrom = beamEnd;
        extraLength = extraEndLength;
        extraArc = extraEndArc;
    }
    else
    {
        offsetFrom = beamStart;
        extraLength = extraBeginLength;
        extraArc = extraBeginArc;
    }

    float2 xOffset = dir * extraLength * vertexOffset.x;
    float2 yOffset = perp(dir) * (vertexOffset.y + length * extraArc * 0.5 * sign(vertexOffset.y));
    return offsetFrom + xOffset + yOffset;
}
float4 calculateWorldVertexLoc(in VERT_INPUT_BEAM input, out float2 beamEnd,
                               float extraBeginLength = 0, float extraEndLength = 0,
                               float extraBeginArc = 0, float extraEndArc = 0)
{
    float2 dir;
    beamEnd = calculateWorldBeamEnd(input, dir);
    float2 vertexLoc = calculateWorldVertexLoc(input.beamStart.xy, beamEnd, dir, input.length, input.vertexOffset,
                                               extraBeginLength, extraEndLength,
                                               extraBeginArc, extraEndArc);
    return float4(vertexLoc, input.beamStart.zw);
}
float4 calculateWorldVertexLoc(in VERT_INPUT_BEAM input,
                               float extraBeginLength = 0, float extraEndLength = 0,
                               float extraBeginArc = 0, float extraEndArc = 0)
{
    float2 beamEnd;
    return calculateWorldVertexLoc(input, beamEnd,
                                   extraBeginLength, extraEndLength,
                                   extraBeginArc, extraEndArc);
}

float4 calculateWorldVertexLocProjZ(in VERT_INPUT_BEAM input, float extraBeginLength, float extraEndLength, float extraBeginArc, float extraEndArc) // http://www.reedbeta.com/blog/quadrilateral-interpolation-part-1/
{
    float2 dir;
    float2 beamEnd = calculateWorldBeamEnd(input, dir);
    float4 currentVertPos = calculateWorldVertexLoc(input, extraBeginLength, extraEndLength, extraBeginArc, extraEndArc);
    float2 diagonalVertPos = calculateWorldVertexLoc(input.beamStart, beamEnd, dir, input.length, float2(-input.vertexOffset.x, -input.vertexOffset.y), extraBeginLength, extraEndLength, extraBeginArc, extraEndArc);
    
    float beginWidth = (abs(input.vertexOffset.y) + input.length * extraBeginArc * 0.5) * 2;
    float endWidth = (abs(input.vertexOffset.y) + input.length * extraEndArc * 0.5) * 2;
    float fullLength = input.length + extraBeginLength + extraEndLength;
    float2 intersection;
    float distFromBase;
    if (beginWidth > endWidth) //determining which end is the base
    {
        distFromBase = (beginWidth * fullLength) / (beginWidth + endWidth);
        intersection = input.beamStart + (dir * (distFromBase - extraBeginLength));
    }
    else 
    {
        distFromBase = (endWidth * fullLength) / (beginWidth + endWidth);
        intersection = beamEnd - (dir * (distFromBase - extraEndLength));
    }

    float d1 = distance(currentVertPos.xy, intersection);
    float d4 = distance(diagonalVertPos.xy, intersection);
    float z = (d1 + d4) / d4;
    return float4(currentVertPos.xy, input.beamStart.z, z);
 }

#ifdef USE_DEFAULT_VERT_BEAM
float _extraBeginLength;
float _extraEndLength;
VERT_OUTPUT vert(in VERT_INPUT_BEAM input)
{
	VERT_OUTPUT output;
    input.vertexOffset.y *= input.intensity;
    float4 vertexLoc = calculateWorldVertexLoc(input, _extraBeginLength, _extraEndLength);
	output.location = mul(vertexLoc, _transform);
	output.color = input.color * _color;
    output.color.a *= input.fadeAlpha;
	output.uv = input.uv;
	return output;
}
#endif