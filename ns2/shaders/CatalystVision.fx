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

texture      depthTexture;	
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

texture      normalTexture;
sampler normalTextureSampler = sampler_state
   {
       texture       = (normalTexture);
       AddressU      = Clamp;
       AddressV      = Clamp;
       MinFilter     = Linear;
       MagFilter     = Linear;
       MipFilter     = Linear;
       SRGBTexture   = False;
   };
	
VS_OUTPUT CatalystVisionVS(VS_INPUT input)
{
	 VS_OUTPUT output;

    output.ssPosition = float4(input.ssPosition, 1);
    output.texCoord   = input.texCoord;
	
	return output;
}

float4 CatalystVisionPS(PS_INPUT input) : COLOR
{
	float2 texCoord = input.texCoord;
	float4 inputPixel = tex2D(baseTextureSampler, texCoord);
	const float4 flashColor = float4(0, 0.2, 1, 1) * 0.3;
	float2 depth = tex2D(depthTextureSampler, texCoord).rg;
	
	float2 screenCenter = float2(0.5, 0.5);
	float darkened = clamp(length(texCoord - screenCenter) - 0.3, 0, 1);
	
	float flash = pow(max(0, amount - 0.8) / 0.2, 2);
	float3 normal = tex2D(normalTextureSampler, texCoord).xyz;
	float intensity = pow((abs(normal.z - 0.5) + abs(normal.y - 0.5) + abs(normal.x - 0.5)) * 1.4, 8) * 0.5;

	return inputPixel + inputPixel * amount * depth.g * 20 + inputPixel * amount * 2 + intensity * amount * clamp(darkened, 0, 1) * flashColor * 4 + flash * intensity * flashColor * 0.5;
}

technique CatalystVision
{
	pass
	{
		VertexShader = compile vs_2_0 CatalystVisionVS();
		PixelShader = compile ps_2_0 CatalystVisionPS();
	}
}