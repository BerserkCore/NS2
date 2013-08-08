-- Auto-generated from Shared.txt - Do not edit.
local pkg, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- VelocityArray FFI method additions --

-- Camera FFI method additions --

function Camera_FFIIndex:isa(className)
   return className == "Camera"
end

function Camera_FFIIndex:SetCoords(coords)
    pkg.Camera_SetCoords(self, coords)
end

function Camera_FFIIndex:GetCoords()
    local __cdataOut = Coords()
    pkg.Camera_GetCoords(self, __cdataOut)

    return __cdataOut
end

function Camera_FFIIndex:SetFov(fov)
    pkg.Camera_SetFov(self, fov)
end

function Camera_FFIIndex:GetFov()
    return (pkg.Camera_GetFov(self))
end

function Camera_FFIIndex:SetType(_dummy2)
    pkg.Camera_SetType(self, _dummy2)
end

function Camera_FFIIndex:GetType()
    return (pkg.Camera_GetType(self))
end

-- ClassEntityList FFI method additions --

function ClassEntityList_FFIIndex:isa(className)
   return className == "ClassEntityList"
end

function ClassEntityList_FFIIndex:GetSize()
    return (pkg.ClassEntityList_GetSize(self))
end

-- TagEntityList FFI method additions --

function TagEntityList_FFIIndex:isa(className)
   return className == "TagEntityList"
end

function TagEntityList_FFIIndex:GetSize()
    return (pkg.TagEntityList_GetSize(self))
end

-- EntityFilter FFI method additions --

-- CoordsArray FFI method additions --

function CoordsArray:GetSize()
    return (pkg.CoordsArray_GetSize(self))
end

function CoordsArray:Get(i)
    local __cdataOut = Coords()
    pkg.CoordsArray_Get(self, i, __cdataOut)

    return __cdataOut
end

if Shared == nil then Shared = {} end

function Shared.Message(message)
    pkg.Shared_Message(message)
end

function Shared.Warning(message)
    pkg.Shared_Warning(message)
end

function Shared.Error(message)
    pkg.Shared_Error(message)
end

function Shared.GetCheatsEnabled()
    return (pkg.Shared_GetCheatsEnabled(world))
end

function Shared.GetDevMode()
    return (pkg.Shared_GetDevMode(world))
end

function Shared.GetRandomInt(minValue, maxValue)
    return (pkg.Shared_GetRandomInt(world, minValue, maxValue))
end

function Shared.GetRandomFloat(min, max)

    if(not min) then
        return (pkg.Shared_GetRandomFloat0(world))
    else
        return (pkg.Shared_GetRandomFloat1(world, min, max))
    end
end

function Shared.PrecacheAnimationGraph(fileName)
    pkg.Shared_PrecacheAnimationGraph(world, fileName)
end

function Shared.PrecacheModel(fileName)
    pkg.Shared_PrecacheModel(world, fileName)
end

function Shared.PrecacheSound(fileName)
    pkg.Shared_PrecacheSound(world, fileName)
end

function Shared.PrecacheSurfaceShader(fileName)
    pkg.Shared_PrecacheSurfaceShader(world, fileName)
end

function Shared.PrecacheTexture(fileName)
    pkg.Shared_PrecacheTexture(world, fileName)
end

function Shared.PrecacheCinematic(fileName)
    pkg.Shared_PrecacheCinematic(world, fileName)
end

function Shared.PrecacheString(string)
    pkg.Shared_PrecacheString(world, string)
end

function Shared.GetString(stringIndex)
    return (ffi_string(pkg.Shared_GetString(world, stringIndex)))
end

function Shared.GetSoundIndex(soundEventName)
    return (pkg.Shared_GetSoundIndex(world, soundEventName))
end

function Shared.GetStringIndex(stringName)
    return (pkg.Shared_GetStringIndex(world, stringName))
end

function Shared.GetCinematicIndex(cinematicEventName)
    return (pkg.Shared_GetCinematicIndex(world, cinematicEventName))
end

function Shared.GetCinematicFileName(cinematicIndex)
    return (ffi_string(pkg.Shared_GetCinematicFileName(world, cinematicIndex)))
end

function Shared.GetModelIndex(fileName)
    return (pkg.Shared_GetModelIndex(world, fileName))
end

function Shared.GetModelName(modelIndex)

    if(type(modelIndex) == "number") then
        return (ffi_string(pkg.Shared_GetModelName0(world, modelIndex)))
    else
        return (ffi_string(pkg.Shared_GetModelName1(world, modelIndex)))
    end
end

function Shared.GetAnimationGraphIndex(fileName)
    return (pkg.Shared_GetAnimationGraphIndex(world, fileName))
end

function Shared.GetAnimationGraphName(animationGraphIndex)
    return (ffi_string(pkg.Shared_GetAnimationGraphName(world, animationGraphIndex)))
end

function Shared.GetBuildNumber()
    return (pkg.Shared_GetBuildNumber(world))
end

function Shared.PreLoadSetGroupPhysicsId(groupName, physicsId)
    pkg.Shared_PreLoadSetGroupPhysicsId(world, groupName, physicsId)
end

function Shared.PreLoadSetGroupNeverVisible(groupName)
    pkg.Shared_PreLoadSetGroupNeverVisible(world, groupName)
end

function Shared.AddTagToEntity(entityId, tag)
    pkg.Shared_AddTagToEntity(world, entityId, tag)
end

function Shared.RemoveTagFromEntity(entityId, tag)
    pkg.Shared_RemoveTagFromEntity(world, entityId, tag)
end

function Shared.SlerpCoords(coords1, coords2, amount)
    local __cdataOut = Coords()
    pkg.Shared_SlerpCoords(coords1, coords2, amount, __cdataOut)

    return __cdataOut
end

function Shared.CalculateBoneVelocities(coords, velocity, previousBoneCoords, boneCoords, deltaTime, boneVelocities)
    pkg.Shared_CalculateBoneVelocities(world, coords, velocity, previousBoneCoords, boneCoords, deltaTime, boneVelocities)
end

function Shared.GetSoundName(soundIndex)
    return (ffi_string(pkg.Shared_GetSoundName(world, soundIndex)))
end

function Shared.GetSystemTime()
    return (pkg.Shared_GetSystemTime())
end

function Shared.GetSystemTimeReal()
    return (pkg.Shared_GetSystemTimeReal())
end

function Shared.SetWebRoot(webRoot)
    pkg.Shared_SetWebRoot(world, webRoot)
end

function Shared.DebugColor(r, g, b, a)
    pkg.Shared_DebugColor(world, r, g, b, a)
end

function Shared.DebugLine(p0, p1, lifetime)
    pkg.Shared_DebugLine(world, p0, p1, lifetime)
end

function Shared.ClearDebugLines()
    pkg.Shared_ClearDebugLines(world)
end

function Shared.DebugCapsule(sweepStart, sweepEnd, capsuleRadius, capsuleHeight, lifetime)
    pkg.Shared_DebugCapsule(world, sweepStart, sweepEnd, capsuleRadius, capsuleHeight, lifetime)
end

function Shared.DebugPoint(p0, size, lifetime)
    pkg.Shared_DebugPoint(world, p0, size, lifetime)
end

function Shared.DebugText(text, p, lifetime)
    pkg.Shared_DebugText(world, text, p, lifetime)
end


