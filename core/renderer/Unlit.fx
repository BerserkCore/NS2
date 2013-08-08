//=============================================================================
//
// shaders/Unlit.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2012, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

#include "WriteDeferred.fxh"
#include "ReadDeferred.fxh"
#include "Constants.fxh"

float4 UnlitPS(PS_DeferredPass_Input input) : COLOR0
{
	return tex2D( albedoTextureSampler, input.texCoord );
}

technique Unlit
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 UnlitPS();
        CullMode            = None;
    }
}