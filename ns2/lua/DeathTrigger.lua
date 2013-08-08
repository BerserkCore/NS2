// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\DeathTrigger.lua
//
//    Created by:   Brian Cronin (brian@unknownworlds.com)
//
// Kill entity that touches this.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TechMixin.lua")
Script.Load("lua/Mixins/SignalListenerMixin.lua")

class 'DeathTrigger' (Trigger)

DeathTrigger.kMapName = "death_trigger"

local networkVars =
{
}

AddMixinNetworkVars(TechMixin, networkVars)

local function KillEntity(self, entity)

    if Server and HasMixin(entity, "Live") and entity:GetIsAlive() and entity:GetCanDie(true) then
    
        local direction = GetNormalizedVector(entity:GetModelOrigin() - self:GetOrigin())
        entity:Kill(self, self, self:GetOrigin(), direction)
        
    end
    
end

local function KillAllInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        KillEntity(self, entity)
    end
    
end

function DeathTrigger:OnCreate()

    Trigger.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, SignalListenerMixin)
    
    self.enabled = true
    
    self:RegisterSignalListener(function() KillAllInTrigger(self) end, "kill")
    
end

function DeathTrigger:OnInitialized()

    Trigger.OnInitialized(self)
    
    self:SetTriggerCollisionEnabled(true)
    
end

function DeathTrigger:OnTriggerEntered(enterEnt, triggerEnt)

    if self.enabled then
        KillEntity(self, enterEnt)
    end
    
end

Shared.LinkClassToMap("DeathTrigger", DeathTrigger.kMapName, networkVars)