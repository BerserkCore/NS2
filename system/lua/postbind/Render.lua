-- Auto-generated from Render.txt - Do not edit.
local pkg, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- RenderModel FFI method additions --

function RenderModel:SetIsVisible(visible)
    pkg.RenderModel_SetIsVisible(self, visible)
end

function RenderModel:GetIsVisible()
    return (pkg.RenderModel_GetIsVisible(self))
end

function RenderModel:SetRenderMask(renderMask)
    pkg.RenderModel_SetRenderMask(self, renderMask)
end

function RenderModel:GetRenderMask()
    return (pkg.RenderModel_GetRenderMask(self))
end

function RenderModel:SetGroup(groupName)
    pkg.RenderModel_SetGroup(world, self, groupName)
end

function RenderModel:SetModelByIndex(modelIndex)
    pkg.RenderModel_SetModelByIndex(world, self, modelIndex)
end

function RenderModel:SetModelByName(modelName)
    pkg.RenderModel_SetModelByName(self, modelName)
end

function RenderModel:SetIsStatic(isStatic)
    pkg.RenderModel_SetIsStatic(self, isStatic)
end

function RenderModel:SetIsInstanced(instanced)
    pkg.RenderModel_SetIsInstanced(self, instanced)
end

function RenderModel:GetIsInstanced()
    return (pkg.RenderModel_GetIsInstanced(self))
end

function RenderModel:SetCoords(coords)
    pkg.RenderModel_SetCoords(self, coords)
end

function RenderModel:GetCoords()
    local __cdataOut = Coords()
    pkg.RenderModel_GetCoords(self, __cdataOut)

    return __cdataOut
end

function RenderModel:SetBoneCoords(boneCoords)
    pkg.RenderModel_SetBoneCoords(self, boneCoords)
end

function RenderModel:GetNumBones()
    return (pkg.RenderModel_GetNumBones(self))
end

function RenderModel:SetEntityId(entityId)
    pkg.RenderModel_SetEntityId(self, entityId)
end

function RenderModel:SetCastsShadows(castsShadows)
    pkg.RenderModel_SetCastsShadows(self, castsShadows)
end

function RenderModel:GetCastsShadows()
    return (pkg.RenderModel_GetCastsShadows(self))
end

function RenderModel:SetMaterialParameter(name, value)

    if(type(value) == "number") then
        pkg.RenderModel_SetMaterialParameter0(self, name, value)
    else
        pkg.RenderModel_SetMaterialParameter1(self, name, value)
    end
end

function RenderModel:AddMaterial(material)
    pkg.RenderModel_AddMaterial(self, material)
end

function RenderModel:RemoveMaterial(material)
    pkg.RenderModel_RemoveMaterial(self, material)
end

function RenderModel:GetNumLayers()
    return (pkg.RenderModel_GetNumLayers(self))
end

function RenderModel:InstanceMaterials()
    pkg.RenderModel_InstanceMaterials(self)
end

function RenderModel:GetZone()
    return (pkg.RenderModel_GetZone(self))
end

function RenderModel:GetNumFramesInvisible()
    return (pkg.RenderModel_GetNumFramesInvisible(self))
end

-- RenderDynamicMesh FFI method additions --

function RenderDynamicMesh:SetCoords(coords)
    pkg.RenderDynamicMesh_SetCoords(self, coords)
end

function RenderDynamicMesh:GetCoords()
    local __cdataOut = Coords()
    pkg.RenderDynamicMesh_GetCoords(self, __cdataOut)

    return __cdataOut
end

function RenderDynamicMesh:SetMaterial(material)
    pkg.RenderDynamicMesh_SetMaterial(self, material)
end

function RenderDynamicMesh:SetRenderMask(renderMask)
    pkg.RenderDynamicMesh_SetRenderMask(self, renderMask)
end

function RenderDynamicMesh:GetRenderMask()
    return (pkg.RenderDynamicMesh_GetRenderMask(self))
end

function RenderDynamicMesh:SetGroup(groupName)
    pkg.RenderDynamicMesh_SetGroup(world, self, groupName)
end

function RenderDynamicMesh:SetIsVisible(visible)
    pkg.RenderDynamicMesh_SetIsVisible(self, visible)
end

