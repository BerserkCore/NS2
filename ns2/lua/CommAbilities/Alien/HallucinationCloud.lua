// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CommAbilities\Alien\HallucinationCloud.lua
//
//      Created by: Andreas Urwalek (andi@unknownworlds.com)
//
//      Creates a hallucination of every affected alien.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'HallucinationCloud' (CommanderAbility)

HallucinationCloud.kMapName = "hallucinationcloud"

HallucinationCloud.kSplashEffect = PrecacheAsset("cinematics/alien/hallucinationcloud.cinematic")
HallucinationCloud.kType = CommanderAbility.kType.Instant

HallucinationCloud.kRadius = 6

local gTechIdToHallucinateTechId = nil
function GetHallucinationTechId(techId)

    if not gTechIdToHallucinateTechId then
    
        gTechIdToHallucinateTechId = {}
        gTechIdToHallucinateTechId[kTechId.Drifter] = kTechId.HallucinateDrifter
        gTechIdToHallucinateTechId[kTechId.Skulk] = kTechId.HallucinateSkulk
        gTechIdToHallucinateTechId[kTechId.Gorge] = kTechId.HallucinateGorge
        gTechIdToHallucinateTechId[kTechId.Lerk] = kTechId.HallucinateLerk
        gTechIdToHallucinateTechId[kTechId.Fade] = kTechId.HallucinateFade
        gTechIdToHallucinateTechId[kTechId.Onos] = kTechId.HallucinateOnos
        
        gTechIdToHallucinateTechId[kTechId.Hive] = kTechId.HallucinateHive
        gTechIdToHallucinateTechId[kTechId.Whip] = kTechId.HallucinateWhip
        gTechIdToHallucinateTechId[kTechId.Shade] = kTechId.HallucinateShade
        gTechIdToHallucinateTechId[kTechId.Crag] = kTechId.HallucinateCrag
        gTechIdToHallucinateTechId[kTechId.Shift] = kTechId.HallucinateShift
        gTechIdToHallucinateTechId[kTechId.Harvester] = kTechId.HallucinateHarvester
        gTechIdToHallucinateTechId[kTechId.Hydra] = kTechId.HallucinateHydra
    
    end
    
    return gTechIdToHallucinateTechId[techId]

end

local networkVars = { }

function HallucinationCloud:OnInitialized()
    
    if Server then
        // sound feedback
        self:TriggerEffects("enzyme_cloud")    
    end
    
    CommanderAbility.OnInitialized(self)

end

function HallucinationCloud:GetStartCinematic()
    return HallucinationCloud.kSplashEffect
end

function HallucinationCloud:GetType()
    return HallucinationCloud.kType
end

if Server then

    function HallucinationCloud:Perform()
        
        // kill all hallucinations before, to prevent unreasonable spam
        for _, hallucination in ipairs(GetEntitiesForTeam("Hallucination", self:GetTeamNumber())) do
            hallucination.consumed = true
            hallucination:Kill()
        end
        
        local friendlyUnits = GetEntitiesForTeamWithinRange("Alien", self:GetTeamNumber(), self:GetOrigin(), HallucinationCloud.kRadius)
        table.copy(GetEntitiesForTeamWithinRange("Drifter", self:GetTeamNumber(), self:GetOrigin(), HallucinationCloud.kRadius), friendlyUnits, true)
        
        local madeDrifter = false
        
        // search for alien in range, cloak them and create a hallucination
        for _, alien in ipairs(friendlyUnits) do
        
            if alien:GetIsAlive() and (not alien:isa("Drifter") or not madeDrifter) then
            
                local angles = alien:GetAngles()
                angles.pitch = 0
                angles.roll = 0
                local origin = GetGroundAt(self, alien:GetOrigin() + Vector(0, .1, 0), PhysicsMask.Movement, EntityFilterOne(alien))
                
                local hallucination = CreateEntity(Hallucination.kMapName, origin, self:GetTeamNumber())
                hallucination:SetEmulation(GetHallucinationTechId(alien:GetTechId()))
                hallucination:SetOwner(alien)
                hallucination:SetAngles(angles)
                
                local randomDestinations = GetRandomPointsWithinRadius(alien:GetOrigin(), 4, 10, 10, 1, 1, nil, nil)
                if randomDestinations[1] then            
                    hallucination:GiveOrder(kTechId.Move, nil, randomDestinations[1], nil, true, true)            
                end
                
                if alien:isa("Drifter") then
                    madeDrifter = true
                end
            
            end
            
        end
        
        for _, resourcePoint in ipairs(GetEntitiesWithinRange("ResourcePoint", self:GetOrigin(), HallucinationCloud.kRadius)) do
        
            if resourcePoint:GetAttached() == nil and GetIsPointOnInfestation(resourcePoint:GetOrigin()) then
            
                local hallucination = CreateEntity(Hallucination.kMapName, resourcePoint:GetOrigin(), self:GetTeamNumber())
                hallucination:SetEmulation(kTechId.HallucinateHarvester)
                hallucination:SetAttached(resourcePoint)
                
            end
        
        end
        
        for _, techPoint in ipairs(GetEntitiesWithinRange("TechPoint", self:GetOrigin(), HallucinationCloud.kRadius)) do
        
            if techPoint:GetAttached() == nil then
            
                local coords = techPoint:GetCoords()
                coords.origin = coords.origin + Vector(0, 2.494, 0)
                local hallucination = CreateEntity(Hallucination.kMapName, techPoint:GetOrigin(), self:GetTeamNumber())
                hallucination:SetEmulation(kTechId.HallucinateHive)
                hallucination:SetAttached(techPoint)
                hallucination:SetCoords(coords)
                
            end
        
        end

    end

end

Shared.LinkClassToMap("HallucinationCloud", HallucinationCloud.kMapName, networkVars)