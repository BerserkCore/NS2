//=============================================================================
//
// lua/ServerBrowser.lua
// 
// Created by Henry Kropf and Charlie Cleveland
// Copyright 2012, Unknown Worlds Entertainment
//
//=============================================================================

Script.Load("lua/Utility.lua")

local kFavoritesFileName = "FavoriteServers.json"
local kHistoryFileName = "HistoryServers.json"

local kFavoriteAddedSound = "sound/NS2.fev/common/checkbox_on"
Client.PrecacheLocalSound(kFavoriteAddedSound)

local kFavoriteRemovedSound = "sound/NS2.fev/common/checkbox_off"
Client.PrecacheLocalSound(kFavoriteRemovedSound)

function FormatServerName(serverName, rookieFriendly)

    // Change name to display "rookie friendly" at the end of the line.
    if rookieFriendly then
    
        local maxLen = 34
        local separator = ConditionalValue(string.len(serverName) > maxLen, "... ", " ")
        serverName = serverName:sub(0, maxLen) .. separator .. Locale.ResolveString("ROOKIE_FRIENDLY")
        
    else
    
        local maxLen = 50
        local separator = ConditionalValue(string.len(serverName) > maxLen, "... ", " ")
        serverName = serverName:sub(0, maxLen) .. separator
        
    end
    
    return serverName
    
end

function FormatGameMode(gameMode)
    return gameMode:sub(0, 12)
end

function BuildServerEntry(serverIndex)

    local mods = Client.GetServerKeyValue(serverIndex, "mods")
    
    local serverEntry = { }
    serverEntry.name = Client.GetServerName(serverIndex)
    serverEntry.mode = FormatGameMode(Client.GetServerGameMode(serverIndex))
    serverEntry.map = GetTrimmedMapName(Client.GetServerMapName(serverIndex))
    serverEntry.numPlayers = Client.GetServerNumPlayers(serverIndex)
    serverEntry.maxPlayers = Client.GetServerMaxPlayers(serverIndex)
    serverEntry.ping = Client.GetServerPing(serverIndex)
    serverEntry.address = Client.GetServerAddress(serverIndex)
    serverEntry.requiresPassword = Client.GetServerRequiresPassword(serverIndex)
    serverEntry.playerSkill = GetServerPlayerSkill(serverIndex)
    serverEntry.rookieFriendly = Client.GetServerHasTag(serverIndex, "rookie")
    serverEntry.friendsOnServer = false
    serverEntry.lanServer = false
    serverEntry.tickrate = Client.GetServerTickRate(serverIndex)
    serverEntry.serverId = serverIndex
    serverEntry.modded = Client.GetServerIsModded(serverIndex)
    serverEntry.favorite = GetServerIsFavorite(serverEntry.address)
    serverEntry.history = GetServerIsHistory(serverEntry.address)
    
    serverEntry.name = FormatServerName(serverEntry.name, serverEntry.rookieFriendly)
    
    return serverEntry
    
end

local function SetLastServerInfo(address, password, mapname)

	Client.SetOptionString(kLastServerConnected, address)
	Client.SetOptionString(kLastServerPassword, password)
	Client.SetOptionString(kLastServerMapName, GetTrimmedMapName(mapname))
	
end

local function GetLastServerInfo()

	local address = Client.GetOptionString(kLastServerConnected, "")
	local password = Client.GetOptionString(kLastServerPassword, "")
	local mapname = Client.GetOptionString(kLastServerMapName, "")
	
	return address, password, mapname
	
end

/**
 * Join the server specified by UID and password.
 * If password is empty string there is no password.
 */
function MainMenu_SBJoinServer(address, password, mapname)

    Client.Disconnect()
    LeaveMenu()
    if password == nil then
        password = ""
    end
    Client.Connect(address, password)
    
    SetLastServerInfo(address, password, mapname)
    
    local params = { steamID = "" .. Client.GetSteamId() }
    Shared.SendHTTPRequest(kCatalyzURL .. "/deregister", "GET", params)
    
end

function OnRetryCommand()

    local address, password, mapname = GetLastServerInfo()
    
    if address == nil or address == "" then
    
        Shared.Message("No valid server to connect to.")
        return
        
    end
    
    Client.Disconnect()
    LeaveMenu()
    Shared.Message("Reconnecting to " .. address)
    MainMenu_SBJoinServer(address, password, mapname)
    
