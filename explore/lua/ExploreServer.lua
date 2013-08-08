// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreServer.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Server.lua")

Script.Load("lua/ExploreShared.lua")
Script.Load("lua/ExploreNS2Gamerules.lua")

Script.Load("lua/ExploreBot.lua")
Script.Load("lua/ExploreBot_Player.lua")

Script.Load("lua/ExplorePlayingTeam.lua")
Script.Load("lua/ExploreMarineTeam.lua")
Script.Load("lua/ExploreAlienTeam.lua")

// ignore pre-placed structures for normal mode
function GetLoadEntity(mapName, groupName, values)
    return ( mapName ~= InfantryPortal.kMapName or values.onlyexplore == true ) and
           ( mapName ~= Cyst.kMapName or values.onlyexplore == true )
end

function GetCreateEntityOnStart(mapName, groupName, values)

    return mapName ~= "prop_static"
       and mapName ~= "light_point"
       and mapName ~= "light_spot"
       and mapName ~= "light_ambient"
       and mapName ~= "color_grading"
       and mapName ~= "cinematic"
       and mapName ~= "skybox"
       and mapName ~= "pathing_settings"
       and mapName ~= ReadyRoomSpawn.kMapName
       and mapName ~= AmbientSound.kMapName
       and mapName ~= Reverb.kMapName
       and mapName ~= Hive.kMapName
       and mapName ~= CommandStation.kMapName
       
end

function GetLoadSpecial(mapName, groupName, values)

    local success = false

    if mapName == Hive.kMapName or mapName == CommandStation.kMapName then
       table.insert(Server.mapLoadLiveEntityValues, { mapName, groupName, values })
       success = true
    elseif mapName == ReadyRoomSpawn.kMapName then
    
        local entity = ReadyRoomSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        table.insert(Server.readyRoomSpawnList, entity)
        success = true
        
    elseif (mapName == AmbientSound.kMapName) then
    
        // Make sure sound index is precached but only create ambient sound object on client
        Shared.PrecacheSound(values.eventName)
        success = true
        
    elseif mapName == Cyst.kMapName then
        table.insert(Server.cystSpawnPoints, values.origin)
        success = true
    elseif mapName == "pathing_settings" then
        ParsePathingSettings(values)
        success = true
    end

    return success    

end

function Embryo:GetGestationTime(gestationTypeTechId)
    return 3
end

assert(SendTeamMessage)
local savedSendTeamMessage = SendTeamMessage
function SendTeamMessage(team, messageType, optionalData)

    // Don't send "You need a commander" alert
    if messageType ~= kTeamMessageTypes.NoCommander then
        savedSendTeamMessage(team, messageType, optionalData)
    end
    
end

