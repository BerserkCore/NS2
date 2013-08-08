-- Auto-generated from ClientLoaded.txt - Do not edit.
local pkg, game, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
if ClientLoaded == nil then ClientLoaded = {} end

function Client.GetScreenWidth()
    return (pkg.Client_GetScreenWidth(game))
end

function Client.GetScreenHeight()
    return (pkg.Client_GetScreenHeight(game))
end

function Client.Disconnect()
    pkg.Client_Disconnect(game)
end

function Client.GetFrameRate()
    return (pkg.Client_GetFrameRate(game))
end

function Client.GetLocalModId(modName)
    return (pkg.Client_GetLocalModId(game, modName))
end

function Client.GetIsConnected()
    return (pkg.Client_GetIsConnected(game))
end

function Client.GetPing()
    return (pkg.Client_GetPing(game))
end

function Client.ReloadGraphicsOptions()
    pkg.Client_ReloadGraphicsOptions(game)
end

function Client.ReloadKeyOptions()
    pkg.Client_ReloadKeyOptions(game)
end

function Client.SetOptionString(name, value)
    pkg.Client_SetOptionString(game, name, value)
end

function Client.SetOptionInteger(name, value)
    pkg.Client_SetOptionInteger(game, name, value)
end

function Client.SetOptionFloat(name, value)
    pkg.Client_SetOptionFloat(game, name, value)
end

function Client.SetOptionBoolean(name, value)
    pkg.Client_SetOptionBoolean(game, name, value)
end

function Client.GetOptionInteger(name, defaultValue)
    return (pkg.Client_GetOptionInteger(game, name, defaultValue))
end

function Client.GetOptionFloat(name, defaultValue)
    return (pkg.Client_GetOptionFloat(game, name, defaultValue))
end

function Client.GetOptionBoolean(name, defaultValue)
    return (pkg.Client_GetOptionBoolean(game, name, defaultValue))
end

function Client.GetSoundDeviceCount(deviceType)
    return (pkg.Client_GetSoundDeviceCount(game, deviceType))
end

function Client.SetSoundDevice(deviceType, id)
    pkg.Client_SetSoundDevice(game, deviceType, id)
end

function Client.GetSoundDevice(deviceType)
    return (pkg.Client_GetSoundDevice(game, deviceType))
end

function Client.GetIsSoundDeviceValid(deviceType)
    return (pkg.Client_GetIsSoundDeviceValid(game, deviceType))
end

function Client.SetMusicVolume(volume)
    pkg.Client_SetMusicVolume(game, volume)
end

function Client.GetMusicVolume()
    return (pkg.Client_GetMusicVolume(game))
end

function Client.SetSoundVolume(volume)
    pkg.Client_SetSoundVolume(game, volume)
end

function Client.SetVoiceVolume(volume)
    pkg.Client_SetVoiceVolume(game, volume)
end

function Client.SetRecordingGain(gain)
    pkg.Client_SetRecordingGain(game, gain)
end

function Client.GetRecordingVolume()
    return (pkg.Client_GetRecordingVolume(game))
end

function Client.SetCursor(fileName, xHotSpot, yHotSpot)
    pkg.Client_SetCursor(game, fileName, xHotSpot, yHotSpot)
end

function Client.GetNumServers()
    return (pkg.Client_GetNumServers(game))
end

function Client.GetUserName()
    return (ffi_string(pkg.Client_GetUserName(game)))
end

function Client.GetSteamId()
    return (pkg.Client_GetSteamId(game))
end

function Client.GetCountryCode()
    return (ffi_string(pkg.Client_GetCountryCode(game)))
end

function Client.RebuildServerList()
    pkg.Client_RebuildServerList(game)
end

function Client.GetServerListRefreshed()
    return (pkg.Client_GetServerListRefreshed(game))
end

function Client.SetMouseSensitivity(sensitivity)
    pkg.Client_SetMouseSensitivity(game, sensitivity)
end

function Client.GetMouseSensitivity()
    return (pkg.Client_GetMouseSensitivity(game))
end

function Client.ConvertKeyCodeToString(keyCode)
    return (ffi_string(pkg.Client_ConvertKeyCodeToString(keyCode)))
end

function Client.SetMouseVisible(mouseVisible)
    pkg.Client_SetMouseVisible(game, mouseVisible)
end

function Client.SetMouseClipped(mouseClipped)
    pkg.Client_SetMouseClipped(game, mouseClipped)
end

function Client.Exit()
    pkg.Client_Exit(game)
end

function Client.GetIsRunningServer()
    return (pkg.Client_GetIsRunningServer(game))
end

function Client.GetMouseVisible()
    return (pkg.Client_GetMouseVisible(game))
end

function Client.GetIsWindowFocused()
    return (pkg.Client_GetIsWindowFocused(game))
end

function Client.GetNumMods()
    return (pkg.Client_GetNumMods(game))
end

function Client.SetModActive(modIndex, active)
    pkg.Client_SetModActive(game, modIndex, active)
end

function Client.GetIsModActive(modIndex)
    return (pkg.Client_GetIsModActive(game, modIndex))
end

function Client.GetIsModMounted(modIndex)
    return (pkg.Client_GetIsModMounted(game, world, modIndex))
end

function Client.RefreshModList()
    return (pkg.Client_RefreshModList(game))
end

function Client.ModListIsBeingRefreshed()
    return (pkg.Client_ModListIsBeingRefreshed(game))
end

function Client.GetModTitle(index)
    return (ffi_string(pkg.Client_GetModTitle(game, index)))
end

function Client.GetModState(index)
    return (ffi_string(pkg.Client_GetModState(game, index)))
end

function Client.GetIsSubscribedToMod(index)
    return (pkg.Client_GetIsSubscribedToMod(game, index))
end

function Client.SubscribeToMod(index, subscribe)
    return (pkg.Client_SubscribeToMod(game, index, subscribe))
end

function Client.PlayMusic(fileName)
    pkg.Client_PlayMusic(world, fileName)
end

function Client.StopMusic(fileName)
    pkg.Client_StopMusic(world, fileName)
end

function Client.GetModeDescription()
    return (ffi_string(pkg.Client_GetModeDescription(game)))
end

function Client.StorePredictionData(key, data)
    pkg.Client_StorePredictionData(game, key, data)
end

function Client.GetIsDlcAuthorized(productId)
    return (pkg.Client_GetIsDlcAuthorized(game, productId))
end


