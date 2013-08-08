// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Marine\Grenade.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")

class 'Grenade' (PredictedProjectile)

Grenade.kMapName = "grenade"
Grenade.kModelName = PrecacheAsset("models/marine/rifle/rifle_grenade.model")

Grenade.kRadius = 0.17

local kMinLifeTime = .7

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)

-- Blow up after a time.
local function UpdateLifetime(self)

    // Grenades are created in predict movement, so in order to get the correct
    // lifetime, we start counting our lifetime from the first UpdateLifetime rather than when
    // we were created
    if not self.endOfLife then
    
        local lifeTime = kGrenadeLifetime
        local owner = self:GetOwner()
        if owner and GetHasTech(owner, kTechId.DetonationTimeTech) then
            lifeTime = kGrenadeUpgradedLifetime
        end

        self.endOfLife = Shared.GetTime() + lifeTime
        
    end

    if self.endOfLife <= Shared.GetTime() then
    
        self:Detonate(nil)
        return false
        
    end
    
    return true
    
end

function Grenade:OnCreate()

    PredictedProjectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, VortexAbleMixin)
    
    if Server then
    
        self:AddTimedCallback(UpdateLifetime, 0.1)
        self.endOfLife = nil
        
    end
    
end

function Grenade:GetProjectileModel()
    return Grenade.kModelName
end

function Grenade:GetDeathIconIndex()
    return kDeathMessageIcon.Grenade
end

function Grenade:GetDamageType()
    return kGrenadeLauncherGrenadeDamageType
end

function Grenade:GetIsAffectedByWeaponUpgrades()
    return false
end

function Grenade:ProcessHit(targetHit, surface)

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

if Server then
    
    function Grenade:Detonate(targetHit)
    
        // Do damage to nearby targets.
        local hitEntities = GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kGrenadeLauncherGrenadeDamageRadius)
        
        // Remove grenade and add firing player.
        table.removevalue(hitEntities, self)
        
        // full damage on direct impact
        if targetHit then
            table.removevalue(hitEntities, targetHit)
            self:DoDamage(kGrenadeLauncherGrenadeDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
        end
        
        local owner = self:GetOwner()
        // It is possible this grenade does not have an owner.
        if owner then
            table.insertunique(hitEntities, owner)
        end
        
        RadiusDamage(hitEntities, self:GetOrigin(), kGrenadeLauncherGrenadeDamageRadius, kGrenadeLauncherGrenadeDamage, self)
        
        // TODO: use what is defined in the material file
        local surface = GetSurfaceFromEntity(targetHit)
        
        if GetIsVortexed(self) then
            surface = "ethereal"
        end
        
        local params = { surface = surface }
        params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
        
        self:TriggerEffects("grenade_explode", params)
        
        CreateExplosionDecals(self)
        
        DestroyEntity(self)
        
    end
    
    function Grenade:PrepareToBeWhackedBy(whacker)
    
        self.whackerId = whacker:GetId()
        
        // It is possible that the endOfLife isn't set yet.
        if not self.endOfLife then
            self.endOfLife = 0
        end
        
        // Prolong lifetime a bit to give it time to get out of range.
        self.endOfLife = Shared.GetTime() + 0.45
        
    end
    
    function Grenade:GetWhacker()
        return self.whackerId and Shared.GetEntity(self.whackerId)
    end
    
    function Grenade:IsWhacked()
        return self.whacked == true
    end
    
    function Grenade:Whack(velocity)
    
        // whack the grenade back where it came from.
        self:SetVelocity(velocity)        
        self.whacked = true
        
    end
    
    function Grenade:GetCanDetonate()
    
        if self.creationTime then
            return self.creationTime + kMinLifeTime < Shared.GetTime()
        end
        return false
        
    end
    
end

Shared.LinkClassToMap("Grenade", Grenade.kMapName, networkVars)