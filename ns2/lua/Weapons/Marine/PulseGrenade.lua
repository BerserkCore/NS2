// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\PulseGrenade.lua 
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Projectile.lua")

class 'PulseGrenade' (PredictedProjectile)

Shared.PrecacheSurfaceShader("cinematics/vfx_materials/elec_trails.surface_shader")

PulseGrenade.kMapName = "pulsegrenadeprojectile"
PulseGrenade.kModelName = PrecacheAsset("models/marine/grenades/gr_pulse.model")

PulseGrenade.kRadius = 0.17
PulseGrenade.kClearOnImpact = false
PulseGrenade.kClearOnEnemyImpact = true

local networkVars = { }

local kLifeTime = 1.2

local kGrenadeCameraShakeDistance = 15
local kGrenadeMinShakeIntensity = 0.01
local kGrenadeMaxShakeIntensity = 0.14

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function PulseGrenade:OnCreate()

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    
    if Server then
    
        self:AddTimedCallback(PulseGrenade.Detonate, kLifeTime)
        
    end
    
end

function PulseGrenade:ProcessHit(targetHit)

    if targetHit and GetAreEnemies(self, targetHit) then
    
        if Server then
            self:Detonate(targetHit)
        else
            return true
        end    
    
    end

    if Server then
    
        if self:GetVelocity():GetLength() > 2 then
            self:TriggerEffects("grenade_bounce")
        end
        
    end
    
    return false
    
end

local function EnergyDamage(hitEntities, origin, radius, damage)

    for _, entity in ipairs(hitEntities) do
    
        if entity.GetEnergy and entity.SetEnergy then
        
            local targetPoint = HasMixin(entity, "Target") and entity:GetEngagementPoint() or entity:GetOrigin()
            local energyToDrain = damage *  (1 - Clamp( (targetPoint - origin):GetLength() / radius, 0, 1))
            entity:SetEnergy(entity:GetEnergy() - energyToDrain)
        
        end
    
        if entity.SetElectrified then
            entity:SetElectrified(kElectrifiedDuration)
        end
    
    end

end

function PulseGrenade:Detonate(targetHit)

    local hitEntities = GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kPulseGrenadeEnergyDamageRadius)
    table.removevalue(hitEntities, self)

    if targetHit then
    
        table.removevalue(hitEntities, targetHit)
        self:DoDamage(kPulseGrenadeDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
        
        if targetHit.SetElectrified then
            targetHit:SetElectrified(kElectrifiedDuration)
        end
        
    end
    
    local owner = self:GetOwner()
    if owner then
        table.insertunique(hitEntities, owner)
    end
    
    RadiusDamage(hitEntities, self:GetOrigin(), kPulseGrenadeDamageRadius, kPulseGrenadeDamage, self)
    EnergyDamage(hitEntities, self:GetOrigin(), kPulseGrenadeEnergyDamageRadius, kPulseGrenadeEnergyDamage)

    local surface = GetSurfaceFromEntity(targetHit)
    
    if GetIsVortexed(self) then
        surface = "ethereal"
    end

    local params = { surface = surface }
    if not targetHit then
        params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
    end
    
    self:TriggerEffects("pulse_grenade_explode", params)    
    CreateExplosionDecals(self)
    TriggerCameraShake(self, kGrenadeMinShakeIntensity, kGrenadeMaxShakeIntensity, kGrenadeCameraShakeDistance)
 
    DestroyEntity(self)

end

function PulseGrenade:GetDeathIconIndex()
    return kDeathMessageIcon.PulseGrenade
end

Shared.LinkClassToMap("PulseGrenade", PulseGrenade.kMapName, networkVars)