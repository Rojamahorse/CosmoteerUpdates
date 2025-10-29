#include "./Data/base.shader"

// TODO: implement base_atlas' modifyRoofAlpha
float _roofOpacity;

struct VERT_GEOM_INPUT
{
    float4 location : POSITION;
    float2 size : POSITION1;
    float4 color : COLOR0;
    float2 uvLocation : TEXCOORD0;
    float2 uvSize : TEXCOORD1;
    
#ifdef ENABLE_INTENSITY
    float intensity : TEXCOORD2;
#endif
};

struct GEOM_OUTPUT
{
    float4 location : SV_POSITION;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
    
#ifdef ENABLE_SHIP_COORDS
    float2 shipLocation : TEXCOORD1;
#endif
    
#ifdef ENABLE_SCREEN_UV
    float2 screenUV : TEXCOORD2;
#endif
    
#ifdef ENABLE_INTENSITY
    float intensity : TEXCOORD3;
#endif
};

#ifdef USE_DEFAULT_VERT
VERT_GEOM_INPUT vert(in VERT_GEOM_INPUT input)
{
    VERT_GEOM_INPUT output = input;
    return output;
}
#endif

#ifdef USE_CUSTOM_LOCATION
float4 getCustomLocation(float4 vertexLocation, in VERT_GEOM_INPUT input);
#endif

float2 RotateVector(float2 vec, float radians)
{
    float2 o;
    o.x = vec.x * cos(radians) - vec.y * sin(radians);
    o.y = vec.x * sin(radians) + vec.y * cos(radians);
    return o;
}

#if defined(DISABLE_ROTATION)
float4x4 _invShipRotMatrix;

GEOM_OUTPUT SetupVertexCameraAligned(in VERT_GEOM_INPUT i, inout GEOM_OUTPUT v, in float4 localCenter, float4 offsetFactor)
{
    float2 uvOffset = i.uvSize * offsetFactor.xy;
    v.uv = i.uvLocation + uvOffset;
    
    offsetFactor -= 0.5;
    float4 offset = float4(i.size.x * offsetFactor.x, i.size.y * offsetFactor.y, 0, 0);
    float4 rotatedOffset = mul(offset, _invShipRotMatrix);
    
#if defined(USE_CUSTOM_LOCATION)
    v.location = getCustomLocation(localCenter + rotatedOffset, i);
#else
    v.location = mul(localCenter + rotatedOffset, _transform);
#endif
    
#ifdef ENABLE_SHIP_COORDS
    v.shipLocation = localCenter + rotatedOffset;
#endif
    
#ifdef ENABLE_SCREEN_UV
    v.screenUV.x = (v.location.x + 1) / 2;
    v.screenUV.y = (-v.location.y + 1) / 2;
#endif
    
    return v;
}
#endif

GEOM_OUTPUT SetupVertex(in VERT_GEOM_INPUT i, inout GEOM_OUTPUT v, float4 offsetFactor)
{
    float2 uvOffset = i.uvSize * offsetFactor.xy;
    v.uv = i.uvLocation + uvOffset;
    
    float4 offset = float4(i.size.x * offsetFactor.x, i.size.y * offsetFactor.y, 0, 0);
    
#if defined(USE_CUSTOM_LOCATION)
    v.location = getCustomLocation(i.location + offset, i);
#else
    v.location = mul(i.location + offset, _transform);
#endif

#if defined(ENABLE_SHIP_COORDS)
    v.shipLocation = i.location + offset;
#endif
    
#ifdef ENABLE_SCREEN_UV
    v.screenUV.x = (v.location.x + 1) / 2;
    v.screenUV.y = (-v.location.y + 1) / 2;
#endif
    
    return v;
}

#if !defined(OVERRIDE_GEOM)
[maxvertexcount(4)]
void geom(point VERT_GEOM_INPUT input[1], inout TriangleStream<GEOM_OUTPUT> output)
{
    VERT_GEOM_INPUT i = input[0];
    GEOM_OUTPUT v;
    
    v.color = i.color;
    
#ifdef ENABLE_INTENSITY
    v.intensity = i.intensity;
#endif
    
#if defined(DISABLE_ROTATION)
    float4 center = i.location;
    center.xy += i.size * 0.5;
    
	v = SetupVertexCameraAligned(i, v, center, float4(0,0,0,0));
	output.Append(v);

	v = SetupVertexCameraAligned(i, v, center, float4(1,0,0,0));
	output.Append(v);

	v = SetupVertexCameraAligned(i, v, center, float4(0,1,0,0));
	output.Append(v);

	v = SetupVertexCameraAligned(i, v, center, float4(1,1,0,0));
	output.Append(v);
    
#else
	v = SetupVertex(i, v, float4(0,0,0,0));
	output.Append(v);

	v = SetupVertex(i, v, float4(1,0,0,0));
	output.Append(v);

	v = SetupVertex(i, v, float4(0,1,0,0));
	output.Append(v);

	v = SetupVertex(i, v, float4(1,1,0,0));
	output.Append(v);
#endif
	
	output.RestartStrip();
}
#endif