// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\RegenerationMixin.lua    
//    
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)   
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

RegenerationMixin = CreateMixin( RegenerationMixin )
RegenerationMixin.type = "Regeneration"

RegenerationMixin.expectedMixins =
{
    Live = "Needed for GetMaxHealth.",
}

local kRegenEffectIntervall = 1

local kRegenerationCombatTimeOut = 5

function RegenerationMixin:__initmixin()
    
end

if Server then

    local function GetCanRegenerate(self)    
        return not HasMixin(self, "Combat") or self:GetTimeLastDamageTaken() + kRegenerationCombatTimeOut < Shared.GetTime() 
    end

    local function SharedUpdate(self, deltaTime)
    
        if GetHasRegenerationUpgrade(self) then
        
            if GetCanRegenerate(self) then

                local healRate = kAlienRegenerationPerSecond
                healRate = (healRate / kAlienRegenerationTime) * deltaTime
                
                local prevHealthScalar = self:GetHealthScalar()
                self:AddHealth(healRate, false, false, true)
                
                if prevHealthScalar < self:GetHealthScalar() and (not self.timeLastRegenEffect or self.timeLastRegenEffect + kRegenEffectIntervall < Shared.GetTime()) then
                    self:TriggerEffects("regeneration")
                    self.timeLastRegenEffect = Shared.GetTime()
                end

            end
            
        end
        
    end

    function RegenerationMixin:OnUpdate(deltaTime)   
        SharedUpdate(self, deltaTime)
    end

    function RegenerationMixin:OnProcessMove(input)   
        SharedUpdate(self, input.time)
    end

end