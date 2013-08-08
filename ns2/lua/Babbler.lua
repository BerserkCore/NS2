// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Babbler.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/MobileTargetMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/OwnerMixin.lua")
Script.Load("lua/TargetCacheMixin.lua")
Script.Load("lua/ConstructMixin.lua")

class 'Babbler' (ScriptActor)

Babbler.kMapName = "babbler"

//Babbler.kModelName = PrecacheAsset("models/alien/babbler/babbler.model")
Babbler.kEggModelName = PrecacheAsset("models/alien/egg/egg.model")

Babbler.kUpdateMoveInterval = 0.3

Babbler.kMass = 15
Babbler.kRadius = .25
Babbler.kLinearDamping = 0
Babbler.kRestitution = .65

Babbler.kTargetSearchRange = 12

Babbler.kMaxSpeed = 8
Babbler.kMinSpeed = 3
Babbler.kJumpForce = 5

Babbler.kAttackRate = 0.5
Babbler.kDamage = 5

Babbler.kLifeTime = 120

local kAnimationGraph = nil

local networkVars =
{
    timeLastJump = "float",
    timeLastAttack = "float",
    targetId = "entityid"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)

if Server then
    Script.Load("lua/Babbler_Server.lua")
end

function Babbler:OnCreate()

    ScriptActor.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, ConstructMixin)
    
    if Server then
    
        self.targetId = Entity.invalidId
        self.timeLastJump = 0
        self.timeLastAttack = 0
        
        InitMixin(self, EntityChangeMixin)
        InitMixin(self, OwnerMixin)
        
        self.targetId = Entity.invalidId
        
    elseif Client then
    
        self.oldModelIndex = 0
        self.clientTimeLastJump = 0
        self.clientTimeLastAttack = 0
        
    end
    
end

function Babbler:OnInitialized()

    self:SetModel(Babbler.kEggModelName, kAnimationGraph)

    if Server then

        InitMixin(self, MobileTargetMixin)
        
        InitMixin(self, TargetCacheMixin)
        
        self.targetSelector = TargetSelector():Init(
                self,
                Babbler.kTargetSearchRange, 
                true,
                { kAlienStaticTargets, kAlienMobileTargets })  
    
    end
    
end

