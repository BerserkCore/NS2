// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreShared.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/WorldTooltip.lua")

Script.Load("lua/ExploreBalance.lua")
Script.Load("lua/ExploreBalanceMisc.lua")

Script.Load("lua/ExploreScriptActor.lua")

Script.Load("lua/Weapons/ExploreViewModel.lua")

// Override GetConstructTime
assert(GetConstructionTime)
local prevGetConstructionTime = GetConstructionTime
function GetConstructionTime(self)
    local time = prevGetConstructionTime(self)
    return time / 4
end

// Don't wait much
assert(kAlienWaveSpawnInterval ~= nil)
assert(kMarineRespawnTime ~= nil)
kAlienWaveSpawnInterval = 2
kMarineRespawnTime = 3