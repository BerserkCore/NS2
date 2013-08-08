#include "WriteDeferred.fxh"
#include "ReadDeferred.fxh"
#include "Constants.fxh"

texture lightingTexture;

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

// Color grading parameters used during tone mapping.

float		contrast;
float		brightness;
float3		balance;

half3 FilmicToneMap(half3 x)
{

	// John Hable's filmic tone mapping operator.

	const float A = 0.22; // Shoulder strength.
	const float B = 0.50; // Linear strength.
	const float C = 0.20; // Linear angle.
	const float D = 0.20; // Toe strength.
	const float E = 0.01; // Toe numerator.
	const float F = 0.30; // Toe denomenator.
	
	return (x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F) - E/F;
	
}

/**
 * Converts to gamma space.
 */
half3 Gamma(half3 color)
{
//return sqrt(color);
    return pow( color, 1.0 / 2.2 );
	/*
	const float3 linearWhite = 11.2;
	return pow( FilmicToneMap(color) / FilmicToneMap(linearWhite), 1.0 / 2.2 );
	*/
}

half3 GetLuminosity(half3 value)
{
	return dot( value, half3(0.2126f, 0.7152f, 0.0722f) );
}

half3 ColorGrading(half3 value)
{
	
	// Apply contrast.
	value = (value - 0.5) * (contrast + 1.0) + 0.5;

	// Apply brightness.
	value += brightness;
	
	// Apply the balance (preserving luminosity).
	half luminosity = GetLuminosity(value);
	value = max(value + balance, 0);
	value = luminosity * value / GetLuminosity(value);

	return value;
	
}
	
half4 ToneMapPS(PS_DeferredPass_Input input) : COLOR0
{

    half3 lighting = tex2D(lightingTextureSampler, input.texCoord).rgb;
   
	// Convert from linear space to gamma space.
	half4 color;
	color.rgb = Gamma(max( lighting.rgb, 0 ));
	
	// Compute luminance as required by FXAA.
	color.a = dot(color.rgb, half3(0.299, 0.587, 0.114));
	
    return color;

}

technique ToneMap
{
    pass p0
    {
        ZEnable             = False;
        VertexShader        = compile vs_2_0 DeferredPassVS();
        PixelShader         = compile ps_2_0 ToneMapPS();
        CullMode            = None;
    }
}