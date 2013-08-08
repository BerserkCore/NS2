-- Auto-generated from Client.txt - Do not edit.
local pkg, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- DisplayMode FFI method additions --

function DisplayMode_FFIIndex:isa(className)
   return className == "DisplayMode"
end

-- SoundEventInstance FFI method additions --

function SoundEventInstance:SetParent(setParentId)
    pkg.SoundEventInstance_SetParent(self, setParentId)
end

function SoundEventInstance:GetParent()
    return (pkg.SoundEventInstance_GetParent(self))
end

function SoundEventInstance:SetCoords(coords)
    pkg.SoundEventInstance_SetCoords(self, coords)
end

function SoundEventInstance:SetParameter(paramName, value, seekSpeed)
    return (pkg.SoundEventInstance_SetParameter(self, paramName, value, seekSpeed))
end

function SoundEventInstance:GetIsPlaying()
    return (pkg.SoundEventInstance_GetIsPlaying(self))
end

function SoundEventInstance:SetVolume(volume)
    pkg.SoundEventInstance_SetVolume(self, volume)
end

function SoundEventInstance:SetMinDistance(minDistance)
    pkg.SoundEventInstance_SetMinDistance(self, minDistance)
end

function SoundEventInstance:SetMaxDistance(maxDistance)
    pkg.SoundEventInstance_SetMaxDistance(self, maxDistance)
end

function SoundEventInstance:SetPitch(pitch)
    pkg.SoundEventInstance_SetPitch(self, pitch)
end

function SoundEventInstance:SetRolloff(rolloff)
    pkg.SoundEventInstance_SetRolloff(self, rolloff)
end

function SoundEventInstance:SetPositional(positional)
    pkg.SoundEventInstance_SetPositional(self, positional)
end

-- Frustum FFI method additions --

function Frustum_FFIIndex:isa(className)
   return className == "Frustum"
end

function Frustum_FFIIndex:GetPoint(pointIndex)
    local __cdataOut = Vector()
    pkg.Frustum_GetPoint(self, pointIndex, __cdataOut)

    return __cdataOut
end

if Client == nil then Client = {} end

function Shared.GetNumDroppedMoves()
    return (pkg.Shared_GetNumDroppedMoves(world))
end

function Client.GetTime()
    return (pkg.Client_GetTime())
end

function Client.PrecacheLocalSound(fileName)
    pkg.Client_PrecacheLocalSound(world, fileName)
end

function Client.GetStartupDisplayMode()
    local __cdataOut = ffi_new("DisplayMode")
    pkg.Client_GetStartupDisplayMode(__cdataOut)

    return __cdataOut
end

function Client.GetNumDisplayModes()
    return (pkg.Client_GetNumDisplayModes())
end

function Client.GetDisplayMode(modeIndex)
    local __cdataOut = ffi_new("DisplayMode")
    pkg.Client_GetDisplayMode(modeIndex, __cdataOut)

    return __cdataOut
end

function Client.GetIsControllingPlayer()
    return (pkg.Client_GetIsControllingPlayer(world))
end

function Client.CreateReverb(reverbName, origin, minDistance, maxDistance)
    pkg.Client_CreateReverb(world, reverbName, origin, minDistance, maxDistance)
end

function Client.DestroyReverbs()
    pkg.Client_DestroyReverbs(world)
end

function Client.ResetSoundSystem()
    pkg.Client_ResetSoundSystem()
end

function Client.CreateDSP(dspType)
    return (pkg.Client_CreateDSP(world, dspType))
end

function Client.SetDSPActive(dspId, state)
    return (pkg.Client_SetDSPActive(world, dspId, state))
end

function Client.SetDSPFloatParameter(dspId, parameterIndex, parameterValue)
    return (pkg.Client_SetDSPFloatParameter(dspId, parameterIndex, parameterValue))
end

function Client.SetMinMaxSoundDistance(minDistance, maxDistance)
    pkg.Client_SetMinMaxSoundDistance(minDistance, maxDistance)
end

function Client.SetSoundParameter(parent, soundName, paramName, seekSpeed, paramValue)

    if(type(paramValue) == "number") then
        return (pkg.Client_SetSoundParameter0(world, parent, soundName, paramName, seekSpeed, paramValue))
    else
        return (pkg.Client_SetSoundParameter1(world, parent, soundName, paramName, seekSpeed, paramValue))
    end
end

function Client.SetSoundGeometryEnabled(setEnabled)
    pkg.Client_SetSoundGeometryEnabled(setEnabled)
end

function Client.SetGroupIsVisible(groupName, state)
    pkg.Client_SetGroupIsVisible(world, groupName, state)
end

function Client.SetZoneFov(zone, fov)
    pkg.Client_SetZoneFov(world, zone, fov)
end

function Client.GetZoneFov(zone)
    return (pkg.Client_GetZoneFov(world, zone))
end

function Client.SetZoneFogDepthScale(zone, fogDepthScale)
    pkg.Client_SetZoneFogDepthScale(world, zone, fogDepthScale)
end

function Client.GetZoneFogDepthScale(zone)
    return (pkg.Client_GetZoneFogDepthScale(world, zone))
end

function Client.SetZoneFogColor(zone, fogColor)
    pkg.Client_SetZoneFogColor(world, zone, fogColor)
end

function Client.GetZoneFogColor(zone)
    local __cdataOut = Color()
    pkg.Client_GetZoneFogColor(world, zone, __cdataOut)

    return __cdataOut
end

function Client.GetConnectionProblems()
    return (pkg.Client_GetConnectionProblems(world))
end

function Client.GetMoveBufferAtMax()
    return (pkg.Client_GetMoveBufferAtMax(world))
end

function Client.IsVoiceRecordingActive()
    return (pkg.Client_IsVoiceRecordingActive(world))
end

function Client.GetIsClientSpeaking(clientId)
    return (pkg.Client_GetIsClientSpeaking(world, clientId))
end

function Client.PlayLocalSoundWithIndex(soundIndex, origin)
    pkg.Client_PlayLocalSoundWithIndex(world, soundIndex, origin)
end

function Client.StopLocalSoundWithIndex(soundIndex, origin)
    pkg.Client_StopLocalSoundWithIndex(world, soundIndex, origin)
end

function Client.SetRenderCamera(camera)
    pkg.Client_SetRenderCamera(world, camera)
end

function Client.GetConnectedServerName()
    return (ffi_string(pkg.Client_GetConnectedServerName(world)))
end

function Client.GetConnectedServerIsSecure()
    return (pkg.Client_GetConnectedServerIsSecure(world))
end

function Locale.SetLocale(inLocale)
    pkg.Locale_SetLocale(world, inLocale)
end

function Locale.GetLocale()
    return (ffi_string(pkg.Locale_GetLocale(world)))
end

function Client.AddTextureLoadRule(pattern, reductionAdjustment)
    pkg.Client_AddTextureLoadRule(world, pattern, reductionAdjustment)
end

function Client.SetRenderSetting(name, value)

    if(type(value) == "string") then
        pkg.Client_SetRenderSetting0(world, name, value)
    else
        pkg.Client_SetRenderSetting1(world, name, value)
    end
end

function Client.VoiceRecordStart()
    pkg.Client_VoiceRecordStart(world)
end

function Client.VoiceRecordStop()
    pkg.Client_VoiceRecordStop(world)
end


