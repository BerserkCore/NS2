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
float		amount;

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

float4 DistortPS(PS_INPUT input) : COLOR0
{
	
	float2 t = input.texCoord;
	
	t.x = (input.texCoord.x - 0.5) * 2;
	t.y = (input.texCoord.y - 0.5) * 2;
	
    float q = atan2(t.y, t.x);
	float r = sqrt(t.x * t.x + t.y * t.y);
	
	r = lerp(r, cos(r * 3.14159265) * 0.5 + 0.5, amount * 0.15);
	
	t.x = cos(q) * r;
	t.y = sin(q) * r;
	
	t.x = t.x / 2  + 0.5;
	t.y = t.y / 2  + 0.5;
	
	float4 result = tex2D( inputTextureSampler, t );
	return result;
	
}

float4 SFXFadeBlinkPS(PS_INPUT input) : COLOR0
{

	const int numSamples = 16;
	const float density  = 0.1;
	const float weight   = 1.0;
	const float decay	 = 0.95;
	
	float2 texCoord   = input.texCoord;

	float4 result = tex2D(inputTextureSampler, texCoord);
	
	float2 screenLightPos = float2(0.5, 0.5);
	float2 deltaTexCoord = texCoord - screenLightPos;
	
	deltaTexCoord *= clamp(amount, 0, 1) * density / numSamples;
	
	float illuminationDecay = 2.0f;
	
	for (int i = 1; i < numSamples; ++i)
	{
		texCoord -= deltaTexCoord;
		
		float4 sample = tex2D(inputTextureSampler, texCoord);
		
		sample *= illuminationDecay * weight;
		result += sample * clamp(amount, 0, 1);
		
		illuminationDecay *= decay;
		
	}

	return result;	
	
}

technique Distort
{
    pass p0
    {
		ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 DistortPS();
        CullMode            = None;
    }
}

technique Blur
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