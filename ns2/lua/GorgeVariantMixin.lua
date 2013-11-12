// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GorgeVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")

GorgeVariantMixin = CreateMixin(GorgeVariantMixin)
GorgeVariantMixin.type = "GorgeVariant"

GorgeVariantMixin.kModelNames = {}

for variant, data in pairs(kGorgeVariantData) do
    GorgeVariantMixin.kModelNames[variant] = PrecacheAsset("models/alien/gorge/gorge" .. data.modelFilePart .. ".model" )
end

GorgeVariantMixin.kDefaultModelName = GorgeVariantMixin.kModelNames[kDefaultGorgeVariant]
local kGorgeAnimationGraph = PrecacheAsset("models/alien/gorge/gorge.animation_graph")

GorgeVariantMixin.networkVars =
{
    variant = "enum kGorgeVariant",
}

function GorgeVariantMixin:__initmixin()

    self.variant = kDefaultGorgeVariant
    
end

function GorgeVariantMixin:GetVariant()
    return self.variant
end

function GorgeVariantMixin:GetVariantModel()
    return GorgeVariantMixin.kModelNames[ self.variant ]
end

if Server then

    -- Usually because the client connected or changed their options
    function GorgeVariantMixin:OnClientUpdated(client)
    
        Player.OnClientUpdated(self, client)
        
        local data = client.variantData
        if data == nil then
            return
        end
        
        local changed = data.gorgeVariant ~= self.variant
        
        if GetHasVariant(kGorgeVariantData, data.gorgeVariant, client) then
        
            -- Cleared, pass info to clients
            self.variant = data.gorgeVariant
            assert(self.variant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel(modelName, kGorgeAnimationGraph)
            
        else
            Print("ERROR: Client tried to request Gorge variant they do not have yet")
        end
        
        if changed then
        end
        
    end
    
end