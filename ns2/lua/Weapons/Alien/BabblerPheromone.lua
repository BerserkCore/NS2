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

class 'BabblerPheromone' (Entity)

BabblerPheromone.kMapName = "babblerpheromone"

local kBabblerPheromoneEffect =  PrecacheAsset("cinematics/alien/gorge/babbler_pheromone.cinematic")
local kBabblerPheromoneDuration = 10

local networkVars =
{
    destination = "vector",
    destinationEntityId = "entityid"
}

function BabblerPheromone:OnCreate()

    if Server then
    
        self.destinationEntityId = Entity.invalidId
        InitMixin(self, EntityChangeMixin)
        
        self.timeDestroy = Shared.GetTime() + kBabblerPheromoneDuration
        
    end    

end

function BabblerPheromone:OnDestroy()
    
    if self.cinematic then
        Client.DestroyCinematic(self.cinematic)
        self.cinematic = nil
    end 
    
end

function BabblerPheromone:OnUpdateRender()

    if self.cinematic then
    
        self.cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.cinematic:SetCinematic(kBabblerPheromoneEffect)
        self.cinematic:SetCoords(self:GetCoords())
        self.cinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    
    end
    
end

function BabblerPheromone:SetAttached(target)
    self.destinationEntityId = target:GetId()
end

if Server then

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
    
        if self:GetIsAttached() then
            local target = Shared.GetEntity(self.destinationEntityId)
            self:SetOrigin(target)
        end
        
        if self.timeDestroy < Shared.GetTime() then
            DestroyEntity(self)
        end    
    
    end

end

Shared.LinkClassToMap("BabblerPheromone", BabblerPheromone.kMapName, networkVars)