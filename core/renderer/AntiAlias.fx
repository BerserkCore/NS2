//=============================================================================
//
// shaders/AntiAlias.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2008-2012, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

#include "WriteDeferred.fxh"
#include "ReadDeferred.fxh"
#include "Constants.fxh"

#include "Fxaa3_8.h"

struct VS_AntiAlias_INPUT
{
    half3 ssPosition        : POSITION;
	half2 texCoord			: TEXCOORD0;
};

struct VS_AntiAlias_OUTPUT
{
    half4 ssPosition       : POSITION;
    half2 pos              : TEXCOORD0;
	half4 posPos		   : TEXCOORD1;
};

struct PS_AntiAlias_INPUT
{
    half2 pos              : TEXCOORD0;
	half4 posPos		   : TEXCOORD1;
};


texture	antiAliasInputTexture;

sampler antiAliasInputTextureSampler = sampler_state
	{
        texture       = (antiAliasInputTexture);
		MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = None;
        AddressU      = Clamp;
        AddressV      = Clamp;
		SRGBTexture   = False;	
	};
	
VS_AntiAlias_OUTPUT AntiAliasVS(VS_AntiAlias_INPUT input)
{

    VS_AntiAlias_OUTPUT output;

    float4 ssPosition = half4(input.ssPosition, 1);

	// Offset by 1/2 a pixel to account for D3D texture sampling.
	ssPosition.x -= rcpFrame.x;
	ssPosition.y += rcpFrame.y;
	
	output.ssPosition   = ssPosition;
    output.pos    		= input.texCoord;
	output.posPos.xy 	= input.texCoord - rcpFrameOpt.zw;
	output.posPos.zw 	= input.texCoord + rcpFrameOpt.zw;

    return output;

}

float4 AntiAliasPS(PS_AntiAlias_INPUT input) : COLOR0
{	
	return FxaaPixelShader(input.pos, input.posPos, antiAliasInputTextureSampler, rcpFrame, rcpFrameOpt);
}

technique AntiAlias
{
    pass p0
    {
        ZEnable             = False;
        VertexShader        = compile vs_3_0 AntiAliasVS();
        PixelShader         = compile ps_3_0 AntiAliasPS();
        CullMode            = None;
    }
}
