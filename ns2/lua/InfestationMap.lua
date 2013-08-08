// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\InfestationMap.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================


function UpdateInfestationMasks()

    PROFILE("InfestationMap:UpdateInfestationMasks")

    local gameEffectEntities = GetEntitiesWithMixin("GameEffects")    
    for index = 1, #gameEffectEntities do
        local entity = gameEffectEntities[index]
        // Don't do this for infestations.
        if not entity:isa("Infestation") then
            UpdateInfestationMask(entity)
        end
    end
    
end

// Clear OnInfestation game effect mask on all entities, unless they are standing on infestation
function UpdateInfestationMask(forEntity)

    if HasMixin(forEntity, "GameEffects") then
    
        local onInfestation = GetIsPointOnInfestation(forEntity:GetOrigin())
        
        // Update the mask.
        if forEntity:GetGameEffectMask(kGameEffect.OnInfestation) ~= onInfestation then
        
            forEntity:SetGameEffectMask(kGameEffect.OnInfestation, onInfestation)
            
            if onInfestation and forEntity.OnTouchInfestation then
                forEntity:OnTouchInfestation()
            end
            
            if not onInfestation and forEntity.OnLeaveInfestation then
                forEntity:OnLeaveInfestation()
            end
            
        end
        
    end
    
end

function EnableCheckUntilTimeInArea(time, position, radius, teamNum)

    local entities = GetEntitiesWithMixinForTeamWithinRange("InfestationTracker", teamNum, position, radius)
    
    for index, entity in ipairs(entities) do    
        entity:EnableCheckUntil(time)    
    end

end