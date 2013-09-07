// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\EtherealGate.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)  
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'EtherealGate' (ScriptActor)

EtherealGate.kMapName = "etherealgate"

kEtherealGateLifeTime = 20
local kGrowDuration = 1
local kRange = 4
local kThinkTime = 0.2
local kCollisionRadius = 0.8

local kUpdateRate = 0.2
local kPlayerInsideTimeout = 0.7

local networkVars = { 
    endTime = "time",
    fadeCrouched = "boolean"
}

local kVortexLoopingSound = PrecacheAsset("sound/NS2.fev/alien/fade/vortex_loop")
local kVortexLoopingCinematic = PrecacheAsset("cinematics/alien/fade/vortex.cinematic")

function EtherealGate:OnCreate()

    self.creationTime = Shared.GetTime()

    ScriptActor.OnCreate(self)

    if Server then
    
        self:AddTimedCallback(EtherealGate.TimeUp, kEtherealGateLifeTime)
        self.endTime = Shared.GetTime() + kEtherealGateLifeTime

        self.loopingVortexSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingVortexSound:SetAsset(kVortexLoopingSound)
        self.loopingVortexSound:SetParent(self)
        
    end
    
    self:SetPropagate(Entity.Propagate_Mask)
    self:SetRelevancyDistance(Math.infinity)

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
            
            local coords = self:GetCoords()
            coords.origin = coords.origin + Vector(0, 0.6, 0)            
            self.vortexCinematic:SetCoords(coords)
            
        end
        
    end   

end 

function EtherealGate:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if Server then
    
        self.loopingVortexSound = nil
        
    elseif Client then
        
        if self.vortexCinematic then
        
            Client.DestroyCinematic(self.vortexCinematic)
            self.vortexCinematic = nil
            
        end
        
    end

end

function EtherealGate:TimeUp()
    
    DestroyEntity(self)
    return false
    
end

Shared.LinkClassToMap("EtherealGate", EtherealGate.kMapName, networkVars)