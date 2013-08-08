//=============================================================================
//
// shaders/AmbientOcclusion.fx
//
// Created by Max McGuire (max@unknownworlds.com), Steven An (steve@unknownworlds.com)
// Copyright (c) 2008-2012, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

#include "WriteDeferred.fxh"
#include "ReadDeferred.fxh"
#include "Constants.fxh"

float4x4 cameraToScreenMatrix : PROJECTION;

texture noiseTexture;
texture lightingTexture;

sampler noiseTextureSampler = sampler_state
    {
        texture       = (noiseTexture);
        AddressU      = Wrap;
        AddressV      = Wrap;
        MinFilter     = Point;
        MagFilter     = Point;
        MipFilter     = Point;
		SRGBTexture   = False;
    };
	
sampler lightingTextureSampler = sampler_state
    {
        texture       = (lightingTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Point;
        MagFilter     = Point;
        MipFilter     = None;
		SRGBTexture   = False;
    };

float4 ResizeDepthPS( PS_DeferredPass_Input input ) : COLOR0
{
    float depth = tex2D(linearDepthTextureSampler, input.texCoord).r;

    return depth;
}
	
float ComputeAccessibility(float radius, float3 vsPosition, float3 vsNormal, float2 texCoord, float2 reflectDir)
{

	// This shader approximates ambient occlusion by computing the volumetric obscurance
	// inside of a sphere using line integrals.

	const float3 samplePoint[] =
		{
		/*
			float3(-0.128007, -0.022282, 0.063852),
			float3(0.266115, -0.615093, 0.168435),
			float3(-0.498448, 0.456597, 0.171426),
			float3(0.663330, -0.199423, 0.180761),
			float3(-0.268535, -0.618153, 0.170431),
			float3(0.128917, 0.023755, 0.063945),
			float3(-0.676788, -0.147004, 0.180684),
			float3(0.521937, 0.453405, 0.180015),
			float3(-0.004151, 0.668710, 0.167703),
			*/

			/*			
			float3( 0.092879, 0.622234, 0.224708),
			float3( 0.291372, -0.557373, 0.224565),
			float3(-0.563022, 0.280211, 0.224611),
			float3( 0.620264, 0.104644, 0.224637),
			float3(-0.439968, -0.450128, 0.224867),
			float3( 0.000000, 0.000000, 0.083359),			
			*/
			
			float3(0.212294, 0.556074, 0.176448),
			float3(0.375838, -0.461999, 0.176583),
			float3(-0.375808, 0.461919, 0.176594),
			float3(0.587555, 0.094700, 0.176406),
			float3(-0.212297, -0.556029, 0.176472),
			float3(-0.587562, -0.094711, 0.176448),
			float3(0.000000, 0.000000, 0.071435),			
			
		};
	
	const int   numSamples 	= 7;
	const float thickness   = 0.5;
		
	float accessibility = 0.0;
	float scale = radius / vsPosition.z; // Account for perspective.
	
	for (int i = 0; i < numSamples - 1; ++i)
	{
	
		float2 s  = reflect(samplePoint[i].xy, reflectDir);
		float2 t  = texCoord + s * scale;
		
		float zs = radius * sqrt(1 - dot(s, s));
		float dr = tex2D(linearDepthTextureSampler, t).r - vsPosition.z;
		
		float zMin = -zs;
		float zMax =  zs;
		
		// Compute intersection with the plane that the normal defines.
		zMax = clamp( dot(s, vsNormal.xy) / vsNormal.z, zMin, zMax );
		
		float weight = samplePoint[i].z;
	
		float frontIntegral = clamp(dr, zMin, zMax) - zMin;
		float backIntegral = zMax - clamp(dr + thickness, zMin, zMax);
		
		accessibility += (frontIntegral + backIntegral) * weight;
	
	}
	
	// The sample weights don't take into account the radius, so normalize by it.
	accessibility /= radius;
	
	// The final sample point is always going to have an accessibility of 1
	// since it's in the center.
	accessibility += samplePoint[numSamples - 1].z;
	
	return accessibility;
	
}

float4 AmbientOcclusion2PS(PS_DeferredPass_Input input) : COLOR0
{
	
	const float radius1     = 0.1;
	const float radius2 	= 0.5;
	const float contrast	= 2.0;
	const float brightness	= 0.2;
	
	float3 vsPosition = GetPosition( input.texCoord, input.projected );
	float3 vsNormal   = GetNormal( input.texCoord );
	
	// The actual view space normal can have a negative z value which causes
	// problems for our orthographic projection assumption. So we compute an
	// approximate normal.
	vsNormal.z = -sqrt(1 - dot(vsNormal.xy, vsNormal.xy));

	float2 reflectDir = tex2D( noiseTextureSampler, (input.texCoord / rcpFrame) / 64 ).xy * 2 - 1;

	float accessibility1 = ComputeAccessibility(radius1, vsPosition, vsNormal, input.texCoord, reflectDir.xy);
	float accessibility2 = ComputeAccessibility(radius2, vsPosition, vsNormal, input.texCoord, reflectDir.yx);

	float ao = pow(accessibility1 * accessibility2 + brightness, contrast);
	return clamp(ao, 0, 1).rrrr;
		
}

const float pi = 3.14159265359;

half4 AngleBasedAmbientOcclusionPS( PS_DeferredPass_Input input ) : COLOR0
{
	const int numSamplePairs = 6;	// If changing this, make sure vsSamplingOffsets has enough
	const float2 ssSampleOffsets[] = {
        //float2(1,0), float2(0,1),
#include "angleBasedAOSamples.txt"
	};

	// Get pixel info
	float depth = tex2D(linearDepthTextureSampler, input.texCoord).r;
	float3 vsNormal = GetNormal( input.texCoord );

	// Pick random reflecting angle, to de-correlate
	float2 reflectDir = tex2D( noiseTextureSampler, (input.texCoord / rcpFrame) / 64 ).xy * 2 - 1;

	const float ABAO_OffsetScale = 0.3;
	const float ABAO_MaxDepthDelta = 0.5;
    const int doMaxDepthCheck = 1;
    const int doNormalAngleClamp = 0;
    const int doRandomReflect = 1;

	float totalAccess = 0.0;
    float aspectRatio = imagePlaneSize.x / imagePlaneSize.y;

	for(int sampleIndex = 0; sampleIndex < numSamplePairs; sampleIndex++)
	{
		float2 ssOffset = ABAO_OffsetScale * ssSampleOffsets[sampleIndex];
        // scale by depth, so further away stuff samples smaller radius
        // effectively making it perspective-invariant
        ssOffset /= depth;

        if( doRandomReflect )
            ssOffset = reflect(ssOffset, reflectDir);

        float2 uvOffset = float2( ssOffset.x*0.5, -ssOffset.y*0.5 );

        // we need the 
        float vsOffsetLen = length(ssOffset)*imagePlaneSize.x*0.5;

		// Right side
        float rightDepth = tex2D( linearDepthTextureSampler, input.texCoord+uvOffset );
        float rightDiff = -(rightDepth - depth);

		if( doMaxDepthCheck && (rightDiff > ABAO_MaxDepthDelta) ) {
            totalAccess += 1.0;
            continue;
        }

		float rightAngle = atan2( rightDiff, vsOffsetLen*rightDepth );

		// Left side
        float leftDepth = tex2D( linearDepthTextureSampler, input.texCoord-uvOffset );
        float leftDiff = -(leftDepth - depth);

		if( doMaxDepthCheck && (leftDiff > ABAO_MaxDepthDelta) ) {
            totalAccess += 1.0;
            continue;
        }

		float leftAngle = atan2( leftDiff, -vsOffsetLen*leftDepth );
		if( leftAngle < 0 ) leftAngle += 2*pi;

        //if( doNormalAngleClamp ) {
            //float normalAngle = atan2( -vsNormal.z, dot(vsNormal.xy, vsOffsetDir) );
            //if( normalAngle < 0 ) normalAngle += 2*pi;
            //rightAngle = max(rightAngle, normalAngle-pi/2);
            //leftAngle = min(leftAngle, normalAngle+pi/2);
        //}

        float spanned = leftAngle - rightAngle;
        float access = clamp( spanned / pi, 0, 1 );

        totalAccess += access;
	}

	const float contrast = 5.0;
    float averageAccess = totalAccess/numSamplePairs;
	return half4( pow(averageAccess, contrast), depth, 1, 1 );
}

half4 ClassicAmbientOcclusionPS(PS_DeferredPass_Input input ) : COLOR0
{

	// Random offset vectors in view space.
	
	const float scale1 = 0.1;
	const float scale2 = 0.5;
	const float scale3 = scale2;
	
	const float3 vsOffset[] = 
		{
			scale1 * float3(0.216834, -0.155471, 0.737176),
			scale1 * float3(0.614390, 0.593342, 0.305865),
			scale1 * float3(0.341256, -0.130665, -0.430910),
			scale1 * float3(-0.695552, 0.676768, -0.003288),
			scale1 * float3(-0.646738, 0.108841, 0.274494),
			scale1 * float3(-0.137272, -0.051132, -0.834031),
			scale1 * float3(-0.458571, -0.582210, -0.282445),
			scale1 * float3(0.291524, 0.098360, 0.625109),
			scale3 * float3(0.449270, 0.125819, -0.271730),
			scale3 * float3(0.444767, 0.684562, 0.359083),
			scale3 * float3(0.901524, 0.187431, 0.068390),
			scale3 * float3(-0.327208, 0.341393, -0.208113),
			scale3 * float3(-0.068513, -0.681866, -0.134642),
			scale3 * float3(0.112915, 0.169422, -0.899765),
			scale3 * float3(-0.490614, -0.087411, 0.141822),
			scale3 * float3(0.491363, -0.468378, 0.027805),
			scale2 * float3(0.096059, -0.740497, 0.533002),
			scale2 * float3(-0.188382, -0.548510, 0.168959),
			scale2 * float3(-0.700401, 0.239835, 0.625689),
			scale2 * float3(-0.548623, 0.583280, 0.090429),
			scale2 * float3(0.183200, 0.722674, -0.351543),
			scale2 * float3(-0.021153, 0.266376, -0.642831),
			scale2 * float3(-0.220145, 0.447061, -0.506037),
			scale2 * float3(-0.521077, 0.101317, 0.809305),
			scale2 * float3(0.348732, 0.330636, 0.718369),
			scale2 * float3(0.829424, 0.063583, 0.511087),
			scale2 * float3(-0.118406, 0.784469, -0.285555),
			scale2 * float3(-0.215721, -0.393665, 0.337551),
			scale2 * float3(0.205934, 0.060879, 0.756306),
			scale2 * float3(-0.113787, 0.932464, -0.139139),
			scale2 * float3(-0.299005, -0.060880, 0.447123),
			scale2 * float3(-0.318876, 0.699613, 0.066440),
		};
		
	half3 reflectDir = tex2D( noiseTextureSampler, (input.texCoord / rcpFrame) / 64 ).xyz * 2 - 1;
	
	half3 vsPosition = GetPosition( input.texCoord, input.projected );
	half3 vsNormal   = GetNormal( input.texCoord );
	
	const int numSamples 			= 16;
	
	const float minO 				= 0.05;	// Minimum distance at which we register occlusion
	const float maxO 				= 0.5; 	// Maximum distance at which we register occlusion
	const float obscuranceFalloff 	= 0.01;	// Lower value gives darker creases
	const float contrast 			= 5.0;
	
	float obscurance = 0.0;

	for (int sampleIndex = 0; sampleIndex < numSamples; ++sampleIndex)
	{
		
		// To keep the samples in the hemisphere around the normal, flip any
		// offset vectors which outside the hemisphere.
		half3 offset = reflect( vsOffset[sampleIndex], reflectDir );
		if (dot(vsNormal, offset) < 0)
		{
			offset = -offset;
		}

        // limit how far apart samples can be to avoid slow down when up-close to walls
        const float OffsetClampDepth = 2.0;
        if( vsPosition.z < OffsetClampDepth )
            offset *= vsPosition.z / OffsetClampDepth;

		half3 vsTestPosition = vsPosition + offset;
		
		// Transform the point from view space to screen space.
		half4 ssPosition = mul(half4(vsTestPosition, 1), cameraToScreenMatrix);
		ssPosition.xyz /= ssPosition.w;

        // Need to un-compensate for the half-pixel offset
        ssPosition.x += rcpFrame.x;
        ssPosition.y -= rcpFrame.y;
		
		// Get the screen space texture coordinates.
		
		half2 texCoord;
		texCoord.x = ssPosition.x * 0.5 + 0.5;
		texCoord.y = 1.0 - (ssPosition.y * 0.5 + 0.5);

		half testDepth = tex2D(linearDepthTextureSampler, texCoord).r;

		float delta = vsTestPosition.z - testDepth;
		if (delta >= minO)
		{
			float d = 1 - min((delta - minO) / (maxO - minO), 1);
            obscurance += pow(d, obscuranceFalloff);
        }
	
	}

	float accessibility = 1 - (obscurance / (numSamples + 1));
	return half4( pow(accessibility.r, contrast), vsPosition.z, 0, 1);
}

float4 BilateralBlur(PS_DeferredPass_Input input, float2 step)
{

	const float weight[] =
		{
			0.101089,
			0.098128,
			0.089756,
			0.077359,
			0.062826,
			0.048079,
			0.034669,
			0.023556,
			0.015082,	
		};

	const float depthThreshold = 0.1;
	const float normalThreshold = 0.9;
	
	float4 sample = tex2D(lightingTextureSampler, input.texCoord);
	float  result   = sample.r * weight[0];
	float  depth    = sample.g;
	
	float  totalWeight = weight[0];	
	
	for (int i = 1; i < 9; ++i)
	{
		float2 offset = step * i;
		
		float2 texCoord1 = input.texCoord + offset;
		float2 texCoord2 = input.texCoord - offset;
		
		float4 sample1 = tex2D(lightingTextureSampler, texCoord1);
		float4 sample2 = tex2D(lightingTextureSampler, texCoord2);
		
		float depth1 = sample1.g;
		float depth2 = sample2.g;
		
		float w = weight[i];
		
		if (abs(depth1 - depth) < depthThreshold)
		{
			result += sample1.r * w;
			totalWeight += w;
		}
		
		if (abs(depth2 - depth) < depthThreshold)
		{
			result += sample2.r * w;
			totalWeight += w;
		}
	}
	
	return float4(result / totalWeight, depth, 0, 1);
		
}

float4 HBilateralBlurPS(PS_DeferredPass_Input input) : COLOR0
{
	return BilateralBlur(input, float2(rcpFrame.x, 0));
}

float4 VBilateralBlurPS(PS_DeferredPass_Input input) : COLOR0
{
	float ao = BilateralBlur(input, float2(0, rcpFrame.y)).r;
	return pow(ao.rrrr, 1.5);
}

float4 AmbientOcclusionCombinePS(PS_DeferredPass_Input input) : COLOR0
{
	return pow(tex2D(lightingTextureSampler, input.texCoord).rrrr, 1.5);
}

technique HBilateralBlur
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 HBilateralBlurPS();
        CullMode            = None;
    }
}

technique VBilateralBlur
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 VBilateralBlurPS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = Zero;
        DestBlend           = SrcColor;		
    }
}

// This uses the normal-weighted SSAO shader, since that doesn't impact performance as much on medium-res
technique ClassicAmbientOcclusion
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 ClassicAmbientOcclusionPS();
        CullMode            = None;
    }
}

technique ResizeDepth
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 ResizeDepthPS();
        CullMode            = None;
        //ColorWriteEnable    = 1;
    }
}

technique AngleBasedAmbientOcclusion
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 AngleBasedAmbientOcclusionPS();
        CullMode            = None;
    }
}

