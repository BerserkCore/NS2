-- Auto-generated from Angles.txt - Do not edit.
local pkg = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- Angles FFI method additions --

function Angles_FFIIndex:isa(className)
   return className == "Angles"
end

function Angles_FFIIndex:BuildFromCoords(coords)
    pkg.Angles_BuildFromCoords(self, coords)
end

function Angles_FFIIndex:GetIsFinite()
    return (pkg.Angles_GetIsFinite(self))
end

function Angles_FFIIndex.Lerp(a, b, fraction)
    local __cdataOut = Angles()
    pkg.Angles_Lerp(a, b, fraction, __cdataOut)

    return __cdataOut
end


