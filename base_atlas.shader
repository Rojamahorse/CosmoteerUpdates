#include "base.shader"

#pragma warning( disable : 3556 )

#ifdef ENABLE_ROOF_PAINT_COLOR
#define ENABLE_LOCAL_LOC
#define ENABLE_SCREEN_UV
#endif

#ifdef ENABLE_ROOF_PAINT_COLOR_KEYED
#define ENABLE_LOCAL_LOC
#define ENABLE_SCREEN_UV
#endif

#ifdef ENABLE_STENCIL
#define ENABLE_SCREEN_UV
#endif

#ifdef ENABLE_GLOBAL_LIGHTING
#define ENABLE_TANGENT
#endif

#ifdef ENABLE_ADDITIVE_LIGHTING
#define ENABLE_CENTER
#define ENABLE_SCREEN_UV
#define ENABLE_SCREEN_LOC
#endif

///////////////////////////////////////////////////////////////////

struct VERT_ANIMATION_INFO
{
	float2 uv : TEXCOORD0;
	float2 uvOffsetPerFrame : TEXCOORD1;
	float animationInterval : TEXCOORD2;
	float animationStartTime : TEXCOORD3;
	float2 animationFrames : TEXCOORD4;
	float animationClamp : TEXCOORD5;
};

struct VERT_INPUT_ATLAS
{
	float4 location : POSITION;
	float4 center : POSITION1;

#ifdef ENABLE_TANGENT
	float4 tangent : TANGENT0;
#endif

	float4 color : COLOR0;

#ifdef ENABLE_SPRITE_UV
	float2 spriteUV : TEXCOORD6;
#endif

#ifndef DISABLE_ANIMATION
	VERT_ANIMATION_INFO animInfo;
#else
	float2 uv : TEXCOORD0;
#endif

#ifndef DISABLE_ROTATION
	float4 rotateAround : POSITION2;
	float rotSpeed : POSITION3;
#endif
};

struct VERT_OUTPUT_ATLAS
{
	float4 location : SV_POSITION;

#ifdef ENABLE_LOCAL_LOC
	float4 localLoc : POSITION0;
#endif

#ifdef ENABLE_SCREEN_LOC
	float4 screenLoc : POSITION1;
#endif

#ifdef ENABLE_CENTER
	float4 center : POSITION2;
#endif

#ifdef ENABLE_TANGENT
	float4 tangent : TANGENT0;
#endif

	float4 color : COLOR0;
	float2 uv : TEXCOORD0;

#ifdef ENABLE_SCREEN_UV
	float2 screenUV : TEXCOORD1;
#endif

#ifdef ENABLE_SPRITE_UV
	float2 spriteUV : TEXCOORD2;
#endif
};

///////////////////////////////////////////////////////////////////

float2 getAnimatedUVs(VERT_ANIMATION_INFO animInfo)
{
	float2 ret;
	ret.y = animInfo.uv.y;

	int frame;
	if(animInfo.animationClamp != 0)
	{
		if(isinf(animInfo.animationInterval))
			frame = (int)min(animInfo.animationStartTime, animInfo.animationFrames.x - 1);
		else
			frame = (int)clampWrapNegativeOnce((_gameTime - animInfo.animationStartTime) / animInfo.animationInterval, animInfo.animationFrames.x - 1);
	}
	else
	{
		if(isinf(animInfo.animationInterval))
			frame = (int)wrap(animInfo.animationStartTime, animInfo.animationFrames.x);
		else
			frame = (int)wrap((_gameTime - animInfo.animationStartTime) / animInfo.animationInterval, animInfo.animationFrames.x);
	}

	int framesPerRow = (int)animInfo.animationFrames.y;
	int col = frame % framesPerRow;
	int row = frame / framesPerRow;
	ret.x = animInfo.uv.x + animInfo.uvOffsetPerFrame.x * col;
	ret.y = animInfo.uv.y + animInfo.uvOffsetPerFrame.y * row;
	return ret;
}

float4 _shipBounds;
float _roofOpacity;
void modifyRoofAlpha(inout float a, float2 localLoc)
{
	float alphaLow = 1 - inverseLerp(_shipBounds.x + _shipBounds.y, _shipBounds.z + _shipBounds.w, localLoc.x + localLoc.y);
	float alphaHigh = alphaLow + .5;
	a *= inverseLerp(alphaLow, alphaHigh, _roofOpacity * 1.5);
}

float _roofBaseAlpha;
Texture2D _roofBaseTexture;
SamplerState _roofBaseTexture_SS;
float2 _roofBaseTextureScale;
Texture2D _roofDecalsTarget;
SamplerState _roofDecalsTarget_SS;
float3 getRoofPaintColor(float2 localLoc, float2 screenUV)
{
	float3 baseTex = (1 - (1 - _roofBaseTexture.Sample(_roofBaseTexture_SS, localLoc / _roofBaseTextureScale)) * _roofBaseAlpha).rgb;
	float3 decal = _roofDecalsTarget.Sample(_roofDecalsTarget_SS, screenUV).rgb;
	return baseTex * decal;
}

