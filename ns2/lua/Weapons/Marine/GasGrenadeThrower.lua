// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\GasGrenadeThrower.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Throws gas grenades.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/Weapons/Marine/GasGrenade.lua")

local networkVars =
{
}

class 'GasGrenadeThrower' (GrenadeThrower)

GasGrenadeThrower.kMapName = "gasgrenadethrower"

GasGrenadeThrower.kModelName = PrecacheAsset("models/marine/grenades/gr_nerve_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/gr_nerve_view.animation_graph")

function GasGrenadeThrower:GetViewModelName()
    return GasGrenadeThrower.kModelName
end

function GasGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function GasGrenadeThrower:GetGrenadeMapName()
    return GasGrenade.kMapName
end

Shared.LinkClassToMap("GasGrenadeThrower", GasGrenadeThrower.kMapName, networkVars)