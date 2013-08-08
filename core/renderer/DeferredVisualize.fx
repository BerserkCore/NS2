//=============================================================================
//
// DeferredVisualize.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2008-2012, Unknown Worlds Entertainment, Inc.
//
// This file contains shaders used during the deferred rendering process.
//
//=============================================================================

#include "ReadDeferred.fxh"

float4x4 	cameraToWorldMatrix : INVVIEW;
float		maxDepth;

/**
 * Converts to gamma space.
 */
half3 Gamma(half3 color)
{
	return sqrt(color);
}

half4 VisualizeAlbedoPS(PS_DeferredPass_Input input) : COLOR0
{
	return half4( Gamma(tex2D(albedoTextureSampler, input.texCoord)), 1 );
}

half4 VisualizeGlossPS(PS_DeferredPass_Input input) : COLOR0
{
    return tex2D(specularGlossTextureSampler, input.texCoord).aaaa;
}

half4 VisualizeEmissivePS(PS_DeferredPass_Input input) : COLOR0
{
	return half4(0, 0, 0, 0);
}

half4 VisualizeNormalsPS(PS_DeferredPass_Input input) : COLOR0
{
    half3 vsNormal = GetNormal(input.texCoord);
	half3 wsNormal = mul(vsNormal, cameraToWorldMatrix);
    return half4((wsNormal + 1) * 0.5, 1);
}

half4 VisualizeSpecularPS(PS_DeferredPass_Input input) : COLOR0
{
	return tex2D(specularGlossTextureSampler, input.texCoord);
}

half4 VisualizeDepthPS(PS_DeferredPass_Input input) : COLOR0
{
	return tex2D(depthTextureSampler, input.texCoord).r / 100;
}

half4 VisualizeIdPS(PS_DeferredPass_Input input) : COLOR0
{
	return tex2D(depthTextureSampler, input.texCoord).g;
}

half4 VisualizeMaskPS(PS_DeferredPass_Input input) : COLOR0
{
	half mask = tex2D(depthTextureSampler, input.texCoord).r < maxDepth;
	return half4(mask, mask, mask, 1.0f);
}

technique VisualizeNormals
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 VisualizeNormalsPS();
		CullMode			= None;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique VisualizeSpecular
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 VisualizeSpecularPS();
		CullMode			= None;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique VisualizeAlbedo
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 VisualizeAlbedoPS();
		CullMode			= None;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique VisualizeGloss
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 VisualizeGlossPS();
		CullMode			= None;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique VisualizeEmissive
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 VisualizeEmissivePS();
		CullMode			= None;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique VisualizeDepth
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 VisualizeDepthPS();
		CullMode			= None;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique VisualizeId
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 VisualizeIdPS();
		CullMode			= None;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique VisualizeMask
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 VisualizeMaskPS();
		CullMode			= None;
        ColorWriteEnable    = Red | Green | Blue;
    }
}
