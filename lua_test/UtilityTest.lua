// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// Utility.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
function GetNumEnts(doPrint)

    local entList = GetEntitiesIsa("Entity", -1)
    local numEnts = table.maxn(entList)
    
    if(doPrint) then
        for index, ent in ipairs(entList) do
            print("Entity: " .. ent:GetId() .. " - " .. ent:GetClassName())
        end
    end
    
    return numEnts
    
end

// Returns table of entity descriptions for testing
function GetEntDescs()

    local descs = {}

    local entList = GetEntitiesIsa("Entity", -1)
    
    for index, ent in ipairs(entList) do
        table.insert(descs, string.format("%s", ent:GetMapName()))
    end
    
    return descs

end

function GetNumPlayers()

    local playerList = GetEntitiesIsa("NsPlayer", -1)
    local numPlayers = table.maxn(playerList)
    return numPlayers
    
end

function CheckZeroPlayers()

    local numPlayers = GetNumPlayers()
    assert(numPlayers == 0)
    
end

// Make sure players aren't stuck when they spawn
function playerStuck(player)

    // Try to move 
    local prePosition = Vector(player:GetOrigin())
    local velocity = Vector(1, 0, 0)
    local time = 1.0
    player:UpdatePosition(velocity, time)
    local postPosition = Vector(player:GetOrigin())
    
    return not prePosition == postPosition
    
end

// Find first instance of entity name on specified team (or nil)
function GetEntityIsa(isaName, teamNumber)
    
    local startEntity = nil
    local currentEntity = nil

    repeat
        
        currentEntity = Shared.FindNextEntity(startEntity)
        if(currentEntity and currentEntity:isa(isaName)) then
            if(teamNumber == nil or teamNumber == -1) or (currentEntity:isa("ScriptActor") and (teamNumber == currentEntity:GetTeamNumber())) then
                return currentEntity
            end
        end
        
        startEntity = currentEntity
        
    until currentEntity == nil

    return nil
    
end

function InitializeReadyRoom(silent)

    local player = CreateEntity(Player.kMapName)
    
    if not player then
        Print("InitializeReadyRoom() returned %s", tostring(success), EntityToString(player))
    end
    
    local success = player:GetTeam():RespawnPlayer(player)
    
    if not success then
        Print("InitializeReadyRoom() respawn failed.")
    elseif player:GetClassName() ~= "Player" and not silent then
        Print("InitializeReadyRoom() new player is a %s instead of a Player.", player:GetClassName())
    end
    
    return player 
    
end

function InitializeMarine(force, silent)

    local player = InitializeReadyRoom()
    local success, marinePlayer = GetGamerules():JoinTeam(player, kTeam1Index, force)
    
    if(not success or not marinePlayer) then
        Print("InitializeMarine() returned %s, %s", tostring(success), EntityToString(marinePlayer))       
    elseif marinePlayer:GetClassName() ~= "Marine" and not silent then
        Print("InitializeMarine() new player is a %s instead of a Marine.", marinePlayer:GetClassName())
    end
    
    return marinePlayer
    
end

function InitializeAlien(force, silent)

    local player = InitializeReadyRoom()
    local success, alienPlayer = GetGamerules():JoinTeam(player, kTeam2Index, force)
    
    if(not success or not alienPlayer) then
        Print("InitializeAlien() returned %s, %s", tostring(success), EntityToString(alienPlayer))
    elseif alienPlayer:GetClassName() ~= "Skulk" and not silent then
        Print("InitializeAlien() new player is a %s instead of a Skulk.", alienPlayer:GetClassName())
    end
    
    return alienPlayer
    
end

function InitializePlayer(mapName, teamNumber)

    local player = InitializeReadyRoom()
    
    local newPlayer = player:Replace(mapName, teamNumber, false)
    
    newPlayer:GetTeam():RespawnPlayer(newPlayer)
    
    return newPlayer
    
end

function CreateStructure(techId, teamNumber, built)

    local mapName = LookupTechData(techId, kTechDataMapName)
    
    local structure = CreateEntity(mapName, nil, teamNumber)
    
    if structure and built then
        structure:SetConstructionComplete()
    end
    
    return structure
    
end

function StandardSetup(testName)

    SetPrintEnabled(true, testName)

    RunUpdate(.1)
       
    GetGamerules():ResetGame()
    
    local player = InitializeReadyRoom()    

    GetGamerules():SetGameStarted()
    
    RunUpdate(.1)    
    
    return player

end

function Cleanup()

    // Delete all players 
    if(Server) then
    
        local gameEntities = GetEntitiesIsaMultiple({"Player", "Structure"})
        
        for index, gameEntity in ipairs(gameEntities) do
        
            if not gameEntity:GetIsMapEntity() then
                Server.DestroyEntity(gameEntity)
            end
            
        end
        
    end
    
    // Reset game rules and cheats
    Shared.ConsoleCommand("cheats 0")
    GetGamerules():ResetGame()
    
