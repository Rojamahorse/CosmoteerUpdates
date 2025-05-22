#define ENABLE_INTENSITY
#define ENABLE_SHIP_COORDS
#define ENABLE_SCREEN_UV
#define USE_DEFAULT_VERT
#include "./Data/base_shipquad.shader"

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

bool _useRoofAlpha;

PIX_OUTPUT pix(in GEOM_OUTPUT input) : SV_TARGET
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
		float baseCol = 1 - ((saturate(lightCol + input.color.a * alpha * mask) * _roofOpacity * rawNormals.a) * 0.9);
		return float4(baseCol, baseCol, baseCol, 1); //multiply
	}
	else
	{
		//return float4(input.color.rgb, saturate(lightCol + input.color.a * alpha * mask * rawNormals.a));
		float baseCol = 1 - ((saturate(lightCol + input.color.a * alpha * mask) * rawNormals.a) * 0.9);
		return float4(baseCol, baseCol, baseCol, 1);
	}
}