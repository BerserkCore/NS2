//=============================================================================
//
// RenderDeferred.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2008-2012, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

#include "WriteDeferred.fxh"
#include "ReadDeferred.fxh"
#include "Constants.fxh"

struct VS_LightVolume_INPUT
{
    half3 osPosition       : POSITION;
};

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

struct VS_Screen_OUTPUT
{
    half4 ssPosition       : POSITION;
    half2 texCoord         : TEXCOORD0;
    half4 projected        : TEXCOORD1;
    half4 color            : COLOR0;
};

float4x4    objectToWorldMatrix : WORLD;
float4x4    worldToScreenMatrix : VIEWPROJECTION;
float4x4    worldToCameraMatrix : VIEW;
float4x4 	cameraToWorldMatrix : INVVIEW;

float4x4	currentToPrevViewMatrix;

texture     lightingTexture;

float3      vsLightDirection;    // Only for spot and directional lights
float3      vsLightPosition;     // Only for spot light.

float       innerCone;           // Only for spot lights.
float       outerCone;           // Only for spot lights.

float3      lightColor;
float		lightRadius;
texture     lightGoboTexture;
float4x4	viewToGoboMatrix;

float3      alvColorRight;          // Only for ambient volume lights.
float3      alvColorLeft;           // Only for ambient volume lights.
float3      alvColorUp;             // Only for ambient volume lights.
float3      alvColorDown;           // Only for ambient volume lights.
float3      alvColorForward;        // Only for ambient volume lights.
float3      alvColorBackward;       // Only for ambient volume lights.
float4x4    viewToLightMatrix;
				   
float       fogDepthScale;          // scale value for fog control.
float3      fogColor;               // color value for fog control.

float		fadeOutDistance;

texture     shadowMap1;             // Shadow map containing static elements
texture     shadowMap2;             // Shadow map containing dynamic elements
float4x4    viewToShadowMatrix;
float4x4    viewToNoiseMatrix;
float       shadowFade;             // Use to smoothly fade out shadows. 0 if the shadows are completely faded out.

bool        enableStencil;          // Whether or not the stencil buffer should be used when drawing light passes.
int         stencilMask;
bool		reverseCulling;			// True when the camera is mirrored.

texture     noiseTexture;

float2		atmosphericsScale;
float       atmosphereDensity;

// Parameters for the reflections technique.

texture     environmentTexture;
float3		vsProbePosition;
float		probeRadius2;
float3		probeTint;

