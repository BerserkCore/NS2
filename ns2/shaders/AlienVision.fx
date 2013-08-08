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
texture		depthTexture;
float		time;
float		startTime;
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
    output.color      = input.color;

    return output;

}

float4 SFXAlienVisionPS(PS_INPUT input) : COLOR0
{

	// This is an exponent which is used to make the pulse front move faster when it gets
	// farther away from the viewer so that the effect doesn't take too long to complete.
	const float frontMovementPower 	= 1.9;
	const float frontSpeed			= 15.0;
	const float pulseWidth			= 20.0;

	float2 texCoord = input.texCoord;

	float2 depth1    = tex2D(depthTextureSampler, input.texCoord).rg;
	float4 inputPixel = tex2D(baseTextureSampler, input.texCoord);

	float highLight = max(0, (1-depth1.r * 0.04));
	
	const float offset = 0.001;
	float  depth2 = tex2D(depthTextureSampler, input.texCoord + float2( offset, 0)).r;
	float  depth3 = tex2D(depthTextureSampler, input.texCoord + float2(-offset, 0)).r;
	float  depth4 = tex2D(depthTextureSampler, input.texCoord + float2( 0,  offset)).r;
	float  depth5 = tex2D(depthTextureSampler, input.texCoord + float2( 0, -offset)).r;

	float4 edgeColor = float4(1, 0.5, 0, 0) * 0.5;	
	float edge = abs(depth2 - depth1.r) + 
				 abs(depth3 - depth1.r) + 
				 abs(depth4 - depth1.r) + 
				 abs(depth5 - depth1.r);
				 
	

	
	//return inputPixel * (1-depth1.g) +  inputPixel * depth1.g * (1-highLight) + (inputPixel * edgeColor * highLight + edge * edgeColor * highLight) * amount * depth1.g;
	return inputPixel + ( clamp(pow(edge, 2), 0, 1) * edgeColor * highLight) * amount * depth1.g;
	
	
}

technique SFXAlienVision
{
    pass p0
    {
		ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 SFXBasicVS();
        PixelShader         = compile ps_2_0 SFXAlienVisionPS();
        CullMode            = None;
    }
}