// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Clog.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/OwnerMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/ClogFallMixin.lua")
Script.Load("lua/DigestMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/TargetMixin.lua")
Script.Load("lua/UsableMixin.lua")

local Shared_GetModel = Shared.GetModel

class 'Clog' (Entity)

Clog.kMapName = "clog"

Clog.kModelName = PrecacheAsset("models/alien/gorge/goowallnode.model")

local networkVars = { }

Clog.kRadius = 0.67

// clogs take maximum X damage per attack (prevents grenades being too effectfive against them), unless the attack is not a of type Flame)
Clog.kMaxShockDamage = 50

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)

function Clog:OnCreate()

    Entity.OnCreate(self)
    
    self.boneCoords = CoordsArray()
    
    InitMixin(self, EffectsMixin)
    InitMixin(self, TechMixin) 
    InitMixin(self, TeamMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, TargetMixin)
    InitMixin(self, DigestMixin)
    InitMixin(self, UsableMixin)
    
    if Server then
    
        InitMixin(self, InvalidOriginMixin)
        InitMixin(self, OwnerMixin)
        InitMixin(self, ClogFallMixin)
        InitMixin(self, EntityChangeMixin)       
        
        self:SetUpdates(false)
        
    elseif Client then
        self:SetUpdates(true)
    end
    
    self:SetPropagate(Entity.Propagate_Mask)
    self:SetRelevancyDistance(kMaxRelevancyDistance)
    
end

function Clog:OnInitialized()

    self:CreatePhysics()
    
    if Server then
    
        local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom)
        
        if sighted or self:GetTeamNumber() == 1 then

            mask = bit.bor(mask, kRelevantToTeam1Commander)   
            
        elseif self:GetTeamNumber() == 2 then
        
            mask = bit.bor(mask, kRelevantToTeam2Commander)
        
        end  
        
        self:SetExcludeRelevancyMask( mask )
    
    end

end

function Clog:CreatePhysics()

    if self.physicsModel then
        Shared.DestroyCollisionObject(self.physicsModel)
        self.physicsModel = nil
    end    

    self.physicsModel = Shared.CreatePhysicsSphereBody(true, Clog.kRadius, 20, self:GetCoords())
    self.physicsModel:SetGroup(PhysicsGroup.BigStructuresGroup)
    self.physicsModel:SetEntity(self)
    self.physicsModel:SetPhysicsType(CollisionObject.Static)

end

function Clog:OnDestroy()

    if self._renderModel ~= nil then
    
        Client.DestroyRenderModel(self._renderModel)
        self._renderModel = nil
        
    end
    
    if self.physicsModel then
    
        Shared.DestroyCollisionObject(self.physicsModel)
        self.physicsModel = nil
        
    end
    
end

function Clog:SpaceClearForEntity(location)
    return true
end

function Clog:GetIsFlameAble()
    return true
end

function Clog:GetShowCrossHairText(toPlayer)
    return false
end

function Clog:GetCanBeHealedOverride()
    return false
end

function Clog:SetCoords(coords)

    if self.physicsModel then
        self.physicsModel:SetBoneCoords(coords, self.boneCoords)
    end
    
    if self._renderModel then    
        self._renderModel:SetCoords(coords)        
    end
    
    Entity.SetCoords(self, coords)

end

function Clog:SetOrigin(origin)

    local newCoords = self:GetCoords()
    newCoords.origin = origin

    if self.physicsModel then
        self.physicsModel:SetBoneCoords(newCoords, CoordsArray())
    end
    
    if self._renderModel then    
        self._renderModel:SetCoords(newCoords)        
    end
    
    Entity.SetOrigin(self, origin)

end

function Clog:GetModelOrigin()
    return self:GetOrigin()    
end

if Server then

    function Clog:OnStarve()
        self:SetUpdates(true)
    end

    function Clog:OnStarveEnd()
        if not self:GetIsOnFire() and not self:GetIsFalling() then
            self:SetUpdates(false)
        end
    end

    function Clog:SetGameEffectMask(gameEffect, state)
    
        if gameEffect == kGameEffect.OnFire then
        
            if state == true then
                self:SetUpdates(true)
            elseif not self:GetIsFalling() then  
                self:SetUpdates(false)
            end
        
        end
    
    end

    function Clog:OnClogFall()
        self:SetUpdates(true)
    end
    
    function Clog:OnClogFallDone()
    
        if not self:GetIsOnFire() then
            self:SetUpdates(false)
        end
        
        if self.physicsModel then

            Shared.DestroyCollisionObject(self.physicsModel)
            self:CreatePhysics()
        
        end
        
    end

    function Clog:OnKill()
    
        self:TriggerEffects("death")
        DestroyEntity(self)
        
    end
    
    function Clog:GetSendDeathMessageOverride()
        return false
    end
    
    function Clog:OnCreatedByGorge(gorge)
    
        self:TriggerEffects("spawn", {effecthostcoords = self:GetCoords()})
        self:TriggerEffects("clog_slime")
    
    end

elseif Client then

    function Clog:GetShowHealthFor()
        return false
    end
    
    function Clog:OnUpdateRender()
    
        PROFILE("Clog:OnUpdateRender")
    
        if self._renderModel then
            self._renderModel:SetCoords(self:GetCoords())            
            //DebugCapsule(self:GetOrigin(), self:GetOrigin(), Clog.kRadius, 0, 0.03)
        else
            self._renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)
            self._renderModel:SetModel(Shared.GetModelIndex(Clog.kModelName))
            self._renderModel:SetCoords(self:GetCoords())  
        end
    
    end

end

function Clog:OnUpdate(deltaTime)

    if self.physicsModel then
    
        if Client and self:GetOrigin() ~= self.storedOrigin then

            self:CreatePhysics()
            self.storedOrigin = self:GetOrigin()
                
        end

    else 
        self:CreatePhysics()    
    end

end

function Clog:GetEffectParams(tableParams)

    // Only override if not specified    
    if not tableParams[kEffectFilterClassName] and self.GetClassName then
        tableParams[kEffectFilterClassName] = self:GetClassName()
    end
    
    if not tableParams[kEffectHostCoords] and self.GetCoords then
        tableParams[kEffectHostCoords] = Coords.GetTranslation( self:GetOrigin() )
    end
    
end

// simple solution for now to avoid griefing
function Clog:GetCanDigest(player)
    return player:GetIsAlive() and player:GetTeamNumber() == self:GetTeamNumber()
end

function Clog:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = player:GetTeamNumber() == self:GetTeamNumber()
end

function Clog:GetUsablePoints()
    return { self:GetOrigin() }
end

function Clog:ComputeDamageOverride(attacker, damage, damageType, time)

    if damageType ~= kDamageType.Flame and damage >= Clog.kMaxShockDamage then
        self:TriggerEffects("spawn", {effecthostcoords = self:GetCoords()})
        damage = Clog.kMaxShockDamage
    end

    return damage

end

Shared.LinkClassToMap("Clog", Clog.kMapName, networkVars)