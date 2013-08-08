//=============================================================================
//
// shaders/Infestation.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2008-2012, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

#include "WriteDeferred.fxh"
#include "ReadDeferred.fxh"
#include "Constants.fxh"

struct PS_SplatDeferred_Output
{
    float4 albedo			        : COLOR0;
	float4 normal	        		: COLOR1;
	float4 specularGloss	        : COLOR2;
};


float4x4 cameraToScreenMatrix : PROJECTION;
float4x4 cameraToWorldMatrix : INVVIEW;
float4x4 worldToCameraMatrix : VIEW;

texture infestationTexture;
texture infestationNormalMap;
float   infestationTextureScale;

texture infestationMask;
texture fullResInfestationMask;
texture noiseTexture;

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

sampler infestationMaskSampler = sampler_state
    {
        texture       = (infestationMask);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Point;
        MagFilter     = Point;
        MipFilter     = None;
		SRGBTexture   = False;
    };
	
// Used for conservative mask down-sampling
sampler infestationMaskLinearSampler = sampler_state
    {
        texture       = (infestationMask);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = None;
		SRGBTexture   = False;
    };

sampler fullResInfestationMaskSampler = sampler_state
    {
        texture       = (fullResInfestationMask);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Point;
        MagFilter     = Point;
        MipFilter     = None;
		SRGBTexture   = False;
    };

sampler infestationMaskSamplerBlur = sampler_state
    {
        texture       = (infestationMask);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = None;
		SRGBTexture   = False;
    };	
	
sampler infestationTextureSampler = sampler_state
    {
        texture       = (infestationTexture);
        AddressU      = Wrap;
        AddressV      = Wrap;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Linear;
		SRGBTexture   = False;
    };
	
sampler infestationNormalMapSampler = sampler_state
    {
        texture       = (infestationNormalMap);
        AddressU      = Wrap;
        AddressV      = Wrap;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Linear;
		SRGBTexture   = False;
    };			
	
float4 InfestationMaskPS(PS_DeferredPass_Input input) : COLOR0
{

	const float scale1 = 0.5;
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
	

    float maskValue = tex2D(infestationMaskLinearSampler, input.texCoord).r;

	if (!maskValue)
	{
		discard;
	}
	
	float3 reflectDir = tex2D( noiseTextureSampler, (input.texCoord / rcpFrame) / 64 ).xyz * 2 - 1;
	
	float3 vsPosition = GetPosition( input.texCoord, input.projected.xy );
	float3 vsNormal   = GetNormal( input.texCoord );
	
	const int numSamples = 4;
	float3 vsSmoothNormal = vsNormal;

	for (int sampleIndex = 0; sampleIndex < numSamples; ++sampleIndex)
	{
		
		float3 offset = reflect( vsOffset[sampleIndex], reflectDir );
		float3 vsTestPosition = vsPosition + offset;
		
		// Transform the point from view space to screen space.
		float4 ssPosition = mul(float4(vsTestPosition, 1), cameraToScreenMatrix);
		ssPosition.xyz /= ssPosition.w;
		
		// Get the screen space texture coordinates.
		
		float2 texCoord;
		texCoord.x = ssPosition.x * 0.5 + 0.5;
		texCoord.y = 1.0 - (ssPosition.y * 0.5 + 0.5);

		float testDepth = tex2D(depthTextureSampler, texCoord).r;

		float delta = vsTestPosition.z - testDepth;
		vsSmoothNormal += GetNormal(texCoord) * step( abs(delta), 1 );
	
	}

	return float4( normalize(vsSmoothNormal.xyz), maskValue );
	
}

float3 TransformNormal(float3 tsNormal, float3 normal, float3 tangent, float3 binormal)
{
	return tsNormal.x * tangent + tsNormal.y * binormal + tsNormal.z * normal;	
}

/**
 * Writes the infestation into the G-buffer.
 */
