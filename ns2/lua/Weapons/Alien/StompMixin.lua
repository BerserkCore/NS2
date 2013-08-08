// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\StompMixin.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Shockwave.lua")

StompMixin = CreateMixin( StompMixin  )
StompMixin.type = "Stomp"

local kMaxPlayerVelocityToStomp = 6
local kDisruptRange = kStompRange
local kStompVerticalRange = 1.5

local kStompRadius = 5

// GetHasSecondary and GetSecondaryEnergyCost should completely override any existing
// same named function defined in the object.
StompMixin.overrideFunctions =
{
    "GetHasSecondary",
    "GetSecondaryEnergyCost",
    "GetSecondaryTechId",
    "OnSecondaryAttack",
    "OnSecondaryAttackEnd",
    "PerformSecondaryAttack"
}

StompMixin.networkVars = 
{
    stomping = "boolean"
}

function StompMixin:GetIsStomping()
    return self.stomping
end

function StompMixin:GetSecondaryTechId()
    return kTechId.Stomp
end

function StompMixin:GetHasSecondary(player)
    return player:GetHasThreeHives()
end

function StompMixin:GetSecondaryEnergyCost(player)
    return kStompEnergyCost
end

function StompMixin:PerformStomp(player)

    local enemyTeamNum = GetEnemyTeamNumber(self:GetTeamNumber())
    local stompOrigin = player:GetOrigin()

    for index, ent in ipairs(GetEntitiesWithMixinForTeamWithinRange("Stun", enemyTeamNum, stompOrigin, kStompRadius)) do
    
        if math.abs(ent:GetOrigin().y - stompOrigin.y) < 1.2 then
            ent:SetStun(kDisruptMarineTime)
        end
        
    end
    
    // discrupt minigun exos in range as well
    /*
    for index, exo in ipairs(GetEntitiesForTeamWithinRange("Exo", enemyTeamNum, stompOrigin, kStompRadius)) do

        if math.abs(exo:GetOrigin().y - stompOrigin.y) < 1.2 then
            exo:Disrupt()
        end
        
    end
    */
    
end

function StompMixin:OnSecondaryAttack(player)

    if player:GetEnergy() >= kStompEnergyCost and player:GetIsOnGround() then
        self.stomping = true
        Ability.OnSecondaryAttack(self, player)
    end

end

function StompMixin:OnSecondaryAttackEnd(player)
    
    Ability.OnSecondaryAttackEnd(self, player)    
    self.stomping = false
    
end

function StompMixin:OnTag(tagName)

    PROFILE("StompMixin:OnTag")

    if tagName == "stomp_hit" then
        
        local player = self:GetParent()
        
        if player then
                
            self:PerformStomp(player)

            self:TriggerEffects("stomp_attack", { effecthostcoords = player:GetCoords() })
            player:DeductAbilityEnergy(kStompEnergyCost)
            
        end
        
        if player:GetEnergy() < kStompEnergyCost then
            self.stomping = false
        end    
        
    end

end

function StompMixin:OnUpdateAnimationInput(modelMixin)

    if self.stomping then
        modelMixin:SetAnimationInput("activity", "secondary") 
    end
    
end