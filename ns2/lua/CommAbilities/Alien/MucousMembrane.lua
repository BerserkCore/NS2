// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CommAbilities\Alien\MucousMembrane.lua
//
//      Created by: Andreas Urwalek (andi@unknownworlds.com)
//
//      Increases movement speed inside the cloud.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'MucousMembrane' (CommanderAbility)

MucousMembrane.kMapName = "mucousmembrane"

MucousMembrane.kSplashEffect = PrecacheAsset("cinematics/alien/mucousmembrane.cinematic")
MucousMembrane.kType = CommanderAbility.kType.Repeat
MucousMembrane.kLifeSpan = 10
MucousMembrane.kThinkTime = 0.1

MucousMembrane.kArmorHealPercentagePerSecond = 20
MucousMembrane.kRadius = 8

local gHealedByMucousMembrane = {}

local networkVars = {}

function MucousMembrane:OnInitialized()
    
    if Server then
        // sound feedback
        self:TriggerEffects("enzyme_cloud")    
    end
    
    CommanderAbility.OnInitialized(self)

end

local function GetEntityRecentlyHealed(entityId, time)

    for index, pair in ipairs(gHealedByMucousMembrane) do
        if pair[1] == entityId and pair[2] > Shared.GetTime() - MucousMembrane.kThinkTime then
            return true
        end
    end
    
    return false
    
end

local function SetEntityRecentlyHealed(entityId)

    for index, pair in ipairs(gHealedByMucousMembrane) do
        if pair[1] == entityId then
            table.remove(gHealedByMucousMembrane, index)
        end
    end
    
    table.insert(gHealedByMucousMembrane, {entityId, Shared.GetTime()})
    
end

function MucousMembrane:GetRepeatCinematic()
    return MucousMembrane.kSplashEffect
end

function MucousMembrane:GetType()
    return MucousMembrane.kType
end

function MucousMembrane:GetThinkTime()
    return MucousMembrane.kThinkTime
end

function MucousMembrane:GetLifeSpan()
    return MucousMembrane.kLifeSpan   
end

if Server then

    function MucousMembrane:Perform()
        
        for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), MucousMembrane.kRadius)) do
        
            if not GetEntityRecentlyHealed(unit:GetId()) then
                
                local addArmor = math.max(1, unit:GetMaxArmor() * MucousMembrane.kThinkTime / MucousMembrane.kArmorHealPercentagePerSecond)
                //Print("%s healarmor %s", ToString(unit), ToString(addArmor))
                unit:SetArmor(unit:GetArmor() + addArmor)
                SetEntityRecentlyHealed(unit:GetId())
            
            end
            
        end

    end

end

Shared.LinkClassToMap("MucousMembrane", MucousMembrane.kMapName, networkVars)