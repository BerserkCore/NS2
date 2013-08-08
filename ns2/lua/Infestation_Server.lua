// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Infestation_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Patch of infestation created by alien commander.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function Infestation:OnHostKilled()

    self:SetUpdates(true)
    self.maxRadius = self:GetRadius()
    self.hostAlive = false
    self.minRadius = 0
    self.timeCycleStarted = Shared.GetTime()
    self.radiusCached = nil
    self.growthRate = Infestation.kDefaultGrowthRate
    self.infestationParentId = Entity.invalidId
    
    if HasMixin(self, "MapBlip") then
        self:MarkBlipDirty()
    end
    
end

function Infestation:InitMapBlipMixin()

    local coords = self:GetCoords()
    
    if coords.yAxis:DotProduct(Vector(0, 1, 0)) > 0.1 and not HasMixin(self, "MapBlip") then
        InitMixin(self, MapBlipMixin)
    end
    
end

function Infestation:OnUpdate(deltaTime)

    PROFILE("Infestation:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)

    self:UpdateInfestation(deltaTime)
    self.lastRadius = self:GetRadius()
    
end

//
// Notify entities found between lastRadius and radius that they may need to update their infestation state.
//
function Infestation:ChangeInfestationState()

    local entityIds = {}
    local smallestRadius = self:GetRadius()
    local biggestRadius = self.lastRadius or 0
    
    if smallestRadius > biggestRadius then
        smallestRadius, biggestRadius = biggestRadius, smallestRadius
    end
    
    local origin = self:GetOrigin() 
    for index, entity in ipairs(GetEntitiesWithMixinWithinRange("InfestationTracker", origin, biggestRadius)) do
    
        if entity then
        
            local range = (origin - entity:GetOrigin()):GetLength()
            if range >= smallestRadius and range <= biggestRadius then
                entity:UpdateInfestedState()
            end
            
        end
        
    end
    
end

// Update radius of infestation according to if they are connected or not! If not connected to hive, we shrink.
// If connected to hive, we grow to our max radius. The rate at which it does either is dependent on the number 
// of connections.
function Infestation:UpdateInfestation(deltaTime)

    PROFILE("Infestation:UpdateInfestation")
    
    local radius = self:GetRadius()
    
    // Mark as fully grown
    if self.hostAlive and self:GetRadius() == self:GetMaxRadius() then
    
        self:TriggerEffects("infestation_grown")
        self:SetUpdates(false)
        
    end
    
    // Kill us off when we get too small!    
    if not self.hostAlive  and radius <= 0.01 then
    
        self:TriggerEffects("death")
        DestroyEntity(self)
        
    end
    
    // if our radius has changed since our last update, find any entities in between there...
    if self.lastRadius ~= radius then
        self:ChangeInfestationState()
    end
    
    self.lastRadius = radius
    
end