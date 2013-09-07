// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreShared.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ExploreBalance.lua")
Script.Load("lua/ExploreBalanceMisc.lua")

Script.Load("lua/Tutorial.lua")

// Don't wait much
assert(kMarineRespawnTime ~= nil)
kMarineRespawnTime = 3
