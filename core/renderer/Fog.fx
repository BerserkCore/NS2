//=============================================================================
//
// Fog.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2008-2012, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

#include "ReadDeferred.fxh"

float       fogDepthScale;          // scale value for fog control.
float3      fogColor;               // color value for fog control.

/**
 * Computes distance fog.
 */
float4 FogPS(PS_DeferredPass_Input input) : COLOR0
{

	float depth = tex2D(depthTextureSampler, input.texCoord).r; 
	
	// Apply distance fog/atmospheric scattering.
	float fogAmount = 1 - saturate(exp(-depth * fogDepthScale));
	return float4(fogColor, fogAmount);

}

technique Fog
{
    pass p0
    {
        ZEnable             = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 FogPS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = SrcAlpha;
        DestBlend           = InvSrcAlpha;
    }
}