// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\GrenadeThrower.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Base class for hand grenades. Override GetViewModelName and GetGrenadeMapName in implementation.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GrenadeThrower' (Weapon)

GrenadeThrower.kMapName = "grenadethrower"

kMaxHandGrenades = 2

local kGrenadeVelocity = 18

local networkVars =
{
    grenadesLeft = "integer (0 to ".. kMaxHandGrenades ..")",
}

local function ThrowGrenade(self, player)

    if Server or (Client and Client.GetIsControllingPlayer()) then

        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        local startPoint = player:GetEyePos() + viewCoords.zAxis * 0.4
        
        local startPointTrace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
        startPoint = startPointTrace.endPoint
        
        local startVelocity = viewCoords.zAxis * kGrenadeVelocity
        local grenadeClassName = self:GetGrenadeClassName()
        local grenade = player:CreatePredictedProjectile(grenadeClassName, startPoint, startVelocity, 0.7, 0.45)
    
    end

end

function GrenadeThrower:OnCreate()

    Weapon.OnCreate(self)
    
    self.grenadesLeft = kMaxHandGrenades

end

function GrenadeThrower:OnPrimaryAttack(player)

    if self.grenadesLeft > 0 then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end    

end

function GrenadeThrower:OnPrimaryAttackEnd(player)
    self.primaryAttacking = false
end

function GrenadeThrower:OnTag(tagName)

    if tagName == "throw" then
    
        local player = self:GetParent()
        if player then
        
            ThrowGrenade(self, player)
            self.grenadesLeft = math.max(0, self.grenadesLeft - 1)
            
            if self.grenadesLeft == 0 then
            
                self:OnHolster(player)
                player:RemoveWeapon(self)
                player:SwitchWeapon(1)
                
                if Server then                
                    DestroyEntity(self)
                end
                
            end
            
        end
        
    end

end

function GrenadeThrower:GetHUDSlot()
    return 5
end

function GrenadeThrower:GetViewModelName()
    assert(false)
end

function GrenadeThrower:GetAnimationGraphName()
    assert(false)
end

function GrenadeThrower:GetGrenadeClassName()
    assert(false)
end

function GrenadeThrower:OnUpdateAnimationInput(modelMixin)

    modelMixin:SetAnimationInput("activity", self.primaryAttacking and "primary" or "none")
    modelMixin:SetAnimationInput("grenadesLeft", self.grenadesLeft)

end

Shared.LinkClassToMap("GrenadeThrower", GrenadeThrower.kMapName, networkVars)