// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// GamerulesTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "GamerulesTest", package.seeall, lunit.testcase )

Script.Load("UtilityTest.lua")
Script.Load("lua/Gamerules_Global.lua")

local marinePlayer = nil
local alienPlayer = nil

function setup()

    SetPrintEnabled(true, "GamerulesTest")

    GetGamerules():ResetGame()
    
    marinePlayer = InitializeMarine()
    alienPlayer = InitializeAlien()        
    
end

function teardown()
    Cleanup()
end

// Test game start and countdown and victory/loss
function test1()

    RunOneUpdate(1)
    assert_false(GetGamerules():GetGameStarted())

    RunOneUpdate(10)
    assert_true(GetGamerules():GetGameStarted())
    
    // Destroy hive and verify aliens lost
    local hives = GetEntitiesIsa("Hive", kTeam2Index)
    assert_equal(table.maxn(hives), 1)
    DestroyEntity(hives[1])
    assert_true(GetGamerules():GetTeam2():GetHasTeamLost())
    
    // Destroy Command Station and verify marines lost
    local commandStations = GetEntitiesIsa("CommandStation", kTeam1Index)
    assert_equal(table.maxn(commandStations), 1)
    DestroyEntity(commandStations[1])
    assert_true(GetGamerules():GetTeam1():GetHasTeamLost())    

end

// Make sure repeated round reset works 
function testReset()

    GetGamerules():ResetGame()
    
    local startEntDescs = GetEntDescs()
    local testStartNumEnts = GetNumEnts()
    
    // Reset lots of times
    for i = 0, 30 do
    
        GetGamerules():ResetGame()
        RunOneUpdate(.1)
        
        // Log which entities are different but only when necessary for perf.
        local errorMsg = ""
        local numEnts = GetNumEnts()
        if numEnts ~= testStartNumEnts then
            errorMsg = string.format("GamerulesTest:testReset() - after round resets %d didn't preserve the number of entities - (diff is %s)", i, table.tostring(table.diff(startEntDescs, GetEntDescs())))
        end
        assert_equal(testStartNumEnts, numEnts, errorMsg)

    end    

    RunOneUpdate(.1)

    // Make sure tech tree still intact but lookup marinePlayer again after reset because it's been rebuilt
    marinePlayer = GetEntitiesIsa("Marine")[1]
    local techTree = marinePlayer:GetTechTree()
    assert_not_nil(techTree)

end

function test3()

    // Make sure player that joins server doesn't have empty name
    assert_not_nil(alienPlayer:GetName())
    assert_not_nil(marinePlayer:GetName())
    
    assert_false(alienPlayer:GetName() == "")
    assert_false(marinePlayer:GetName() == "")
    
    // Test weirder names with symbols, spaces, etc.
    alienPlayer:SetName("[UWE] Chops")
    assert_equal("[UWE] Chops", alienPlayer:GetName())
    
    alienPlayer:SetName("\"[UWE] Chops\"")
    assert_equal("[UWE] Chops", alienPlayer:GetName())
    
    alienPlayer:SetName("57*$^#^% A093 *398Q")
    assert_equal("57*$^#^% A093 *398Q", alienPlayer:GetName())
    
    // Make sure long names get trimmed
    local kLongName = "123456789012345678901234567890"
    alienPlayer:SetName(kLongName)
    assert_equal(string.sub(kLongName, 0, kMaxNameLength), alienPlayer:GetName())
    assert_equal(kMaxNameLength, alienPlayer:GetName():len())

end

// If players join team after game has started they should go into spawn queue. 
function test5()

    RunOneUpdate(10)
    assert_true(GetGamerules():GetGameStarted())

    local newMarine = InitializeMarine(false, true)
    RunOneUpdate(.1)
    assert_true(newMarine:GetTeam():GetIsPlayerInRespawnQueue(newMarine))

    local newAlien = InitializeAlien(false, true)
    RunOneUpdate(.1)
    assert_true(newAlien:GetTeam():GetIsPlayerInRespawnQueue(newAlien))

end

// If players join team before game started or if cheats are on, they can spawn immediately at team location.
function test6()

    // No update has run yet so game shouldn't be started
    assert_false(GetGamerules():GetGameStarted())
    
    local newMarine = InitializeMarine()    
    assert_false(newMarine:GetTeam():GetIsPlayerInRespawnQueue(newMarine))

    local newAlien = InitializeAlien()    
    assert_false(newAlien:GetTeam():GetIsPlayerInRespawnQueue(newAlien))  
    RunOneUpdate(1)
    
end

// Make sure spectate command works
function test7()

    local success, newPlayer = Spectate(marinePlayer)
    assert_true(success)
    assert_not_equal(newPlayer, marinePlayer)

end