function RenderDynamicMesh:GetIsVisible()
    return (pkg.RenderDynamicMesh_GetIsVisible(self))
end

-- RenderLight FFI method additions --

function RenderLight:SetIsVisible(visible)
    pkg.RenderLight_SetIsVisible(self, visible)
end

function RenderLight:GetIsVisible()
    return (pkg.RenderLight_GetIsVisible(self))
end

function RenderLight:SetCoords(coords)
    pkg.RenderLight_SetCoords(self, coords)
end

function RenderLight:GetCoords()
    local __cdataOut = Coords()
    pkg.RenderLight_GetCoords(self, __cdataOut)

    return __cdataOut
end

function RenderLight:SetType(type)
    pkg.RenderLight_SetType(self, type)
end

function RenderLight:GetType()
    return (pkg.RenderLight_GetType(self))
end

function RenderLight:SetCastsShadows(castsShadows)
    pkg.RenderLight_SetCastsShadows(self, castsShadows)
end

function RenderLight:GetCastsShadows()
    return (pkg.RenderLight_GetCastsShadows(self))
end

function RenderLight:SetShadowFadeRate(shadowFadeRate)
    pkg.RenderLight_SetShadowFadeRate(self, shadowFadeRate)
end

function RenderLight:GetShadowFadeRate()
    return (pkg.RenderLight_GetShadowFadeRate(self))
end

function RenderLight:SetColor(color)
    pkg.RenderLight_SetColor(self, color)
end

function RenderLight:GetColor()
    local __cdataOut = Color()
    pkg.RenderLight_GetColor(self, __cdataOut)

    return __cdataOut
end

function RenderLight:SetRadius(radius)
    pkg.RenderLight_SetRadius(self, radius)
end

function RenderLight:GetRadius()
    return (pkg.RenderLight_GetRadius(self))
end

function RenderLight:SetIntensity(intensity)
    pkg.RenderLight_SetIntensity(self, intensity)
end

function RenderLight:GetIntensity()
    return (pkg.RenderLight_GetIntensity(self))
end

function RenderLight:SetInnerCone(innerCone)
    pkg.RenderLight_SetInnerCone(self, innerCone)
end

function RenderLight:GetInnerCone()
    return (pkg.RenderLight_GetInnerCone(self))
end

function RenderLight:SetOuterCone(outerCone)
    pkg.RenderLight_SetOuterCone(self, outerCone)
end

function RenderLight:GetOuterCone()
    return (pkg.RenderLight_GetOuterCone(self))
end

function RenderLight:SetRenderMask(renderMask)
    pkg.RenderLight_SetRenderMask(self, renderMask)
end

function RenderLight:GetRenderMask()
    return (pkg.RenderLight_GetRenderMask(self))
end

function RenderLight:SetDirectionalColor(_dummy2, color)
    pkg.RenderLight_SetDirectionalColor(self, _dummy2, color)
end

function RenderLight:SetAtmosphericDensity(atmosphericDensity)
    pkg.RenderLight_SetAtmosphericDensity(self, atmosphericDensity)
end

function RenderLight:GetAtmosphericDensity()
    return (pkg.RenderLight_GetAtmosphericDensity(self))
end

function RenderLight:SetSpecular(specular)
    pkg.RenderLight_SetSpecular(self, specular)
end

function RenderLight:GetSpecular()
    return (pkg.RenderLight_GetSpecular(self))
end

function RenderLight:SetGoboTexture(fileName)
    pkg.RenderLight_SetGoboTexture(self, fileName)
end

function RenderLight:SetGroup(groupName)
    pkg.RenderLight_SetGroup(world, self, groupName)
end

-- RenderDecal FFI method additions --

function RenderDecal:SetMaterial(materialFileName)

    if(type(materialFileName) == "string") then
        pkg.RenderDecal_SetMaterial0(self, materialFileName)
    else
        pkg.RenderDecal_SetMaterial1(self, materialFileName)
    end
end

function RenderDecal:SetCoords(coords)
    pkg.RenderDecal_SetCoords(self, coords)
end

function RenderDecal:GetCoords()
    local __cdataOut = Coords()
    pkg.RenderDecal_GetCoords(self, __cdataOut)

    return __cdataOut
end