sampler noiseTextureSampler = sampler_state
    {
        texture       = (noiseTexture);
        AddressU      = Wrap;
        AddressV      = Wrap;
        MinFilter     = Linear;
        MagFilter     = Linear;
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

sampler shadowMap1SamplerLinear = sampler_state
    {
        texture       = (shadowMap1);
		MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = None;
        AddressU      = Clamp;
        AddressV      = Clamp;
		SRGBTexture   = False;
    };
	
sampler shadowMap1SamplerPoint = sampler_state
    {
        texture       = (shadowMap1);
		MinFilter     = Point;
        MagFilter     = Point;
        MipFilter     = None;
        AddressU      = Clamp;
        AddressV      = Clamp;
		SRGBTexture   = False;
    };	

sampler shadowMap2SamplerLinear = sampler_state
    {
        texture       = (shadowMap2);
		MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = None;
        AddressU      = Clamp;
        AddressV      = Clamp;
		SRGBTexture   = False;
    };
	
sampler shadowMap2SamplerPoint = sampler_state
    {
        texture       = (shadowMap2);
		MinFilter     = Point;
        MagFilter     = Point;
        MipFilter     = None;
        AddressU      = Clamp;
        AddressV      = Clamp;
		SRGBTexture   = False;
    };

samplerCUBE environmentTextureSampler = sampler_state
	{
        texture       = (environmentTexture);
		MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Linear;
		SRGBTexture   = False;	
	};
	
sampler lightGoboTextureSampler = sampler_state
    {
        texture       = (lightGoboTexture);
        AddressU      = Clamp;
        AddressV      = Clamp;
        MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Linear;
		SRGBTexture   = True;
    };				
		
float4 LightVolumeVS(VS_LightVolume_INPUT input) : POSITION
{

    half4 wsPosition = mul(half4(input.osPosition, 1.0), objectToWorldMatrix);
    half4 ssPosition = mul(wsPosition, worldToScreenMatrix);

    return ssPosition;

}

/**
 * Gets the perctage of shadow.
 *   smPosition - The point projected into the shadow map homogenous coordinates
 */
half GetShadow(uniform bool depthReadTest, half4 smPosition, half4 nmPosition)
{

    half radius = 0.0006;

	if (depthReadTest)
	{
		radius *= smPosition.w;
	}
	
    half4 noise = tex2Dproj(noiseTextureSampler, nmPosition) * radius;

    half2 sampleOffset[] =
        {
            half2( noise.x,  noise.y),
            half2( noise.x, -noise.y),
            half2(-noise.x, -noise.y),
            half2(-noise.x,  noise.y),
            half2( noise.z,  noise.w),
            half2( noise.z, -noise.w),
            half2(-noise.z, -noise.w),
            half2(-noise.z,  noise.w),            
        };

	int numSamples = 7;

    half shadow = 0.0;
    
	if (depthReadTest)
	{

		for (int i = 0; i < numSamples; ++i)
		{
			half4 texCoord = smPosition + half4(sampleOffset[i], 0, 0);
			shadow += 1 - min( tex2Dproj(shadowMap1SamplerLinear, texCoord).r,
                               tex2Dproj(shadowMap2SamplerLinear, texCoord).r );
		}

	}
	else
	{
		
		smPosition /= smPosition.w;

		for (int i = 0; i < numSamples; ++i)
		{
		
			half2 texCoord = smPosition.xy + sampleOffset[i];
			
			if (min(tex2D(shadowMap1SamplerPoint, texCoord).r,
					tex2D(shadowMap2SamplerPoint, texCoord).r) < smPosition.z)
			{
				shadow += 1.0;
			}

		}

	}
    
    return shadow / numSamples;
	
}    

/**
 * Gets the perctage of shadow.
 *   smPosition - The point projected into the shadow map homogenous coordinates
 */
half GetShadowFast(uniform bool depthReadTest, half4 smPosition, half4 nmPosition)
{

    half radius = 0.003;

	if (depthReadTest)
	{
		radius *= smPosition.w;
	}
	
    half4 noise = tex2Dproj(noiseTextureSampler, nmPosition);

    half2 sampleOffset[] =
        {
            half2( noise.x,  noise.y) * radius,
            half2( noise.x, -noise.y) * radius,
            half2(-noise.x, -noise.y) * radius,
            half2(-noise.x,  noise.y) * radius,
            half2( noise.z,  noise.w) * radius,
            half2( noise.z, -noise.w) * radius,
            half2(-noise.z, -noise.w) * radius,
            half2(-noise.z,  noise.w) * radius,            
        };

	int numSamples = 1;

    half shadow = 0.0;
    
	if (depthReadTest)
	{

		for (int i = 0; i < numSamples; ++i)
		{
			half4 texCoord = smPosition + half4(sampleOffset[i], 0, 0);
			shadow += 1 - min( tex2Dproj(shadowMap1SamplerLinear, texCoord).r, tex2Dproj(shadowMap2SamplerLinear, texCoord).r );
		}

	}
	else
	{
		
		smPosition /= smPosition.w;

		for (int i = 0; i < numSamples; ++i)
		{
		
			half2 texCoord = smPosition.xy + sampleOffset[i];
			
			if (min(tex2D(shadowMap1SamplerPoint, texCoord).r,
					tex2D(shadowMap2SamplerPoint, texCoord).r) < smPosition.z)
			{
				shadow += 1.0;
			}

		}

	}
    
    return shadow / numSamples;
	
}  

/**
 * Gets the perctage of shadow from a single shadow map.
 *   smPosition - The point projected into the shadow map homogenous coordinates
 */
half GetSingleShadow(half4 smPosition, half4 nmPosition)
{

    half radius = 0.001;
    half bias = 0.004;
    
    smPosition.xy /= smPosition.w;
    nmPosition.xy /= nmPosition.w;
/*    
    half2 sampleOffset[] =
        {
            half2( radius,  0.0000),
            half2(-radius,  0.0000),
            half2( 0.0000,  radius),
            half2( 0.0000, -radius),
            half2( radius,  radius),
            half2( radius, -radius),            
            half2(-radius,  radius),
            half2(-radius, -radius),            
        };

    int numSamples = 8;
*/
    
    half4 noise = tex2D(noiseTextureSampler, nmPosition.xy);
    
    half2 sampleOffset[] =
        {
            half2( noise.x,  noise.y) * radius,
            half2( noise.x, -noise.y) * radius,
            half2(-noise.x, -noise.y) * radius,
            half2(-noise.x,  noise.y) * radius,
            half2( noise.z,  noise.w) * radius,
            half2( noise.z, -noise.w) * radius,
            half2(-noise.z, -noise.w) * radius,
            half2(-noise.z,  noise.w) * radius,            
        };

    int numSamples = 8;

    half shadow = 0.0;

    for (int i = 0; i < numSamples; ++i)
    {
    
        half2 texCoord = smPosition.xy + sampleOffset[i];

        if (tex2D(shadowMap1SamplerPoint, texCoord).r + bias < smPosition.z)
        {
            shadow += 1.0;
        }

    }
    
    return shadow / numSamples;

}    

/**
 * Gets the perctage of shadow from a single shadow map using an optimized, but
 *  lower quality calculation.
 *   smPosition - The point projected into the shadow map homogenous coordinates
 */
half GetSingleShadowFast(half4 smPosition)
{
    half bias = 0.004;
    smPosition.xy /= smPosition.w;
    return tex2D(shadowMap1SamplerPoint, smPosition.xy).r + bias < smPosition.z;
}    

/**
 * Computes Blinn-Phong shading.
 *
 *      radiance  - incident radiance at the point.
 *      n         - world space surface normal
 *      l         - world space direction to the light
 *      v         - world space direction to the viewer
 *      albedo    - surface color
 *      specular  - specular reflection color
 *      shininess - specular exponent
 */
half3 BlinnPhong(half3 radiance, half3 n, half3 l, half3 v, half3 albedo, half3 specular, half shininess)
{
	half  d = saturate(dot(n, l));
	half3 h = normalize(l + v);
	half3 s = pow(saturate(dot(n, h)), shininess) * specular;
	return (d * albedo + s) * radiance;
}

/**
 * Diffuse only shading.
 */
half3 Diffuse(half3 radiance, half3 n, half3 l, half3 v, half3 albedo)
{
	half d = saturate(dot(n, l));
	return d * albedo * radiance;
}

half GetDistanceAttenuation(half distance)
{

	// This is not physically based; instead of using the inverse square of the distance
	// to compute the falloff, we use a parabolic attenuation. We do this for three reasons:
	//  1) The attenuation goes to 0 at the light radius
	//  2) The attenuation is "slower" so that light fills the light sphere more evenly
	//  3) The light doesn't blow out at points very close to the light source
	
	half l = saturate(1.0f - distance / lightRadius);
    return l * l;
	
}

/**
 * Pixel shader for computing the illumination from an ambient light.
 */  
half4 AmbientLightPS(PS_DeferredPass_Input input) : COLOR0
{
	half4 albedo = tex2D( albedoTextureSampler, input.texCoord );
    return half4(albedo.rgb * lightColor, 1);
}

/**
 * Pixel shader for computing the illumination from a spot light.
 */  
half4 SpotLightPS(uniform bool useConeAttenuation, uniform bool shadows, uniform bool depthReadTest, uniform bool specular, uniform bool gobo, PS_DeferredPass_Input input) : COLOR0
{

	half4 albedo 		= tex2D( albedoTextureSampler, input.texCoord );
	half3 vsNormal   	= GetNormal( input.texCoord  );
	half3 vsPosition    = GetPosition( input.texCoord, input.projected.xy );
	
	half shadow = 1;
	
	if (shadows)
	{
		half4 smPosition = mul(half4(vsPosition, 1), viewToShadowMatrix);
		half4 nmPosition = mul(half4(vsPosition, 1), viewToNoiseMatrix);
		shadow = (1 - GetShadow(depthReadTest, smPosition, nmPosition) * shadowFade);
	}
    
    // Compute the normalized view direction.
    half3 v = -normalize(vsPosition);
        
    // Compute the lighting.
    
    half3 l = vsLightPosition - vsPosition;
    half  d = length(l);
    l = l / d;
    
    half attenuation = GetDistanceAttenuation(d);
	if (useConeAttenuation)
	{
		attenuation *= saturate((dot(l, vsLightDirection) - outerCone ) / (innerCone - outerCone));
	}
	
    half3 radiance = lightColor * attenuation * shadow;

	if (gobo)
	{
		float3 lsLightDir = mul(float4(l, 0.0), viewToGoboMatrix);
		float2 goboTexCoord = (lsLightDir.xy / lsLightDir.z) * 0.5 + 0.5;
		radiance *= tex2D( lightGoboTextureSampler, goboTexCoord ).rgb;
	}

	if (specular)
	{
		half4 specularGloss = tex2D( specularGlossTextureSampler, input.texCoord );
		return half4( BlinnPhong(radiance, vsNormal, l, v, albedo.rgb, specularGloss.rgb, specularGloss.a * 256), 1 );
	}
	else
	{
		return half4( Diffuse(radiance, vsNormal, l, v, albedo.rgb), 1 );
	}
	
}

/**
 * Pixel shader for computing the illumination from a sky/directional light.
 */  
half4 SkyLightPS(PS_DeferredPass_Input input) : COLOR0
{

	half4 albedo 		 = tex2D( albedoTextureSampler, input.texCoord );
	half4 specularGloss = tex2D( specularGlossTextureSampler, input.texCoord );
	half3 vsNormal   	 = GetNormal( input.texCoord  );
	half3 vsPosition    = GetPosition( input.texCoord, input.projected.xy );
    
    // Compute the normalized view direction.
    half3 v = -normalize(vsPosition);
        
    // Compute the lighting.
    half3 radiance = lightColor;
    return half4( BlinnPhong(radiance, vsNormal, vsLightDirection, v, albedo.rgb, specularGloss.rgb, specularGloss.a * 256), 1 );

}

/**
 * Pixel shader for computing the illumination from a sky light with shadows.
 */  
half4 SkyLightShadowsPS(PS_DeferredPass_Input input) : COLOR0
{
    return SkyLightPS( input );
}

half4 PointLightPS(PS_DeferredPass_Input input) : COLOR0
{

	half4 albedo		= tex2D( albedoTextureSampler, input.texCoord );
	half3 vsNormal   	= GetNormal( input.texCoord  );
	half3 vsPosition    = GetPosition( input.texCoord, input.projected.xy );
    
    // Compute the normalized view direction.
    half3 v = -normalize(vsPosition);
        
    // Compute the lighting.
    
    half3 l = vsLightPosition - vsPosition;
    half  d = length(l);
    l = l / d;
    
    half attenuation = GetDistanceAttenuation(d);
    half3 radiance = lightColor * attenuation;
	
	return half4( Diffuse(radiance, vsNormal, l, v, albedo.rgb), 1 );
	
}

half4 PointLightSpecularPS(PS_DeferredPass_Input input) : COLOR0
{

	half4 albedo		= tex2D( albedoTextureSampler, input.texCoord );
	half3 vsNormal   	= GetNormal( input.texCoord  );
	half3 vsPosition    = GetPosition( input.texCoord, input.projected.xy );
    
    // Compute the normalized view direction.
    half3 v = -normalize(vsPosition);
        
    // Compute the lighting.
    
    half3 l = vsLightPosition - vsPosition;
    half  d = length(l);
    l = l / d;
    
    half attenuation = GetDistanceAttenuation(d);
    half3 radiance = lightColor * attenuation;
	
	half4 specularGloss = tex2D( specularGlossTextureSampler, input.texCoord );
	return half4( BlinnPhong(radiance, vsNormal, l, v, albedo.rgb, specularGloss.rgb, specularGloss.a * 256), 1 );
	
}

/**
 * Pixel shader for computing the illumination from an ambient volume light.
 */  
half4 AmbientVolumeLightPS(PS_DeferredPass_Input input) : COLOR0
{

	half4 albedo 		 = tex2D( albedoTextureSampler, input.texCoord );
	half3 vsNormal   	 = GetNormal( input.texCoord );
    half  lightDistance  = length(vsLightPosition - GetPosition( input.texCoord, input.projected.xy ));
    
    float attenuation = saturate(1.0f - (lightDistance / lightRadius));
	
	half3 lsNormal = mul( half4(vsNormal, 0), viewToLightMatrix );
	
	half3 pf = saturate( lsNormal);
	half3 nf = saturate(-lsNormal);

	half3 radiance = pf.x * alvColorLeft
	               + nf.x * alvColorRight
				   + nf.y * alvColorUp
				   + pf.y * alvColorDown
				   + nf.z * alvColorForward
				   + pf.z * alvColorBackward;

    float intensity = lightColor.r * attenuation;
    return half4( saturate(radiance * intensity * albedo.rgb), 1);

}

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

/**
 * Computes distance fog.
 */
float4 FadeOutPS(PS_DeferredPass_Input input) : COLOR0
{
	float depth = tex2D(depthTextureSampler, input.texCoord).r;
	float fade = 1 - depth / fadeOutDistance;
	return float4(fade.rrr, 1);
}

half4 MotionBlurPS(PS_DeferredPass_Input input) : COLOR0
{

	// Apply motion blur based on the camera movement. Uses a post processing
	// technique (http://http.developer.nvidia.com/GPUGems3/gpugems3_ch27.html)

	int maxSamples = 32;

	half3 vsPosition = GetPosition( input.texCoord, input.projected.xy );

	// This is a hack to account for the fact that pixels on the sky box will have
	// 0 depth, since it's not possible to clear the G-buffer to a specific depth
	// outside the 0-1 range (due to D3D9 limitations). To avoid artifacts when
	// blurring these pixels, treat them at a fixed depth.
	if (vsPosition.z == 0)
	{
		vsPosition.z   = 1000;
		vsPosition.xy = input.projected.xy * vsPosition.z;
	}		

	half4 vsOldPosition = mul( half4(vsPosition, 1), currentToPrevViewMatrix );
	
	half2 newPosition = half2( input.projected.x, -input.projected.y);
	half2 oldPosition = vsOldPosition.xy / vsOldPosition.w;

	half2 delta = (newPosition - oldPosition) / maxSamples;
	delta.y = -delta.y;
	
	// Cap the maximum blur amount.
	half l = length(delta);
	const half maxDelta = 0.01;
	if (l > maxDelta)
	{
		delta = normalize(delta) * maxDelta;
	}
	
	half2 texCoord = input.texCoord;
	half4 lighting = half4(0, 0, 0, 0);
	
	for (int i = 0; i < maxSamples; ++i)  
	{  
		texCoord += delta;	
		lighting += tex2D(lightingTextureSampler, texCoord);
	}

	lighting = lighting / maxSamples;
	
	return lighting;
	
}

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

half4 PointLightScatteringPS(uniform bool shadows, uniform bool depthReadTest, PS_Scattering_INPUT input) : COLOR0
{
    
    half3 l = vsLightPosition - input.vsPosition;
    half  d = length(l);
    l = l / d;
	    
    half attenuation = saturate((dot(l, vsLightDirection) - outerCone ) / (innerCone - outerCone));
	attenuation *= GetDistanceAttenuation(d);
	
    half4 smPosition = mul(half4(input.vsPosition, 1), viewToShadowMatrix);
    half4 nmPosition = mul(half4(input.vsPosition, 1), viewToNoiseMatrix);
    
    half shadow = 1;
	if (shadows)
	{	
		shadow = (1 - GetShadowFast(depthReadTest, smPosition, nmPosition) * shadowFade);
	}

	return half4(lightColor * attenuation * shadow * atmosphereDensity, 0);
    
}

float4 DecodeRGBE(float4 m)
{
	return m * pow(2, 256 * (m.w - 0.5));
}

float4 ReflectionsPS(PS_DeferredPass_Input input) : COLOR0
{

	float3 vsNormal      = GetNormal( input.texCoord );
	float3 vsPosition    = GetPosition( input.texCoord, input.projected.xy );
	float4 specularGloss = tex2D( specularGlossTextureSampler, input.texCoord );
    
    // Compute the normalized view direction.
    float3 vsView = -normalize(vsPosition);	

	// Compute the reflection direction.
	float3 vsReflect = reflect(-vsView, vsNormal);
	
	float attenuation;
	
	// Update the reflection direction to take into account the position
	// of the point relative to the reflection probe. We do this by intersecting
	// the reflection ray with a sphere around the reflection probe, and using
	// the intersection point to determine where to sample in the cube map.
	
	float3 l = vsProbePosition - vsPosition;
	float  d = dot(vsReflect, l);
	
	// Note, we assume the point is inside the sphere so we don't need to do
	// any checking for rays that miss the sphere.
	float l2 = dot(l, l);
	float m2 = l2 - d * d;
	float q  = sqrt(probeRadius2 - m2);
	float t  = d + q;

	// Fade out the reflection over the volume of the reflection probe.
	attenuation = max(1 - l2 / probeRadius2, 0);

	// Compute the new reflection direction based on the intersection point
	// with the sphere.
	vsReflect = vsPosition + vsReflect * t - vsProbePosition;
	
	const float maxBias = 2;
	float bias = maxBias - specularGloss.a / (255 / maxBias);
	
	float3 wsReflect = mul(vsReflect, cameraToWorldMatrix);
	float3 env = DecodeRGBE(texCUBEbias(environmentTextureSampler, float4(wsReflect, bias))) * attenuation;
	return float4( env * specularGloss.rgb * probeTint, attenuation );
	
}

technique StencilBackAndFront
{
    pass Back
    {
        ZWriteEnable        = False;
        ColorWriteEnable    = 0;
        StencilZFail        = Invert;
        StencilEnable       = True;
		StencilMask         = <stencilMask>;
		StencilWriteMask	= <stencilMask>;
		CullMode            = (reverseCulling) ? D3DCULL_CCW : D3DCULL_CW;  
        VertexShader        = compile vs_2_0 LightVolumeVS();
		PixelShader			= NULL;
    }
	pass Front
    {
        ZWriteEnable        = False;
        ColorWriteEnable    = 0;
        StencilZFail        = Invert;
        StencilEnable       = True;
		StencilMask         = <stencilMask>;
		StencilWriteMask	= <stencilMask>;
		CullMode            = (reverseCulling) ? D3DCULL_CW : D3DCULL_CCW;  
        VertexShader        = compile vs_2_0 LightVolumeVS();
		PixelShader			= NULL;
    }
}

technique StencilTwoSided
{
    pass p0
    {
        ZWriteEnable        = False;
        ColorWriteEnable    = 0;
        StencilEnable       = True;
		TwoSidedStencilMode = True;
        StencilZFail        = Invert;
		Ccw_StencilZFail    = Invert;
        CullMode            = None;
		StencilMask         = <stencilMask>;
		StencilWriteMask	= <stencilMask>;
        VertexShader        = compile vs_2_0 LightVolumeVS();
		PixelShader			= NULL;
    }
}

technique AmbientLight
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 AmbientLightPS();
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique PointLightShadows[DepthReadTest][Specular][Gobo]
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 SpotLightPS(false, true, DepthReadTest, Specular, Gobo);
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
        StencilEnable       = <enableStencil>;
        StencilFunc         = Less;
        StencilPass         = Zero;
		StencilWriteMask	= <stencilMask>;
		StencilMask         = <stencilMask>;
    }
}

