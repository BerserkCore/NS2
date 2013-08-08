// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\HighlightMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/FunctionContracts.lua")

Shared.PrecacheSurfaceShader("cinematics/vfx_materials/highlightmodel.surface_shader")

HighlightMixin = CreateMixin( HighlightMixin )
HighlightMixin.type = "Hightlight"

local kHighlightTimeout = 0.5
local kFadeSecs = 1.0

function HighlightMixin:__initmixin()

    assert(Client)
    self.highlightAmount = 0
    self.timeLastHightlight = 0
    
end

function HighlightMixin:OnUpdate(deltaTime)

    self.highlightAmount = math.max(0, self.highlightAmount - deltaTime/kFadeSecs)

    local model = nil
    if HasMixin(self, "Model") then
    
        model = self:GetRenderModel()
        if model then
        
            if not self.highlightMaterial then
                self.highlightMaterial = AddMaterial(model, "cinematics/vfx_materials/highlightmodel.material")
            end
        
            self.highlightMaterial:SetParameter("intensity", self.highlightAmount)
        
        end
    
    end
    
end

function HighlightMixin:Highlight()

    local didReset = false
    
    if self.timeLastHightlight + kHighlightTimeout < Shared.GetTime() then

        // newly highlighted
        // reset highlight animation
        self.highlightAmount = 1
        didReset = true
        
    end

    self.timeLastHightlight = Shared.GetTime()
    
    return didReset

end