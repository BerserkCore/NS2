// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Vortex.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)  
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Blink.lua")
Script.Load("lua/Weapons/Alien/EtherealGate.lua")
Script.Load("lua/EntityChangeMixin.lua")

class 'Vortex' (Blink)

Vortex.kMapName = "vortex"

local networkVars =
{
}

local kRange = 35

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/vortex.surface_shader")

function Vortex:OnCreate()

    Blink.OnCreate(self)
 
    self.primaryAttacking = false
    
    if Server then
    
        self.etherealGateId = Entity.invalidId
        self.vortexTargetId = Entity.invalidId
        InitMixin(self, EntityChangeMixin)
        
    end

end

function Vortex:OnEntityChange(oldId, newId)

    if oldId == self.etherealGateId then
        self.etherealGateId = Entity.invalidId
    elseif oldId == self.vortexTargetId then
        self.vortexTargetId = Entity.invalidId
    end
    
end

function Vortex:DestroyOldGate()

    if self.etherealGateId ~= Entity.invalidId then
    
        local oldGate = Shared.GetEntity(self.etherealGateId)
        if oldGate then
            DestroyEntity(oldGate)
        end
        
        self.etherealGateId = Entity.invalidId
    
    end

end

function Vortex:GetAnimationGraphName()
    return kAnimationGraph
end

function Vortex:GetEnergyCost(player)
    return kVortexEnergyCost
end

function Vortex:GetPrimaryEnergyCost(player)
    return kVortexEnergyCost
end

function Vortex:GetHUDSlot()
    return 2
end

function Vortex:GetDeathIconIndex()
    return kDeathMessageIcon.Swipe
end

function Vortex:GetSecondaryTechId()
    return kTechId.Blink
end

function Vortex:GetBlinkAllowed()
    return true
end

function Vortex:OnPrimaryAttack(player)

    if not self:GetIsBlinking() and player:GetEnergy() >= self:GetEnergyCost() then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function Vortex:OnPrimaryAttackEnd()
    
    Blink.OnPrimaryAttackEnd(self)
    
    self.primaryAttacking = false
    
end

function Vortex:OnHolster(player)

    Blink.OnHolster(self, player)
    
    self.primaryAttacking = false
    
end

function Vortex:FreeOldTarget(newTarget)

    if self.vortexTargetId ~= Entity.invalidId then
    
        local oldTarget = Shared.GetEntity(self.vortexTargetId)
        if oldTarget and HasMixin(oldTarget, "VortexAble") and oldTarget ~= newTarget then
            oldTarget:FreeVortexed()
        end
        
        self.vortexTargetId = Entity.invalidId
        
    end

end

local function PerformVortex(self, player)

    local player = self:GetParent()  
    
    local viewCoords = player:GetViewAngles():GetCoords()
    local startPoint = player:GetEyePos()

    // double trace; first as a ray to allow us to hit through narrow openings, then as a fat box if the first one misses
    local trace = Shared.TraceRay(startPoint, startPoint + viewCoords.zAxis * kRange, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))

    if not trace.entity then
        local extents = GetDirectedExtentsForDiameter(viewCoords.zAxis, 0.2)
        trace = Shared.TraceBox(extents, startPoint, startPoint + viewCoords.zAxis * kRange, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
    end
    
    //self:DestroyOldGate()
    self:FreeOldTarget(trace.entity)

    if trace.entity and HasMixin(trace.entity, "VortexAble") and not trace.entity:GetIsVortexed() and trace.entity:GetCanBeVortexed() then   

        trace.entity:SetVortexDuration(kVortexDuration)
        self.vortexTargetId = trace.entity:GetId()
        
    end    
    /*    
    else
        local gate = CreateEntity(EtherealGate.kMapName, endPoint, player:GetTeamNumber())
        self.etherealGateId = gate:GetId()
    end
    */
    
end

function Vortex:OnTag(tagName)

    PROFILE("Vortex:OnTag")

    if Server and tagName == "hit" then
    
        local player = self:GetParent()
        if player then
        
            player:DeductAbilityEnergy(self:GetPrimaryEnergyCost())
            self:TriggerEffects("stab_attack")
            PerformVortex(self, player)
            
        end
        
    end
    
end

function Vortex:OnUpdateAnimationInput(modelMixin)

    PROFILE("Vortex:OnUpdateAnimationInput")

    Blink.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("ability", "vortex")
    
    local activityString = (self.primaryAttacking and "primary") or "none"
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("Vortex", Vortex.kMapName, networkVars)