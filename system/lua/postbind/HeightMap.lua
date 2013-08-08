-- Auto-generated from HeightMap.txt - Do not edit.
local pkg = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- HeightMap FFI method additions --

function HeightMap:Load(fileName)
    return (pkg.HeightMap_Load(self, fileName))
end

function HeightMap:GetElevation(x, z)
    return (pkg.HeightMap_GetElevation(self, x, z))
end

function HeightMap:GetWorldX(normY)
    return (pkg.HeightMap_GetWorldX(self, normY))
end

function HeightMap:GetWorldZ(normX)
    return (pkg.HeightMap_GetWorldZ(self, normX))
end

function HeightMap:GetMapX(worldZ)
    return (pkg.HeightMap_GetMapX(self, worldZ))
end

function HeightMap:GetMapY(worldX)
    return (pkg.HeightMap_GetMapY(self, worldX))
end

function HeightMap:ClampXToMapBounds(x)
    return (pkg.HeightMap_ClampXToMapBounds(self, x))
end

function HeightMap:ClampZToMapBounds(z)
    return (pkg.HeightMap_ClampZToMapBounds(self, z))
end

function HeightMap:GetAspectRatio()
    return (pkg.HeightMap_GetAspectRatio(self))
end

function HeightMap:GetOffset()
    local __cdataOut = Vector()
    pkg.HeightMap_GetOffset(self, __cdataOut)

    return __cdataOut
end

function HeightMap:GetExtents()
    local __cdataOut = Vector()
    pkg.HeightMap_GetExtents(self, __cdataOut)

    return __cdataOut
end


