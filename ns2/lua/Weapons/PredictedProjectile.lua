// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\PredictedProjectile.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

PredictedProjectileMixin = CreateMixin( PredictedProjectileMixin )
PredictedProjectileMixin.type = "PredictedProjectile"

local physicsMask = PhysicsMask.Bullets
local kMaxNumProjectiles = 200

function PredictedProjectileMixin:__initmixin()
    self.nextProjectileId = 0
    self.predictedProjectiles = {}
end

function PredictedProjectileShooterMixin:CreatePredictedProjectile(className, startPoint, velocity)

    local projectileController = ProjectileController()
    projectileController:Initialize(startPoint, velocity, className.radius)    
    projectileController.projectileId = self.nextProjectileId     
    projectileController.modelName = className.kModelName
    
    local projectileEntId = Entity.invalidId
    
    if Server then
        local projectile = CreateEntity(className.kMapName, startPoint, self:GetTeamNumber())
        projectile.projectileId = self.nextProjectileId
        projectile:SetController(projectileController)
        projectileEntId = projectile:GetId()
    end
    
    if Client then
    
        local projectileModel = nil
        
        local modelIndex = Shared.GetModelIndex(className.kModelName)
        if modelIndex then
        
            projectileModel = Client.CreateRenderModel(RenderScene.Zone_Default)
            projectileModel:SetModel(modelIndex)
            
        end
    
    end
    
    self.predictedProjectiles[self.nextProjectileId] = { Controller = projectileController, Model = projectileModel, EntityId = projectileEntId }
    
    self.nextProjectileId = self.nextProjectileId + 1
    if self.nextProjectileId > kMaxNumProjectiles then
        self.nextProjectileId = 0
    end

end

function PredictedProjectileShooterMixin:OnProcessMove(input)

    for projectileId, entry in pairs(self.predictedProjectiles) do

        local projectile = Shared.GetEntity(entry.EntityId)
        entry.Controller:Update(input.time, projectile)
        
        if entry.Model then
            entry.Model:SetCoords(entry.Controller:GetCoords())
        end
    
    end

end

if Server then

    function PredictedProjectileShooterMixin:OnUpdate(deltaTime)

        for projectileId, entry in pairs(self.predictedProjectiles) do
        
            local projectile = Shared.GetEntity(entry.EntityId)
            if projectile then
                projectile:SetProjectileController(entry.Controller)
            end
        
        end
        
        self.predictedProjectiles = {}

    end

end

function PredictedProjectileShooterMixin:StopProjectilePrediction(projectile)

    local entry = self.predictedProjectiles[projectile.projectileId]
    if entry then
    
        local model = entry.Model
        projectile:SetModel(model)
        entry.Controller:Uninitialize()
        
        self.predictedProjectiles[projectile.projectileId] = nil
    
    end

end

class 'ProjectileController'

function ProjectileController:Initialize(startPoint, velocity, radius, bounce, friction)

    self.controller = Shared.CreateCollisionObject()
    self.controller:SetPhysicsType(CollisionObject.Kinematic)    
    self.controller:SetGroup(PhysicsGroup.ProjectileGroup)
    self.controller:SetupSphere(radius, self.controller:GetCoords(), false)
    
    self.velocity = Vector(velocity)
    self.bounce = bounce or 0.5
    self.friction = friction or 0
    
    self.controller:SetPosition(startPoint, false)

end

local function ApplyFriction(velocity, frictionForce, deltaTime)

    if friction > 0 then
    
        local friction = -GetNormalizedVector(velocity) * deltaTime * velocity:GetLength() * frictionForce

        if math.abs(friction.x) >= math.abs(velocity.x) then
            velocity.x = 0
        else
            velocity.x = friction.x + velocity.x
        end    
        if math.abs(friction.y) >= math.abs(velocity.y) then
            velocity.y = 0
        else
            velocity.y = friction.y + velocity.y
        end    
        if math.abs(friction.z) >= math.abs(velocity.z) then
            velocity.z = 0
        else
            velocity.z = friction.z + velocity.z
        end  
    
    end

end

function ProjectileController:Update(deltaTime, projectile)

    self.velocity.y = self.velocity.y - deltaTime * 9.81
    
    // apply friction
    ApplyFriction(self.velocity, self.friction, deltaTime)

    // update position
    local trace = self.controller:Move(velocity * deltaTime, CollisionRep.Damage, CollisionRep.Damage, PhysicsMask.Bullets)
    local impact = false
    
    if trace.fraction ~= 1 then
    
        impact = true
        
        local velocityLength = self.velocity:Normalize()
        self.velocity = self.velocity:GetProjection(trace.normal)        
        self.velocity:Scale(velocityLength * self.bounce)
    
    end

    if projectile then
        projectile:SetOrigin(trace.endPoint)
        if trace.fraction ~= 1 then
            projectile:ProcessHit(trace.entity, trace.surface, trace.normal)
        end
    end

end

function ProjectileController:GetCoords()
    return self.controller:GetCoords()
end

function ProjectileController:GetPosition()
    return self.controller:GetPosition()
end    

function ProjectileController:Uninitialize()
    
    if self.controller ~= nil then
    
        Shared.DestroyCollisionObject(self.controller)
        self.controller = nil
        
    end
    
end


class 'PredictedProjectile' (Entity)

local networkVars =
{
    ownerId = "entityid",
    projectileId = "integer",
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function PredictedProjectile:OnCreate()

    Entity.OnCreate(self)

    InitMixin(self, EffectsMixin)
    InitMixin(self, TechMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, TeamMixin)
    
    if Server then
    
        InitMixin(self, InvalidOriginMixin)
        InitMixin(self, RelevancyMixin)
        InitMixin(self, OwnerMixin) 
    
    end
    
    if Client then
        
        local owner = Shared.GetEntity(self.ownerId)
        if owner and owner == Client.GetLocalPlayer() then
            owner:StopProjectilePrediction(self)
        end
        
    end

end

function PredictedProjectile:OnDestroy()

    if self.projectileController then
        
        self.projectileController:Uninitialize()
        self.projectileController = nil
        
    end
    
    if self.renderModel then
    
        Client.DestroyRenderModel(self.renderModel)
        self.renderModel = nil
    
    end

end

function PredictedProjectile:SetProjectileController(controller)
    self.projectileController = controller
end

function PredictedProjectile:SetModel(model)
    self.renderModel = model
end

if Server then

    function PredictedProjectile:OnUpdate(deltaTime)
    
        if self.projectileController then
            self:SetCoords(self.projectileController:GetCoords())
        end
    
    end

end

function PredictedProjectile:OnUpdateRender()

    if self.renderModel then
        self.renderModel:SetCoords(self:GetCoords())
    end

end


