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

float4 SFXFadeBlinkPS(PS_INPUT input) : COLOR0
{

	const int numSamples = 16;
	const float density  = 0.1;
	const float weight   = 1.0;
	const float decay	 = 0.95;
	
	float2 texCoord   = input.texCoord;

	float4 result = float4(0, 0, 0, 1);
	
	float2 screenLightPos = float2(0.5, 0.5);
	float2 deltaTexCoord = texCoord - screenLightPos;
	
	deltaTexCoord *= density / numSamples;
	
	float illuminationDecay = 1.0f;
	
	for (int i = 0; i < numSamples; ++i)
	{
		texCoord -= deltaTexCoord;
		
		float4 sample = tex2D(baseTextureSampler, texCoord);
		
		sample *= illuminationDecay * weight;
		result += sample;
		
		illuminationDecay *= decay;
		
	}
	
	float4 base = tex2D(inputTextureSampler, input.texCoord);
	
	float4 color = base + result;
	
	// Tint everything and blend over the original.
	const float4 tint = float4(0.05, 0.25, 0.5, 1);
	float intensity = color.r * 0.2126f + color.g * 0.7152f + color.b * 0.0722f;
	return lerp(base, intensity * tint, 0.8);
	
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

technique SFXFadeBlink
{
    pass p0
    {
		ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 SFXFadeBlinkPS();
        CullMode            = None;
    }
}