function RenderDecal:SetRenderMask(renderMask)
    pkg.RenderDecal_SetRenderMask(self, renderMask)
end

function RenderDecal:GetRenderMask()
    return (pkg.RenderDecal_GetRenderMask(self))
end

function RenderDecal:SetExtents(extents)
    pkg.RenderDecal_SetExtents(self, extents)
end

-- RenderColorGrading FFI method additions --

-- ScreenEffect FFI method additions --

function ScreenEffect:SetActive(setActive)
    pkg.ScreenEffect_SetActive(self, setActive)
end

function ScreenEffect:GetActive()
    return (pkg.ScreenEffect_GetActive(self))
end

function ScreenEffect:SetParameter(name, value)

    if(type(value) == "number") then
        pkg.ScreenEffect_SetParameter0(self, name, value)
    elseif(value:isa("Vector")) then
        pkg.ScreenEffect_SetParameter1(self, name, value)
    else
        pkg.ScreenEffect_SetParameter2(self, name, value)
    end
end

function ScreenEffect:SetParameterIndex(name, index, value)

    if(type(value) == "number") then
        pkg.ScreenEffect_SetParameterIndex0(self, name, index, value)
    elseif(value:isa("Vector")) then
        pkg.ScreenEffect_SetParameterIndex1(self, name, index, value)
    else
        pkg.ScreenEffect_SetParameterIndex2(self, name, index, value)
    end
end

-- RenderCamera FFI method additions --

function RenderCamera:SetCoords(coords)
    pkg.RenderCamera_SetCoords(self, coords)
end

function RenderCamera:GetCoords()
    local __cdataOut = Coords()
    pkg.RenderCamera_GetCoords(self, __cdataOut)

    return __cdataOut
end

function RenderCamera:SetRenderMask(renderMask)
    pkg.RenderCamera_SetRenderMask(self, renderMask)
end

function RenderCamera:SetFov(fov)
    pkg.RenderCamera_SetFov(self, fov)
end

function RenderCamera:GetFov()
    return (pkg.RenderCamera_GetFov(self))
end

function RenderCamera:SetNearPlane(nearPlane)
    pkg.RenderCamera_SetNearPlane(self, nearPlane)
end

function RenderCamera:GetNearPlane()
    return (pkg.RenderCamera_GetNearPlane(self))
end

function RenderCamera:SetFarPlane(farPlane)
    pkg.RenderCamera_SetFarPlane(self, farPlane)
end

function RenderCamera:GetFarPlane()
    return (pkg.RenderCamera_GetFarPlane(self))
end

function RenderCamera:SetIsVisible(visible)
    pkg.RenderCamera_SetIsVisible(self, visible)
end

function RenderCamera:SetCullingMode(cullingMode)
    pkg.RenderCamera_SetCullingMode(self, cullingMode)
end

function RenderCamera:GetCullingMode()
    return (pkg.RenderCamera_GetCullingMode(self))
end

function RenderCamera:SetType(type)
    pkg.RenderCamera_SetType(self, type)
end

function RenderCamera:SetRenderSetup(renderSetupFile)
    pkg.RenderCamera_SetRenderSetup(self, renderSetupFile)
end

function RenderCamera:SetTargetTexture(targetName, hdr, xSize, ySize)

    if(not hdr) then
        pkg.RenderCamera_SetTargetTexture0(world, self, targetName)
    elseif(not xSize) then
        pkg.RenderCamera_SetTargetTexture1(world, self, targetName, hdr)
    else
        pkg.RenderCamera_SetTargetTexture2(world, self, targetName, hdr, xSize, ySize)
    end
end

-- RenderBillboard FFI method additions --

function RenderBillboard:SetIsVisible(visible)
    pkg.RenderBillboard_SetIsVisible(self, visible)
end

function RenderBillboard:GetIsVisible()
    return (pkg.RenderBillboard_GetIsVisible(self))
end

function RenderBillboard:SetOrigin(origin)
    pkg.RenderBillboard_SetOrigin(self, origin)
end

function RenderBillboard:SetColor(color)
    pkg.RenderBillboard_SetColor(self, color)
end