end

function GetMinServerUpdateInterval()
    return 1/30
end

// Way to update the world without having both a client and server (the engine depends on networking).
// Client gets updated before server on listen server, so OnProcessMove() gets called before Server.Update()
// Can run in one update if oneUpdate true. 
function RunUpdate(timePassed, move, oneUpdate)

    if timePassed == nil then
        timePassed = GetMinServerUpdateInterval()
    end

    // Runs updates at 15 fps
    local kFPS = 15
    local timeInterval = ConditionalValue(oneUpdate, timePassed, math.min(timePassed, 1/kFPS))
    local timeSimulated = 0
    
    // timePassed must be at least 1/30 or else a frame may not get run (due to the server running at 30 fps).
    if timePassed < (GetMinServerUpdateInterval() - kEpsilon) then
        Print("RunUpdate(%.2f) - Must be called with a value of at least %.2f or a frame won't be run.", timePassed, GetMinServerUpdateInterval())
        return         
    end
    
    while timeSimulated < timePassed do
    
        // So last frame is run with partial interval
        timeInterval = math.min(timeInterval, timePassed - timeSimulated)
    
        // Update game rules on the server
        if(Server) then
            
            // Used so entities have their OnUpdate() methods called
            local time = Shared.GetTime()
            Server.Update(timeInterval)
            
            if math.abs((time + timeInterval) - Shared.GetTime()) > kEpsilon then
                Print("RunUpdate(): Server.Update(%.2f): Server time not incremented properly (off by %.2f)", timeInterval, Shared.GetTime() - (time + timeInterval))
            end
            
        end  
        
        // Update every player with fake move
        local players = GetEntitiesIsa("Player", -1)
        
        if(move == nil) then
            move = Move()
            move:Clear()
        end
        
        move.time = timeInterval
        
        for index, player in ipairs(players) do 
                    
            player:OnProcessMove(move)

        end
        
        timeSimulated = timeSimulated + timeInterval
        
        // For efficiency we want the ability to run updates in one chunk
        if oneUpdate then
            break
        end
        
    end
    
    //Print("RunUpdate(%.2f) end, timeSimulated = %.2f", timePassed, timeSimulated)
 
end

// Helper function for RunUpdate
function RunOneUpdate(timePassed)
    RunUpdate(timePassed, nil, true)
end

// Run enough discrete updates to make sure minTimePassed passes (usually results in a bit more time passed).
// Returns time passed.
function RunUpdates(minTimePassed)

    local numUpdates = math.ceil( minTimePassed / GetMinServerUpdateInterval() )
    //Print("RunUpdates(%.2f) - Running %d updates", minTimePassed, numUpdates)
    
    for i = 1, numUpdates do
        RunUpdate()
    end
    
    return numUpdates * GetMinServerUpdateInterval()
    
end

function MoveEntityDistanceFrom(moveEntity, baseEntity, distance)
    local origin = (baseEntity:GetOrigin())
    local newOrigin = Vector(origin.x + distance, origin.y, origin.z)
    moveEntity:SetOrigin(newOrigin)
end

// Used for telling if animation is playing. Takes an animation name or animTable like 
// {{1, "draw"}, {1, "draw2"}} and returns true if equal or if in that table. 
function GetAnimationInTable(animName, animOrTable)

    //Print("GetAnimationInTable(%s, %s)", animName, ToString(animOrTable))
    
    if type(animName) ~= "string" then
        Print("GetAnimationInTable(%s, %s) - First parameter not a string.", tostring(animName), tostring(animOrTable))
    end
    
    if type(animOrTable) == "table" then
    
        for index, animPair in ipairs(animOrTable) do
        
            if animPair[2] == animName then
            
                return true
                
            end
            
        end
        
        return false
        
    elseif type(animOrTable) == "string" then
        return animName == animOrTable
    else
        Print("GetAnimationInTable(%s, %s) - bad type passed for 2nd parameter.", animName, type(animOrTable))
    end
    
    return false
    
end

function GetPointOnGround()

    // Return first player spawn (must be deterministic)
    local spawns = Server.playerSpawnList
    if table.maxn(spawns) > 0 then
    
        return Vector(spawns[1]:GetOrigin())
    
    else
        Print("GetPointOnGround() - Couldn't find PlayerSpawn, returning <0, 0, 0>")
    end
    
    return Vector(0, 0, 0)
    
end

// Input mask like Move.Weapon1, Move.Jump, Move.Crouch, etc.
function BuildMove(inputMask, x, z)

    local input = Move()
    
    input:Clear()    
    
    if inputMask then
        input.commands = bit.bor(input.commands, inputMask) 
    end
    
    if x then 
        input.move.x = x
    end
    
    if z then
        input.move.z = z
    end
    
    return input
    
end

function CommAction(player, techId)
    if(player:GetIsCommander()) then
        player:ProcessTechTreeAction(tonumber(techId), nil, nil)
    end
end
