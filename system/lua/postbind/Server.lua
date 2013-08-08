-- Auto-generated from Server.txt - Do not edit.
local pkg, game, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- ServerClient FFI method additions --

function ServerClient:GetIsVirtual()
    return (pkg.ServerClient_GetIsVirtual(self))
end

function ServerClient:SetControllingPlayer(player)
    pkg.ServerClient_SetControllingPlayer(self, player)
end

function ServerClient:SetSpectatingPlayer(player)
    pkg.ServerClient_SetSpectatingPlayer(self, player)
end

function ServerClient:GetId()
    return (pkg.ServerClient_GetId(self))
end

function ServerClient:GetPing()
    return (pkg.ServerClient_GetPing(game, self))
end

function ServerClient:GetIsLocalClient()
    return (pkg.ServerClient_GetIsLocalClient(world, self))
end

function ServerClient:SetRelevancyMask(mask)
    pkg.ServerClient_SetRelevancyMask(self, mask)
end

function ServerClient:GetUserId()
    return (pkg.ServerClient_GetUserId(game, self))
end

if Server == nil then Server = {} end

function Shared.GetIsRunningPrediction()
    return (pkg.Shared_GetIsRunningPrediction())
end

function Server.GetNumPlayers()
    return (pkg.Server_GetNumPlayers(world))
end

function Server.GetMaxPlayers()
    return (pkg.Server_GetMaxPlayers(game))
end

function Server.GetIsDlcAuthorized(client, productId)
    return (pkg.Server_GetIsDlcAuthorized(game, client, productId))
end

function Server.Broadcast(player, message)
    pkg.Server_Broadcast(world, player, message)
end

function Server.GetClientAddress(client)
    return (pkg.Server_GetClientAddress(game, client))
end

function Server.GetIpAddress()
    return (pkg.Server_GetIpAddress(game))
end

function Server.VerifyPredictionData(key, data)
    return (pkg.Server_VerifyPredictionData(game, key, data))
end

function Server.GetSoundLength(soundName)
    return (pkg.Server_GetSoundLength(world, soundName))
end

function Server.GetCinematicLength(resourceIndex)
    return (pkg.Server_GetCinematicLength(world, resourceIndex))
end

function Server.SetPassword(newPassword)
    pkg.Server_SetPassword(game, newPassword)
end

function Server.GetName()
    return (ffi_string(pkg.Server_GetName(game)))
end

function Server.GetFrameRate()
    return (pkg.Server_GetFrameRate(game))
end

function Server.SetKeyValue(key, value)
    pkg.Server_SetKeyValue(game, key, value)
end

function Server.AddTag(tag)
    pkg.Server_AddTag(game, tag)
end

function Server.RemoveTag(tag)
    pkg.Server_RemoveTag(game, tag)
end

function Server.AddFileHashes(filePattern)
    return (pkg.Server_AddFileHashes(world, filePattern))
end

function Server.RemoveFileHashes(filePattern)
    return (pkg.Server_RemoveFileHashes(world, filePattern))
end

function Server.GetNumMods()
    return (pkg.Server_GetNumMods(game))
end

function Server.GetModTitle(modIndex)
    return (ffi_string(pkg.Server_GetModTitle(game, modIndex)))
end

function Server.GetNumActiveMods()
    return (pkg.Server_GetNumActiveMods(world))
end

function Server.GetNumMaps()
    return (pkg.Server_GetNumMaps(game))
end

function Server.GetMapName(mapIndex)
    return (ffi_string(pkg.Server_GetMapName(game, mapIndex)))
end

function Server.InstallMod(modId)
    return (pkg.Server_InstallMod(game, modId))
end


