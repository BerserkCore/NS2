-- Auto-generated from Pathing.txt - Do not edit.
local pkg, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- PointArray FFI method additions --

function PointArray:GetSize()
    return (pkg.PointArray_GetSize(self))
end

function PointArray:Get(i)
    local __cdataOut = Vector()
    pkg.PointArray_Get(self, i, __cdataOut)

    return __cdataOut
end

if Pathing == nil then Pathing = {} end

function Pathing.InsertPoint(points, b1Pos, pt)
    pkg.Pathing_InsertPoint(points, b1Pos, pt)
end

function Pathing.GetLevelHasPathingMesh()
    return (pkg.Pathing_GetLevelHasPathingMesh(world))
end

function Pathing.AddObstacle(position, radius, height)
    return (pkg.Pathing_AddObstacle(world, position, radius, height))
end

function Pathing.RemoveObstacle(inId)
    pkg.Pathing_RemoveObstacle(world, inId)
end

function Pathing.BuildMesh()
    pkg.Pathing_BuildMesh(world)
end

function Pathing.CreatePathingObject(modelName, coords, isWalkable)
    pkg.Pathing_CreatePathingObject(world, modelName, coords, isWalkable)
end

function Pathing.GetPathPoints(startLocation, endLocation, pointsOut)
    return (pkg.Pathing_GetPathPoints(world, startLocation, endLocation, pointsOut))
end

function Pathing.IsBlocked(startLocation, endLocation)
    return (pkg.Pathing_IsBlocked(world, startLocation, endLocation))
end

function Pathing.GetClosestPoint(origin)
    local __cdataOut = Vector()
    pkg.Pathing_GetClosestPoint(world, origin, __cdataOut)

    return __cdataOut
end

function Pathing.SetPolyFlags(origin, extents, flags)
    pkg.Pathing_SetPolyFlags(world, origin, extents, flags)
end

function Pathing.ClearPolyFlags(origin, extents, flags)
    pkg.Pathing_ClearPolyFlags(world, origin, extents, flags)
end

function Pathing.GetIsFlagSet(origin, extents, flags)
    return (pkg.Pathing_GetIsFlagSet(world, origin, extents, flags))
end

function Pathing.FloodFill(origin)
    pkg.Pathing_FloodFill(world, origin)
end

function Pathing.AddFillPoint(origin)
    pkg.Pathing_AddFillPoint(world, origin)
end

function Pathing.GetNumObstacles()
    return (pkg.Pathing_GetNumObstacles(world))
end

function Pathing.FindRandomPointAroundCircle(center, radius, height)
    local __cdataOut = Vector()
    pkg.Pathing_FindRandomPointAroundCircle(world, center, radius, height, __cdataOut)

    return __cdataOut
end


