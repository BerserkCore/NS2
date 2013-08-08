// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Babbler.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")

Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/MobileTargetMixin.lua")
Script.Load("lua/DamageMixin.lua")

class 'Babbler' (ScriptActor)

Babbler.kMapName = "babbler"

Babbler.kModelName = PrecacheAsset("models/alien/babbler/babbler.model")

Babbler.kUpdateMoveInterval = 0.3

Babbler.kMass = 15
Babbler.kRadius = .25
Babbler.kLinearDamping = 0
Babbler.kRestitution = .65

Babbler.kMaxSpeed = 8
Babbler.kMinSpeed = 3
Babbler.kJumpForce = 5

Babbler.kAttackRate = 0.5
Babbler.kDamage = 5

local networkVars =
{
    timeLastJump = "float",
    timeLastAttack = "float"
}

// TODO: use maybe Client.RenderModel in case we don't have animations, would remove a ton of unused netvars
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

if Server then
    Script.Load("lua/Babbler_Server.lua")
end

function Babbler:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    
    self.modelIndex = 0
    
    if Server then
    
        self.targetId = Entity.invalidId
        self.timeLastJump = 0
        self.timeLastAttack = 0
        
    elseif Client then
    
        self.oldModelIndex = 0
        self.clientTimeLastJump = 0
        self.clientTimeLastAttack = 0
        
    end
    
end

function Babbler:OnInitialized()
    
    self:SetModel(Babbler.kModelName)
    
    if Server then
    
        self:AddTimedCallback(Babbler.UpdateMove, Babbler.kUpdateMoveInterval + 2 * math.random())        
        self:SetVelocity(Vector( (math.random() * 3) - 1.5, 3, (math.random() * 3) - 1.5 ))

        InitMixin(self, MobileTargetMixin)

    end
    
end    

function Babbler:OnDestroy()

    ScriptActor.OnDestroy(self)

    if (Server) then
        Shared.DestroyCollisionObject(self.physicsBody)
        self.physicsBody = nil
    end
    
    if (Client) then
    
        // Destroy the render model.
        if (self.renderModel ~= nil) then
            Client.DestroyRenderModel(self.renderModel)
            self.renderModel = nil
        end
        
    end

end

// for testing only, babblers will be controlled as a swarm by another entity
function Babbler:FindClosestEnemy()

    local enemies = GetEntitiesForTeamWithinRange("Marine", kMarineTeamType, self:GetOrigin(), 15)
    if enemies and enemies[1] then
        self.targetId = enemies[1]:GetId()
        Print("Enemy: %s", ToString(enemies[1]))
    end
    
end

function Babbler:OnKill()

    self:TriggerEffects("death", {effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
    DestroyEntity(self)
    
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

function Babbler:UpdateMove()

    if self:GetVelocity():GetLength() < 0.5 then
    
        local target = nil
        if self.targetId ~= Entity.invalidId then
            target = Shared.GetEntity(self.targetId)
        end

        local moveVelocity = Vector(0, 0, 0)

        if target then
        
            local targetSpeed = Vector(0,0,0)            
            if target.GetVelocity then
                // babblers should not jump perfectly, so we don't consider the actual distance
                targetSpeed = target:GetVelocity() * 1.3 
            end

            local attackOrigin = target:GetOrigin()
            if target.GetEngagementPoint then
                attackOrigin = target:GetEngagementPoint()
            end    
            
            moveVelocity = self:GetMoveVelocity(attackOrigin + targetSpeed)
            
        
        elseif self.targetPos then
        
            moveVelocity = self:GetMoveVelocity(self.targetPos)
        
        // no orders, babblers will jump randomly around
        else
        
            local jump = Babbler.kJumpForce
            if math.random() > 0.5 then
                jump = Babbler.kJumpForce * .4
            end        
            moveVelocity = self:GetCoords().yAxis + Vector( (math.random() * Babbler.kMaxSpeed) - Babbler.kMaxSpeed * .5, jump, (math.random() * Babbler.kMaxSpeed) - Babbler.kMaxSpeed * .5 )
            
        end

        self:SetVelocity(moveVelocity)  
        self.timeLastJump = Shared.GetTime()

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
 * Babbler manages it's own physics body and doesn't require
 * a physics model from Actor.
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

    /*
    function Babbler:OnUpdateAnimationInput(modelMixin)

        PROFILE("Babbler:OnUpdateAnimationInput")
        
        local moveState = "idle"
        if self.jumping then
            moveState = "jump"
        elseif self.running then
            moveState = "run"
        end
        modelMixin:SetAnimationInput("move", moveState)

    end
    */
    
    function Babbler:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        if self.clientTimeLastJump ~= self.timeLastJump then
            self:TriggerEffects("babbler_jump") 
            self.clientTimeLastJump = self.timeLastJump
        end

        if self.clientTimeLastAttack ~= self.timeLastAttack then
            self:TriggerEffects("babbler_attack")
            self.clientTimeLastAttack = self.timeLastAttack 
        end    
    
    
    end

    function Babbler:OnUpdateRender()

        PROFILE("Babbler:OnUpdateRender")
        
        ScriptActor.OnUpdateRender(self)
        
        if self.oldModelIndex ~= self.modelIndex then

            // Create/destroy the model as necessary.
            if self.modelIndex == 0 then
                Client.DestroyRenderModel(self.renderModel)
                self.renderModel = nil
            else
                self.renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)
                self.renderModel:SetModel(self.modelIndex)
            end
        
            // Save off the model index so we can detect when it changes.
            self.oldModelIndex = self.modelIndex
            
        end
        
        if self.renderModel ~= nil then
            
            if self.lastPosition then
            
                if not self.moveDirection then
                    self.moveDirection = Vector(0, 0, 0)
                end
            
                local moveDirection = self:GetOrigin() - self.lastPosition
                moveDirection.y = 0
                moveDirection:Normalize()
                
                // smooth out turning of babblers
                self.moveDirection = self.moveDirection + moveDirection * 0.2
                self.moveDirection:Normalize()
                
                self.renderModel:SetCoords( Coords.GetLookIn( self:GetOrigin(), self.moveDirection ) )
            end

            self.lastPosition = self:GetOrigin()
            
        end

    end

end

function Babbler:GetShowHitIndicator()
    return false
end

Shared.LinkClassToMap("Babbler", Babbler.kMapName, networkVars)