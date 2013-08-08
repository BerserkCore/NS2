//=============================================================================
//
// Atmospherics.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2008-2012, Unknown Worlds Entertainment, Inc.
//
// This file contains shaders used during the deferred rendering process.
//
//=============================================================================

#include "ReadDeferred.fxh"

struct VS_INPUT
{
    float3 ssPosition       : POSITION;
    float2 texCoord         : TEXCOORD0;
};

struct VS_OUTPUT
{
    half4 ssPosition       : POSITION;
    half2 texCoord         : TEXCOORD1;
};

struct PS_INPUT
{
    half2 projected        : TEXCOORD0;
    half2 texCoord         : TEXCOORD1;
};  

struct PS_ResizeDepth_Output
{
    half4 color            : COLOR0;
    half  depth            : DEPTH;
};

float _nearPlane;
float _farPlane;


struct VS_Blur_Output
{
    float4 ssPosition       : POSITION;
    float2 tap0             : TEXCOORD0;
    float2 tap12            : TEXCOORD1;
    float2 tap34            : TEXCOORD2;
    float2 tapMinus12       : TEXCOORD3;
    float2 tapMinus34       : TEXCOORD4;    
};

struct PS_Blur_Input
{
    float2 tap0             : TEXCOORD0;
    float2 tap12            : TEXCOORD1;
    float2 tap34            : TEXCOORD2;
    float2 tapMinus12       : TEXCOORD3;
    float2 tapMinus34       : TEXCOORD4;
};

float       blurWeight0  = 0.368763316;     // Weight for filter tap 0.
float       blurWeight12 = 0.223666191;     // Weight for filter taps 1 and 2 (combined).
float       blurWeight34 = 0.091952150;		// Weight for filter taps 3 and 4 (combined).

texture     srcTexture;
texture     blendTexture;

sampler srcSampler = sampler_state
    {
        texture       = (srcTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Linear;
    };

sampler blendTextureSampler = sampler_state
    {
        texture       = (blendTexture);
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
VS_OUTPUT BasicScreenVS(VS_INPUT input)
{

    VS_OUTPUT output;

    output.ssPosition   = float4(input.ssPosition, 1);
    output.texCoord     = input.texCoord;

    return output;

}

/**
 * Outputs the depth value from a texture into the z-buffer.
 */
PS_ResizeDepth_Output ResizeDepthPS(PS_DeferredPass_Input input)
{

    PS_ResizeDepth_Output result;
	
	float w = tex2D(depthTextureSampler, input.texCoord).r;
	float q = _farPlane / (_farPlane - _nearPlane);
	float z = q * w - q * _nearPlane;
	
    result.color = half4(0, 0, 0, 1);
    result.depth = z / w; 

    return result;
    
}	
	
VS_Blur_Output Blur(VS_INPUT input, float2 tapOffset)
{

    VS_Blur_Output output;

    output.ssPosition  = float4(input.ssPosition, 1);
    output.tap0        = input.texCoord;
    output.tap12       = input.texCoord + tapOffset * 1.5;
    output.tap34       = input.texCoord + tapOffset * 2.5;
    output.tapMinus12  = input.texCoord - tapOffset * 1.5;
    output.tapMinus34  = input.texCoord - tapOffset * 2.5;

    return output;

}

VS_Blur_Output HBlurVS(VS_INPUT input)
{
	return Blur(input, float2(rcpFrame.x, 0));
}

VS_Blur_Output VBlurVS(VS_INPUT input)
{
	return Blur(input, float2(0, rcpFrame.y));
}

float4 BlurPS( PS_Blur_Input input ) : COLOR0
{
    
    float4 result;
    
    result  = tex2D( srcSampler, input.tap0 ) * blurWeight0;
    result += (tex2D( srcSampler, input.tap12 ) + tex2D( srcSampler, input.tapMinus12 )) * blurWeight12;
    result += (tex2D( srcSampler, input.tap34 ) + tex2D( srcSampler, input.tapMinus34 )) * blurWeight34;
    
    return result;

}

half4 BlendPS(PS_DeferredPass_Input input) : COLOR0
{
    return tex2D(blendTextureSampler, input.texCoord);
}

technique Blend
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 BlendPS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
    }
}

technique HBlur
{
    pass p0
    {
        ZEnable             = False;
        VertexShader        = compile vs_2_0 HBlurVS();
        PixelShader	        = compile ps_2_0 BlurPS();
        CullMode            = None;
    }
}

technique VBlur
{
    pass p0
    {
        ZEnable             = False;
        VertexShader        = compile vs_2_0 VBlurVS();
        PixelShader	        = compile ps_2_0 BlurPS();
        CullMode            = None;
    }
}

technique ResizeDepth
{
    pass p0
    {
        ZFunc               = Always;
        VertexShader        = compile vs_2_0 BasicScreenVS();
        PixelShader         = compile ps_2_0 ResizeDepthPS();
        CullMode            = None;
        ColorWriteEnable    = 0;
    }
}