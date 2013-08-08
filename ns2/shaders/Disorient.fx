struct VS_INPUT
{
    float3 ssPosition   : POSITION;
    float2 texCoord     : TEXCOORD0;
    float4 color        : COLOR0;
};

struct VS_OUTPUT
{
    float4 ssPosition	: POSITION;
    float2 texCoord     : TEXCOORD0;
    float4 color        : COLOR0;
};

struct PS_INPUT
{
    float2 texCoord     : TEXCOORD0;
    float4 color        : COLOR0;
};

texture     baseTexture;
float		time;
float		amount;

sampler baseTextureSampler = sampler_state
    {
        texture       = (baseTexture);
        AddressU      = Wrap;
        AddressV      = Wrap;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Linear;
		SRGBTexture   = False;
    };

/**
 * Vertex shader.
 */  
VS_OUTPUT SFXBasicVS(VS_INPUT input)
{

    VS_OUTPUT output;

    output.ssPosition = float4(input.ssPosition, 1);
    output.texCoord   = input.texCoord;
    output.color      = input.color;

    return output;

}

float SmoothStep(float x)
{
    return (x * x) * (3.0f - (2.0f * x));
}

float4 SFXDisorientPS(PS_INPUT input) : COLOR0
{

	float2 t = (input.texCoord - 0.5) * 2;
	
    float q = atan2(t.y, t.x);
	float r = length(t);
	
	float rippleSpeed 		= 1;
	float rippleness  		= 20;
	float rippleStrength 	= 0.02;
	
	// Riple factor blends out the ripple effect near the center of the screen and near
	// the edges (to avoid artifacts).
	float rippleFactor = saturate(SmoothStep(r * 1.5)) * amount;
	
	r += rippleFactor * cos(r * rippleness + time * rippleSpeed) * rippleStrength;
	
	sincos(q, t.y, t.x);
	t = r * (t / 2) + 0.5;
	
	float4 result = tex2D( baseTextureSampler, t );
	return result;
	
}

technique SFXDisorient
{
    pass p0
    {
		ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 SFXDisorientPS();
        CullMode            = None;
    }
}