PS_SplatDeferred_Output SplatPS(PS_DeferredPass_Input input)
{
	PS_SplatDeferred_Output output;
	
	float4 mask = tex2D(infestationMaskSampler, input.texCoord);

	float3 vsNormal  = mask.rgb;
	float3 vsPosition = GetPosition( input.texCoord, input.projected.xy );

	float3 wsNormal = mul(vsNormal, cameraToWorldMatrix);
	float3 wsPosition = mul(half4(vsPosition, 1), cameraToWorldMatrix);
	
	float3 tex1 = tex2D( infestationTextureSampler, wsPosition.yz * infestationTextureScale ).rgb;
	float3 tex2 = tex2D( infestationTextureSampler, wsPosition.xz * infestationTextureScale ).rgb;
	float3 tex3 = tex2D( infestationTextureSampler, wsPosition.yx * infestationTextureScale ).rgb;
	
	float3 blend = pow(wsNormal, 4);
	blend = blend / dot(blend, float3(1, 1, 1));
	
	float3 albedo = tex1 * blend.x + tex2 * blend.y + tex3 * blend.z;
				 		 
	float3 tsNormal1 = tex2D( infestationNormalMapSampler, wsPosition.yz * infestationTextureScale ).rgb * 2 - 1;
	float3 tsNormal2 = tex2D( infestationNormalMapSampler, wsPosition.xz * infestationTextureScale ).rgb * 2 - 1;
	float3 tsNormal3 = tex2D( infestationNormalMapSampler, wsPosition.yx * infestationTextureScale ).rgb * 2 - 1;
	
	// Transform from tangent space to world space.
	float3 s = sign(wsNormal);

	float3 wsNormal1 = TransformNormal(tsNormal1, wsNormal,
		float3(  wsNormal.y, wsNormal.x, -wsNormal.z) * s.x ,
		float3( -wsNormal.z, wsNormal.y,  wsNormal.x) * s.x );
		
	float3 wsNormal2 = TransformNormal(tsNormal2, wsNormal,
		float3( wsNormal.y, -wsNormal.x, wsNormal.z) * s.y,
		float3( wsNormal.x, -wsNormal.z, wsNormal.y) * s.y );

	float3 wsNormal3 = TransformNormal(tsNormal3, wsNormal,
		float3( wsNormal.x, wsNormal.z, wsNormal.y),
		float3( wsNormal.z, wsNormal.y, wsNormal.x) * s.z );
	
	// Blend the normals together.
	wsNormal = normalize(wsNormal1 * blend.x + wsNormal2 * blend.y + wsNormal3 * blend.z);
	
	// Transform the normal to view space.
	vsNormal = mul(wsNormal, worldToCameraMatrix);
		
	// Break up the solid color with a low detail color variation.
		
	float r = saturate(sin(wsPosition.x) + cos(wsPosition.z)) * 0.2 + 0.8;
	float3 tintColor = float3(1, r, r);

	
	float intensity = dot(albedo, float3(0.2126, 0.7152, 0.0722));
	
	const float3 specular = saturate(intensity.rrr + 0.25);
	
	// Compute a "splotchy" blending 
    const float blendRange = 0.2;
	float alphaMask = albedo.g / 0.65 + 0.05;
	float opacity   = mask.a * mask.a;
	float alpha     = saturate((alphaMask - 1 + opacity + blendRange) / (2 * blendRange));
	
    output.albedo        = float4( albedo * tintColor, alpha);
	output.specularGloss = float4( specular, alpha ); // can't write gloss, but since we want infestation to be shiny that's ok
	output.normal        = float4( ConvertNormal( vsNormal ).xyz, alpha );
	
	return output;

	
}

// Blurs the mask, using depth to prevent bleeding
float4 BilateralBlurMask(PS_DeferredPass_Input input, float2 stepSize)
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
	
	float4 sample0 = tex2D(infestationMaskSampler, input.texCoord);
    float  depth   = tex2D(depthTextureSampler, input.texCoord);
	float4 result  = sample0 * weight[0];

	float totalWeight = weight[0];	

    int numSteps = 4;

	for (int i = 1; i < numSteps; ++i)
	{
		float2 offset = stepSize * i;
		
		float2 texCoord1 = input.texCoord + offset;
		float2 texCoord2 = input.texCoord - offset;
		
        float4 sample1 = tex2D(infestationMaskSampler, texCoord1);
        float4 sample2 = tex2D(infestationMaskSampler, texCoord2);
		
        float depth1 = tex2D(depthTextureSampler, texCoord1);
        float depth2 = tex2D(depthTextureSampler, texCoord2);
		
		float w = weight[i];
		
		float factor1 = step( abs(depth1 - depth), depthThreshold ) * w;
		float factor2 = step( abs(depth2 - depth), depthThreshold ) * w;
	
		result += sample1 * factor1;
		result += sample2 * factor2;
		totalWeight += factor1 + factor2;
	
	}
	
	return float4( normalize(result.rgb), result.a / totalWeight );

}

float4 HBilateralBlurMaskPS(PS_DeferredPass_Input input) : COLOR0
{
    return BilateralBlurMask(input, float2(rcpFrame.x, 0));
}

float4 VBilateralBlurMaskPS(PS_DeferredPass_Input input) : COLOR0
{
    return BilateralBlurMask(input, float2(0, rcpFrame.y));
}


float4 VisualizeInfestationPS(PS_DeferredPass_Input input) : COLOR0
{
	float4 mask = tex2D( infestationMaskSampler, input.texCoord );
	return float4((mask.xyz * 0.5 + 0.5) * mask.a, 1);
}

technique VisualizeInfestation
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 VisualizeInfestationPS();
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique InfestationMaskSkirt
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 InfestationMaskPS();
        CullMode            = None;
    }
}

technique HBilateralBlurMask
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 HBilateralBlurMaskPS();
        CullMode            = None;
    }
}

technique VBilateralBlurMask
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 VBilateralBlurMaskPS();
        CullMode            = None;
    }
}

technique Splat
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 SplatPS();
        CullMode            = None;	
        AlphaBlendEnable    = True;
        SrcBlend            = SrcAlpha;
        DestBlend           = InvSrcAlpha;
        StencilEnable       = True;
        StencilFunc         = Equal;
		StencilRef			= 1;
	}
}
