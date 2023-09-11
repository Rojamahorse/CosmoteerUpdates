#include "../base_atlas.shader"

struct CREW_INPUT
{
	float2 vertexOffset : POSITION;
	float3 center : POSITION1;
	float3 fromOffset : POSITION2;
	float4 tangent : TANGENT0;
	float crewTime : POSITION3;
	float3 lightNormal : NORMAL0;
	float4 shirtColor : COLOR0;
	float4 skinColor : COLOR1;
	float4 hairColor : COLOR2;
	VERT_ANIMATION_INFO animInfo;
};

struct VERT_OUTPUT_ATLAS_CREW
{
	float4 location : SV_POSITION;
	float4 tangent : TANGENT0;
	float4 shirtColor : COLOR0;
	float4 skinColor : COLOR1;
	float4 hairColor : COLOR2;
	float2 uv : TEXCOORD0;
	float3 lightNormal : NORMAL0;

#ifdef ANIM_UVS
	nointerpolation float2 animUV : TEXCOORD1;
	nointerpolation float2 animUVOffsetPerFrame : TEXCOORD2;
#endif
};

float _crewTime;
VERT_OUTPUT_ATLAS_CREW vert(in CREW_INPUT input)
{
	float t = inverseLerp(input.crewTime + 1, input.crewTime, _crewTime);
	float2 center = input.center.xy + input.fromOffset.xy * t;
	float rot = input.center.z + input.fromOffset.z * t;
	float2 localLoc = center + rotate(input.vertexOffset, rot);

	VERT_OUTPUT_ATLAS_CREW output;
	output.location = mul(float4(localLoc.x, localLoc.y, 0, 1), _transform);
	output.tangent.xy = normalize(mul(float4(rotate(input.tangent.xy, rot), 0, 0), _transform).xy * _viewportScale);
	output.tangent.zw = input.tangent.zw;
	output.shirtColor = input.shirtColor;
	output.skinColor = input.skinColor;
	output.hairColor = input.hairColor;
	output.uv = getAnimatedUVs(input.animInfo);
	output.lightNormal = input.lightNormal;

#ifdef ANIM_UVS
	output.animUV = input.animInfo.uv;
	output.animUVOffsetPerFrame = input.animInfo.uvOffsetPerFrame;
#endif

	return output;
}


float4 getDiffuseColor(VERT_OUTPUT_ATLAS_CREW input)
{
	float4 pixel = _texture.Sample(_texture_SS, input.uv);
	pixel.rgb = input.shirtColor.rgb * pixel.g + input.skinColor.rgb * pixel.r + input.hairColor.rgb * pixel.b;
	pixel *= _color;
	return pixel;
}