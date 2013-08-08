// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TunnelProp.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")

class 'TunnelProp' (Entity)

TunnelProp.kMapName = "tunnelprop"

local networkVars =
{
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)

local kPropModels =
{
    {
         PrecacheAsset("models/alien/tunnel/tunnel_prop1.model"),
         PrecacheAsset("models/alien/tunnel/tunnel_prop1.animation_graph")
    },
    
    {
         PrecacheAsset("models/alien/tunnel/tunnel_prop2.model"),
         PrecacheAsset("models/alien/tunnel/tunnel_prop2.animation_graph")
    },
}


local function GetRandomPropModel()

    local numModels = #kPropModels
    local randomIndex = math.random(1, numModels)
    
    return kPropModels[randomIndex]

end

function TunnelProp:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)

    if Server then

        local randomModel = GetRandomPropModel()
        self:SetModel(randomModel[1], randomModel[2])
        
    end

end

function TunnelProp:OnDestroy()

    Entity.OnDestroy(self)

end

Shared.LinkClassToMap("TunnelProp", TunnelProp.kMapName, networkVars)
