-- Auto-generated from Cinematic.txt - Do not edit.
local pkg = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- Cinematic FFI method additions --

function Cinematic:SetRepeatStyle(repeatStyle)
    pkg.Cinematic_SetRepeatStyle(self, repeatStyle)
end

function Cinematic:SetCinematic(fileName)
    pkg.Cinematic_SetCinematic(self, fileName)
end

function Cinematic:SetCoords(coords)
    pkg.Cinematic_SetCoords(self, coords)
end

function Cinematic:SetIsVisible(visible)
    pkg.Cinematic_SetIsVisible(self, visible)
end

function Cinematic:GetIsVisible()
    pkg.Cinematic_GetIsVisible(self)
end

function Cinematic:SetIsActive(active)
    pkg.Cinematic_SetIsActive(self, active)
end

function Cinematic:GetIsActive()
    return (pkg.Cinematic_GetIsActive(self))
end

function Cinematic:SetParent(entity)
    pkg.Cinematic_SetParent(self, entity)
end

function Cinematic:SetAttachPoint(attachPoint)
    pkg.Cinematic_SetAttachPoint(self, attachPoint)
end


