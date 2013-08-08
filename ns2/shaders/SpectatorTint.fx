struct VS_INPUT
{
    float3 ssPosition   : POSITION;
    float2 texCoord     : TEXCOORD0;
    float4 color        : COLOR0;
};

struct VS_OUTPUT
{
    float4 ssPosition    : POSITION;
    float2 texCoord     : TEXCOORD0;
    float4 color        : COLOR0;
};

struct PS_INPUT
{
    float2 texCoord     : TEXCOORD0;
    float4 color        : COLOR0;
};

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

float4 SFXSpectatorTintPS(PS_INPUT input) : COLOR0
{
    float4 inputPixel = tex2D(baseTextureSampler, input.texCoord);
    float distToCenter = abs(input.texCoord.y - 0.5);
    return lerp(inputPixel, float4(0, 0, 0, 0), distToCenter*distToCenter*distToCenter*8);
}

technique SFXSpectatorTint
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;    
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 SFXSpectatorTintPS();
        CullMode            = None;
    }
}