if Server then

    function Babbler:OnConstructionComplete()
    
        self:SetModel(Babbler.kModelName, kAnimationGraph)
        self:CreatePhysics()
        self:AddTimedCallback(Babbler.UpdateMove, Babbler.kUpdateMoveInterval + 2 * math.random())
        self:AddTimedCallback(Babbler.UpdateTarget, 0.5)
        self:AddTimedCallback(Babbler.TimeUp, Babbler.kLifeTime)        
        self:JumpRandom()
        self:TriggerEffects("babbler_hatch")
    
    end

    function Babbler:OnEntityChange(oldId)
    
        if oldId == self.targetId then            
            self.targetId = Entity.invalidId            
        end
    
    end
    
    function Babbler:Jump(velocity)
    
        self.physicsBody:SetCoords(self:GetCoords())
        self.physicsBody:AddImpulse(self:GetOrigin(), velocity)
        self.timeLastJump = Shared.GetTime()
    
    end
    
    function Babbler:JumpRandom()
        self:Jump(Vector( (math.random() * 3) - 1.5, 3 + math.random() * 2, (math.random() * 3) - 1.5 ))
    end
    
    function Babbler:MoveRandom()
    
        self.physicsBody:SetCoords(self:GetCoords())
        self.physicsBody:AddImpulse(self:GetOrigin(), Vector( (math.random() * 6) - 3, 0.2, (math.random() * 6) - 3 ))
        
    end
    
    function Babbler:OnDestroy()

        ScriptActor.OnDestroy(self)
        
        if self.physicsBody then
        
            Shared.DestroyCollisionObject(self.physicsBody)
            self.physicsBody = nil
            
        end

    end
    
    function Babbler:OnKill()

        self:TriggerEffects("death", {effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
        DestroyEntity(self)
        
    end
    
    function Babbler:TimeUp()

        self:TriggerEffects("death", {effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
        DestroyEntity(self)
        
    end
    
    function Babbler:OnUpdate(deltaTime)

        ScriptActor.OnUpdate(self, deltaTime)

        if self.physicsBody then

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
        
        end
        
        self.lastVelocity = velocity
        self.lastOrigin = origin
        
    end

end

function Babbler:GetMoveVelocity(targetPos)

    moveVelocity = targetPos - self:GetOrigin()

    local moveSpeedXZ = moveVelocity:GetLengthXZ()

    if moveSpeedXZ > Babbler.kMaxSpeed then    
        moveVelocity:Scale(Babbler.kMaxSpeed / moveSpeedXZ)        
    elseif moveSpeedXZ < Babbler.kMinSpeed then
        moveVelocity:Scale(Babbler.kMinSpeed / (moveSpeedXZ + 0.0001) )
    end   
    
    moveVelocity.y = Babbler.kJumpForce
    
    return moveVelocity

end

function Babbler:UpdateTarget()

    self.targetId = Entity.invalidId

    local enemy = self.targetSelector:AcquireTarget()
    if enemy then
        self.targetId = enemy:GetId()    
    else
    
        local babblerPheromone = GetEntitiesForTeamWithinRange("BabblerPheromone", self:GetTeamNumber(), self:GetOrigin(), Babbler.kTargetSearchRange)
        if #babblerPheromone > 0 then
            self.targetId = babblerPheromone[1]:GetId()
        else

            local ownerGorge = self:GetOwner()       
            if ownerGorge then
            
                if (ownerGorge:GetOrigin() - self:GetOrigin()):GetLength() > 20 then
                    DestroyEntity(self)
                end
                
                if ownerGorge:isa("Gorge") then
                    self.targetId = ownerGorge:GetId()
                end
            
            end
            
        end
    
    end

    return true

end

function Babbler:GetTarget()

    local target = self.targetId ~= nil and Shared.GetEntity(self.targetId)
    return target

end

local kEyeOffset = Vector(0, 0.2, 0)
function Babbler:GetEyePos()
    return self:GetOrigin() + kEyeOffset
end

function Babbler:UpdateMove()

    if self:GetVelocity():GetLength() < 0.5 then
    
        local target = self:GetTarget()
        local moveVelocity = Vector(0, 0, 0)

        if target then
        
            local targetSpeed = Vector(0,0,0)            
            if target.GetVelocity then
                // babblers should not jump perfectly, so we don't consider the actual distance
                targetSpeed = target:GetVelocity() * 1.3 
            end

            local attackOrigin = target:GetOrigin()
            if HasMixin(target, "Target") then
                attackOrigin = target:GetEngagementPoint()
            end    
            
            moveVelocity = self:GetMoveVelocity(attackOrigin + targetSpeed)
            self:Jump(moveVelocity)
        
        // no orders, babblers will jump randomly around
        else
        
            if math.random() < 0.6 then
                self:MoveRandom()
            else
                self:JumpRandom()
            end    
                
        end
        
        self.targetSelector:AttackerMoved()
        
    end

    return true   

end

function Babbler:GetVelocity()

    if self.physicsBody then
        return self.physicsBody:GetLinearVelocity()
    end
    return Vector(0, 0, 0)
    
end

/**
 * Babbler manages it's own physics body
 */
function Babbler:GetPhysicsModelAllowedOverride()
    return false
end

/**
 * Called when the Babbler collides with something.
 */
function Babbler:ProcessHit(entityHit, surface)

    if entityHit then
    
        if HasMixin(entityHit, "Live") and HasMixin(entityHit, "Team") and entityHit:GetTeamNumber() ~= self:GetTeamNumber() then
        
            if self.timeLastAttack + Babbler.kAttackRate < Shared.GetTime() then
                
                self.timeLastAttack = Shared.GetTime()
                
                local targetOrigin = nil
                if entityHit.GetEngagementPoint then
                    targetOrigin = entityHit:GetEngagementPoint()
                else
                    targetOrigin = entityHit:GetOrigin()
                end
                
                //local attackDirection = self:GetOrigin() - targetOrigin
                //attackDirection:Normalize()
                
                self:DoDamage(Babbler.kDamage, entityHit, self:GetOrigin(), nil, surface)
            
            end
            
        end
        
    end

end 

if Client then

    function Babbler:OnAdjustModelCoords(modelCoords)
  
        if self:GetIsBuilt() and self.moveDirection then
            modelCoords = Coords.GetLookIn(modelCoords.origin, -self.moveDirection)
        end
    
        return modelCoords
    
    end

    // just updating effects here
    function Babbler:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        if self:GetIsBuilt() then
        
            if self.clientTimeLastJump ~= self.timeLastJump then
                self:TriggerEffects("babbler_jump") 
                self.clientTimeLastJump = self.timeLastJump
            end

            if self.clientTimeLastAttack ~= self.timeLastAttack then
                self:TriggerEffects("babbler_attack")
                self.clientTimeLastAttack = self.timeLastAttack 
            end
            
            if self.lastPosition then
            
                if not self.moveDirection then
                    self.moveDirection = Vector(0, 0, 0)
                end

                local moveDirection = GetNormalizedVectorXZ(self:GetOrigin() - self.lastPosition)
                
                local target = self:GetTarget()
                if target then
                    local targetPosition = target:GetOrigin()
                    moveDirection = GetNormalizedVectorXZ(targetPosition - self:GetOrigin())
                end
                
                // smooth out turning of babblers
                self.moveDirection = self.moveDirection + moveDirection * deltaTime * 8
                self.moveDirection:Normalize()
                
            end

            self.lastPosition = self:GetOrigin()
        
        end
    
    end

end

function Babbler:GetShowHitIndicator()
    return true
end

Shared.LinkClassToMap("Babbler", Babbler.kMapName, networkVars)