// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\ClogAbility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'ClogAbility' (StructureAbility)

local kMinDistance = 1.4
local kVerticalMinDistance = 6
local kClogOffset = 0.15

function ClogAbility:OverrideInfestationCheck(trace)

    if trace.entity and trace.entity:isa("Clog") then
        return true
    end

    return false    

end

function ClogAbility:GetIsPositionValid(position, player)

    local valid = true
    local entities = GetEntitiesWithinRange("ScriptActor", position, kVerticalMinDistance)
    Shared.SortEntitiesByDistance(position, entities)
    
    for _, entity in ipairs(entities) do
    
        if not entity:isa("Infestation") and not entity == player then
        
            local closestPoint = entity:GetOrigin()
            local fromStructure = position - closestPoint
            local dotProduct = entity:GetCoords().yAxis:DotProduct(fromStructure)
            
            // check horizontal distance (don't allow build on top of the structure)
            valid = ( math.abs( fromStructure:GetLength() ) > kMinDistance and dotProduct < kMinDistance ) or dotProduct > kVerticalMinDistance
            break
        
        end
    
    end
    
    return valid

end

function ClogAbility:ModifyCoords(coords)
    coords.origin = coords.origin + coords.yAxis * kClogOffset
end

function ClogAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end

function ClogAbility:GetDropRange()
    return 3
end

/*
function ClogAbility:IsAllowed(player)
    return player and player.GetHasTwoHives and player:GetHasTwoHives()
end
*/

function ClogAbility:GetPrimaryAttackDelay()
    return 1.0
end

function ClogAbility:GetGhostModelName(ability)
    return Clog.kModelName
end

function ClogAbility:GetDropStructureId()
    return kTechId.Clog
end

function ClogAbility:GetSuffixName()
    return "clog"
end

function ClogAbility:GetDropClassName()
    return "Clog"
end

function ClogAbility:GetDropMapName()
    return Clog.kMapName
end    

