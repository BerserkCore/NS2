//=============================================================================
//
// lua/ServerBrowser.lua
// 
// Created by Henry Kropf and Charlie Cleveland
// Copyright 2012, Unknown Worlds Entertainment
//
//=============================================================================

Script.Load("lua/Utility.lua")

local hasNewData = true

local kFavoritesFileName = "FavoriteServers.json"

// List of server records - { {servername, gametype, map, playercount, ping, ipAddress}, {servername, gametype, map, playercount, ping, ipAddress}, etc. }
local serverRecords = { }

// Data to return to flash. Single-dimensional array like:
// {servername, gametype, map, playercount, ping, ipAddress, servername, gametype, map, playercount, ping, ipAddress, ...)
local returnServerList = { }

local kNumColumns = 6

local kSortTypeName = 1
local kSortTypeGame = 2
local kSortTypeMap = 3
local kSortTypePlayers = 4
local kSortTypePing = 5

local sortType = kSortTypePing
local ascending = true
local justSorted = false

local kFavoriteAddedSound = "sound/NS2.fev/common/checkbox_on"
Client.PrecacheLocalSound(kFavoriteAddedSound)

local kFavoriteRemovedSound = "sound/NS2.fev/common/checkbox_off"
Client.PrecacheLocalSound(kFavoriteRemovedSound)

local function SetLastServerInfo(address, password, mapname)

	Client.SetOptionString(kLastServerConnected, address)
	Client.SetOptionString(kLastServerPassword, password)
	Client.SetOptionString(kLastServerMapName, GetTrimmedMapName(mapname) )
	
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
    
    // Connecting through the console won't specify a map name.
    if mapname then
        SetLastServerInfo(address, password, mapname)
    end
    
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

local gFavoriteServers = LoadConfigFile(kFavoritesFileName) or { }

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
        Shared.PlaySound(nil, kFavoriteAddedSound)
        
    elseif foundIndex then
    
        table.remove(gFavoriteServers, foundIndex)
        Shared.PlaySound(nil, kFavoriteRemovedSound)
        
    end
    
    SaveConfigFile(kFavoritesFileName, gFavoriteServers)
    
end

function GetServerIsFavorite(address)

    for f = 1, #gFavoriteServers do
    
        if gFavoriteServers[f].address == address then
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

function GetFavoriteServers()
    return gFavoriteServers
end