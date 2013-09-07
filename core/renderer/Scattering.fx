//=============================================================================
//
// Scattering.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2008-2012, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

#include "ReadDeferred.fxh"
#include "Lighting.fxh"

struct VS_INPUT
{
    float3 osPosition       : POSITION;
    float2 texCoord         : TEXCOORD0;
};

struct VS_Scattering_OUTPUT
{
    half4 ssPosition       : POSITION;
    half3 vsPosition       : TEXCOORD0;
};

struct PS_Scattering_INPUT
{
    half3 vsPosition       : TEXCOORD0;
};

float4x4    objectToWorldMatrix;
float4x4    worldToScreenMatrix;
float4x4    worldToCameraMatrix;
float4x4 	cameraToWorldMatrix;

float2		atmosphericsScale;
float       atmosphereDensity;

/**
 * Vertex shader for rendering atmospheric scattering effects for a light.
 */
VS_Scattering_OUTPUT ScatteringVS(VS_INPUT input)
{

    VS_Scattering_OUTPUT output;
	
	half z = atmosphericsScale.x * input.osPosition.z + atmosphericsScale.y;
	half3 osPosition;

	osPosition.xy = input.osPosition.xy * z * imagePlaneSize;
	osPosition.z  = z;
    
    half4 wsPosition = mul(half4(osPosition, 1.0), objectToWorldMatrix);
    half4 vsPosition = mul(wsPosition, worldToCameraMatrix);
    half4 ssPosition = mul(wsPosition, worldToScreenMatrix);

    output.ssPosition  = ssPosition;
    output.vsPosition  = vsPosition.xyz;

    return output;

}

half4 PointLightScatteringPS(uniform bool shadows, PS_Scattering_INPUT input) : COLOR0
{
    
    half3 l = vsLightPosition - input.vsPosition;
    half  d = length(l);
    l = l / d;
	    
    half attenuation = saturate((dot(l, vsLightDirection) - outerCone ) / (innerCone - outerCone));
	attenuation *= GetDistanceAttenuation(d);
	
    half4 smPosition = mul(half4(input.vsPosition, 1), viewToShadowMatrix);
    
    half shadow = 1;
	if (shadows)
	{	
		shadow = (1 - GetShadowFast(smPosition) * shadowFade);
	}

	return (attenuation * shadow * atmosphereDensity) * lightColor;
    
}

technique PointLightScattering[Shadows]
{
    pass p0
    {
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 ScatteringVS();
        PixelShader         = compile ps_2_0 PointLightScatteringPS(Shadows);
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
    }
}
