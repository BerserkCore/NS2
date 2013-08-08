// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// SpawnTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "SpawnTest", package.seeall, lunit.testcase )

Script.Load("UtilityTest.lua")

local player = nil

function setup()
    player = StandardSetup("SpawnTest")
    assert_not_nil(player)    
end

function teardown()   
    Cleanup()
    player = nil
end

// Verify team locations chosen properly and not the same
function test1()

    assert_not_nil(GetGamerules():GetTeam1().teamLocation)
    assert_not_nil(GetGamerules():GetTeam2().teamLocation)
    assert_not_equal(GetGamerules():GetTeam1().teamLocation, GetGamerules():GetTeam2().teamLocation)

end

function test2()
   
    // Verify that we're in the ready room and that we spawned
    assert_true(player ~= nil)
    assert_true(player:GetTeam() == GetGamerules():GetWorldTeam())
    assert_false(player:GetOrigin() == playerOrigin)
    assert_false(playerStuck(player))
    
    // Join marines and make sure we are a marine with a machine gun
    local success = false
    success, player = JoinTeamOne(player, true)
    
    // Run a bit so marine gets weapons
    RunOneUpdate(.1)
    
    assert_true(player ~= nil)
    assert_true(player:isa("Marine"))
    assert_not_nil(player:GetItem(Rifle.kMapName))
    assert_false(playerStuck(player))
    
    // Back to ready room -> no weapons
    success, player = ReadyRoom(player)
    assert_true(success)
    
    assert_true(player ~= nil)
    assert_false(playerStuck(player))

    RunOneUpdate(1)
    assert_true(player:GetIsOnGround())
    
    player:SetOrigin(player:GetOrigin() + Vector(0, 1, 0))
    assert_false(player:GetIsOnGround())    

    // Join aliens -> bite
    success, player = JoinTeamTwo(player, true)
    assert_true(success)
    assert_not_nil(player)

    assert_true(player:isa("Skulk"))
    assert_not_nil(player:GetItem(BiteLeap.kMapName))
    assert_false(playerStuck(player))

    player:SetTeamNumber(kTeamReadyRoom)   

end

function testViewModelCreateDestroy()

    local viewModels = GetEntitiesIsa("ViewModel")
    assert_equal(1, table.count(viewModels))
    
    // Change to marine and make sure view models are preserved
    local success = false
    local marinePlayer = nil
    success, marinePlayer = JoinTeamOne(player)
    assert(success)
    assert_not_nil(marinePlayer)

    viewModels = GetEntitiesIsa("ViewModel")
    assert_equal(1, table.count(viewModels))
    
end

// Reset game and make sure number of entities doesn't change
function test4()

    // Remember original ents - only one player, in ready room
    local testStartEnts = GetNumEnts()
    local testStartEntDescs = GetEntDescs()
    
    // Join marines, remember new number of ents
    local success = false
    local marinePlayer = nil
    success, marinePlayer = JoinTeamOne(player)
    assert(success)
    assert_not_nil(marinePlayer)
    RunUpdate(1)
    
    // Don't destroy it during teardown
    player = nil
    
    // Reset game
    GetGamerules():ResetGame()    
    RunUpdate(.1)
        
    // After reset, marine player is new
    assert_equal(1, GetGamerules():GetTeam1():GetNumPlayers())
    marinePlayer = GetGamerules():GetTeam1():GetPlayer(1)
    assert_not_nil(marinePlayer)
    
    // Readyroom, verify
    local readyRoomPlayer = nil
    success, readyRoomPlayer = GetGamerules():JoinTeam(marinePlayer, kTeamReadyRoom)
    assert_true(success)
    assert_not_nil(readyRoomPlayer)

    // aliens, remember
    local alienPlayer = nil
    success, alienPlayer = JoinTeamTwo(readyRoomPlayer)
    assert(success)
    local alienStartEnts = GetNumEnts()
    local alienTeam = alienPlayer:GetTeam()

    // reset, verify
    GetGamerules():ResetGame()
    assert_equal(alienStartEnts, GetNumEnts())
    
    // ready room, verify
    alienPlayer = GetGamerules():GetTeam2():GetPlayer(1)
    assert_not_nil(alienPlayer)
    success, readyRoomPlayer = ReadyRoom(alienPlayer)
    GetGamerules():SetGameStarted()
    RunOneUpdate(1)
    
    // Make sure we have same number and types of entities
    local newNumEnts = GetNumEnts()
    local errorString = ""
    if testStartEnts ~= newNumEnts then
        errorString = string.format("Diff: %s", table.tostring(table.diff(testStartEntDescs, GetEntDescs())))
    end
    assert_equal(testStartEnts, newNumEnts, errorString)
    
    // Make sure tech tree is working properly
    success, marinePlayer = JoinTeamOne(readyRoomPlayer)
    
    local techTree = marinePlayer:GetTechTree()
    assert(techTree ~= nil)
   
end

