//const float PI = 3.14159265359;

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

texture      baseTexture;
texture      depthTexture;
texture      normalTexture;
texture      albedoTexture;
float        time;
float        startTime;
float        amount;

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

float4 SFXDarkVisionPS(PS_INPUT input) : COLOR0
{

	const float4 color = float4(1, 0.4, 0.1, 0);
	const float4 edgeColor = float4(1, 0.15, 0, 0);

	float2 texCoord = input.texCoord;

	float4 normalColor = 0;
	float4 inputPixel = tex2D(baseTextureSampler, texCoord);
	float2 depth = tex2D(depthTextureSampler, texCoord).rg;
	float3 normal = tex2D(normalTextureSampler, texCoord).xyz;
	float intensity = pow((abs(normal.z - 0.5) + abs(normal.y - 0.5) + abs(normal.x - 0.5)) * 1.4, 8);
	float4 edge = 0;
	
	float2 screenCenter = float2(0.5 + cos(time) * 0.01, 0.5 + sin(time) * 0.01);
	float darkened = 1 - clamp(length(texCoord - screenCenter) - 0.3, 0, 1);
	darkened = pow(darkened, 17);

	normalColor = color * intensity * amount * darkened * 0.2;
	
	const float offset = 0.0005 + max(0, -depth.r * 0.005);
	float2  depth2 = tex2D(depthTextureSampler, texCoord + float2( offset, 0)).rg;
	float2  depth3 = tex2D(depthTextureSampler, texCoord + float2(-offset, 0)).rg;
	float2  depth4 = tex2D(depthTextureSampler, texCoord + float2( 0,  offset)).rg;
	float2  depth5 = tex2D(depthTextureSampler, texCoord + float2( 0, -offset)).rg;
	
	float brightness = 1;
	
	if (depth.g > 0.5) brightness = 0;

	if (depth.g > 0.5)
	{		


		edge = abs(depth2.r - depth.r) + 
			   abs(depth3.r - depth.r) + 
			   abs(depth4.r - depth.r) + 
			   abs(depth5.r - depth.r);
					 
		edge = min(1, pow(edge, 1)) * edgeColor * (1- amount);		
	}
	
	return inputPixel + normalColor * brightness + edge;
	
}

technique SFXDarkVision
{
    pass p0
    {
		ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 SFXDarkVisionPS();
        CullMode            = None;
    }
}
