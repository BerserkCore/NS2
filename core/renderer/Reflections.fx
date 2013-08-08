//=============================================================================
//
// shaders/Reflections.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2012, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

#include "WriteDeferred.fxh"
#include "ReadDeferred.fxh"
#include "Constants.fxh"

float4x4 cameraToScreenMatrix : PROJECTION;

texture lightingTexture;
	
sampler lightingTextureSampler = sampler_state
    {
        texture       = (lightingTexture);
        AddressU      = Border;
        AddressV      = Border;
		BorderColor	  = 0;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = None;
		SRGBTexture   = False;
    };

float4 Reflections3PS(PS_DeferredPass_Input input) : COLOR0
{

	float3 vsNormal      = GetNormal( input.texCoord );
	float3 vsPosition    = GetPosition( input.texCoord, input.projected.xy );

	// Compute the view space reflection direction.
	float3 vsView = normalize(vsPosition);
	float3 vsReflect = reflect(vsView, vsNormal);
	
	int numSteps = 32;
	
	float3 step = vsReflect * 0.2;
	
	float3 vsTestPosition = vsPosition;
	
	const float maxDepthDelta = 0.5;
	
	[unroll]
	for (int i = 0; i < numSteps; ++i)
	{
	
		vsTestPosition += step;
		
		// Transform the point from view space to screen space.
		half4 ssPosition = mul(half4(vsTestPosition, 1), cameraToScreenMatrix);
		ssPosition.xyz /= ssPosition.w;
		
		// Get the screen space texture coordinates.
		
		half2 texCoord;
		texCoord.x = ssPosition.x * 0.5 + 0.5;
		texCoord.y = 1.0 - (ssPosition.y * 0.5 + 0.5);
		
		float depth = tex2D(depthTextureSampler, texCoord);

		float depthDelta = vsTestPosition.z - depth;
		if (depthDelta > 0 && depthDelta < maxDepthDelta)
		{
			float atten = (1 - (float)i / numSteps) * pow((1 - depthDelta/ maxDepthDelta), 0.5);
			return tex2D(lightingTextureSampler, texCoord) * atten;
		}
		
	}
	
	return float4(0 ,0, 0, 0);

}

float4 ReflectionsPS(PS_DeferredPass_Input input) : COLOR0
{

	float3 vsNormal      = GetNormal( input.texCoord );
	float3 vsPosition    = GetPosition( input.texCoord, input.projected.xy );

	// Compute the view space reflection direction.
	float3 vsView = normalize(vsPosition);
	float3 vsReflect = reflect(vsView, vsNormal);
	
	// Compute the screen space reflection direction.
	float4 ssPosition = mul(float4(vsPosition , 1), cameraToScreenMatrix);
	ssPosition.xyz /= ssPosition.w;
	
	/*
	float4 ssReflectPos = mul(float4(vsPosition + vsReflect, 1), cameraToScreenMatrix);
	ssReflectPos.xyz /= ssReflectPos.w;
	
	float3 ssReflect = normalize(ssReflectPos - ssPosition);
	*/
	
	ssPosition.z = vsPosition.z;
	
	float3 ssReflect = vsReflect;
	
	int numSteps = 32;
	
	float l = length(ssReflect.xy);
	ssReflect = numSteps * ssReflect * rcpFrame.x / l;
	
	const float maxDepthDelta = 0.5;
	
	[unroll]
	for (int i = 0; i < numSteps; ++i)
	{
	
		ssPosition.xyz += ssReflect.xyz;
	
		// Get the screen space texture coordinates.
		
		half2 texCoord;
		texCoord.x = ssPosition.x * 0.5 + 0.5;
		texCoord.y = 1.0 - (ssPosition.y * 0.5 + 0.5);
		
		float depth = tex2D(depthTextureSampler, texCoord);
		
		float depthDelta = ssPosition.z - depth;
		if (depthDelta > 0 && depthDelta < maxDepthDelta)
		{
			//float atten = (1 - (float)i / numSteps) * pow((1 - depthDelta/ maxDepthDelta), 0.5);
			return tex2D(lightingTextureSampler, texCoord);
		}
		
	}
	
	return float4(0, 0, 0, 0);

}

float4 ReflectionsCombinePS(PS_DeferredPass_Input input) : COLOR0
{
	return tex2D(lightingTextureSampler, input.texCoord) * 0.5;
}

technique Reflections
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 Reflections3PS();
        CullMode            = None;
    }
}

technique ReflectionsCombine
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 ReflectionsCombinePS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
    }
}