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

float		screenwidth;
float		screenheight;
texture     inputTexture;
texture     baseTexture;
texture		depthTexture;
float		amount;		

sampler inputTextureSampler = sampler_state
    {
        texture       = (inputTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Point;
		SRGBTexture   = False;
    };

sampler baseTextureSampler = sampler_state
    {
        texture       = (baseTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Point;
		SRGBTexture   = False;
    };
	
sampler depthTextureSampler = sampler_state
    {
        texture       = (depthTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = None;
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

float4 DownSampleBoxPS(PS_INPUT input) : COLOR0
{
	float2 t1 = input.texCoord;
	return tex2D(inputTextureSampler, t1);
}

float4 SFXShadowStepPS(PS_INPUT input) : COLOR0
{

	const int numSamples = 20;
	const float density  = amount;
	const float weight   = 0.1;
	
	float2 texCoord   = input.texCoord;

	float depth = tex2D(depthTextureSampler,texCoord).r;

	float4 result = float4(0, 0, 0, 1);
	
	float2 screenLightPos = float2(0.5, 0.5);
	float2 deltaTexCoord = texCoord - screenLightPos;
	
	float positionWeight = length(deltaTexCoord) * 0.5;
	
	if (positionWeight < 0)
	{
		positionWeight *= -1;
	}
	
	deltaTexCoord *= density / numSamples;

	for (int i = 0; i < numSamples; ++i)
	{
		texCoord -= deltaTexCoord;
		
		float4 sample = tex2D(baseTextureSampler, texCoord);
		
		sample *= weight * positionWeight;
		result += sample;
		
	}
	
	float4 base = tex2D(inputTextureSampler, input.texCoord);

	return base + result * amount;
	
}

technique DownSample
{
    pass p0
    {
		ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 DownSampleBoxPS();
        CullMode            = None;
    }
}

technique SFXShadowStep
{
    pass p0
    {
		ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 SFXShadowStepPS();
        CullMode            = None;
    }
}