// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\SabotUtility.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

local kSabotURL = "http://hive.naturalselection2.com/api/"

local gServerSettings = { password = "", mapName = "ns2_summit" }
local gGathers = {}

// for current gather
local gGatherId = -1
local gChatMessages = {}
local gPlayerNames = {}

// translate these
local kStatusMessages = {}
kStatusMessages["GATHER_WAITING_FOR_PLAYERS"] = "Waiting for players"
kStatusMessages["GATHER_SEARCHING_SERVER"] = "Searching server"

Sabot = {}

local function GetPlayerName()
    return Client.GetOptionString(kNicknameOptionsKey, Client.GetUserName()) or kDefaultPlayerName
end

local function JoinGatherOnSuccess(gatherInfo)

    return function (data)

        local obj, pos, err = json.decode(data, 1, nil)

        if obj and obj.status == true then

            gGathers[obj.data.gatherId] = gatherInfo
            gGathers[obj.data.gatherId].gatherId = obj.data.gatherId
            
            Sabot.JoinGather(obj.data.gatherId)

        end
    
    end

end

local function GatherJoined(gatherId)

    return function (data)
    
        local obj, pos, err = json.decode(data, 1, nil)
        if obj and obj.status == true then
            gGatherId = gatherId
        end
    
    end

end

local function StoreGatherList(data)

    local obj, pos, err = json.decode(data, 1, nil)
    
    gGathers = {}

    if obj then

        for index, gatherInfo in pairs(obj) do
            gGathers[gatherInfo.gatherId] = gatherInfo
        end
    
    end
    
    if gGatherId ~= -1 then
        if not gGathers[gGatherId] then
            gGatherId = -1
        end
    end    

end

local function StoreGather(data)

    local obj, pos, err = json.decode(data, 1, nil)
    if obj then
        gGathers[obj.gatherId] = obj   
    end

end

local function RoomUpdated(gatherId)

    return function (data)
    
        local obj, pos, err = json.decode(data, 1, nil)
        if obj.status ~= true then   
            gGatherId = -1
        else
        
            gChatMessages = {}
            for _, message in pairs(obj.messages) do
                table.insert(gChatMessages, message.playerName ..": " .. message.text )       
            end
            
            gPlayerNames = {}
            for _, player in pairs(obj.players) do
                table.insert(gPlayerNames, ToString(player.playerId)) // TODO: change to player.playerName once added
            end
        
        end
 
    end

end

local function ServerUpdated(data)        

    local obj, pos, err = json.decode(data, 1, nil)
    if obj.status == true then   

        gServerSettings.password = obj.password
        gServerSettings.mapName = obj.mapName

    end

end

function Sabot.GetNumGathers()

    local count = 0

    for index, gather in pairs(gGathers) do
        count = count + 1
    end
    
    return count
    
end

function Sabot.GetGathers()
    return gGathers
end

function Sabot.RefreshGatherList()
    Shared.SendHTTPRequest(kSabotURL .. "get/gathers", "GET", {}, StoreGatherList)
end

function Sabot.CreateGather(gatherInfo)

    gatherInfo.ownerId = Client.GetSteamId()
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/add", "POST",  { data = json.encode(gatherInfo) }, JoinGatherOnSuccess(gatherInfo))
    
end

function Sabot.SendChatMessage(message)

    local params = { playerId = Client.GetSteamId(), gatherId = gGatherId, playerName = GetPlayerName(), text = message }
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/chat", "POST", { data = json.encode(params) })

end

function Sabot.QuitGather()

    gGatherId = -1    
    local params = { playerId = Client.GetSteamId() }
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/quit", "POST", { data = json.encode(params) })

end

function Sabot.JoinGather(gatherId, password)

    local params = { playerId = Client.GetSteamId(), password = password, gatherId = gatherId }
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/join", "POST", { data = json.encode(params) }, GatherJoined(gatherId))
    
end

function Sabot.GetGatherInfo(gatherId)  
    return gGathers[gatherId]
end

function Sabot.GetCurrentGatherId()
    return gGatherId
end

function Sabot.GetIsInGather()
    return gGatherId ~= -1
end

function Sabot.GetGatherStatusMessage()

    if gatherId > 0 then
    
        local gather = gGathers[gGatherId]
        if gather then
            
            if gather.playerNumber >= gather.playerSlots then
                return kStatusMessages["GATHER_SEARCHING_SERVER"]
            else
                return kStatusMessages["GATHER_WAITING_FOR_PLAYERS"]
            end
            
        end
        
    end

    return ""
    
end

function Sabot.GetPlayerNames()
    return gPlayerNames
end

function Sabot.GetChatMessates()
    return gChatMessages
end

function Sabot.GetLastChatMessage()
    return gChatMessages[#gChatMessages]
end

function Sabot.UpdateRoom()

    local params = { playerId = Client.GetSteamId(), gatherId = gGatherId, playerName = GetPlayerName() }
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/update", "POST", { data = json.encode(params) }, RoomUpdated(gGatherId))

end

function Sabot.UpdateGather()
    Shared.SendHTTPRequest(kSabotURL .. "get/gathers/"..gGatherId, "GET", {}, StoreGather)
end

function Sabot.GetGatherId()
    return gGatherId
end

function Sabot.GetServerSettings()
    return gServerSettings
end

function Sabot.RequestServerConfig()

    local params = {  }
    Shared.SendHTTPRequest(kSabotURL .. "post/gather/serverconfig", "POST", { data = json.encode(params) }, ServerUpdated)
    
end

