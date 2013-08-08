-- Auto-generated from Vec3.txt - Do not edit.
local pkg = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- Vector FFI method additions --

function Vector_FFIIndex:isa(className)
   return className == "Vector"
end

function Vector_FFIIndex:SafeNormal()
    local __cdataOut = Vector()
    pkg.Vector_SafeNormal(self, __cdataOut)

    return __cdataOut
end

function Vector_FFIIndex:Or(v)
    return (pkg.Vector_Or(self, v))
end


