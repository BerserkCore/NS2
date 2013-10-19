// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========    
//    
// lua\EquipmentOutline.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

local _renderMask = 0x4
local _invRenderMask = bit.bnot(_renderMask)
local _maxDistance = 38
local _maxDistance_Commander = 60
local _enabled = true

function EquipmentOutline_Initialize()

    EquipmentOutline_camera = Client.CreateRenderCamera()
    EquipmentOutline_camera:SetTargetTexture("*equipment_outline", true)
    EquipmentOutline_camera:SetRenderMask(_renderMask)
    EquipmentOutline_camera:SetIsVisible(false)
    EquipmentOutline_camera:SetCullingMode(RenderCamera.CullingMode_Frustum)
    EquipmentOutline_camera:SetRenderSetup("shaders/Mask.render_setup")
    
    EquipmentOutline_screenEffect = Client.CreateScreenEffect("shaders/EquipmentOutline.screenfx")
    EquipmentOutline_screenEffect:SetActive(false)
    
end

function EquipmentOutline_Shudown()

    Client.DestroyRenderCamera(EquipmentOutline_camera)
    EquipmentOutline_camera = nil
    
    Client.DestroyScreenEffect(EquipmentOutline_screenEffect)
    EquipmentOutline_screenEffect = nil
    
end

/** Enables or disabls the hive vision effect. When the effect is not needed it should 
 * be disabled to boost performance. */
function EquipmentOutline_SetEnabled(enabled)

    EquipmentOutline_camera:SetIsVisible(enabled and _enabled)
    EquipmentOutline_screenEffect:SetActive(enabled and _enabled)
    
end

/** Must be called prior to rendering */
function EquipmentOutline_SyncCamera(camera, forCommander)

    local distance = ConditionalValue(forCommander, _maxDistance_Commander, _maxDistance)
    
    EquipmentOutline_camera:SetCoords(camera:GetCoords())
    EquipmentOutline_camera:SetFov(camera:GetFov())
    EquipmentOutline_camera:SetFarPlane(distance + 1)
    EquipmentOutline_screenEffect:SetParameter("time", Shared.GetTime())
    EquipmentOutline_screenEffect:SetParameter("maxDistance", distance)
    
end

/** Adds a model to the hive vision */
function EquipmentOutline_AddModel(model)

    local renderMask = model:GetRenderMask()
    model:SetRenderMask(bit.bor(renderMask, _renderMask))
    
end

/** Removes a model from the hive vision */
function EquipmentOutline_RemoveModel(model)

    local renderMask = model:GetRenderMask()
    model:SetRenderMask(bit.band(renderMask, _invRenderMask))
    
end

function EquipmentOutline_UpdateModel(forEntity)

    local player = Client.GetLocalPlayer()
    
    // Check if player can pickup this item.
    local visible = player ~= nil and forEntity:GetIsValidRecipient(player)
    local model = HasMixin(forEntity, "Model") and forEntity:GetRenderModel() or nil
    
    // Update the visibility status.
    if model and visible ~= model.equipmentVisible then
    
        if visible then
            EquipmentOutline_AddModel(model)
        else
            EquipmentOutline_RemoveModel(model)
        end
        model.equipmentVisible = visible
        
    end
    
end

// For debugging.
local function OnCommandOutline(enabled)
    _enabled = enabled ~= "false"
end
Event.Hook("Console_outline", OnCommandOutline)