///////////////////////////////////////////////////////////////////

#ifdef ENABLE_CUSTOM_VERTEX_WORLD_LOC
float4 getCustomVertexWorldLoc(in VERT_INPUT_ATLAS input);
#endif

#ifdef ENABLE_CUSTOM_VERTEX_COLOR
float4 getCustomVertexColor(in VERT_INPUT_ATLAS input);
#endif

#ifdef USE_DEFAULT_VERT_ATLAS
VERT_OUTPUT_ATLAS vert(in VERT_INPUT_ATLAS input)
{
	VERT_OUTPUT_ATLAS output;

#ifdef ENABLE_CUSTOM_VERTEX_WORLD_LOC
	float4 localLoc = getCustomVertexWorldLoc(input);
#else
	float4 localLoc = input.location;
#endif

#ifndef DISABLE_ROTATION
	float rot = (_gameTime - input.animInfo.animationStartTime) * input.rotSpeed;
	localLoc.xy = rotate(localLoc.xy - input.rotateAround.xy, rot) + input.rotateAround.xy;
#endif

#ifdef ENABLE_LOCAL_LOC
	output.localLoc = localLoc;
#endif

	output.location = mul(localLoc, _transform);

#ifdef ENABLE_SCREEN_LOC
	output.screenLoc = output.location;
#endif

#ifdef ENABLE_CENTER
    float4 localCenter = input.center;
#ifndef DISABLE_ROTATION
	localCenter.xy = rotate(localCenter.xy - input.rotateAround.xy, rot) + input.rotateAround.xy;
#endif
	output.center = mul(localCenter, _transform);
#endif

#ifdef ENABLE_TANGENT
#ifndef DISABLE_ROTATION
	input.tangent.xy = rotate(input.tangent.xy, rot);
#endif
	output.tangent.xy = normalize(mul(float4(input.tangent.xy, 0, 0), _transform).xy * _viewportScale);
	output.tangent.zw = input.tangent.zw;
#endif

#ifdef ENABLE_CUSTOM_VERTEX_COLOR
	output.color = getCustomVertexColor(input);
#else
	output.color = input.color * _color;
#endif

#ifdef ENABLE_ROOF_ALPHA
	modifyRoofAlpha(output.color.a, localLoc.xy);
#endif

#ifndef DISABLE_ANIMATION
	output.uv = getAnimatedUVs(input.animInfo);
#else
	output.uv = input.uv;
#endif

#ifdef ENABLE_SCREEN_UV
	output.screenUV.x = (output.location.x + 1) / 2;
	output.screenUV.y = (-output.location.y + 1) / 2;
#endif

#ifdef ENABLE_SPRITE_UV
	output.spriteUV = input.spriteUV;
#endif

	return output;
}
#endif

///////////////////////////////////////////////////////////////////

#ifdef ENABLE_CUSTOM_PIXEL_COLOR
float4 getCustomPixelColor(in VERT_OUTPUT_ATLAS input);
#endif

#ifdef USE_DEFAULT_PIX_ATLAS
PIX_OUTPUT pix(in VERT_OUTPUT_ATLAS input) : SV_TARGET
{
	float4 c;

#ifdef ENABLE_CUSTOM_PIXEL_COLOR
	c = getCustomPixelColor(input);
#else
	c = _texture.Sample(_texture_SS, input.uv);
#endif

#ifdef ENABLE_STENCIL
	c.a *= 1 - _stencilTarget.Sample(_stencilTarget_SS, input.screenUV).a;
#endif

#ifdef ENABLE_ROOF_PAINT_COLOR_KEYED
	c.rgb = swapAllegianceColor(c.rgb, getRoofPaintColor(input.localLoc.xy, input.screenUV));
#endif

#ifdef ENABLE_ROOF_PAINT_COLOR
	c.rgb *= getRoofPaintColor(input.localLoc.xy, input.screenUV);
#endif

#ifdef ENABLE_GLOBAL_LIGHTING
	applyGlobalLighting(c, input.uv, input.tangent, _lightNormal);
#endif

#ifdef ENABLE_ADDITIVE_LIGHTING
	multiplyAdditiveLightValue(c.rgb, input.screenUV, input.center.xyz, input.screenLoc.xyz);
    c.rgb *= c.a;
#endif

#ifndef DISABLE_PIXEL_VERTEX_COLOR_SCALING
	c *= input.color;
#endif

	if (c.a <= 0)
		discard;

	return c;
}
#endif