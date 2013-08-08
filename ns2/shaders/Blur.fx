struct VS_INPUT
{
    float3 ssPosition   : POSITION;
    float2 texCoord     : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 ssPosition	: POSITION;
    float2 texCoord     : TEXCOORD0;
};

struct PS_INPUT
{
    float2 texCoord     : TEXCOORD0;
};

texture     inputTexture;
float		screenwidth;
float		screenheight;

sampler inputTextureSampler = sampler_state
    {
        texture       = (inputTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
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

    return output;

}
 
const float offset[3] = { 0.0, 1.3846153846, 3.2307692308 };
const float weight[3] = { 0.2270270270, 0.3162162162, 0.0702702703 };

float4 HBlurPS(PS_INPUT input) : COLOR0
{
	float4 result = tex2D( inputTextureSampler, input.texCoord ) * weight[0];
	for (int i = 1; i < 3; ++i)
	{
		float2 dt = float2(offset[i] / screenwidth, 0.0f);
		result += tex2D( inputTextureSampler, input.texCoord + dt ) * weight[i];
		result += tex2D( inputTextureSampler, input.texCoord - dt ) * weight[i];
	}
	return result;
}

float4 VBlurPS(PS_INPUT input) : COLOR0
{
	float4 result = tex2D( inputTextureSampler, input.texCoord ) * weight[0];
	for (int i = 1; i < 3; ++i)
	{
		float2 dt = float2(0.0f, offset[i] / screenheight);
		result += tex2D( inputTextureSampler, input.texCoord + dt ) * weight[i];
		result += tex2D( inputTextureSampler, input.texCoord - dt ) * weight[i];
	}
	return result;
}

technique HBlur
{
    pass p0
    {
		ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 HBlurPS();
        CullMode            = None;
    }
}

technique VBlur
{
    pass p0
    {
		ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 VBlurPS();
        CullMode            = None;
    }
}