// Test hive sight. Add some more robust tests.
/*function test8()

    // Move player so he's looking at hive to make number of blips 0
    local hive = GetEntitiesIsa("Hive", kTeam2Index)[1]
    assert_not_nil(hive)
    MoveEntityDistanceFrom(alienPlayer, hive, 3)
    SetAnglesFromVector(alienPlayer, hive:GetOrigin())
    
    local sightedEntityPairs = {}
    local entities = GetEntitiesIsa("ScriptActor", -1)
    local team = alienPlayer:GetTeam()
    local queuedNumEnts = 0
    
    for entIndex, entity in ipairs(entities) do
        
        local blipType = team:GetBlip(entity)
        
        if(blipType ~= kBlipType.Undefined) then
            
            table.insertunique(sightedEntityPairs, {entity, blipType})
            queuedNumEnts = queuedNumEnts + 1
            
        end        
        
    end
    
    assert_equal(6, queuedNumEnts)
    
    local numEnts = team:SendBlipData(alienPlayer, sightedEntityPairs)
    assert_equal(0, numEnts)
        
end*/

function testUniqueNames()

    // Have a bunch of players join the server, make sure they are all assigned unique names
    for i = 1, 3 do
        InitializeMarine()    
        InitializeAlien()
        InitializeReadyRoom()
    end
    
    local players = GetEntitiesIsa("Player")
    
    local names = {}
    for index, player in ipairs(players) do
        table.insertunique(names, player:GetName())
    end
    
    assert_equal(table.count(players), table.count(names))
    
end

// Test to make sure game start works and that game resets properly and preserves players on teams. 
// Also check game end when no players left on team.
function testGameStart()

    DestroyEntity(alienPlayer)
    RunUpdate(.1)

    // Make sure we are properly on the team
    local team = GetGamerules():GetTeam1()
    assert_not_nil(team)
    assert_true(team:GetHasActivePlayers())
    RunOneUpdate(1)
    local np = marinePlayer:GetTeam():GetNumPlayers()
    assert_equal(1, np, "Numplayers ~= 1")

    // Game won't start until both sides have players
    RunOneUpdate(1)
    GetGamerules():CheckGameStart()
    assert_false(GetGamerules():GetGameStarted())    

    local alienPlayer = InitializeAlien()
    GetGamerules():SetGameStarted()
    
    RunOneUpdate(1)
    assert_true(GetGamerules():GetGameStarted())   
    
    GetGamerules():ResetGame()
    assert_false(GetGamerules():GetGameStarted()) 
    GetGamerules():SetGameStarted()
    RunOneUpdate(1)
    assert_true(GetGamerules():GetGameStarted())
    
    // Move alien to ready room, check losing team
    alienPlayer = GetGamerules():GetTeam2():GetPlayer(1)
    assert_not_nil(alienPlayer)
    
    local success, readyRoomPlayer = ReadyRoom( alienPlayer ) 
    assert_true(success)
    assert_not_nil(readyRoomPlayer)
    
    GetGamerules():SetPreventGameEnd(false)
   
    RunOneUpdate(1)
    assert_true(GetGamerules():GetGameEnded())
    
    local team2Lost = (GetGamerules():GetLosingTeam() == GetGamerules():GetTeam2())
    assert_true(team2Lost)

    // Re-set global player variable so it can be deleted (it was changed during reset-game)
    local numPlayers = 0
    function TestNonNilPlayers(player)
        assert_not_nil(player)
        numPlayers = numPlayers + 1
    end
    
    team:ForEachPlayer(TestNonNilPlayers)
    assert_equal(1, numPlayers) 
    
end           

// Test computation of player list
function testPlayerList()

    local list = GetGamerules():GetAllPlayers()
    assert_not_nil(list)
    
    assert_equal(2, table.count(list))
    
    assert_not_equal(Entity.invalidId, list[1]:GetId())
    assert_not_equal(Entity.invalidId, list[2]:GetId())
    
    assert_equal("Marine", list[1]:GetClassName())
    assert_equal("Skulk", list[2]:GetClassName())

    alienPlayer:Kill(alienPlayer, nil, nil, nil)

    list = GetGamerules():GetAllPlayers()
    assert_not_nil(list)    
    assert_equal(1, table.count(list))
    
    assert_not_equal(Entity.invalidId, list[1]:GetId())
    //assert_not_equal(Entity.invalidId, list[2]:GetId())   
    
    // Back to ready room
    GetGamerules():JoinTeam(alienPlayer, 0, true)

    list = GetGamerules():GetAllPlayers()
    assert_not_nil(list)    
    assert_equal(2, table.count(list))
    
    assert_not_equal(Entity.invalidId, list[1]:GetId())
    assert_not_equal(Entity.invalidId, list[2]:GetId())   

    assert_equal("Marine", list[1]:GetClassName())
    assert_equal("Player", list[2]:GetClassName())    
    
end