function RenderBillboard:SetMaterial(materialFileName)

    if(type(materialFileName) == "string") then
        pkg.RenderBillboard_SetMaterial0(self, materialFileName)
    else
        pkg.RenderBillboard_SetMaterial1(self, materialFileName)
    end
end

function RenderBillboard:SetSize(size)
    pkg.RenderBillboard_SetSize(self, size)
end

function RenderBillboard:SetGroup(groupName)
    pkg.RenderBillboard_SetGroup(world, self, groupName)
end

-- RenderReflectionProbe FFI method additions --

function RenderReflectionProbe:SetIsVisible(visible)
    pkg.RenderReflectionProbe_SetIsVisible(self, visible)
end

function RenderReflectionProbe:GetIsVisible()
    return (pkg.RenderReflectionProbe_GetIsVisible(self))
end

function RenderReflectionProbe:SetOrigin(origin)
    pkg.RenderReflectionProbe_SetOrigin(self, origin)
end

function RenderReflectionProbe:GetOrigin()
    local __cdataOut = Vector()
    pkg.RenderReflectionProbe_GetOrigin(self, __cdataOut)

    return __cdataOut
end

function RenderReflectionProbe:SetRadius(radius)
    pkg.RenderReflectionProbe_SetRadius(self, radius)
end

function RenderReflectionProbe:SetStrength(strength)
    pkg.RenderReflectionProbe_SetStrength(self, strength)
end

function RenderReflectionProbe:SetTint(color)
    pkg.RenderReflectionProbe_SetTint(self, color)
end

function RenderReflectionProbe:GetTint()
    local __cdataOut = Color()
    pkg.RenderReflectionProbe_GetTint(self, __cdataOut)

    return __cdataOut
end

function RenderReflectionProbe:SetGroup(groupName)
    pkg.RenderReflectionProbe_SetGroup(world, self, groupName)
end

function RenderReflectionProbe:SetRenderMask(renderMask)
    pkg.RenderReflectionProbe_SetRenderMask(self, renderMask)
end

function RenderReflectionProbe:GetRenderMask()
    return (pkg.RenderReflectionProbe_GetRenderMask(self))
end

-- RenderMaterial FFI method additions --

function RenderMaterial:SetMaterial(fileName)
    pkg.RenderMaterial_SetMaterial(self, fileName)
end

function RenderMaterial:SetParameter(name, value)

    if(type(value) == "boolean") then
        pkg.RenderMaterial_SetParameter0(self, name, value)
    elseif(type(value) == "number") then
        pkg.RenderMaterial_SetParameter1(self, name, value)
    else
        pkg.RenderMaterial_SetParameter2(self, name, value)
    end
end

-- RenderModelArray FFI method additions --

function RenderModelArray:SetIsVisible(visible)
    pkg.RenderModelArray_SetIsVisible(self, visible)
end

function RenderModelArray:GetIsVisible()
    return (pkg.RenderModelArray_GetIsVisible(self))
end

function RenderModelArray:SetRenderMask(renderMask)
    pkg.RenderModelArray_SetRenderMask(self, renderMask)
end

function RenderModelArray:GetRenderMask()
    return (pkg.RenderModelArray_GetRenderMask(self))
end

function RenderModelArray:SetCastsShadows(castsShadows)
    pkg.RenderModelArray_SetCastsShadows(self, castsShadows)
end

function RenderModelArray:GetCastsShadows()
    return (pkg.RenderModelArray_GetCastsShadows(self))
end

function RenderModelArray:InstanceMaterials()
    pkg.RenderModelArray_InstanceMaterials(self)
end

function RenderModelArray:SetMaterialParameter(name, value)

    if(type(value) == "number") then
        pkg.RenderModelArray_SetMaterialParameter0(self, name, value)
    elseif(type(value) == "string") then
        pkg.RenderModelArray_SetMaterialParameter1(self, name, value)
    else
        pkg.RenderModelArray_SetMaterialParameter2(self, name, value)
    end
end

function RenderModelArray:SetModelByIndex(modelIndex)
    pkg.RenderModelArray_SetModelByIndex(world, self, modelIndex)
end

function RenderModelArray:SetModelByName(modelName)
    pkg.RenderModelArray_SetModelByName(self, modelName)
end

function RenderModelArray:Clear()
    pkg.RenderModelArray_Clear(self)
end


