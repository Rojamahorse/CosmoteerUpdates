#include "../../base.shader"

struct VERT_INPUT_PARTICLE
{
	float2 center : POSITION0;
	float2 scale : POSITION1;
	float rotation : POSITION2;
	float4 color : COLOR0;
	float2 offset : POSITION3;
	float2 uv : TEXCOORD0;

#ifdef ENABLE_LIGHT_NORMAL
	float3 lightNormal : NORMAL0;
#endif

#ifdef ENABLE_COLOR2
    float4 color2 : COLOR1;
#endif
};

struct VERT_OUTPUT_PARTICLE
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;

#ifdef ENABLE_SCREEN_LOC
	float4 screenLoc : POSITION1;
#endif

#ifdef ENABLE_SCREEN_CENTER
	float4 screenCenter : POSITION2;
#endif

#ifdef ENABLE_WORLD_LOC
float4 worldLoc : POSITION3;
#endif

#ifdef ENABLE_SCREEN_UV
	float2 screenUV : TEXCOORD1;
#endif

#ifdef ENABLE_TANGENT
	float4 tangent : TANGENT0;
#endif

#ifdef ENABLE_LIGHT_NORMAL
	float3 lightNormal : NORMAL0;
#endif

#ifdef ENABLE_COLOR2
    float4 color2 : COLOR1;
#endif
};

float2 _baseSize;

#ifdef USE_DEFAULT_VERT_PARTICLE
VERT_OUTPUT_PARTICLE vert(in VERT_INPUT_PARTICLE input)
{
	float4 loc;
	loc.xy = input.center + rotate(input.offset * _baseSize * input.scale, input.rotation);
	loc.z = 0;
	loc.w = 1;

	VERT_OUTPUT_PARTICLE output;
	output.location = mul(loc, _transform);
	output.color = input.color * _color;
	output.uv = input.uv;

#ifdef ENABLE_SCREEN_LOC
	output.screenLoc = output.location;
#endif

#ifdef ENABLE_SCREEN_CENTER
	output.screenCenter = mul(float4(input.center, 0, 1), _transform);
#endif

#ifdef ENABLE_WORLD_LOC
	output.worldLoc = loc;
#endif

#ifdef ENABLE_SCREEN_UV
	output.screenUV.x = (output.location.x + 1) / 2;
	output.screenUV.y = (output.location.y - 1) / -2;
#endif

#ifdef ENABLE_TANGENT
	output.tangent.xy = float2(cos(input.rotation), sin(input.rotation));
	output.tangent.xy = normalize(mul(float4(output.tangent.xy, 0, 0), _transform).xy * _viewportScale);
	output.tangent.zw = float2(1, 1);
#endif

#ifdef ENABLE_LIGHT_NORMAL
	output.lightNormal = input.lightNormal;
#endif

#ifdef ENABLE_COLOR2
    output.color2 = input.color2;
#endif

	return output;
}
#endif
