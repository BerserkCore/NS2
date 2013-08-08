// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\BabblerAbility.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Spit attack on primary.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/BabblerPheromone.lua")
Script.Load("lua/Weapons/Alien/HealSprayMixin.lua")

class 'BabblerAbility' (Ability)

BabblerAbility.kMapName = "babblerability"

local kSpitSpeed = 40
local kSpitRange = 40

local kAnimationGraph = PrecacheAsset("models/alien/gorge/gorge_view.animation_graph")

local kSpitViewEffect = PrecacheAsset("cinematics/alien/gorge/spit_1p.cinematic")
local kSpitProjectileEffect = PrecacheAsset("cinematics/alien/gorge/spit_1p_projectile.cinematic")
local attackEffectMaterial = nil

if Client then

    attackEffectMaterial = Client.CreateRenderMaterial()
    attackEffectMaterial:SetMaterial("materials/effects/mesh_effects/view_spit.material")
    
end

local networkVars =
{
}

AddMixinNetworkVars(HealSprayMixin, networkVars)

function BabblerAbility:OnCreate()

    Ability.OnCreate(self)
    
    self.primaryAttacking = false
    
    InitMixin(self, HealSprayMixin)
    
end

function BabblerAbility:GetAnimationGraphName()
    return kAnimationGraph
end

function BabblerAbility:GetEnergyCost(player)
    return kBabblerPheromoneEnergyCost
end

function BabblerAbility:GetHUDSlot()
    return 4
end

function BabblerAbility:GetSecondaryTechId()
    return kTechId.Spray
end

function BabblerAbility:GetPrimaryEnergyCost()
    return kBabblerPheromoneEnergyCost
end

local function CreateSpitProjectile(self, player)   

    if Server then
        
        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        local startPoint = player:GetEyePos() + viewCoords.zAxis * 1

        local startVelocity = viewCoords.zAxis * kSpitSpeed
        
        local spit = CreateEntity(Spit.kMapName, startPoint, player:GetTeamNumber())
        SetAnglesFromVector(spit, viewCoords.zAxis)
        spit:Setup(player, startVelocity, false)
        
    end

end

local function CreatePredictedProjectile(self, player)

    local viewAngles = player:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()
    local startPoint = player:GetEyePos() - viewCoords.yAxis * 0.2
    local trace = Shared.TraceRay(startPoint, player:GetEyePos() + viewCoords.zAxis * kSpitRange, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())
    local endPoint = trace.endPoint
    local tracerVelocity = viewCoords.zAxis * kSpitSpeed

    if Server then
    
        if not self.compensatedProjectiles then
            self.compensatedProjectiles = {}
        end    
    
        local compensatedProjectile = {}
        compensatedProjectile.velocity = Vector(tracerVelocity)
        compensatedProjectile.origin = Vector(startPoint)
        compensatedProjectile.endPoint = Vector(endPoint)
        compensatedProjectile.endTime = ((startPoint - endPoint):GetLength() / kSpitSpeed) + Shared.GetTime()
        
        table.insert(self.compensatedProjectiles, compensatedProjectile)
    
    end

end

function BabblerAbility:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function BabblerAbility:OnPrimaryAttackEnd(player)

    Ability.OnPrimaryAttackEnd(self, player)
    
    self.primaryAttacking = false
    
end

function BabblerAbility:OnTag(tagName)

    PROFILE("BabblerAbility:OnTag")

    if self.primaryAttacking and tagName == "shoot" then
    
        local player = self:GetParent()
        
        if player then

            CreatePredictedProjectile(self, player)
            
            player:DeductAbilityEnergy(self:GetEnergyCost())
            
            self:TriggerEffects("babblerability_attack")
            
            if Client then
            
                local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                cinematic:SetCinematic(kSpitViewEffect)
                
                local model = player:GetViewModelEntity():GetRenderModel()

                model:RemoveMaterial(attackEffectMaterial)
                model:AddMaterial(attackEffectMaterial)
                attackEffectMaterial:SetParameter("attackTime", Shared.GetTime())
                
            end
            
        end
        
    end
    
end

function BabblerAbility:OnUpdateAnimationInput(modelMixin)

    PROFILE("BabblerAbility:OnUpdateAnimationInput")

    modelMixin:SetAnimationInput("ability", "spit")
    
    local activityString = "none"
    if self.primaryAttacking then
        activityString = "primary"
    end
    modelMixin:SetAnimationInput("activity", activityString)
    
end

function BabblerAbility:GetDeathIconIndex()
    return ConditionalValue(self.spitted, kDeathMessageIcon.Spit, kDeathMessageIcon.Spray)
end

function BabblerAbility:GetDamageType()
    return ConditionalValue(self.spitted, kSpitDamageType, kHealsprayDamageType)
end

if Server then

    function BabblerAbility:ProcessHit(position, entity)
    
        local parent = self:GetParent()
        
        if parent then
        
            local client = Server.GetOwner(parent)    
            local ownerClientId = client:GetUserId()
            
            // destroy at first all other pheromones
            for _, pheromone in ientitylist(Shared.GetEntitiesWithClassname("BabblerPheromone")) do
                if pheromone:GetOwnerClientId() == ownerClientId then
                    DestroyEntity(pheromone)
                end
            end
        
            local babblerPheromone = CreateEntity(BabblerPheromone.kMapName, position, parent:GetTeamNumber())
            babblerPheromone:SetOwnerClientId(ownerClientId)
        
            if entity and entity:isa("Alien") then
                babblerPheromone:SetAttached(entity)
            end
        
        end
    
    end

    function BabblerAbility:OnProcessMove(input)

        local player = self:GetParent()
        if self.compensatedProjectiles and player then
        
            local updateTable = {}
        
            for _, compensatedProjectile in ipairs(self.compensatedProjectiles) do
            
                if compensatedProjectile.endTime > Shared.GetTime() then
                
                    local trace = Shared.TraceRay(compensatedProjectile.origin, compensatedProjectile.origin + 3 * compensatedProjectile.velocity * input.time, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(self, player))
                    if trace.entity then                    
                        self:ProcessHit(trace.endPoint, trace.entity)                        
                    else
                        compensatedProjectile.origin = compensatedProjectile.origin + input.time * compensatedProjectile.velocity
                        table.insert(updateTable, compensatedProjectile)
                    end
                
                else
                    self:ProcessHit(compensatedProjectile.origin , nil)   
                end
            
            end
            
            self.compensatedProjectiles = updateTable
        
        end

    end

end

Shared.LinkClassToMap("BabblerAbility", BabblerAbility.kMapName, networkVars)