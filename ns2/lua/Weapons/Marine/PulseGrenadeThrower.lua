// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\PulseGrenadeThrower.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Throws pulse grenades.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/Weapons/Marine/PulseGrenade.lua")

local networkVars =
{
}

class 'PulseGrenadeThrower' (GrenadeThrower)

PulseGrenadeThrower.kMapName = "pulsegrenadethrower"

PulseGrenadeThrower.kModelName = PrecacheAsset("models/marine/grenades/gr_cluster_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/gr_cluster_view.animation_graph")

function PulseGrenadeThrower:GetViewModelName()
    return PulseGrenadeThrower.kModelName
end

function PulseGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function PulseGrenadeThrower:GetGrenadeMapName()
    return PulseGrenade.kMapName
end

Shared.LinkClassToMap("PulseGrenadeThrower", PulseGrenadeThrower.kMapName, networkVars)