// Player must have unique name
function test5()

    local uniqueName = GetUniqueNameForPlayer("NsPlayer", {"Charlie", "Max"})
    assert_equal(uniqueName, "NsPlayer", "GetUniqueNameForPlayer simple case")

    uniqueName = GetUniqueNameForPlayer("NsPlayer", {"Charlie", "NsPlayer", "Max"})
    assert_equal(uniqueName, "NsPlayer (2)", "GetUniqueNameForPlayer one clash")

    uniqueName = GetUniqueNameForPlayer("NsPlayer", {"NsPlayer", "NsPlayer (2)"})
    assert_equal(uniqueName, "NsPlayer (3)", "GetUniqueNameForPlayer two clashes")

    uniqueName = GetUniqueNameForPlayer("nsplayer", {"NsPlayer", "NsPlayer (2)"})
    assert_equal(uniqueName, "nsplayer (3)", "GetUniqueNameForPlayer case insensitive with clashes")
    
    // Test full server of NsPlayers
    local names = {}    
    for i=1, kMaxPlayers do

        local name = GetUniqueNameForPlayer("NsPlayer", names)
        table.insert(names, name) 
    
        if(i == 1) then
            assert_equal(names[i], "NsPlayer")
        else
            assert_equal(names[i], string.format("NsPlayer (%d)", i))
        end
        
    end
    
end

function test6()

    local ip = GetGamerules():GetEntities("InfantryPortal")[1]
    assert_not_nil(ip)
    local name = ip:GetLocationName()
    assert_true((name == "Marine Start West") or (name == "Marine Start East"), name)
    
    local hive = GetGamerules():GetEntities("Hive")[1]
    assert_not_nil(hive)
    assert_equal("Alien Start", hive:GetLocationName())
    
end

function test7()

    player:GetTeam():RespawnPlayer(player)
    
    assert_true(player:SpaceClearForEntity(player:GetOrigin(), true))
    assert_true(player:SpaceClearForEntity(player:GetOrigin() + Vector(3, 0, 0), true))
    assert_false(player:SpaceClearForEntity(player:GetOrigin() - Vector(0, 1, 0)))
    
    local secondPlayer = CreateEntity(Player.kMapName, Vector(0, 0, 0), kTeamReadyRoom)    
    secondPlayer:SetControllingPlayer(Server.GetOwner(player))

    local success, alienPlayer
    success, alienPlayer = JoinTeamTwo(secondPlayer, true)
    assert_true(success)
    assert_not_equal(alienPlayer, nil)
    assert_equal("Skulk", alienPlayer:GetClassName())
    
    // Players shouldn't be allowed inside each other
    assert_false(alienPlayer:SpaceClearForEntity(player:GetOrigin()))
    assert_true(alienPlayer:SpaceClearForEntity( player:GetOrigin() + Vector(2, 0, 2), true ))
    
end

function test8()

    // Respawn player so they're not at the origin
    assert_true(player:GetTeam():RespawnPlayer(player))

    // Spawn player in and make sure they fall to the ground
    assert_false(player:GetIsOnGround())
    
    RunOneUpdate(.5)
    
    assert_true(player:GetIsOnGround())
    
end

function SpawnPlayer(mapName, teamNumber)

    local player = CreateEntity(mapName)
    assert_not_nil(player)
        
    // Spawn in ready room
    local success = player:GetTeam():RespawnPlayer(player)
    assert_true(success)
    
    // Now join team
    player:SetTeamNumber(teamNumber)
    
    success = player:GetTeam():RespawnPlayer(player)
    assert_true(success)
    
    assert_equal(mapName, player:GetMapName())
    
    // Make sure old players are deleted and aren't blocking spawn points
    RunOneUpdate()
    
    return player

end

// Spawn every player class and reset game to make sure we don't have errors
function test9()

    SpawnPlayer(Marine.kMapName, 1)
    SpawnPlayer(Heavy.kMapName, 1)
    
    SpawnPlayer(Skulk.kMapName, 2)
    SpawnPlayer(Gorge.kMapName, 2)
    SpawnPlayer(Lerk.kMapName, 2)
    SpawnPlayer(Fade.kMapName, 2)
    SpawnPlayer(Onos.kMapName, 2)
    
    GetGamerules():ResetGame()
    
end

