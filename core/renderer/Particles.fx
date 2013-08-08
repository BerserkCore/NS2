#include "ReadDeferred.fxh"

texture lowAccumTexture;
texture lowDepthTexture;

float _nearPlane;
float _farPlane;

sampler lowAccumTextureSampler = sampler_state
{
    texture     = (lowAccumTexture);
    AddressU    = Clamp;
    AddressV    = Clamp;
    MinFilter   = Linear;
    MagFilter   = Linear;
    MipFilter   = Linear;
    SRGBTexture = False;
};

float4 CompositePS(PS_DeferredPass_Input input) : COLOR0
{
    float2 uv = input.texCoord;

    // These offset corrections are needed when using half-res textures. Not 100% sure why..
    uv.x += rcpFrame.x * 0.5;
    uv.y += rcpFrame.y * 0.5;

    return tex2D( lowAccumTextureSampler, uv );
}

float4 DebugDepthPS(PS_DeferredPass_Input input) : COLOR0
{
    float2 uv = input.texCoord;
    //uv.x += rcpFrame.x * 0.5;
    //uv.y += rcpFrame.y * 0.5;

    float4 gDepth = tex2D( depthTextureSampler, uv );
    float vsDepth = gDepth.r;
    float ssDepth = gDepth.g;
	
        discard;
    return float4( 1.0, 0, 0, 1 );
}

struct PS_ResizeDepth_Output
{
    half4 vsDepth            : COLOR0;
    half  ssDepth            : DEPTH;
};

// Particles need VS depth (to do soften) and SS depth (to not draw over over stuff, especially view models)
PS_ResizeDepth_Output ResizeDepthPS(PS_DeferredPass_Input input)
{
    float2 uv = input.texCoord;

    uv.x += rcpFrame.x*0.25;
    uv.y += rcpFrame.y*0.25;
	
    float vsDepth = tex2D( linearDepthTextureSampler, uv ).r;

    PS_ResizeDepth_Output result;
    result.vsDepth = half4(vsDepth, 0, 0, 1);
    result.ssDepth = 1.0;
    return result;
}	

technique ResizeDepth
{
    pass p0
    {
        ZFunc               = Always;
        //ZWriteEnable        = True;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 ResizeDepthPS();
        CullMode            = None;
        //ColorWriteEnable    = 1;
    }
}

technique Composite
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 CompositePS();
        CullMode            = None;

        AlphaBlendEnable    = True;
        SrcBlend            = One;
        DestBlend           = One;
    }
}

technique DebugDepth
{
    pass p0
    {
        ZEnable             = False;
        ZWriteEnable        = False;	
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 DebugDepthPS();
        CullMode            = None;
    }
}
