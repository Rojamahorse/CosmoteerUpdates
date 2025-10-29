struct VERT_INPUT
{
	float2 center : POSITION0;
	float2 scale : POSITION1;
	float rotation : POSITION2;
	float4 color : COLOR0;
	float2 offset : POSITION3;
	float2 uv : TEXCOORD0;
};

struct VERT_OUTPUT
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

typedef float4 PIX_OUTPUT;

float2 rotate(float2 v, float radians)
{
	float cosRot = cos(radians);
	float sinRot = sin(radians);
	return float2(
		v.x * cosRot - v.y * sinRot,
		v.x * sinRot + v.y * cosRot);
}

float4x4 _transform;
float4 _color = 255;
float2 _baseSize;
VERT_OUTPUT vert(in VERT_INPUT input)
{
	float4 loc;
	loc.xy = input.center + rotate(input.offset * _baseSize * input.scale, input.rotation);
	loc.z = 0;
	loc.w = 1;

	VERT_OUTPUT output;
	output.location = mul(loc, _transform);
	output.color = input.color * _color;
	output.uv = input.uv;
	return output;
}

Texture2D _texture;
SamplerState _texture_SS;

float4 swapAllegianceColor(float4 pixel, float4 allegianceColor)
{
	if(pixel.g > pixel.r && abs(pixel.r - pixel.b) < .25) // Replace green pixels with allegiance color.
	{
		float3 scaledAllegianceColor = allegianceColor.rgb * pixel.g;
		float desaturation = pixel.r / pixel.g; // works because pixel.r == pixel.b (approximately)
		float desaturationValue = max(scaledAllegianceColor.r, max(scaledAllegianceColor.g, scaledAllegianceColor.b));
		float3 desaturationColor = float3(desaturationValue, desaturationValue, desaturationValue);
		pixel.rgb = scaledAllegianceColor * (1 - desaturation) + desaturationColor * desaturation;
	}
	return pixel;
}

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 pixel = _texture.Sample(_texture_SS, input.uv);
	pixel = swapAllegianceColor(pixel, input.color);
	pixel.a *= input.color.a;
	if(pixel.a <= 0)
		discard;
	return pixel;
}
