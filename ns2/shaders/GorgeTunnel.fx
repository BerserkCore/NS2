float amount;
float time;

struct VS_INPUT
{
    float3 ssPosition   : POSITION;
    float2 texCoord     : TEXCOORD0;
};


struct VS_OUTPUT
{
	float4 ssPosition : POSITION0;
	float2 texCoord  : TEXCOORD0;
};

struct PS_INPUT
{
	float2 texCoord : TEXCOORD0;
	float4 noiseCoord : TEXCOORD1;
};

texture baseTexture;
sampler baseTextureSampler = sampler_state
    {
        texture       = (baseTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Linear;
		SRGBTexture   = False;
    };
	
texture noiseMap;
sampler noiseMapSampler = sampler_state
	{
		texture = (noiseMap);
		AddressU = Wrap;
		AddressV = Wrap;
		AddressW = Wrap;
		MinFilter = Linear;
		MagFilter = Linear;
		MipFilter = Linear;
		SRGBTexture   = False;
	};
	
VS_OUTPUT WaterVS(VS_INPUT input)
{
	 VS_OUTPUT output;

    output.ssPosition = float4(input.ssPosition, 1);
    output.texCoord   = input.texCoord;
	
	return output;
}

float WaterMap(float2 texCoord, float amount)
{

	float flowSpeed = 5;
	float t = time * 0.04;

	float4 noiseCoord;
	noiseCoord.xy = (texCoord * 0.5f) + float2(sin(t), -t * 2) * 0.5;
	noiseCoord.zw = texCoord - float2(0.0f, t * flowSpeed);

	float bump1 = tex2D(noiseMapSampler, noiseCoord.xy).r;
	float bump2 = tex2D(noiseMapSampler, noiseCoord.zw).r;
	float bump  = (bump1 + bump2) * amount; 
	
	const float minValue = 0.5;
	const float maxValue = 0.7;
	
	return pow(saturate((bump - minValue) / (maxValue - minValue)), 5);
	
}

float4 WaterPS(PS_INPUT input) : COLOR
{

	//float amount = 1 - pow(frac(time * 0.2), 0.7);

	float e = 0.002;

	float v0 = WaterMap(input.texCoord, amount);
	float vx = WaterMap(input.texCoord + float2(e, 0), amount);
	float vy = WaterMap(input.texCoord + float2(0, e), amount);
	
	// Built-in gradients would be faster, but creates blocky artifacts
	//float dx = ddx(v0);
	//float dy = ddy(v0);
	
	float dx = (vx - v0) / e;
	float dy = (vy - v0) / e;
	
	float t = time * 0.005;
	float2 distortCoord = (input.texCoord * 0.5f) + float2(sin(t), -t * 2);
	
	float2 offset = float2(dx, dy) * 0.001 ;
	float3 sample = tex2D(baseTextureSampler, input.texCoord + offset).rgb;
	
	float light = v0 * dy;
	float3 result = sample * lerp( float3(1, 1, 1), float3(0.8, 1, 0.1), v0);
	
	float cutoff = 15;
	if (light > cutoff)
	{
		result *= (light - cutoff) * 0.1;
	}
	
	return float4(result, 1);

}

technique Water
{
	pass
	{
		VertexShader = compile vs_3_0 WaterVS();
		PixelShader = compile ps_3_0 WaterPS();
	}
}