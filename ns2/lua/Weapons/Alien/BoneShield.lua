// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\BoneShield.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Puts the onos in a defensive, slow moving position where it uses energy to absorb damage.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/StompMixin.lua")

class 'BoneShield' (Ability)

BoneShield.kMapName = "boneshield"

local kAnimationGraph = PrecacheAsset("models/alien/onos/onos_view.animation_graph")

local networkVars =
{
    timeLastBoneShield = "time"
}

AddMixinNetworkVars(StompMixin, networkVars)

function BoneShield:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, StompMixin)
    
    self.timeLastBoneShield = 0

end

function BoneShield:GetEnergyCost()
    return kStartBoneShieldCost
end

function BoneShield:GetAnimationGraphName()
    return kAnimationGraph
end

function BoneShield:GetHUDSlot()
    return 2
end

function BoneShield:GetCanUseBoneShield()
    return self.timeLastBoneShield + 2 < Shared.GetTime()
end

function BoneShield:OnPrimaryAttack(player)

    if self:GetEnergyCost() < player:GetEnergy() and player:GetIsOnGround() and self:GetCanUseBoneShield() then
        self.primaryAttacking = true
    end

end

function BoneShield:OnPrimaryAttackEnd(player)
    self.primaryAttacking = false
end

function BoneShield:OnUpdateAnimationInput(modelMixin)

    local activityString = "none"
    local abilityString = "gore"
    
    if self.primaryAttacking then
        activityString = "none" // TODO: set anim input
    end
    
    modelMixin:SetAnimationInput("ability", abilityString)
    modelMixin:SetAnimationInput("activity", activityString)
    
end

function BoneShield:OnHolster(player)

    Ability.OnHolster(self, player)
    
    self.primaryAttacking = false
    
end

function BoneShield:OnProcessMove(input)

    if self.primaryAttacking then
        
        local player = self:GetParent()
        if player then
        
            local energy = player:GetEnergy()
            player:DeductAbilityEnergy(input.time * kBoneShieldEnergyPerSecond)
            
            if player:GetEnergy() == 0 then
                self.primaryAttacking = false
                self.timeLastBoneShield = Shared.GetTime()
            end
        end
        
    end

end

Shared.LinkClassToMap("BoneShield", BoneShield.kMapName, networkVars)