technique SpotLight[Shadows, ShadowsDepthReadTest][Specular][Gobo]
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 SpotLightPS(true, Shadows || ShadowsDepthReadTest, ShadowsDepthReadTest, Specular, Gobo);
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
        StencilEnable       = <enableStencil>;
        StencilFunc         = Less;
        StencilPass         = Zero;
		StencilMask         = <stencilMask>;
		StencilWriteMask	= <stencilMask>;
    }
}

technique PointLight
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 PointLightPS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
        StencilEnable       = <enableStencil>;
        StencilFunc         = Less;
        StencilPass         = Zero;
		StencilMask         = <stencilMask>;
		StencilWriteMask	= <stencilMask>;
    }
}

technique PointLightSpecular
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 PointLightSpecularPS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
        StencilEnable       = <enableStencil>;
        StencilFunc         = Less;
        StencilPass         = Zero;
		StencilMask         = <stencilMask>;
		StencilWriteMask	= <stencilMask>;
    }
}

technique SkyLight
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 SkyLightPS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique SkyLightShadows
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 SkyLightShadowsPS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
    }
}

technique AmbientVolumeLight
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 AmbientVolumeLightPS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
        StencilEnable       = <enableStencil>;
        StencilFunc         = Less;
        StencilPass         = Zero;
		StencilMask         = <stencilMask>;	
		StencilWriteMask	= <stencilMask>;		
    }
}

technique Reflections
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 ReflectionsPS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
        StencilEnable       = <enableStencil>;
        StencilFunc         = Less;
        StencilPass         = Zero;
		StencilMask         = <stencilMask>;	
		StencilWriteMask	= <stencilMask>;		
    }
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

/** This technique fades out to black at a specified distance */
technique FadeOut
{
    pass p0
    {
        ZEnable             = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 FadeOutPS();
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = Zero;
        DestBlend           = SrcColor;
    }
}

technique MotionBlur
{
    pass p0
    {
        ZEnable             = False;
        VertexShader        = compile vs_3_0 DeferredPassVS();
        PixelShader         = compile ps_3_0 MotionBlurPS();
        CullMode            = None;
    }
}

technique PointLightScattering[Shadows, ShadowsDepthReadTest]
{
    pass p0
    {
        ZWriteEnable        = False;
        VertexShader        = compile vs_2_0 ScatteringVS();
        PixelShader         = compile ps_2_0 PointLightScatteringPS(Shadows || ShadowsDepthReadTest, ShadowsDepthReadTest);
        CullMode            = None;
        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
        ColorWriteEnable    = Red | Green | Blue;
    }
}
