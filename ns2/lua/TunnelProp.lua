// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TunnelProp.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")

kTunnelPropType = enum({'Ceiling', 'Floor'})

class 'TunnelProp' (Entity)

TunnelProp.kMapName = "tunnelprop"
local kAnimationGraph = PrecacheAsset("models/alien/tunnel/tunnel_prop.animation_graph")

local networkVars = 
{
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)

local kPropModels =
{
    [kTunnelPropType.Ceiling] = {
        PrecacheAsset("models/alien/tunnel/tunnel_attch_botTents.model"),
        PrecacheAsset("models/alien/tunnel/tunnel_attch_bulp.model"),
        PrecacheAsset("models/alien/tunnel/tunnel_attch_growth.model"),
        PrecacheAsset("models/alien/tunnel/tunnel_attch_polyps.model"),
    },
    
    [kTunnelPropType.Floor] = {
        PrecacheAsset("models/alien/tunnel/tunnel_attach_topTent.model"),
        PrecacheAsset("models/alien/tunnel/tunnel_attch_bulp.model"),
        PrecacheAsset("models/alien/tunnel/tunnel_attch_growth.model"),
        PrecacheAsset("models/alien/tunnel/tunnel_attch_polyps.model"),
    }
}


local function GetRandomPropModel(propType)

    local propModels = kPropModels[propType]
    local numModels = #propModels
    local randomIndex = math.random(1, numModels)
    
    return propModels[randomIndex]

end

function TunnelProp:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)

end

function TunnelProp:OnDestroy()

    Entity.OnDestroy(self)

end

function TunnelProp:SetTunnelPropType(propType)

    if Server then

        local randomModel = GetRandomPropModel(propType)
        self:SetModel(randomModel, kAnimationGraph)
        
    end

end

Shared.LinkClassToMap("TunnelProp", TunnelProp.kMapName, networkVars)
