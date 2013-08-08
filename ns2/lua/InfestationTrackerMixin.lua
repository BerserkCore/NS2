// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\InfestationTrackerMixin.lua
//
// Created by: Mats Olsson (mats.olsson@matsotech.se)
//
// Tracks infested state for entities.
// Cooperates with the Infestation to update the infestation state of entities.
// Listens for changes in location for self, adding itself to the dirty table, which
// is cleaned out regularly.
// In addition, an infestation that changes its radius will also cause all entities in the
// changed radius to be marked as dirty
// ========= For more information, visit us at http://www.unknownworlds.com =====================

InfestationTrackerMixin = CreateMixin( InfestationTrackerMixin )
InfestationTrackerMixin.type = "InfestationTracker"


//
// Listen on the state that infested state depends on - ie where we are
//
InfestationTrackerMixin.expectedCallbacks = {
    SetOrigin = "Sets the location of an entity",
    SetCoords = "Sets both both location and angles",
}

// What entities have become dirty.
// Flushed in the UpdateServer hook by InfestationTrackerMixin.OnUpdateServer
InfestationTrackerMixin.dirtyTable = {}

//
// Call all dirty entities
//
function InfestationTrackerMixin.OnUpdateServer()
    PROFILE("InfestationTrackerMixin:OnUpdateServer")
    for entityId, _ in pairs(InfestationTrackerMixin.dirtyTable) do
        local entity = Shared.GetEntity(entityId)
        if entity then
            if not entity.UpdateInfestedState then
                Print("waning: %s has no implementation of UpdateInfestedState()", entity:GetClassName())
            else
                entity:UpdateInfestedState()
            end
        end
    end
    InfestationTrackerMixin.dirtyTable = {}
end


//
// Intercept the functions that changes the state the mapblip depends on
//
function InfestationTrackerMixin:SetOrigin(origin)
    InfestationTrackerMixin.dirtyTable[self:GetId()] = true
end
function InfestationTrackerMixin:SetCoords(coords)
    InfestationTrackerMixin.dirtyTable[self:GetId()] = true
end

function InfestationTrackerMixin:__initmixin()

    assert(Server)
    self.checkUntilTime = 0

end

function InfestationTrackerMixin:UpdateInfestedState()

    UpdateInfestationMask(self)    
    
end

function InfestationTrackerMixin:OnUpdate(deltaTime)

    if self.checkUntilTime ~= 0 then
        if self.checkUntilTime > Shared.GetTime() then
            self:UpdateInfestedState()
        else
            self.checkUntilTime = 0
        end
    end

end

function InfestationTrackerMixin:EnableCheckUntil(time)
    self.checkUntilTime = time
end

function InfestationTrackerMixin:InfestationNeedsUpdate()
    //Log("%s: inf update", self)
    InfestationTrackerMixin.dirtyTable[self:GetId()] = true
end

Event.Hook("UpdateServer", InfestationTrackerMixin.OnUpdateServer)