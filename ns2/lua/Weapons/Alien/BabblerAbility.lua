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

Script.Load("lua/Babbler.lua")
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/BabblerPheromone.lua")
Script.Load("lua/Weapons/Alien/HealSprayMixin.lua")

class 'BabblerAbility' (Ability)

BabblerAbility.kMapName = "babblerability"

local kAnimationGraph = PrecacheAsset("models/alien/gorge/gorge_view.animation_graph")
local kPheromoneTraceWidth = 0.1

local networkVars =
{
}

AddMixinNetworkVars(HealSprayMixin, networkVars)

function BabblerAbility:OnCreate()

    Ability.OnCreate(self)
    
    self.primaryAttacking = false
    
    InitMixin(self, HealSprayMixin)
    
    if Client then
        self.babblerMoveType = kBabblerMoveType.Move
    end
    
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

function BabblerAbility:OnUpdateAnimationInput(modelMixin)

    PROFILE("BabblerAbility:OnUpdateAnimationInput")

    modelMixin:SetAnimationInput("ability", "spit")
    
    local activityString = "none"
    if self.primaryAttacking then
        activityString = "primary"
    end
    modelMixin:SetAnimationInput("activity", activityString)
    
end

function BabblerAbility:GetRange()
    return 15
end

local function FindTarget(self, player)

    local startPoint = player:GetEyePos()
    local direction = player:GetViewCoords().zAxis
    local extents = Vector(kPheromoneTraceWidth, kPheromoneTraceWidth, kPheromoneTraceWidth)
    
    local trace = Shared.TraceBox(extents, startPoint, startPoint + direction * self:GetRange(), CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
    
    local targetEntity = trace.entity
    local endPoint = trace.fraction < 1 and (trace.endPoint + trace.normal * kPheromoneTraceWidth) or nil
    
    return targetEntity, endPoint

end

local function CreateBabblerPheromone(self, player)

    local client = Server.GetOwner(player)    
    local ownerClientId = client:GetUserId()
    
    // destroy at first all other pheromones
    for _, pheromone in ientitylist(Shared.GetEntitiesWithClassname("BabblerPheromone")) do
        if pheromone:GetOwnerClientId() == ownerClientId then
            DestroyEntity(pheromone)
        end
    end

    local viewAngles = player:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()
    local startPoint = player:GetEyePos() + viewCoords.zAxis * 1
    
    local startPointTrace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
    startPoint = startPointTrace.endPoint
    
    local babblerPheromone = CreateEntity(BabblerPheromone.kMapName, startPoint, player:GetTeamNumber())
    babblerPheromone:SetOwnerClientId(ownerClientId)
    
    local startVelocity = viewCoords.zAxis * 10
    babblerPheromone:Setup(player, startVelocity, true)

end

function BabblerAbility:OnTag(tagName)

    PROFILE("BabblerAbility:OnTag")

    if self.primaryAttacking and tagName == "shoot" then
    
        local player = self:GetParent()
        
        if player then

            if Server then
                CreateBabblerPheromone(self, player)
            end
            
            player:DeductAbilityEnergy(self:GetEnergyCost())
            player:TriggerEffects("babblerability_attack")
            
            
        end
        
    end
    
end

if Client then

    local function CleanUpGUI(self)
    
        if self.babblerMoveGUI then
        
            GetGUIManager():DestroyGUIScript(self.babblerMoveGUI)
            self.babblerMoveGUI = nil
            
        end
        
    end
    
    local function CreateGUI(self)
    
        local player = self:GetParent()
        if not self.babblerMoveGUI and player and player:GetIsLocalPlayer() then        
            self.babblerMoveGUI = GetGUIManager():CreateGUIScript("GUIBabblerMoveIndicator")        
        end
    
    end

    function BabblerAbility:OnProcessIntermediate()
    
        //update babbler move type for GUI
        local player = self:GetParent()
        if player then
        
            local target, endPoint = FindTarget(self, player)
            
            if target and GetAreEnemies(self, target) and HasMixin(target, "Live") and target:GetIsAlive() then
                self.babblerMoveType = kBabblerMoveType.Attack
            
            elseif target and GetAreFriends(self, target) and HasMixin(target, "BabblerCling") and target:GetIsAlive() then
                self.babblerMoveType = kBabblerMoveType.Cling
            
            else
                self.babblerMoveType = kBabblerMoveType.Move
            end  
        
        end
        
    end

    function BabblerAbility:GetBabblerMoveType()
        return self.babblerMoveType
    end
    
    function BabblerAbility:OnDrawClient()
        
        CreateGUI(self)
        Ability.OnDrawClient(self)
        
    end
    
    function BabblerAbility:OnHolsterClient()
    
        CleanUpGUI(self)
        Ability.OnHolsterClient(self)

    end 
    
    function BabblerAbility:OnKillClient()
        CleanUpGUI(self)
    end
    
    function BabblerAbility:OnDestroy()
    
        CleanUpGUI(self)
        Ability.OnDestroy(self)
    
    end

end

Shared.LinkClassToMap("BabblerAbility", BabblerAbility.kMapName, networkVars)