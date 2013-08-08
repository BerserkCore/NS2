// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\BabblerClingMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Handles babblers attaching to units.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// TODO: create better effect
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/parasited.surface_shader")
local kMaterialName = "cinematics/vfx_materials/parasited.material"

BabblerClingMixin = CreateMixin(BabblerClingMixin)
BabblerClingMixin.type = "BabblerCling"

BabblerClingMixin.expectedMixins =
{
    EntityChange = "Required to update list of babbler Ids"
}

local kBabblerAttachPoints = 
{
    "babbler_attach1",
    "babbler_attach2",
    "babbler_attach3",
    "babbler_attach4",
    "babbler_attach5",
    "babbler_attach6",
}

BabblerClingMixin.networkVars =
{
    hasBabblers = "boolean"
}

function BabblerClingMixin:__initmixin()

    self.attachedBabblers = {}
    self.freeAttachPoints = {}
    table.copy(kBabblerAttachPoints, self.freeAttachPoints)

end

if Server then

    local function UpdateHasBabblers(self)

        local hasBabblers = false
        for babblerId, attachPointName in pairs(self.attachedBabblers) do
            hasBabblers = true
        end
        
        self.hasBabblers = hasBabblers

    end

    function BabblerClingMixin:AttachBabbler(babbler)
    
        local success = false
        local freeAttachPoint = #self.freeAttachPoints > 0 and self.freeAttachPoints[1] or false
        if freeAttachPoint then

            table.removevalue(self.freeAttachPoints, freeAttachPoint)
            self.attachedBabblers[babbler:GetId()] = freeAttachPoint
            babbler:SetParent(self)
            babbler:SetAttachPoint(freeAttachPoint)
            success = true

        end
        
        UpdateHasBabblers(self)        
        return success
    
    end
    
    function BabblerClingMixin:DetachBabbler(babbler)
    
        local usedAttachPoint = self.attachedBabblers[babbler:GetId()]
        if usedAttachPoint then
            table.insertunique(self.freeAttachPoints, usedAttachPoint)
        end
        self.attachedBabblers[babbler:GetId()] = nil
        UpdateHasBabblers(self)
    
    end
    
    function BabblerClingMixin:GetBabblerAttachPointCoords(babbler)
        
        local attachPointName = self.attachedBabblers[babbler:GetId()]
        if attachPointName then
            return self:GetAttachPointCoords(attachPointName)
        end
        
    end

    function BabblerClingMixin:OnEntityChange(oldId, newId)

        if self.attachedBabblers[oldId] then
        
            table.insertunique(self.freeAttachPoints, self.attachedBabblers[oldId])
            self.attachedBabblers[oldId] = nil
            UpdateHasBabblers(self) 
            
        end

    end
    
    local function DetachAll(self)
    
        for babblerId, attachPointName in pairs(self.attachedBabblers) do
        
            local babbler = Shared.GetEntity(babblerId)
            babbler:SetMoveType(kBabblerMoveType.None)
            table.insertunique(self.freeAttachPoints, attachPointName)            
        
        end
        
        self.attachedBabblers = {}
        self.hasBabblers = false
    
    end

    function BabblerClingMixin:OnKill()
        DetachAll(self)    
    end

    function BabblerClingMixin:OnDestroy()
        DetachAll(self)
    end
    
    function BabblerClingMixin:GetFreeBabblerAttachPointOrigin()
    
        local freeAttachPoint = #self.freeAttachPoints > 0 and self.freeAttachPoints[1] or false
        if freeAttachPoint then
            return self:GetAttachPointOrigin(freeAttachPoint)
        end
    
    end

end

// show an effect on the local players viewmodel
function BabblerClingMixin:OnUpdateRender()

    if self.GetIsLocalPlayer and self:GetIsLocalPlayer() then
    
        local viewModelEnt = self:GetViewModelEntity()
        local viewModel = viewModelEnt ~= nil and viewModelEnt:GetRenderModel() or nil
        
        if viewModel then
        
            if not self.babblerClingMaterial and self.hasBabblers then            
                self.babblerClingMaterial = AddMaterial(viewModel, kMaterialName)
                
            elseif self.babblerClingMaterial and not self.hasBabblers then   
         
                RemoveMaterial(viewModel, self.babblerClingMaterial)
                self.babblerClingMaterial = nil
            
            end
        
        else
            self.babblerClingMaterial = nil
        end

    end

end
