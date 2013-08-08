// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Weapons\Marine\Railgun.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/BulletsMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'Railgun' (Entity)

Railgun.kMapName = "railgun"

local kChargeTime = 2
local kRailgunRange = 400
local kRailgunSpread = Math.Radians(0)

local networkVars =
{
    timeChargeStarted = "private time",
    railgunAttacking = "private boolean",
    shooting = "boolean"
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function Railgun:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, BulletsMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    
    self.timeChargeStarted = 0
    self.railgunAttacking = false
    self.shooting = false
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end
    
end

function Railgun:OnPrimaryAttack(player)

    if not self.railgunAttacking then
        self.timeChargeStarted = Shared.GetTime()
    end
    self.railgunAttacking = true
    
end

function Railgun:OnPrimaryAttackEnd(player)

    if self.railgunAttacking then
        self.shooting = false
    end
    
    self.railgunAttacking = false
    
end

function Railgun:GetBarrelPoint()

    local player = self:GetParent()
    if player then
    
        if player:GetIsLocalPlayer() then
        
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.65 + viewCoords.yAxis * -0.19
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.65 + viewCoords.yAxis * -0.19
            end    
        
        else
    
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.35 + viewCoords.yAxis * -0.15
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.35 + viewCoords.yAxis * -0.15
            end
            
        end    
        
    end
    
    return self:GetOrigin()
    
end

function Railgun:GetTracerEffectName()
    return kMinigunTracerEffectName
end

function Railgun:GetTracerEffectFrequency()
    return 1
end

function Railgun:GetDeathIconIndex()
    return kDeathMessageIcon.Minigun
end

local function GetChargeAmount(timeChargeStarted)
    return math.min(1, (Shared.GetTime() - timeChargeStarted) / kChargeTime)
end

local function Shoot(self, leftSide)

    local player = self:GetParent()
    
    // We can get a shoot tag even when the clip is empty if the frame rate is low
    // and the animation loops before we have time to change the state.
    if player then
    
        player:TriggerEffects("railgun_attack")
        
        local viewAngles = player:GetViewAngles()
        local shootCoords = viewAngles:GetCoords()
        
        // Filter ourself out of the trace so that we don't hit ourselves.
        local filter = EntityFilterTwo(player, self)
        local startPoint = player:GetEyePos()
        
        local spreadDirection = CalculateSpread(shootCoords, kRailgunSpread, NetworkRandom)
        
        local endPoint = startPoint + spreadDirection * kRailgunRange
        
        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
        
        if trace.fraction < 1 then
        
            local direction = (trace.endPoint - startPoint):GetUnit()
            
            local impactPoint = trace.endPoint - GetNormalizedVector(endPoint - startPoint) * kHitEffectOffset
            local surfaceName = trace.surface
            
            local effectFrequency = self:GetTracerEffectFrequency()
            local showTracer = ConditionalValue(GetIsVortexed(player), false, math.random() < effectFrequency)
            
            self:ApplyBulletGameplayEffects(player, trace.entity, trace.endPoint, direction, kRailgunDamage + (kRailgunChargeDamage * GetChargeAmount(self.timeChargeStarted)), trace.surface, showTracer)
            
            if Client and showTracer then
                TriggerFirstPersonTracer(self, trace.endPoint)
            end
            
        end
        
        self.shooting = true
        
    end
    
end

if Server then

    function Railgun:OnParentKilled(attacker, doer, point, direction)
        self.shooting = false
    end
    
end

function Railgun:ProcessMoveOnWeapon(player, input)
end

function Railgun:OnTag(tagName)

    PROFILE("Railgun:OnTag")
    
    if self:GetIsLeftSlot() and tagName == "l_shoot" then
        Shoot(self, true)
    elseif not self:GetIsLeftSlot() and tagName == "r_shoot" then
        Shoot(self, false)
    end
    
end

function Railgun:OnUpdateAnimationInput(modelMixin)

    local activity = "none"
    if self.railgunAttacking then
        activity = "primary"
    end
    modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), activity)
    
end

function Railgun:UpdateViewModelPoseParameters(viewModel)

    local chargeParam = "charge_" .. (self:GetIsLeftSlot() and "l" or "r")
    local chargeAmount = self.railgunAttacking and GetChargeAmount(self.timeChargeStarted) or 0
    viewModel:SetPoseParam(chargeParam, chargeAmount)
    
end

if Client then

    local kRailgunMuzzleEffectRate = 0.15
    local kAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "fxnode_l_railgun_muzzle", [ExoWeaponHolder.kSlotNames.Right] = "fxnode_r_railgun_muzzle" }
    local kMuzzleEffectName = PrecacheAsset("cinematics/marine/railgun/muzzle_flash.cinematic")
    
    function Railgun:GetIsActive()
        return true
    end
    
    function Railgun:GetPrimaryEffectRate()
        return kRailgunMuzzleEffectRate
    end
    
    function Railgun:GetPrimaryAttacking()
        return self.shooting
    end
    
    function Railgun:GetSecondaryAttacking()
        return false
    end
    
    function Railgun:OnClientPrimaryAttacking()
    
        local parent = self:GetParent()
        
        if parent then
            //CreateMuzzleCinematic(self, kMuzzleEffectName, kMuzzleEffectName, kAttachPoints[self:GetExoWeaponSlot()] , parent)
        end
    
    end
    
end

Shared.LinkClassToMap("Railgun", Railgun.kMapName, networkVars)