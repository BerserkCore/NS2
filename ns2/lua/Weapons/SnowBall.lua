// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Weapons\SnowBall.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/TeamMixin.lua")

class 'SnowBall' (Projectile)

SnowBall.kMapName = "SnowBall"
local kModelName = PrecacheAsset("seasonal/holiday2012/models/snowball_01.model")

local kLifetime = 60

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function SnowBall:OnCreate()

    Projectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
end

function SnowBall:OnInitialized()

    Projectile.OnInitialized(self)
    
    if Server then
        self:AddTimedCallback(SnowBall.TimeUp, kLifetime)
    end
    
end

function SnowBall:GetProjectileModel()
    return kModelName
end

if Server then

    function SnowBall:ProcessHit(targetHit, surface)
    
        if (not self:GetOwner() or targetHit ~= self:GetOwner()) then
        
            self:TriggerEffects("snowball_hit")

            DestroyEntity(self)

        end

    end
    
    function SnowBall:TimeUp(currentRate)
    
        DestroyEntity(self)
        return false
        
    end
    
end

Shared.LinkClassToMap("SnowBall", SnowBall.kMapName, networkVars)