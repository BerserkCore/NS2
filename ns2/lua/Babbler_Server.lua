// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Babbler_Server.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/PhysicsGroups.lua")

function Babbler:SetTarget(target)
    if target then
        self.targetId = target:GetId()
        self.targetPos = nil
    end
end

function Babbler:SetMoveTarget(moveTargetPos)
    self.targetPos = moveTargetPos
    self.targetId = Entity.invalidId
end

function Babbler:SetVelocity(velocity)

    // workaround since AddImpulse is not working yet, use AddImpulse once it's available
    if self.physicsBody ~= nil then
        Shared.DestroyCollisionObject(self.physicsBody)
        self.physicsBody = nil
    end

    self:CreatePhysics()
    self.physicsBody:SetLinearVelocity(velocity)
    self.lastVelocity = velocity

end

/**
 * Creates the physics representation for the Babbler
 */
function Babbler:CreatePhysics()

    if (self.physicsBody == nil) then
        self.physicsBody = Shared.CreatePhysicsSphereBody(true, Babbler.kRadius, Babbler.kMass, self:GetCoords() )
        self.physicsBody:SetGravityEnabled(true)
        self.physicsBody:SetGroup( PhysicsGroup.BabblerGroup )        
        self.physicsBody:SetGroupFilterMask( PhysicsMask.BabblerFilter )
        
        self.physicsBody:SetEntity( self )

        self.physicsBody:SetCCDEnabled(false)
        self.physicsBody:SetPhysicsType( CollisionObject.Dynamic )
        self.physicsBody:SetLinearDamping(Babbler.kLinearDamping)
        self.physicsBody:SetRestitution(Babbler.kRestitution)
    end
    
end

/**
 * From Actor. We need to override as Babbler manages it's own physics.
 */
function Babbler:SetPhysicsType(physicsType)

    self.physicsType = physicsType
    
end

function Babbler:SetGravityEnabled(state)
    if self.physicsBody then
        self.physicsBody:SetGravityEnabled(state)
    else
        Print("%s:SetGravityEnabled(%s) - Physics body is nil.", self:GetClassName(), tostring(state))
    end
end   

function Babbler:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)

    self:CreatePhysics()

    // If the Babbler has moved outside of the world, destroy it
    local coords = self.physicsBody:GetCoords()
    local origin = coords.origin
    
    local maxDistance = 1000
    
    if origin:GetLengthSquared() > maxDistance * maxDistance then
        Print( "%s moved outside of the playable area, destroying", self:GetClassName() )
        DestroyEntity(self)
    else
        // Update the position/orientation of the entity based on the current
        // position/orientation of the physics object.
        self:SetCoords( coords )
    end
    
    // DL: Workaround for bouncing Babblers. Detect a change in velocity and find the impacted object
    // by tracing a ray from the last frame's origin.
    local velocity = self.physicsBody:GetLinearVelocity()
    local origin = self:GetOrigin()
    
    if self.lastVelocity ~= nil then
        local delta = velocity - self.lastVelocity
        if delta:GetLengthSquaredXZ() > 0.0001 then                    
            local endPoint = self.lastOrigin + 1.25*deltaTime*self.lastVelocity
            local trace = Shared.TraceCapsule(self.lastOrigin, endPoint, Babbler.kRadius, 0, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))

            self:SetOrigin(trace.endPoint)
            self:ProcessHit(trace.entity, trace.surface)
        end
    end
    self.lastVelocity = velocity
    self.lastOrigin = origin
    
end

function Babbler:SetOrientationFromVelocity()

    // Set orientation according to velocity
    local velocity = self:GetVelocity()
    if velocity:GetLengthSquared() > 0.01 and self.physicsBody then
        self:SetCoords( Coords.GetLookIn( self:GetOrigin(), velocity ) )
    end

end

function Babbler:SetOwner(player)

    if player ~= nil and self.physicsBody and player:GetController() then
        // Make sure the owner cannot collide with the Babbler
        Shared.SetPhysicsObjectCollisionsEnabled(self.physicsBody, player:GetController(), false)
    end
    
end

// Register for callbacks when projectiles collide with the world
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, 0)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, PhysicsGroup.DefaultGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, PhysicsGroup.BigStructuresGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, PhysicsGroup.SmallStructuresGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, PhysicsGroup.PlayerControllersGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, PhysicsGroup.CommanderPropsGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, PhysicsGroup.AttachClassGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, PhysicsGroup.CommanderUnitGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, PhysicsGroup.CollisionGeometryGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, PhysicsGroup.ProjectileGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.BabblerGroup, PhysicsGroup.WhipGroup)
