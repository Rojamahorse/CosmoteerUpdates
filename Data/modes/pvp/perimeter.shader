struct VERT_INPUT
{
	float4 location : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

struct VERT_OUTPUT
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

typedef float4 PIX_OUTPUT;

float4x4 _transform;
float4 _color = 255;
float _innerRadius;
float _thickness;
VERT_OUTPUT vert(in VERT_INPUT input)
{
	float locLength = length(input.location.xy);
	float2 locNrm = input.location.xy / locLength;
	float2 newLoc = locNrm * (_innerRadius + (locLength - 1) * _thickness);

	VERT_OUTPUT output;
	output.location = mul(float4(newLoc, input.location.zw), _transform);
	output.color = input.color * _color;
	output.uv = input.uv;
	return output;
}

Texture2D _texture;
SamplerState _texture_SS;
PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float3 rgb = _texture.Sample(_texture_SS, input.uv).rgb;
	float a = _texture.Sample(_texture_SS, float2(0, input.uv.y)).a;
	float4 ret = float4(rgb.r, rgb.g, rgb.b, a) * input.color;
	if (ret.a <= 0)
		discard;
	return ret;
}
