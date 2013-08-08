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

function Babbler:GetSendDeathMessageOverride()
    return false
end

function Babbler:SetMoveTarget(moveTargetPos)
    self.targetPos = moveTargetPos
    self.targetId = Entity.invalidId
end

function Babbler:SetVelocity(velocity)

    self.desiredVelocity = velocity
    self.physicsBody:SetLinearVelocity(velocity)
    self.lastVelocity = velocity
    
end

/**
 * Creates the physics representation for the Babbler
 */
function Babbler:CreatePhysics()

    if not self.physicsBody then
    
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

function Babbler:SetOrientationFromVelocity()

    // Set orientation according to velocity
    local velocity = self:GetVelocity()
    if velocity:GetLengthSquared() > 0.01 and self.physicsBody then
        self:SetCoords( Coords.GetLookIn( self:GetOrigin(), velocity ) )
    end

end

function Babbler:GetOwnerClientId()
    return self.ownerClientId
end

function Babbler:SetOwner(player)

    if player then

        if self.physicsBody and player:GetController() then
            // Make sure the owner cannot collide with the Babbler
            Shared.SetPhysicsObjectCollisionsEnabled(self.physicsBody, player:GetController(), false)
        end
        
        local client = Server.GetOwner(player)    
        self.ownerClientId = client:GetUserId()

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
