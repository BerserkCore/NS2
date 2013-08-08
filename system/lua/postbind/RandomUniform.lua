-- Auto-generated from RandomUniform.txt - Do not edit.
local pkg = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- Randomizer FFI method additions --

function Randomizer_FFIIndex:isa(className)
   return className == "Randomizer"
end

function Randomizer_FFIIndex:randomseed(seed)
    pkg.Randomizer_randomseed(self, seed)
end

function Randomizer_FFIIndex:random(min, max)

    if(not min) then
        return (pkg.Randomizer_random0(self))
    else
        return (pkg.Randomizer_random1(self, min, max))
    end
end


