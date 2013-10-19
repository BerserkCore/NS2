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
MucousMembrane.kLifeSpan = 2.5
MucousMembrane.kThinkTime = 0.2

MucousMembrane.kRadius = 8

local gHealedByMucousMembrane = {}

local networkVars = {}

function MucousMembrane:OnInitialized()
    
    if Server then
        // sound feedback
        self:TriggerEffects("enzyme_cloud")
        DestroyEntitiesWithinRange("MucousMembrane", self:GetOrigin(), 25, EntityFilterOne(self)) 
    end
    
    CommanderAbility.OnInitialized(self)

end

function MucousMembrane:GetRepeatCinematic()
    return MucousMembrane.kSplashEffect
end

function MucousMembrane:GetType()
    return MucousMembrane.kType
end

function MucousMembrane:GetUpdateTime()
    return MucousMembrane.kThinkTime
end

function MucousMembrane:GetLifeSpan()
    return MucousMembrane.kLifeSpan   
end

if Server then

    function MucousMembrane:Perform()
        /*
        if not self.totalHeal then
            self.totalHeal = 0
        end
        */
        for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), MucousMembrane.kRadius)) do

            local addArmor = Clamp(unit:GetMaxArmor() * MucousMembrane.kThinkTime * 0.25, 1, 8)
            //local oldArmor = unit:GetArmor()
            unit:SetArmor(unit:GetArmor() + addArmor)
            //self.totalHeal = self.totalHeal + math.max(0, unit:GetArmor() - oldArmor)
            
        end
        
        //DebugPrint(ToString(self.totalHeal))

    end

end

Shared.LinkClassToMap("MucousMembrane", MucousMembrane.kMapName, networkVars)