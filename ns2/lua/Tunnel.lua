// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Tunnel.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Tunnel entity, connection between 2 gorge tunnel entrances!
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TunnelProp.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/MinimapConnectionMixin.lua")

class 'Tunnel' (Entity)

local function CreateEntranceLight()

    local entranceLight = Client.CreateRenderLight()
    entranceLight:SetType( RenderLight.Type_Point )
    entranceLight:SetColor( Color(1, .7, .2) )
    entranceLight:SetIntensity( 3 )
    entranceLight:SetRadius( 10 ) 
    entranceLight:SetIsVisible(false)
    
    return entranceLight

end

local gNumTunnels = 0

local kTunnelSpacing = Vector(160, 0, 0)
local kTunnelStart = Vector(-1600, 200, -1600)

local kTunnelLength = 27

local kEntranceAPos = Vector(3, 0.5, -8)
local kEntranceBPos = Vector(3, 0.5, 8)

local kExitAPos = Vector(3, 0.25, -13.5)
local kExitBPos = Vector(3, 0.25, 13.5)

Tunnel.kModelName = PrecacheAsset("models/alien/tunnel/tunnel.model")
local kAnimationGraph = PrecacheAsset("models/alien/tunnel/tunnel.animation_graph")

local kTunnelCinematic = PrecacheAsset("cinematics/alien/tunnel/tunnel_ambient.cinematic")

local kTunnelPropAttachPoints =
{
    { "Tunnel_attachPointCeiling_00", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_02", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_03", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_04", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_05", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_06", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_07", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_08", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_09", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_10", kTunnelPropType.Ceiling },
    { "Tunnel_attachPointCeiling_11", kTunnelPropType.Ceiling },
    
    { "Tunnel_attachPointGrnd_00", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_01", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_02", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_03", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_04", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_05", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_06", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_07", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_08", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_09", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_10", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_11", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_12", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_13", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_14", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_15", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_16", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_17", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_18", kTunnelPropType.Floor },
    { "Tunnel_attachPointGrnd_19", kTunnelPropType.Floor }, 
}

local networkVars =
{
    exitAConnected = "boolean",
    exitBConnected = "boolean",
    exitAEntityPosition = "vector",
    exitBEntityPosition = "vector",
}

Tunnel.kMapName = "tunnel"

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function Tunnel:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
    if Server then
    
        gNumTunnels = gNumTunnels + 1
        
        InitMixin(self, EntityChangeMixin)
        
        self.exitAId = Entity.invalidId
        self.exitBId = Entity.invalidId
        
        self.exitAConnected = false
        self.exitBConnected = false
        
        self:SetPropagate(Entity.Propagate_Mask)
        self:SetRelevancyDistance(kMaxRelevancyDistance)
    
    end
    
    self:SetUpdates(true)

end

local function CreateRandomTunnelProps(self)

    for i = 1, #kTunnelPropAttachPoints do
    
        local attachPointEntry = kTunnelPropAttachPoints[i]
        local attachPointPosition = self:GetAttachPointOrigin(attachPointEntry[1])
        
        if attachPointPosition then
        
            local tunnelProp = CreateEntity(TunnelProp.kMapName, attachPointPosition)
            tunnelProp:SetParent(self)
            tunnelProp:SetTunnelPropType(attachPointEntry[2])
            tunnelProp:SetAttachPoint(attachPointEntry[1])
            
        end
    
    end

end

function Tunnel:OnInitialized()

    self:SetModel(Tunnel.kModelName, kAnimationGraph)

    if Server then    
    
        self:SetOrigin(gNumTunnels * kTunnelSpacing + kTunnelStart)
        CreateRandomTunnelProps(self)
        
        InitMixin(self, MinimapConnectionMixin)
      
    elseif Client then
        
        self.entranceLightA = CreateEntranceLight()
        self.entranceLightB = CreateEntranceLight()
        
        self.entranceLightA:SetCoords(Coords.GetLookIn(self:GetEntranceAPosition(), self:GetCoords().zAxis))
        self.entranceLightB:SetCoords(Coords.GetLookIn(self:GetEntranceBPosition(), -self:GetCoords().zAxis))
        
        self.tunnelCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.tunnelCinematic:SetCinematic(kTunnelCinematic)
        self.tunnelCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.tunnelCinematic:SetCoords(self:GetCoords())
    
    end

end

function Tunnel:OnDestroy()

    Entity.OnDestroy(self)
    
    if Server then    
        gNumTunnels = gNumTunnels - 1    
    elseif Client then
    
        if self.entranceLightA then
        
            Client.DestroyRenderLight(self.entranceLightA)
            self.entranceLightA = nil
            
        end  

        if self.entranceLightB then
        
            Client.DestroyRenderLight(self.entranceLightB)
            self.entranceLightB = nil
            
        end  
        
        if self.tunnelCinematic then
            
            Client.DestroyCinematic(self.tunnelCinematic)
            self.tunnelCinematic = nil
            
        end

    end 

end

if Server then
    
    function Tunnel:SetExits(exitA, exitB)
    
        assert(exitA)
        assert(exitB)
        
        self.exitAId = exitA:GetId()
        self.exitAEntityPosition = exitA:GetOrigin()
        self.timeExitAChanged = Shared.GetTime()

        self.exitBId = exitB:GetId()
        self.exitBEntityPosition = exitB:GetOrigin()
        self.timeExitBChanged = Shared.GetTime()
    
    end
 
    function Tunnel:GetConnectionStartPoint()
    
        if self.exitAConnected then
            return self.exitAEntityPosition
        end
        
    end
 
    function Tunnel:GetConnectionEndPoint()
    
        if self.exitBConnected then
            return self.exitBEntityPosition
        end
        
    end
 
    function Tunnel:AddExit(exit)
    
        assert(exit)
        
        if self.exitAId == Entity.invalidId then
        
            self.exitAId = exit:GetId()
            self.exitAEntityPosition = exit:GetOrigin()
            self.timeExitAChanged = Shared.GetTime()
        
        elseif self.exitBId == Entity.invalidId then
        
            self.exitBId = exit:GetId()
            self.exitBEntityPosition = exit:GetOrigin()
            self.timeExitBChanged = Shared.GetTime()
        
        else
        
            if self.timeExitAChanged < self.timeExitBChanged then
            
                self.exitAId = exit:GetId()
                self.timeExitAChanged = Shared.GetTime()
            
            else
            
                self.exitBId = exit:GetId()
                self.timeExitBChanged = Shared.GetTime()
            
            end
        
        end
    
    end

    local function GetUnitsInTunnel(self)        
        return GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), (kTunnelLength + 1))        
    end
    
    local function DestroyAllUnitsInside(self)
    
        for _, unit in ipairs(GetUnitsInTunnel(self)) do
        
            if HasMixin(unit, "Live") then
                unit:Kill()
            else
                DestroyEntity(unit)
            end
        
        end
    
    end
    
    function Tunnel:OnEntityChange(oldId)
    
        if self.exitAId == oldId then
            self.exitAId = Entity.invalidId
        end
        
        if self.exitBId == oldId then
            self.exitBId = Entity.invalidId
        end
    
    end
    
    local kExitRadius = 4
    local kExitOffset = Vector(0, 0.2, 0)
    
    local function UpdateExit(self, exit, position)
    
        for _, player in ipairs(GetEntitiesWithinRange("Player", position, kExitRadius)) do
   
            player:SetOrigin(exit:GetOrigin() + kExitOffset)

            local newAngles = player:GetViewAngles()
            newAngles.pitch = 0
            newAngles.roll = 0
            newAngles.yaw = newAngles.yaw + self:GetMinimapYawOffset()
            
            player:SetOffsetAngles(newAngles)
            exit:OnPlayerExited(player)
    
        end
    
    end
    
    function Tunnel:OnUpdate(deltaTime)
    
        self.exitAConnected = self.exitAId ~= Entity.invalidId and Shared.GetEntity(self.exitAId) and Shared.GetEntity(self.exitAId):GetIsAlive()
        self.exitBConnected = self.exitBId ~= Entity.invalidId and Shared.GetEntity(self.exitBId) and Shared.GetEntity(self.exitBId):GetIsAlive()

        // collapse when no exist has been found. free clientId for possible reuse later
        if not self.exitAConnected and not self.exitBConnected then
        
            DestroyAllUnitsInside(self)
            self.ownerClientId = nil
            
        else
        
            if self.exitAConnected then       
                UpdateExit(self, Shared.GetEntity(self.exitAId), self:GetExitAPosition())                
            end
            
            if self.exitBConnected then            
                UpdateExit(self, Shared.GetEntity(self.exitBId), self:GetExitBPosition())                
            end
        
        end
        
    end
    
    function Tunnel:GetOwnerClientId()
        return self.ownerClientId
    end
    
    function Tunnel:SetOwnerClientId(clientId)
        self.ownerClientId = clientId
    end
    
    function Tunnel:MovePlayerToTunnel(player, entrance)
    
        assert(player)
        assert(entrance)
        
        local entranceId = entrance:GetId()
        
        local newAngles = player:GetViewAngles()
        newAngles.pitch = 0
        newAngles.roll = 0
        
        if entranceId == self.exitAId then
        
            player:SetOrigin(self:GetEntranceAPosition())
            newAngles.yaw = GetYawFromVector(self:GetCoords().zAxis)
            player:SetOffsetAngles(newAngles)
            
        elseif entranceId == self.exitBId then
        
            player:SetOrigin(self:GetEntranceBPosition())
            newAngles.yaw = GetYawFromVector(-self:GetCoords().zAxis)
            player:SetOffsetAngles(newAngles)
            
        end
    
    end

