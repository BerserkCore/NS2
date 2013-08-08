// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/Actor.lua
//
// Created by Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TimedCallbackMixin.lua")
if Server then
    Script.Load("lua/InvalidOriginMixin.lua")
end

class 'Actor' (Entity)

Actor.kMapName = "actor"

local networkVars = { }

// Set to non-empty to enable
gActorAnimDebugClass = ""

AddMixinNetworkVars(TimedCallbackMixin, networkVars)

function Actor:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TimedCallbackMixin)
    if Server then
        InitMixin(self, InvalidOriginMixin)
    end
    
    // This field is not synchronized over the network.
    self.creationTime = Shared.GetTime()
    
    self:SetUpdates(true)
    
    self:SetPropagate(Entity.Propagate_Mask)
    self:SetRelevancyDistance(kMaxRelevancyDistance)

end

function Actor:OnInitialized()

    if Client then
        self:TriggerEffects("on_init")
    end
    
end

function Actor:OnDestroy()

    if Server then
        self:TriggerEffects("on_destroy")
    end
    
    Entity.OnDestroy(self)
    
end

/**
 * Returns the time which this Actor was created at.
 */
function Actor:GetCreationTime()
    return self.creationTime
end

/** 
 * Called when actor collides with another entity. Entity hit will be nil if we hit
 * the world or if SetUserData() wasn't called on the physics actor.
 */
function Actor:OnCollision(entityHit)
end

// Hooks into effect manager
function Actor:GetEffectParams(tableParams)

    // Only override if not specified    
    if not tableParams[kEffectFilterClassName] and self.GetClassName then
        tableParams[kEffectFilterClassName] = self:GetClassName()
    end
    
    if not tableParams[kEffectHostCoords] and self.GetCoords then
        tableParams[kEffectHostCoords] = self:GetCoords()
    end
    
end

// Hooks into effect manager
function Actor:TriggerEffects(effectName, tableParams)

    PROFILE("Actor:TriggerEffects")

    if effectName and effectName ~= "" then

        if not tableParams then
            tableParams = {}
        end
        
        self:GetEffectParams(tableParams)
        
        GetEffectManager():TriggerEffects(effectName, tableParams, self)
        
    else
        Print("%s:TriggerEffects(): Called with invalid effectName)", self:GetClassName(), ToString(effectName))
    end
        
end

Shared.LinkClassToMap("Actor", Actor.kMapName, networkVars)