// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\GrenadeThrower.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Base class for hand grenades. Override GetViewModelName and GetGrenadeMapName in implementation.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kViewModelTemplates = { green = "_view.model", special = "_view_special.model", deluxe = "_view_deluxe.model" }
function GenerateMarineGrenadeViewModelPaths(grenadeType)

    local viewModels = { male = { }, female = { } }
    
    for name, suffix in pairs(kViewModelTemplates) do
        viewModels.male[name] = PrecacheAsset("models/marine/grenades/" .. grenadeType .. suffix)
    end
    
    for name, suffix in pairs(kViewModelTemplates) do
        viewModels.female[name] = PrecacheAsset("models/marine/grenades/female_" .. grenadeType .. suffix)
    end
    
    return viewModels
    
end

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

        local viewCoords = player:GetViewCoords()
        local eyePos = player:GetEyePos()

        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis, 0.2, 0, CollisionRep.Move, PhysicsMask.PredictedProjectileGroup, EntityFilterTwo(self, player))
        local startPoint = startPointTrace.endPoint

        local direction = viewCoords.zAxis
        
        if startPointTrace.fraction ~= 1 then
            direction = GetNormalizedVector(direction:GetProjection(startPointTrace.normal))
        end
        
        local grenadeClassName = self:GetGrenadeClassName()
        local grenade = player:CreatePredictedProjectile(grenadeClassName, startPoint, direction * kGrenadeVelocity, 0.7, 0.45)
    
    end

end

function GrenadeThrower:OnCreate()

    Weapon.OnCreate(self)
    
    self.grenadesLeft = kMaxHandGrenades
    
    self:SetModel(self:GetThirdPersonModelName())
    
end

function GrenadeThrower:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)
    
    // Attach weapon to parent's hand.
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    
end

function GrenadeThrower:OnPrimaryAttack(player)

    if self.grenadesLeft > 0 then
    
        if not self.primaryAttacking then
            self:TriggerEffects("grenade_pull_pin")
        end
    
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end    

end

function GrenadeThrower:OnPrimaryAttackEnd(player)
    self.primaryAttacking = false
end

function GrenadeThrower:OnTag(tagName)

    local player = self:GetParent()
    
    if tagName == "throw" then
    
        if player then
        
            ThrowGrenade(self, player)
            self.grenadesLeft = math.max(0, self.grenadesLeft - 1)
            self:SetIsVisible(false)
            self:TriggerEffects("grenade_throw")
            
        end
        
    elseif tagName == "attack_end" then
    
        if self.grenadesLeft == 0 then        
            self.readyToDestroy = true    
        else
            self:SetIsVisible(true)
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

function GrenadeThrower:GetWeight()
    return kHandGrenadeWeight
end

function GrenadeThrower:GetGrenadeClassName()
    assert(false)
end

function GrenadeThrower:OnUpdateAnimationInput(modelMixin)

    modelMixin:SetAnimationInput("activity", self.primaryAttacking and "primary" or "none")
    modelMixin:SetAnimationInput("grenadesLeft", self.grenadesLeft)
    
end

function GrenadeThrower:OverrideWeaponName()
    return "grenades"
end

if Server then

    function GrenadeThrower:OnProcessMove(input)

        Weapon.OnProcessMove(self, input)
        
        local player = self:GetParent()
        if player then

            local activeWeapon = player:GetActiveWeapon()
            local allowDestruction = self.readyToDestroy or (activeWeapon ~= self and self.grenadesLeft == 0)
        
            if allowDestruction then

                if activeWeapon == self then
                
                    self:OnHolster(player)
                    player:SwitchWeapon(1)
                    
                end
                    
                player:RemoveWeapon(self)
                DestroyEntity(self)
            
            end

        end

    end

end

Shared.LinkClassToMap("GrenadeThrower", GrenadeThrower.kMapName, networkVars)