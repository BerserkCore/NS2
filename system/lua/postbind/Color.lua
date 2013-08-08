-- Auto-generated from Color.txt - Do not edit.
local pkg = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- Color FFI method additions --

function Color_FFIIndex:isa(className)
   return className == "Color"
end

function ColorFromPacked(rgba)
    local __cdataOut = Color()
    pkg.ColorFromPacked(rgba, __cdataOut)

    return __cdataOut
end


