// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreAlienTeam.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// don't generate cysts, those are pre-placed in explore mode
function AlienTeam:SpawnInitialStructures(techPoint)
    return nil, nil    
end