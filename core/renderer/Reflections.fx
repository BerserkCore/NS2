#include "WriteDeferred.fxh"
#include "ReadDeferred.fxh"
#include "Constants.fxh"

float4x4 	cameraToWorldMatrix;

texture     environmentTexture;
float3		vsProbePosition;
float		probeRadius2;
float3		probeTint;

samplerCUBE environmentTextureSampler = sampler_state
	{
        texture       = (environmentTexture);
		MinFilter     = Linear;
        MagFilter     = Linear;
        MipFilter     = Linear;
		SRGBTexture   = False;	
	};
	
float4 DecodeRGBE(float4 m)
{
	return m * pow(2, 256 * (m.w - 0.5));
}

float4 ReflectionsPS(PS_DeferredPass_Input input) : COLOR0
{

	float3 vsNormal      = GetNormal( input.texCoord );
	float3 vsPosition    = GetPosition( input.texCoord, input.projected );
	float4 specularGloss = tex2D( specularGlossTextureSampler, input.texCoord );
    
    // Compute the normalized view direction.
    float3 vsView = normalize(-vsPosition);	

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
	attenuation = saturate(1 - l2 / probeRadius2);

	// Compute the new reflection direction based on the intersection point
	// with the sphere.
	vsReflect = vsPosition + vsReflect * t - vsProbePosition;
	
	const float maxBias = 2;
	float bias = maxBias - specularGloss.a / (255 / maxBias);
	
	float3 wsReflect = mul(vsReflect, cameraToWorldMatrix);
	float3 env = DecodeRGBE(texCUBEbias(environmentTextureSampler, float4(wsReflect, bias))) * attenuation;
	return float4( env * specularGloss.rgb * probeTint, attenuation );
	
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
        StencilEnable       = True;
        StencilFunc         = Less;
        StencilPass         = Zero;
		StencilMask         = 1;	
		StencilWriteMask	= 1;		
    }
}