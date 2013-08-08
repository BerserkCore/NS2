//=============================================================================
//
// ReadDeferred.fxh
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
//
// This file contains shader code used to read the G-buffer during deferred
// rendering.
//
//=============================================================================

struct VS_DeferredPass_Input
{
    float3 osPosition       : POSITION;
    float2 texCoord         : TEXCOORD0;
};

struct VS_DeferredPass_Output
{
    float4 ssPosition       : POSITION;
    float2 projected        : TEXCOORD0;
    float2 texCoord         : TEXCOORD1;
};

struct PS_DeferredPass_Input
{
    half2 projected        : TEXCOORD0;
    half2 texCoord         : TEXCOORD1;
};  

texture     depthTexture;        	// G-buffer component.
texture		normalTexture;			// G-buffer component.
texture     albedoTexture;        	// G-buffer component.
texture     specularGlossTexture;   // G-buffer component.

float2      imagePlaneSize;
float2 		rcpFrame;				// 1/xSize, 1/ySize
float4 		rcpFrameOpt;

sampler albedoTextureSampler = sampler_state
    {
        texture       = (albedoTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Point;
        MagFilter     = Point;
        MipFilter     = None;
		SRGBTexture   = True;				
    };	

sampler specularGlossTextureSampler = sampler_state
    {
        texture       = (specularGlossTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Point;
        MagFilter     = Point;
        MipFilter     = None;
		SRGBTexture   = True;				
    };		
	
sampler depthTextureSampler = sampler_state
    {
        texture       = (depthTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Point;
        MagFilter     = Point;
        MipFilter     = None;
		SRGBTexture   = False;
    };			

// Used for AO to remove artifacts for distant glancing angles
sampler linearDepthTextureSampler = sampler_state
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
        MinFilter     = Point;
        MagFilter     = Point;
        MipFilter     = None;
		SRGBTexture   = False;
    };			

/**
 * Extracts the view-space normal from the G-buffer.
 */
half3 GetNormal(half2 texCoord)
{
	half3 G = tex2D(normalTextureSampler, texCoord).xyz;
	return G * 2.0 - 1.0;
}

/**
 * Returns the object ID for a pixel.
 */
half GetId(half2 texCoord)
{
	return tex2D(depthTextureSampler, texCoord).g;
}

/**
 * Extracts the view-space position from the G-buffer.
 */
half3 GetPosition(half2 texCoord, half2 ssPosition)
{

	half depth = tex2D(depthTextureSampler, texCoord).r;
	half3 vsPosition;
    
    vsPosition.z   = depth.r;
    vsPosition.xy = ssPosition * vsPosition.z;
    
    return vsPosition;
	
}	

/**
 * Vertex shader that can be used with a screen space deferred rendering pass.
 */  
VS_DeferredPass_Output DeferredPassVS(VS_DeferredPass_Input input)
{

    VS_DeferredPass_Output output;
    
    float4 ssPosition = float4(input.osPosition, 1);

	// Offset by 1/2 a pixel to account for D3D texture sampling.
	ssPosition.x -= rcpFrame.x;
	ssPosition.y += rcpFrame.y;
	
    output.ssPosition   = ssPosition;
    output.projected    = ssPosition;
    output.projected.y  = -output.projected.y;
	
	output.projected    = output.projected * -imagePlaneSize;
	
    output.texCoord     = input.texCoord;

    return output;

}
