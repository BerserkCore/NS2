-- Auto-generated from Entity.txt - Do not edit.
local pkg = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- Entity FFI method additions --

function Entity:GetId()
    return (pkg.Entity_GetId(self))
end

function Entity:GetClassName()
    return (ffi_string(pkg.Entity_GetClassName(self)))
end

function Entity:GetMapName()
    return (ffi_string(pkg.Entity_GetMapName(self)))
end

function Entity:SetNextThink(nextThink)
    pkg.Entity_SetNextThink(self, nextThink)
end

function Entity:SetUpdates(updates)
    pkg.Entity_SetUpdates(self, updates)
end

function Entity:SetPropagate(propagate)
    pkg.Entity_SetPropagate(self, propagate)
end

function Entity:SetRelevancyDistance(relevancyDistance)
    pkg.Entity_SetRelevancyDistance(self, relevancyDistance)
end

function Entity:SetIncludeRelevancyMask(includeMask)
    pkg.Entity_SetIncludeRelevancyMask(self, includeMask)
end

function Entity:SetExcludeRelevancyMask(excludeMask)
    pkg.Entity_SetExcludeRelevancyMask(self, excludeMask)
end

function Entity:SetLagCompensated(lagCompensated)
    pkg.Entity_SetLagCompensated(self, lagCompensated)
end

function Entity:GetLagCompensated()
    return (pkg.Entity_GetLagCompensated(self))
end

function Entity:SetPhysicsBoundingBox(modelIndex)
    pkg.Entity_SetPhysicsBoundingBox(self, modelIndex)
end

function Entity:UpdatePhysicsBoundingBox()
    pkg.Entity_UpdatePhysicsBoundingBox(self)
end

function Entity:GetParentId()
    return (pkg.Entity_GetParentId(self))
end

function Entity:GetNumChildren()
    return (pkg.Entity_GetNumChildren(self))
end

function Entity:OnCreate()
    pkg.Entity_OnCreate(self)
end

function Entity:OnInitialized()
    pkg.Entity_OnInitialized(self)
end

function Entity:OnDestroy()
    pkg.Entity_OnDestroy(self)
end

function Entity:OnInvalidOrigin()
    pkg.Entity_OnInvalidOrigin(self)
end

function Entity:GetIsDestroyed()
    return (pkg.Entity_GetIsDestroyed(self))
end

function Entity:OnUpdate(deltaTime)
    pkg.Entity_OnUpdate(self, deltaTime)
end

function Entity:OnThink()
    pkg.Entity_OnThink(self)
end

function Entity:DisableOnPreUpdate()
    pkg.Entity_DisableOnPreUpdate(self)
end

function Entity:DisableOnUpdatePhysics()
    pkg.Entity_DisableOnUpdatePhysics(self)
end

function Entity:DisableOnUpdateRender()
    pkg.Entity_DisableOnUpdateRender(self)
end

function Entity:OnProcessMove(input)
    pkg.Entity_OnProcessMove(self, input)
end

function Entity:OnProcessSpectate(deltaTime)
    pkg.Entity_OnProcessSpectate(self, deltaTime)
end

function Entity:OnGetIsRelevant(player)
    return (pkg.Entity_OnGetIsRelevant(self, player))
end

function Entity:OnParentChanged(oldParent, newParent)
    pkg.Entity_OnParentChanged(self, oldParent, newParent)
end

function Entity:OverrideInput(input)
    local __cdataOut = Move()
    pkg.Entity_OverrideInput(self, input, __cdataOut)

    return __cdataOut
end

function Entity:GetOrigin()
    local __cdataOut = Vector()
    pkg.Entity_GetOrigin(self, __cdataOut)

    return __cdataOut
end

function Entity:SetIsVisible(visible)
    pkg.Entity_SetIsVisible(self, visible)
end

function Entity:GetIsVisible()
    return (pkg.Entity_GetIsVisible(self))
end

function Entity:SetMapEntity()
    pkg.Entity_SetMapEntity(self)
end

function Entity:GetIsMapEntity()
    return (pkg.Entity_GetIsMapEntity(self))
end

function Entity:GetAngles()
    local __cdataOut = Angles()
    pkg.Entity_GetAngles(self, __cdataOut)

    return __cdataOut
end

function Entity:SetAngles(angles)
    pkg.Entity_SetAngles(self, angles)
end

function Entity:GetDistanceToVector(origin)
    return (pkg.Entity_GetDistanceToVector(self, origin))
end

function Entity:GetDistanceSquaredToVector(origin)
    return (pkg.Entity_GetDistanceSquaredToVector(self, origin))
end


