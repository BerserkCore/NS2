-- Auto-generated from GUI.txt - Do not edit.
local pkg, system = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- GUIItem FFI method additions --

function GUIItem:SetIsVisible(setVisible)
    pkg.GUIItem_SetIsVisible(self, setVisible)
end

function GUIItem:GetIsVisible()
    return (pkg.GUIItem_GetIsVisible(self))
end

function GUIItem:SetPosition(position)
    pkg.GUIItem_SetPosition(self, position)
end

function GUIItem:GetPosition()
    local __cdataOut = Vector()
    pkg.GUIItem_GetPosition(self, __cdataOut)

    return __cdataOut
end

function GUIItem:GetScreenPosition(screenSizeX, screenSizeY)
    local __cdataOut = Vector()
    pkg.GUIItem_GetScreenPosition(self, screenSizeX, screenSizeY, __cdataOut)

    return __cdataOut
end

function GUIItem:SetAnchor(setXAnchor, setYAnchor)
    pkg.GUIItem_SetAnchor(self, setXAnchor, setYAnchor)
end

function GUIItem:GetXAnchor()
    return (pkg.GUIItem_GetXAnchor(self))
end

function GUIItem:GetYAnchor()
    return (pkg.GUIItem_GetYAnchor(self))
end

function GUIItem:SetColor(color)
    pkg.GUIItem_SetColor(self, color)
end

function GUIItem:GetColor()
    local __cdataOut = Color()
    pkg.GUIItem_GetColor(self, __cdataOut)

    return __cdataOut
end

function GUIItem:AddChild(child)
    pkg.GUIItem_AddChild(self, child)
end

function GUIItem:RemoveChild(child)
    pkg.GUIItem_RemoveChild(self, child)
end

function GUIItem:GetNumChildren()
    return (pkg.GUIItem_GetNumChildren(self))
end

function GUIItem:SetLayer(layer)
    pkg.GUIItem_SetLayer(self, layer)
end

function GUIItem:GetLayer()
    return (pkg.GUIItem_GetLayer(self))
end

function GUIItem:SetSize(setSize)
    pkg.GUIItem_SetSize(self, setSize)
end

function GUIItem:GetSize()
    local __cdataOut = Vector()
    pkg.GUIItem_GetSize(self, __cdataOut)

    return __cdataOut
end

function GUIItem:SetScale(setScale)
    pkg.GUIItem_SetScale(self, setScale)
end

function GUIItem:GetScale()
    local __cdataOut = Vector()
    pkg.GUIItem_GetScale(self, __cdataOut)

    return __cdataOut
end

function GUIItem:GetAbsoluteScale()
    local __cdataOut = Vector()
    pkg.GUIItem_GetAbsoluteScale(self, __cdataOut)

    return __cdataOut
end

function GUIItem:SetRotation(setRotation)
    pkg.GUIItem_SetRotation(self, setRotation)
end

function GUIItem:GetRotation()
    local __cdataOut = Vector()
    pkg.GUIItem_GetRotation(self, __cdataOut)

    return __cdataOut
end

function GUIItem:SetRotationOffset(setOffset)
    pkg.GUIItem_SetRotationOffset(self, setOffset)
end

function GUIItem:GetRotationOffset()
    local __cdataOut = Vector()
    pkg.GUIItem_GetRotationOffset(self, __cdataOut)

    return __cdataOut
end

function GUIItem:SetInheritsParentAlpha(setInherits)
    pkg.GUIItem_SetInheritsParentAlpha(self, setInherits)
end

function GUIItem:GetInheritsParentAlpha()
    return (pkg.GUIItem_GetInheritsParentAlpha(self))
end

function GUIItem:SetBlendTechnique(setTechnique)
    pkg.GUIItem_SetBlendTechnique(self, setTechnique)
end

function GUIItem:GetBlendTechnique()
    return (pkg.GUIItem_GetBlendTechnique(self))
end

function GUIItem:SetIsStencil(setIsStencil)
    pkg.GUIItem_SetIsStencil(self, setIsStencil)
end

function GUIItem:GetIsStencil()
    return (pkg.GUIItem_GetIsStencil(self))
end

function GUIItem:SetStencilFunc(setFunc)
    pkg.GUIItem_SetStencilFunc(self, setFunc)
end