end
Event.Hook("Console_retry", OnRetryCommand)
Event.Hook("Console_reconnect", OnRetryCommand)

local gFavoriteServers = LoadConfigFile(kFavoritesFileName) or { }
local gHistoryServers = LoadConfigFile(kHistoryFileName) or { }

local function UpgradeFavoriteServersFormat(favorites)

    local newFavorites = favorites
    // The old format stored a list of addresses as strings.
    if type(favorites[1]) == "string" then
    
        // The new format stores a list of server entries as tables.
        newFavorites = { }
        for f = 1, #favorites do
            table.insert(newFavorites, { address = favorites[f] })
        end
        
        SaveConfigFile(kFavoritesFileName, newFavorites)
        
    end
    
    return newFavorites
    
end
gFavoriteServers = UpgradeFavoriteServersFormat(gFavoriteServers)

// Remove any entries lacking a server address. These are bogus entries.
for f = #gFavoriteServers, 1, -1 do

    if not gFavoriteServers[f].address then
        table.remove(gFavoriteServers, f)
    end
    
end

for f = #gHistoryServers, 1, -1 do

    if not gHistoryServers[f].address then
        table.remove(gHistoryServers, f)
    end
    
end

function SetServerIsFavorite(serverData, isFavorite)

    local foundIndex = nil
    for f = 1, #gFavoriteServers do
    
        if gFavoriteServers[f].address == serverData.address then
        
            foundIndex = f
            break
            
        end
        
    end
    
    if isFavorite and not foundIndex then
    
        local savedServerData = { }
        for k, v in pairs(serverData) do savedServerData[k] = v end
        table.insert(gFavoriteServers, savedServerData)
        StartSoundEffect(kFavoriteAddedSound)
        
    elseif foundIndex then
    
        table.remove(gFavoriteServers, foundIndex)
        StartSoundEffect(kFavoriteRemovedSound)
        
    end
    
    SaveConfigFile(kFavoritesFileName, gFavoriteServers)
    
end

kMaxServerHistory = 10

// first in, first out
function AddServerToHistory(serverData)

    local foundIndex = nil
    for f = 1, #gHistoryServers do
    
        if gHistoryServers[f].address == serverData.address then
        
            foundIndex = f
            break
            
        end
        
    end
    
    if foundIndex == nil then

        if #gHistoryServers > kMaxServerHistory then
            table.remove(gHistoryServers, 1)    
        end
        
        local savedServerData = { }
        for k, v in pairs(serverData) do savedServerData[k] = v end        
        table.insert(gHistoryServers, savedServerData)
        
        SaveConfigFile(kHistoryFileName, gHistoryServers)
    
    end

end

function GetServerIsFavorite(address)

    for f = 1, #gFavoriteServers do
    
        if gFavoriteServers[f].address == address then
            return true
        end
        
    end
    
    return false
    
end

function GetServerIsHistory(address)

    for f = 1, #gHistoryServers do

        if gHistoryServers[f].address == address then
            return true
        end
        
    end
    
    return false

end

function UpdateFavoriteServerData(serverData)

    for f = 1, #gFavoriteServers do
    
        if gFavoriteServers[f].address == serverData.address then
        
            for k, v in pairs(serverData) do gFavoriteServers[f][k] = v end
            break
            
        end
        
    end
    
end

function UpdateHistoryServerData(serverData)

    for f = 1, #gFavoriteServers do
    
        if gHistoryServers[f].address == serverData.address then
        
            for k, v in pairs(serverData) do gHistoryServers[f][k] = v end
            break
            
        end
        
    end
    
end

function GetFavoriteServers()
    return gFavoriteServers
end

function GetHistoryServers()
    return gHistoryServers
end

function GetStoredServers()

    local servers = {}
    
    local function UpdateHistoryFlag(address, list)
    
        for i = 1, #list do
            if list[i].address == address then
                list[i].history = true
                return true
            end
        end
        
        return false
    
    end
    
    for f = 1, #gFavoriteServers do
    
        table.insert(servers, gFavoriteServers[f])  
        servers[f].favorite = true
        
    end
    
    for f = 1, #gHistoryServers do
 
        if not UpdateHistoryFlag(gHistoryServers[f].address, servers) then
        
            table.insert(servers, gHistoryServers[f])
            servers[#servers].favorite = false
            servers[#servers].history = true
            
        end
        
    end
    
    return servers

end
