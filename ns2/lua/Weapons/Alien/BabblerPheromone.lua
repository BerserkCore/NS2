// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\BabblerPheromone.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Attracts babblers.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'BabblerPheromone' (Projectile)

BabblerPheromone.kMapName = "babblerpheromone"
BabblerPheromone.kModelName = PrecacheAsset("models/alien/babbler/babbler_ball.model")

Shared.PrecacheSurfaceShader("models/alien/babbler/babbler_ball.surface_shader")

local kBabblerSearchRange = 20
local kBabblerPheromoneDuration = 10
local kPheromoneEffectInterval = 0.15

local networkVars =
{
    destinationEntityId = "entityid",
    impact = "boolean"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function BabblerPheromone:OnCreate()

    Projectile.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)

    if Server then
    
        self.destinationEntityId = Entity.invalidId
        InitMixin(self, EntityChangeMixin)
        InitMixin(self, TeamMixin)
        
        self.timeDestroy = Shared.GetTime() + kBabblerPheromoneDuration
        self.impact = false
        
    end  

    self.radius = 0.1
    self.mass = 1
    self.linearDamping = 0
    self.restitution = 0.95

end

function BabblerPheromone:GetProjectileModel()
    return BabblerPheromone.kModelName
end

function BabblerPheromone:OnDestroy()
    
    Projectile.OnDestroy(self)
    
    if Server and not self.triggeredPuff then
        self:TriggerEffects("babbler_pheromone_puff")  
    end
        
end

function BabblerPheromone:OnUpdateRender()

    if not self.timeLastPheromoneEffect or self.timeLastPheromoneEffect + kPheromoneEffectInterval < Shared.GetTime() then

        if self.destinationEntityId and self.destinationEntityId ~= Entity.invalidId and Shared.GetEntity(self.destinationEntityId) then
            
            local destinationEntity = Shared.GetEntity(self.destinationEntityId)
            destinationEntity:TriggerEffects("babbler_pheromone")
            
        else
            self:TriggerEffects("babbler_pheromone")
        end
        
        self.timeLastPheromoneEffect = Shared.GetTime()
    
    end
    
end

function BabblerPheromone:GetSimulatePhysics()
    return not self.impact
end

function BabblerPheromone:SetAttached(target)
    self.destinationEntityId = target:GetId()
end

if Server then

    local kUp = Vector(0, 1, 0)
    function BabblerPheromone:ProcessHit(entity, surface, normal)
        
        if entity and (GetAreEnemies(self, entity) or HasMixin(entity, "BabblerCling")) and HasMixin(entity, "Live") and entity:GetIsAlive() then
        
            self.impact = true
            self.destinationEntityId = entity:GetId()
            self:SetModel(nil)     
            self:TriggerEffects("babbler_pheromone_puff")
            self.triggeredPuff = true

        end   
        
    end

    function BabblerPheromone:SetOwnerClientId(ownerId)  
        self.ownerClientId = ownerId
    end
    
    function BabblerPheromone:GetOwnerClientId()
        return self.ownerClientId
    end

    function BabblerPheromone:OnEntityChange(oldId)

        if oldId == self.destinationEntityId then
            DestroyEntity(self)
        end   
         
    end

    function BabblerPheromone:GetIsAttached()
        return self.destinationEntityId ~= Entity.invalidId
    end

    function BabblerPheromone:OnUpdate(deltaTime)
    
        Projectile.OnUpdate(self, deltaTime)
    
        if self.impact or self:GetVelocity():GetLength() > 0.2 then
        
            if self:GetIsAttached() then
                local target = Shared.GetEntity(self.destinationEntityId)
                self:SetOrigin(target:GetOrigin())
            end
            
            if self.timeDestroy < Shared.GetTime() then
                DestroyEntity(self)
            end
            
            // update just once in a while, there could be a lot of babblers around :)
            if not self.timeLastUpdate or self.timeLastUpdate + 0.3 < Shared.GetTime() then
            
                self.timeLastUpdate = Shared.GetTime()
                for _, babbler in ipairs(GetEntitiesForTeamWithinRange("Babbler", self:GetTeamNumber(), self:GetOrigin(), kBabblerSearchRange )) do
            
                    if babbler:GetOwnerClientId() == self:GetOwnerClientId() then
                        
                        // adjust babblers move type
                        local moveType = kBabblerMoveType.Move
                        local target = nil
                        local position = self:GetOrigin()
                        local giveOrder = true
                        
                        if self:GetIsAttached() then
                        
                            target = Shared.GetEntity(self.destinationEntityId)
                            if GetAreFriends(self, target) and HasMixin(target, "BabblerCling") then
                                moveType = kBabblerMoveType.Cling
                            elseif GetAreEnemies(self, target) and HasMixin(target, "Live") and target:GetIsAlive() then
                                moveType = kBabblerMoveType.Attack
                            end
                        
                        end
                        
                        if target then
                            position = HasMixin(target, "Target") and target:GetEngagementPoint() or target:GetOrigin()
                        else
                        
                            if (babbler:GetOrigin() - position):GetLength() < 2 then
                                giveOrder = false
                            end
                        
                        end
                        
                        if giveOrder then
                            babbler:SetMoveType(moveType, target, position)
                        end
                        
                    end
            
                end
                
            end 

        end   
    
    end

end

Shared.LinkClassToMap("BabblerPheromone", BabblerPheromone.kMapName, networkVars)