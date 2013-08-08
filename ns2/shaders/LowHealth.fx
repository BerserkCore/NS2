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

float       healthWeight;

texture     baseTexture;

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

float4 SFXLowHealthPS(PS_INPUT input) : COLOR0
{
	float4 inputPixel = tex2D(baseTextureSampler, input.texCoord);
	float4 healthColor = inputPixel;
	healthColor += tex2D(baseTextureSampler, input.texCoord + 0.001);
	healthColor += tex2D(baseTextureSampler, input.texCoord - 0.001);
	healthColor += tex2D(baseTextureSampler, input.texCoord + 0.002);
	healthColor += tex2D(baseTextureSampler, input.texCoord - 0.002);
	healthColor = healthColor / 5;
	
	float distToCenter = length((input.texCoord * 2.0f) - 1.0f);
	
	healthColor *= float4(2, 0.1, 0.1, 0);
	return lerp(inputPixel, healthColor, max(0.25, healthWeight) * (distToCenter * 1.3));
}

technique SFXLowHealth
{
    pass p0
    {
		ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 SFXLowHealthPS();
        CullMode            = None;
    }
}