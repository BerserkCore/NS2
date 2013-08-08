//=============================================================================
//
// Refraction.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2013, Unknown Worlds Entertainment, Inc.
//
// This file contains shaders used during the deferred rendering process.
//
//=============================================================================

#include "ReadDeferred.fxh"

texture 	refractionTexture;
sampler 	refractionTextureSampler = sampler_state
	{
		texture       = (refractionTexture);
		AddressU      = Clamp;
		AddressV      = Clamp;
		MinFilter     = Linear;
		MagFilter     = Linear;
		MipFilter     = Point;
		SRGBTexture   = False;
	};
	

float4 VisualizeRefractionPS(PS_DeferredPass_Input input) : COLOR0
{
	return tex2D( refractionTextureSampler, input.texCoord ).aaaa;
}

float4 RefractionMaskClearPS(PS_DeferredPass_Input input) : COLOR0
{
	return float4(0, 0, 0, 0);
}

technique VisualizeRefraction
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 VisualizeRefractionPS();
		CullMode			= None;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique RefractionMaskClear
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 RefractionMaskClearPS();
		CullMode			= None;
        ColorWriteEnable    = Alpha;
    }
}
