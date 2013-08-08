#include "ReadDeferred.fxh"

texture     inputTexture;
texture     inputTexture1;
texture     inputTexture2;

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
	
sampler inputTextureSampler1 = sampler_state
    {
        texture       = (inputTexture1);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Linear;
		SRGBTexture   = False;
    };	

sampler inputTextureSampler2 = sampler_state
    {
        texture       = (inputTexture2);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Linear;
		SRGBTexture   = False;
    };	

float4 BloomCurvePS(PS_DeferredPass_Input input) : COLOR0
{
	
	float4 src = tex2D( inputTextureSampler, input.texCoord);
	
	// Use a piecewise curve to reduce the intensity of lower values
	// and boost the intensity of high values.
	
	float lowPoint   = 2.0;
	float lowFactor  = 0.25;
	float highFactor = 1.5;
	float c = lowPoint * (lowFactor - highFactor);

	float intensity = dot(src, 0.33f);
	float bloomIntensity = max(intensity * lowFactor, intensity * highFactor + c);
	
	float exposure = 1.0f / 6.0f;
	
	return (src * bloomIntensity / intensity) * exposure;
	
}
 
float4 DownSamplePS(PS_DeferredPass_Input input) : COLOR0
{
	return tex2D( inputTextureSampler, input.texCoord );
 }

float4 CompositePS(PS_DeferredPass_Input input) : COLOR0
{
	return tex2D( inputTextureSampler1, input.texCoord) + tex2D( inputTextureSampler2, input.texCoord);
}

float4 FinalCompositePS(PS_DeferredPass_Input input) : COLOR0
{
	return tex2D(inputTextureSampler1,  input.texCoord) +
		   tex2D( inputTextureSampler2, input.texCoord);
}

technique BloomCurve
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 BloomCurvePS();
        CullMode            = None;
    }
}

technique DownSample
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 DownSamplePS();
        CullMode            = None;
    }
}

technique Composite
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 CompositePS();
        CullMode            = None;
    }
}

technique FinalComposite
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 FinalCompositePS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
    }
}