function GUIItem:GetStencilFunc()
    return (pkg.GUIItem_GetStencilFunc(self))
end

function GUIItem:SetClearsStencilBuffer(setClears)
    pkg.GUIItem_SetClearsStencilBuffer(self, setClears)
end

function GUIItem:GetClearsStencilBuffer()
    return (pkg.GUIItem_GetClearsStencilBuffer(self))
end

function GUIItem:SetInheritsParentStencilSettings(setInherits)
    pkg.GUIItem_SetInheritsParentStencilSettings(self, setInherits)
end

function GUIItem:GetInheritsParentStencilSettings()
    return (pkg.GUIItem_GetInheritsParentStencilSettings(self))
end

function GUIItem:SetTextureCoordinates(setX1, setY1, setX2, setY2)
    pkg.GUIItem_SetTextureCoordinates(self, setX1, setY1, setX2, setY2)
end

function GUIItem:SetTexturePixelCoordinates(pixelX1, pixelY1, pixelX2, pixelY2)
    pkg.GUIItem_SetTexturePixelCoordinates(self, pixelX1, pixelY1, pixelX2, pixelY2)
end

function GUIItem:SetFontSize(setSize)
    pkg.GUIItem_SetFontSize(self, setSize)
end

function GUIItem:SetFontName(fontName)
    pkg.GUIItem_SetFontName(self, fontName)
end

function GUIItem:SetTextClipped(setTextClipped, setWidth, setHeight)
    pkg.GUIItem_SetTextClipped(self, setTextClipped, setWidth, setHeight)
end

function GUIItem:GetTextClipped()
    return (pkg.GUIItem_GetTextClipped(self))
end

function GUIItem:SetTextAlignmentX(alignment)
    pkg.GUIItem_SetTextAlignmentX(self, alignment)
end

function GUIItem:SetTextAlignmentY(alignment)
    pkg.GUIItem_SetTextAlignmentY(self, alignment)
end

function GUIItem:GetTextAlignmentX()
    return (pkg.GUIItem_GetTextAlignmentX(self))
end

function GUIItem:GetTextAlignmentY()
    return (pkg.GUIItem_GetTextAlignmentY(self))
end

function GUIItem:SetTexture(fileName)
    pkg.GUIItem_SetTexture(self, fileName)
end

function GUIItem:SetAdditionalTexture(name, fileName)
    pkg.GUIItem_SetAdditionalTexture(self, name, fileName)
end

function GUIItem:SetShader(name)
    pkg.GUIItem_SetShader(self, name)
end

function GUIItem:GetShader()
    return (ffi_string(pkg.GUIItem_GetShader(self)))
end

function GUIItem:AddLine(point1, point2, color)
    pkg.GUIItem_AddLine(self, point1, point2, color)
end

function GUIItem:ClearLines()
    pkg.GUIItem_ClearLines(self)
end

function GUIItem:SetOptionFlag(inFlag)
    pkg.GUIItem_SetOptionFlag(self, inFlag)
end

function GUIItem:ClearOptionFlag(inFlag)
    pkg.GUIItem_ClearOptionFlag(self, inFlag)
end

function GUIItem:IsOptionFlagSet(inFlag)
    return (pkg.GUIItem_IsOptionFlagSet(self, inFlag))
end

function GUIItem:SetFontIsBold(bold)
    pkg.GUIItem_SetFontIsBold(self, bold)
end

function GUIItem:GetFontIsBold()
    return (pkg.GUIItem_GetFontIsBold(self))
end

function GUIItem:SetFontIsItalic(bold)
    pkg.GUIItem_SetFontIsItalic(self, bold)
end

function GUIItem:GetFontIsItalic()
    return (pkg.GUIItem_GetFontIsItalic(self))
end

function GUIItem:SetWideText(text)
    pkg.GUIItem_SetWideText(self, text)
end

if GUI == nil then GUI = {} end

function GUI.GetNumItems()
    return (pkg.GUI_GetNumItems(system))
end

function GUI.GetNumItemsRenderedLastFrame()
    return (pkg.GUI_GetNumItemsRenderedLastFrame(system))
end

function GUI.PrintItemInfoToLog()
    pkg.GUI_PrintItemInfoToLog(system)
end

function GUI.SetSize(xSize, ySize)
    pkg.GUI_SetSize(system, xSize, ySize)
end


