// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\WorldTooltip.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/BaseModelMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/HighlightMixin.lua")

class 'WorldTooltip' (Entity)

WorldTooltip.kMapName            = "worldtooltip"
WorldTooltip.kModelName          = PrecacheAsset("models/misc/attentionmark/attentionmark.model")

local networkVars = { 
    tooltipText = string.format("string (%d)", kMaxEntityStringLength),
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)

function WorldTooltip:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    self.techId = kTechId.WorldTooltip
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    self:SetModel(WorldTooltip.kModelName)
    
    if Client then
        InitMixin(self, HighlightMixin)
    end
    
    self:SetUpdates(true)
    
    self:SetPhysicsCollisionRep(CollisionRep.Move)
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)

end

function WorldTooltip:OnInitialized()

    self:SetRelevancyDistance(Math.infinity)
    self.tooltipText = self.tooltip
    
end

function WorldTooltip:GetTooltipText()
    local string = Locale.ResolveString(self.tooltipText)
    return SubstituteBindStrings(string)
end  

if Client then

    function WorldTooltip:GetModelScale()
    
        local animFraction = 2 - Clamp((Shared.GetTime() - self.timeLastHightlight) / 1, 0, 1)
        return animFraction
    
    end

end

Shared.LinkClassToMap("WorldTooltip", WorldTooltip.kMapName, networkVars)