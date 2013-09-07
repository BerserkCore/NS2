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
    float3 projected        : TEXCOORD0;
    float2 texCoord         : TEXCOORD1;
};

struct PS_DeferredPass_Input
{
    half3 projected        : TEXCOORD0;
    half2 texCoord         : TEXCOORD1;
};  

float2      imagePlaneSize;
float2 		rcpFrame;				// 1/xSize, 1/ySize
float4 		rcpFrameOpt;

sampler     depthTextureSampler             : register(s0);     // G-buffer component.
sampler		normalTextureSampler            : register(s1);     // G-buffer component.
sampler     albedoTextureSampler            : register(s2);     // G-buffer component.
sampler     specularGlossTextureSampler     : register(s3);     // G-buffer component.

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
half3 GetPosition(half2 texCoord, half3 projected)
{
	half depth = tex2D(depthTextureSampler, texCoord).r;
    return projected * depth;
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
    output.projected.x  = ssPosition.x;
    output.projected.y  = -ssPosition.y;
    output.projected.z  = 1;
    
	output.projected.xy *= -imagePlaneSize;
	
    output.texCoord     = input.texCoord;

    return output;

}
