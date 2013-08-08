// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//    
// lua\EffectsMixin.lua
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//  
//    Supports trigging effects in the EffectManager.
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

EffectsMixin = CreateMixin(EffectsMixin)
EffectsMixin.type = "Effects"

function EffectsMixin:__initmixin()
end

function EffectsMixin:OnInitialized()

    if Client then
        self:TriggerEffects("on_init")
    end
    
end

function EffectsMixin:OnDestroy()

    if Server then
        self:TriggerEffects("on_destroy")
    end
    
end

function EffectsMixin:GetEffectParams(tableParams)

    // Only override if not specified.
    if not tableParams[kEffectFilterClassName] and self.GetClassName then
        tableParams[kEffectFilterClassName] = self:GetClassName()
    end
    
    if not tableParams[kEffectHostCoords] and self.GetCoords then
        tableParams[kEffectHostCoords] = self:GetCoords()
    end
    
end

function EffectsMixin:TriggerEffects(effectName, tableParams)

    PROFILE("EffectsMixin:TriggerEffects")
    
    assert(effectName and effectName ~= "")
    tableParams = tableParams or { }
    
    self:GetEffectParams(tableParams)
    
    GetEffectManager():TriggerEffects(effectName, tableParams, self)
    
end