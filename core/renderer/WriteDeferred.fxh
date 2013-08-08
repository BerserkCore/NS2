//=============================================================================
//
// shaders/WriteDeferred.fx
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2008-2010, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

struct PS_WriteDeferred_Output
{
    float4 albedo			        : COLOR0;
	float4 normal	        		: COLOR1;
	float4 specularGloss	        : COLOR2;
    float4 depth              		: COLOR3;
};

float4 ConvertNormal(float3 vsNormal)
{
	return float4( vsNormal * 0.5 + 0.5, 1);
}
