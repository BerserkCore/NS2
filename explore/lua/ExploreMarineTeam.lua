// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreMarineTeam.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// don't generate infantry portals, those are pre-placed in explore mode
function MarineTeam:SpawnInitialStructures(techPoint)
    return nil, nil
end