else
    // Predict or Client
    
    function Tunnel:OnUpdateRender()
    
        self.entranceLightA:SetIsVisible(self.exitAConnected)
        self.entranceLightB:SetIsVisible(self.exitBConnected)
    
    end

end

// TODO: use attach points?
function Tunnel:GetExitAPosition()
    return self:GetOrigin() + self:GetCoords():TransformVector(kExitAPos)
end

function Tunnel:GetExitBPosition()
    return self:GetOrigin() + self:GetCoords():TransformVector(kExitBPos)
end

function Tunnel:GetEntranceAPosition()
    return self:GetOrigin() + self:GetCoords():TransformVector(kEntranceAPos)
end

function Tunnel:GetEntranceBPosition()
    return self:GetOrigin() +  self:GetCoords():TransformVector(kEntranceBPos)
end

function Tunnel:GetRelativePosition(position)

    local fractionPos = ( (-self:GetCoords().zAxis):DotProduct( self:GetOrigin() - position ) + kTunnelLength *.5) / kTunnelLength
    return (self.exitBEntityPosition - self.exitAEntityPosition) * fractionPos + self.exitAEntityPosition

end

function Tunnel:GetMinimapYawOffset()

    local tunnelDirection = GetNormalizedVector( self.exitBEntityPosition - self.exitAEntityPosition )
    return math.atan2(tunnelDirection.x, tunnelDirection.z)

end

Shared.LinkClassToMap("Tunnel", Tunnel.kMapName, networkVars)