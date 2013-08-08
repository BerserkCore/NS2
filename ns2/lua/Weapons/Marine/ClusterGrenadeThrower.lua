// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\ClusterGrenadeThrower.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Throws cluster grenades.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/Weapons/Marine/ClusterGrenade.lua")

local networkVars =
{
}

class 'ClusterGrenadeThrower' (GrenadeThrower)

ClusterGrenadeThrower.kMapName = "clustergrenadethrower"

ClusterGrenadeThrower.kModelName = PrecacheAsset("models/marine/grenades/gr_cluster_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/gr_cluster_view.animation_graph")

function ClusterGrenadeThrower:GetViewModelName()
    return ClusterGrenadeThrower.kModelName
end

function ClusterGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function ClusterGrenadeThrower:GetGrenadeMapName()
    return ClusterGrenade.kMapName
end

Shared.LinkClassToMap("ClusterGrenadeThrower", ClusterGrenadeThrower.kMapName, networkVars)