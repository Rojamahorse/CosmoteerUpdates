#include "./Data/base.shader"

struct VERT_INPUT_SCORCH
{
    float4 location : POSITION;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
    float2 shipLocation : TEXCOORD1;
    float intensity : TEXCOORD2;
	float roofOpacity : TEXCOORD3;
};
struct VERT_OUTPUT_SCORCH
{
    float4 location : SV_POSITION;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
    float2 shipLocation : TEXCOORD1;
	float intensity : TEXCOORD2;
	float roofOpacity : TEXCOORD3;
    float2 screenUV : TEXCOORD4;
};

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

bool _useRoofAlpha;

VERT_OUTPUT_SCORCH vert(in VERT_INPUT_SCORCH input)
{
    VERT_OUTPUT_SCORCH output;
    output.location = mul(input.location, _transform);
    output.color = input.color;
    output.uv = input.uv;
    output.shipLocation = input.shipLocation;
    output.screenUV.x = (output.location.x + 1) / 2;
	output.screenUV.y = (-output.location.y + 1) / 2;
    output.roofOpacity = input.roofOpacity;
    return output;
}

PIX_OUTPUT pix(in VERT_OUTPUT_SCORCH input) : SV_TARGET
{
//    float4 sample = _texture.Sample(_texture_SS, input.uv);
//    return float4(sample.rgb, sample.r);
//    float4 normals = _normalsTarget.Sample(_normalsTarget_SS, input.screenUV);
//    return normals;
    float alpha = 1 - _texture.Sample(_texture_SS, input.shipLocation * 0.2).r;
    float mask = _maskTexture.Sample(_maskTexture_SS, input.uv).a;
    float noise = _noiseTexture.Sample(_noiseTexture_SS, input.shipLocation * 0.064).r; //was 0.14
	noise = pow(noise, 3);

    float intensity = input.color.a;
    alpha = pow(alpha, 0.75 + (noise * intensity * 5) + (1 - intensity) * 5);
    
    float4 rawNormals = _normalsTarget.Sample(_normalsTarget_SS, input.screenUV);
	float3 baseNormal = colorToNormals(rawNormals.rgb);
	float3 normal = baseNormal;
	normal.z = 0.2; //0.02 for ships, 0.2 for asteroids
	normal = normalize(normal);
	float edges = 1 - saturate(dot(normal, float3(0, 0, 1)));
    
    alpha = (alpha * edges) * 0.3 + alpha * 0.7;
    alpha = saturate(alpha + edges);
    
    //float intensity = input.color.a;
    //alpha = pow(alpha, 1 + (1 - intensity) * 5);
    
    //float lightCol = intensity * 0.5 * mask;
    float lightCol = alpha * mask * intensity * (0.5 + (0.5 * noise));
    //noise = pow(noise, 3);
    //return float4(noise, noise, noise, 1);
    
    //float col;
	//if (_useRoofAlpha)
		//col = saturate(lightCol + input.color.a * alpha * mask) * input.roofOpacity;
	//else
		//col = saturate(lightCol + input.color.a * alpha * mask);
	//float baseCol = 1 - (saturate(lightCol + input.color.a * alpha * mask) * input.roofOpacity * rawNormals.a);
	//return float4(col, col, col, 1);
	if (_useRoofAlpha)
	{
		//return float4(input.color.rgb, saturate(lightCol + input.color.a * alpha * mask) * input.roofOpacity * rawNormals.a);
		float baseCol = 1 - ((saturate(lightCol + input.color.a * alpha * mask) * input.roofOpacity * rawNormals.a) * 0.9);
		return float4(baseCol, baseCol, baseCol, 1); //multiply
	}
	else
	{
		//return float4(input.color.rgb, saturate(lightCol + input.color.a * alpha * mask * rawNormals.a));
		float baseCol = 1 - ((saturate(lightCol + input.color.a * alpha * mask) * rawNormals.a) * 0.9);
		return float4(baseCol, baseCol, baseCol, 1);
	}
}