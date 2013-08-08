-- Auto-generated from Coords.txt - Do not edit.
local pkg = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- Coords FFI method additions --

function Coords_FFIIndex:isa(className)
   return className == "Coords"
end

function Coords_FFIIndex:GetInverse()
    local __cdataOut = Coords()
    pkg.Coords_GetInverse(self, __cdataOut)

    return __cdataOut
end

function Coords_FFIIndex:TransformPoint(p)
    local __cdataOut = Vector()
    pkg.Coords_TransformPoint(self, p, __cdataOut)

    return __cdataOut
end

function Coords_FFIIndex:GetIsFinite()
    return (pkg.Coords_GetIsFinite(self))
end

function Coords_FFIIndex:Scale(scale)
    pkg.Coords_Scale(self, scale)
end

function Coords_FFIIndex.GetTranslation(offset)
    local __cdataOut = Coords()
    pkg.Coords_GetTranslation(offset, __cdataOut)

    return __cdataOut
end

function Coords_FFIIndex.GetRotation(axis, angle)
    local __cdataOut = Coords()
    pkg.Coords_GetRotation(axis, angle, __cdataOut)

    return __cdataOut
end

function Coords_FFIIndex.GetIdentity()
    local __cdataOut = Coords()
    pkg.Coords_GetIdentity(__cdataOut)

    return __cdataOut
end

function Coords_FFIIndex.GetLookIn(origin, direction, up)
    local __cdataOut = Coords()

    if(not up) then
        pkg.Coords_GetLookIn1(origin, direction, __cdataOut)
    else
        pkg.Coords_GetLookIn0(origin, direction, up, __cdataOut)
    end

    return __cdataOut
end

function Coords_FFIIndex.GetLookAt(origin, target, up)
    local __cdataOut = Coords()
    pkg.Coords_GetLookAt(origin, target, up, __cdataOut)

    return __cdataOut
end

function Coords_FFIIndex.GetOrthonormal(yAxis)
    local __cdataOut = Coords()
    pkg.Coords_GetOrthonormal(yAxis, __cdataOut)

    return __cdataOut
end