function testSpawnAndDeath()
    
    // Kill marine, make sure he respawns if game hasn't started
    assert_not_nil(player)
    local success, marine = JoinTeamOne(player)
    
    assert_true(GetGamerules():CanEntityDoDamageTo(nil, marine))
    
    marine:TakeDamage(1000)
    assert_false(marine:GetIsAlive())
    
    RunOneUpdate(1)
    
    local spectator = GetGamerules():GetTeam1():GetPlayer(1)
    assert_not_nil(spectator)
    success, newMarine = spectator:ReplaceRespawn()
    
    assert_true(newMarine:GetIsAlive())
    
    // Kill and then go back to ready room from spectator mode
    newMarine:TakeDamage(1000)
    assert_false(newMarine:GetIsAlive())
    
    RunOneUpdate(1)
    spectator = GetGamerules():GetTeam1():GetPlayer(1)
    assert_not_nil(spectator)
    GetGamerules():JoinTeam(spectator, kTeamReadyRoom)   
    
    local alien = InitializeAlien(true)
    assert_true(GetGamerules():CanEntityDoDamageTo(nil, alien))
    
    alien:TakeDamage(1000)
    assert_false(alien:GetIsAlive())

    RunOneUpdate(1)
    
    spectator = GetGamerules():GetTeam2():GetPlayer(1)
    assert_not_nil(spectator)
    success, newAlien = spectator:ReplaceRespawn()
    
    assert_true(newAlien:GetIsAlive())
    
end

function testEggSpawn()

    // Test spawning out of egg
    local marine = InitializeMarine(true)
    local alien = InitializeAlien(true)
    
    GetGamerules():SetGameStarted()
    RunOneUpdate(1)
    assert_true(GetGamerules():GetGameStarted())    
    
    // Test that eggs spawn over time
    hive = GetEntitiesIsa("Hive")[1]
    assert_not_nil(hive)
    assert_equal(Hive.kBaseNumEggs, table.count(GetEntitiesIsa("Egg")))
    assert_equal(Hive.kBaseNumEggs, hive:KillEggs())
    
    assert_equal(0, table.count(GetEntitiesIsa("Egg")))
    RunOneUpdate(10)
    assert_true(table.count(GetEntitiesIsa("Egg")) > 0)
    
    alien:TakeDamage(1000)
    assert_false(alien:GetIsAlive())

    local spectator = GetGamerules():GetTeam2():GetPlayer(1)
    assert_not_nil(spectator)
    assert_equal("Skulk", spectator:GetClassName())
    
    RunOneUpdate(kFadeToBlackTime - .1)
    spectator = GetGamerules():GetTeam2():GetPlayer(1)
    
    assert_not_nil(spectator)
    
    RunOneUpdate(5)
    spectator = GetGamerules():GetTeam2():GetPlayer(1)
    assert_not_nil(spectator)
    assert_true(spectator:isa("AlienSpectator"))

end

function getRespawningEgg(teamNumber)

    local respawningEgg = nil
    
    local eggs = GetEntitiesIsa("Egg", teamNumber)
    
    for index, egg in ipairs(eggs) do
    
        local queuedId = egg:GetQueuedPlayerId()
        if queuedId ~= nil then
        
            respawningEgg = egg
            break
            
        end
        
    end
    
    return respawningEgg

end

// Make sure that if egg respawning player is killed, player goes back into
// respawn queue
function testEggKill()

    // Start game
    InitializeMarine(true)
    InitializeAlien(true)
    RunOneUpdate(8)
    
    local hive = GetEntitiesIsa("Hive", -1)[1]
    assert_not_nil(hive)
    
    RunOneUpdate(6)
    
    local alien = GetGamerules():GetTeam2():GetPlayer(1)
    assert_not_nil(alien)
    alien:OnKill(0, nil, nil, alien:GetOrigin(), nil)
    assert_false(alien:GetIsAlive())

    RunOneUpdate(6)
    local spectator = GetGamerules():GetTeam2():GetPlayer(1)
    assert_not_nil(spectator)
    
    // Find egg that's respawning us
    RunOneUpdate(3)
    local respawningEgg = getRespawningEgg(spectator:GetTeamNumber())
    assert_not_nil(respawningEgg)
    
    // Now kill egg    
    respawningEgg:OnKill(0, nil, nil, respawningEgg:GetOrigin(), nil)
    assert_false(respawningEgg:GetIsAlive())
    RunOneUpdate(2)
    
    spectator = GetGamerules():GetTeam2():GetPlayer(1)
    assert_not_nil(spectator)
    RunOneUpdate(3)
    respawningEgg = getRespawningEgg(spectator:GetTeamNumber())
    assert_not_nil(respawningEgg)
    
end

function testSpawnAngle()
    
    local numTimes = 10
    while(numTimes > 0) do
    
        numTimes = numTimes - 1
        // Respawn player so they're not at the origin
        assert_true(player:GetTeam():RespawnPlayer(player))

        //RunOneUpdate(.5)
        
        local playerOrigin = Vector(player:GetOrigin())
        local playerAngles = Angles(player:GetViewAngles())
        // Ignore y due to gravity or player origin offset
        playerOrigin.y = 0
        local playerSpawnMatch = false
        
        for index, spawnPoint in ipairs(Server.readyRoomSpawnList) do
        
            origin = Vector(spawnPoint:GetOrigin())
            angles = spawnPoint:GetAngles()
            origin.y = 0
            if(playerOrigin == origin and playerAngles == angles) then
            
                playerSpawnMatch = true
                break
                
            end
            
        end
        
        assert_true(playerSpawnMatch)
        
    end
    
end