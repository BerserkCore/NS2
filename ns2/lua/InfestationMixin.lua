// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//    
// lua\InfestationMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    
//    Anything that spawns Infestation should use this.
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

InfestationMixin = CreateMixin(InfestationMixin)
InfestationMixin.type = "Infestation"

// Whatever uses the InfestationMixin needs to implement the following callback functions.
InfestationMixin.expectedCallbacks = 
{
    GetInfestationRadius = "How far infestation should spread from entity." 
}

local function TriggerInfestationReceed(self)

    for key, id in pairs(self.infestationIds) do
    
        local infestation = Shared.GetEntity(id)
        if infestation then
        
            assert(infestation:isa("Infestation"))
            infestation:OnHostKilled()
            
        end
        
        self.infestationIds[key] = Entity.invalidId
        
    end
    
end

function InfestationMixin:__initmixin()

    self.infestationIds = { }
    self.infestationIds.bottom = Entity.invalidId
    self.infestationIds.left = Entity.invalidId
    self.infestationIds.right = Entity.invalidId
    self.infestationIds.front = Entity.invalidId
    self.infestationIds.top = Entity.invalidId
    self.infestationIds.back = Entity.invalidId
    
end

local function GenerateInfestationCoords(origin, normal)

    local coords = Coords.GetIdentity()
    coords.origin = origin
    coords.yAxis = normal
    coords.zAxis = normal:GetPerpendicular()
    coords.xAxis = coords.zAxis:CrossProduct(coords.yAxis)
    
    return coords
    
end

local function OverrideSpawnInfestation(self, infestation)

    if self.OnOverrideSpawnInfestation then
        self:OnOverrideSpawnInfestation(infestation)    
    end
    
end

function InfestationMixin:SetAttached(structure)

    if structure and self.infestationIds.bottom then

        local coords = self:GetCoords()
        coords = structure:GetCoords()
        coords.origin = coords.origin + Vector(0.1, 0, 0.1)
        local infestation = Shared.GetEntity(self.infestationIds.bottom)
        
        if infestation then
            infestation:SetCoords(coords)
        end
    
    end
    
end

function InfestationMixin:SpawnInfestation(percent)

    // Let old infestation starve.
    TriggerInfestationReceed(self)
    
    local coords = self:GetCoords()
    local attached = self:GetAttached()
    if attached then
    
        // Add a small offset, otherwise we are not able to track the infested state of the techpoint.
        coords = attached:GetCoords()
        coords.origin = coords.origin + Vector(0.1, 0, 0.1)
        
    end
    
    // Floor.
    local radius = self:GetInfestationRadius()
    local infestation = CreateStructureInfestation(self, coords, self:GetTeamNumber(), radius, percent)
    self.infestationIds.bottom = infestation:GetId()
    OverrideSpawnInfestation(self, infestation)
    
    // Ceiling.
    local trace = Shared.TraceRay(self:GetOrigin() + coords.yAxis * 0.1, self:GetOrigin() + coords.yAxis * radius,  CollisionRep.Default,  PhysicsMask.Bullets, EntityFilterAll())
    local roomMiddlePoint = self:GetOrigin() + coords.yAxis * 0.1
    if trace.fraction ~= 1 then
        
        infestation = CreateStructureInfestation(self, GenerateInfestationCoords(trace.endPoint, trace.normal), self:GetTeamNumber(), radius, percent)
        self.infestationIds.top = infestation:GetId()
        OverrideSpawnInfestation(self, infestation)
        roomMiddlePoint = (trace.endPoint - self:GetOrigin()) * 0.5 + self:GetOrigin()
        
    end
    
    // Front wall.
    trace = Shared.TraceRay(roomMiddlePoint, roomMiddlePoint + coords.zAxis * radius, CollisionRep.Default,  PhysicsMask.Bullets, EntityFilterAll())
    if trace.fraction ~= 1 then
    
        infestation = CreateStructureInfestation(self, GenerateInfestationCoords(trace.endPoint, trace.normal), self:GetTeamNumber(), radius, percent)
        self.infestationIds.front = infestation:GetId()
        OverrideSpawnInfestation(self, infestation)
        
    end
    
    // Back wall.
    trace = Shared.TraceRay(roomMiddlePoint, roomMiddlePoint - coords.zAxis * radius, CollisionRep.Default,  PhysicsMask.Bullets, EntityFilterAll())
    if trace.fraction ~= 1 then
    
        infestation = CreateStructureInfestation(self, GenerateInfestationCoords(trace.endPoint, trace.normal), self:GetTeamNumber(), radius, percent)
        self.infestationIds.back = infestation:GetId()
        OverrideSpawnInfestation(self, infestation)
        
    end
    
    // Left wall.
    trace = Shared.TraceRay(roomMiddlePoint, roomMiddlePoint + coords.xAxis * radius, CollisionRep.Default,  PhysicsMask.Bullets, EntityFilterAll())
    if trace.fraction ~= 1 then
    
        infestation = CreateStructureInfestation(self, GenerateInfestationCoords(trace.endPoint, trace.normal), self:GetTeamNumber(), radius, percent)
        self.infestationIds.left = infestation:GetId()
        OverrideSpawnInfestation(self, infestation)
        
    end
    
    // Right wall.
    trace = Shared.TraceRay(roomMiddlePoint, roomMiddlePoint - coords.xAxis * radius, CollisionRep.Default,  PhysicsMask.Bullets, EntityFilterAll())
    if trace.fraction ~= 1 then
    
        infestation = CreateStructureInfestation(self, GenerateInfestationCoords(trace.endPoint, trace.normal), self:GetTeamNumber(), radius, percent)
        self.infestationIds.right = infestation:GetId()
        OverrideSpawnInfestation(self, infestation)
        
    end
    
    if GetAndCheckBoolean(self.startsBuilt, "startsBuilt", false) then    
        self:SetInfestationFullyGrown()    
    end
    
end

function InfestationMixin:SetInfestationFullyGrown()

    for _, id in pairs(self.infestationIds) do
    
        local infestation = Shared.GetEntity(id)
        
        // It is possible for there to not be infestation on some of the sides.
        if infestation then
        
            assert(infestation:isa("Infestation"))
            infestation:SetFullyGrown()
            
        end
        
    end
    
end

function InfestationMixin:OnConstructionComplete()
    self:SpawnInfestation()
end

function InfestationMixin:SetExcludeRelevancyMask(mask)
    
    for _, id in pairs(self.infestationIds) do
    
        local infestation = Shared.GetEntity(id)
        if infestation then
            infestation:SetExcludeRelevancyMask(mask)            
        end
        
    end
end

function InfestationMixin:OnSighted(sighted)

    for _, id in pairs(self.infestationIds) do
    
        local infestation = Shared.GetEntity(id)
        if infestation then
            infestation:SetIsSighted(sighted)
        end
        
    end
    
end

function InfestationMixin:OnKill()
    TriggerInfestationReceed(self)
end