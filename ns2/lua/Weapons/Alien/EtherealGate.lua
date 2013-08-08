// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\EtherealGate.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)  
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'EtherealGate' (ScriptActor)

EtherealGate.kMapName = "etherealgate"

local kLifeTime = 4
local kGrowDuration = 1
local kRange = 4
local kThinkTime = 0.2
local kCollisionRadius = 0.8

local kUpdateRate = 0.2
local kPlayerInsideTimeout = 0.7

local networkVars = { }

local kVortexLoopingSound = PrecacheAsset("sound/NS2.fev/alien/fade/vortex_loop")
local kVortexLoopingCinematic = PrecacheAsset("cinematics/alien/fade/vortex.cinematic")

local function CreateHitBox(self)

    if not self.hitBox then
    
        self.hitBox = Shared.CreatePhysicsSphereBody(false, kCollisionRadius, 1, self:GetCoords())
        self.hitBox:SetGroup(PhysicsGroup.SmallStructuresGroup)
        self.hitBox:SetEntity(self)
        self.hitBox:SetPhysicsType(CollisionObject.Kinematic)
        
    end

end

function EtherealGate:OnCreate()

    self.creationTime = Shared.GetTime()

    ScriptActor.OnCreate(self)

    if Server then
    
        self:AddTimedCallback(EtherealGate.TimeUp, kLifeTime)
        self:AddTimedCallback(EtherealGate.CheckForPlayersInside, kUpdateRate)

        self.loopingVortexSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingVortexSound:SetAsset(kVortexLoopingSound)
        self.loopingVortexSound:SetParent(self)
        
    end

end

function EtherealGate:OnInitialized()

    if Server then   
 
        self.loopingVortexSound:Start()
        self:TriggerEffects("spawn")
        
    elseif Client then
  
        if not self.vortexCinematic then
        
            self.vortexCinematic = Client.CreateCinematic(RenderScene.Zone_Default)    
            self.vortexCinematic:SetCinematic(kVortexLoopingCinematic)    
            self.vortexCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.vortexCinematic:SetCoords(self:GetCoords())
            
        end
        
    end   

    CreateHitBox(self) 

end 

function EtherealGate:GetSurfaceOverride()
    return "ethereal"
end

function EtherealGate:CheckForPlayersInside()

    local playersInside = false
    
    for _, player in ipairs(GetEntitiesWithinRange("Player", self:GetOrigin(), kRange)) do
    
        if player:GetTeamType() == kMarineTeamType or player:GetTeamType() == kAlienTeamType then
            
            playersInside = true
            break
            
        end
    
    end
    
    if playersInside then
    
        if not self.timeSincePlayersInside then
            self.timeSincePlayersInside = Shared.GetTime()
        end
    
    else
        self.timeSincePlayersInside = nil
    end
    
    return true

end

function EtherealGate:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Server then
    
        self.loopingVortexSound = nil
        
    elseif Client then
    
        self:TriggerEffects("vortex_destroy")
        
        if self.vortexCinematic then
        
            Client.DestroyCinematic(self.vortexCinematic)
            self.vortexCinematic = nil
            
        end
        
    end
    
    if self.hitBox then
    
        Shared.DestroyCollisionObject(self.hitBox)
        self.hitBox = nil
        
    end

end

function EtherealGate:TimeUp()
    
    DestroyEntity(self)
    return false
    
end

if Server then

    function EtherealGate:OnUpdate(deltaTime)

        ScriptActor.OnUpdate(self, deltaTime)
        
        // detonate all nearby projectiles
        /*
        for _, projectile in ipairs( GetEntitiesWithinRange("Projectile", self:GetOrigin(), kCollisionRadius * 1.5) ) do
        
            if projectile.Detonate then
                projectile:Detonate()
            elseif projectile.ProcessHit then
                projectile:ProcessHit(self, "ethereal", GetNormalizedVector(projectile:GetOrigin() - self:GetOrigin()))
            end
            
        end
        
        if self.timeSincePlayersInside and self.timeSincePlayersInside + kPlayerInsideTimeout < Shared.GetTime() then
            DestroyEntity(self)        
        end
        */

    end

end

Shared.LinkClassToMap("EtherealGate", EtherealGate.kMapName, networkVars)