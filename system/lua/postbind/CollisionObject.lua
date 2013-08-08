-- Auto-generated from CollisionObject.txt - Do not edit.
local pkg, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- CollisionObject FFI method additions --

function CollisionObject:SetupCapsule(radius, height, coords, allowTrigger)
    return (pkg.CollisionObject_SetupCapsule(self, radius, height, coords, allowTrigger))
end

function CollisionObject:SetupCylinder(radius, height, coords, allowTrigger)
    return (pkg.CollisionObject_SetupCylinder(self, radius, height, coords, allowTrigger))
end

function CollisionObject:SetupSphere(radius, coords, allowTrigger)
    return (pkg.CollisionObject_SetupSphere(self, radius, coords, allowTrigger))
end

function CollisionObject:SetupBox(extents, coords, allowTrigger)
    return (pkg.CollisionObject_SetupBox(self, extents, coords, allowTrigger))
end

function CollisionObject:SetPhysicsType(physicsType)
    pkg.CollisionObject_SetPhysicsType(self, physicsType)
end

function CollisionObject:GetPhysicsType()
    return (pkg.CollisionObject_GetPhysicsType(self))
end

function CollisionObject:SetPhysicsCollisionRep(physicsCollisionRep)
    pkg.CollisionObject_SetPhysicsCollisionRep(self, physicsCollisionRep)
end

function CollisionObject:RemoveCollisionRep(collisionRep)
    pkg.CollisionObject_RemoveCollisionRep(self, collisionRep)
end

function CollisionObject:SetTriggerCollisionRep(physicsCollisionRep)
    pkg.CollisionObject_SetTriggerCollisionRep(self, physicsCollisionRep)
end

function CollisionObject:SetTriggeringCollisionRep(physicsCollisionRep)
    pkg.CollisionObject_SetTriggeringCollisionRep(self, physicsCollisionRep)
end

function CollisionObject:SetCoordsInternal(coords)
    return (pkg.CollisionObject_SetCoordsInternal(self, coords))
end

function CollisionObject:GetCoords()
    local __cdataOut = Coords()
    pkg.CollisionObject_GetCoords(self, __cdataOut)

    return __cdataOut
end

function CollisionObject:SetGroup(group)
    pkg.CollisionObject_SetGroup(self, group)
end

function CollisionObject:SetGroupFilterMask(groupFilterMask)
    pkg.CollisionObject_SetGroupFilterMask(self, groupFilterMask)
end

function CollisionObject:GetGroup()
    return (pkg.CollisionObject_GetGroup(self))
end

function CollisionObject:GetGroupFilterMask()
    return (pkg.CollisionObject_GetGroupFilterMask(self))
end

function CollisionObject:SetPositionInternal(position, allowTrigger)

    if(not allowTrigger) then
        return (pkg.CollisionObject_SetPositionInternal0(self, position))
    else
        return (pkg.CollisionObject_SetPositionInternal1(self, position, allowTrigger))
    end
end

function CollisionObject:GetPosition()
    local __cdataOut = Vector()
    pkg.CollisionObject_GetPosition(self, __cdataOut)

    return __cdataOut
end

function CollisionObject:SetGravityEnabled(gravityEnabled)
    pkg.CollisionObject_SetGravityEnabled(self, gravityEnabled)
end

function CollisionObject:GetGravityEnabled()
    return (pkg.CollisionObject_GetGravityEnabled(self))
end

function CollisionObject:SetRestitution(restitution)
    pkg.CollisionObject_SetRestitution(self, restitution)
end

function CollisionObject:GetRestitution()
    return (pkg.CollisionObject_GetRestitution(self))
end

function CollisionObject:SetLinearDamping(damping)
    pkg.CollisionObject_SetLinearDamping(self, damping)
end

function CollisionObject:GetLinearDamping()
    return (pkg.CollisionObject_GetLinearDamping(self))
end

function CollisionObject:SetLinearVelocity(velocity)
    pkg.CollisionObject_SetLinearVelocity(self, velocity)
end

function CollisionObject:GetLinearVelocity()
    local __cdataOut = Vector()
    pkg.CollisionObject_GetLinearVelocity(self, __cdataOut)

    return __cdataOut
end

function CollisionObject:SetAngularVelocity(velocity)
    pkg.CollisionObject_SetAngularVelocity(self, velocity)
end

function CollisionObject:GetAngularVelocity()
    local __cdataOut = Vector()
    pkg.CollisionObject_GetAngularVelocity(self, __cdataOut)

    return __cdataOut
end

function CollisionObject:SetCCDEnabled(ccdEnabled)
    pkg.CollisionObject_SetCCDEnabled(self, ccdEnabled)
end

function CollisionObject:AddImpulse(position, impulse)
    pkg.CollisionObject_AddImpulse(self, position, impulse)
end

function CollisionObject:SetTriggerEnabled(triggerEnabled)
    pkg.CollisionObject_SetTriggerEnabled(self, triggerEnabled)
end

function CollisionObject:GetTriggerEnabled()
    return (pkg.CollisionObject_GetTriggerEnabled(self))
end

function CollisionObject:SetTriggeringEnabled(triggeringEnabled)
    pkg.CollisionObject_SetTriggeringEnabled(self, triggeringEnabled)
end

function CollisionObject:GetTriggeringEnabled()
    return (pkg.CollisionObject_GetTriggeringEnabled(self))
end

function CollisionObject:SetCollisionEnabled(collisionEnabled)
    pkg.CollisionObject_SetCollisionEnabled(self, collisionEnabled)
end

function CollisionObject:GetCollisionEnabled()
    return (pkg.CollisionObject_GetCollisionEnabled(self))
end

function CollisionObject:GetContainsPoint(point, collisionRep)
    return (pkg.CollisionObject_GetContainsPoint(self, point, collisionRep))
end

function CollisionObject:GetBoneCoords(boneCoords)
    pkg.CollisionObject_GetBoneCoords(self, boneCoords)
end

function CollisionObject:SetBoneCoordsInternal(coords, boneCoords)
    return (pkg.CollisionObject_SetBoneCoordsInternal(self, coords, boneCoords))
end

function CollisionObject:SetBoneVelocities(boneVelocities)
    pkg.CollisionObject_SetBoneVelocities(self, boneVelocities)
end

function CollisionObject:Test(testCollisionRep, collisionRep, groupsMask)
    return (pkg.CollisionObject_Test(self, testCollisionRep, collisionRep, groupsMask))
end


