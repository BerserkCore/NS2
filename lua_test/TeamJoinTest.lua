// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TeamJoinTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "TeamJoinTest", package.seeall, lunit.testcase )

local marinePlayer, alienPlayer = nil

function setup()

    GetGamerules():ResetGame()
    
    marinePlayer = InitializeMarine()
    alienPlayer = InitializeAlien()   

    GetGamerules():SetGameStarted()
    RunOneUpdate(10)
        
end

function teardown()    
    Cleanup()    
end

function verifyTeamJoin(teamNumber, classNames)

    local player = InitializeReadyRoom()
    local joinOrigin = Vector(player:GetOrigin())
    joinOrigin.x = joinOrigin.x + 2
    //Print("Join origin: %s", joinOrigin:tostring())
    
    // Create team join 
    local teamJoin = CreateEntity(TeamJoin.kMapName, joinOrigin, teamNumber)
    assert_not_nil(teamJoin)
    
    // Make sure we haven't touched anything yet
    RunOneUpdate(1)
    assert(0, player:GetTeamNumber())

    // Make sure we join appropriate team when we touch join
    //player:SetOrigin(joinOrigin)
    local playerStartX = player:GetOrigin().x
    //Print("Start player origin: %s", player:GetOrigin():tostring())
    
    // Move player onto join
    local move = Move()
    move:Clear()
    move.timePassed = 1
    move.move.x = 1
    RunUpdate(1, move)
    
    player = GetEntitiesIsa("Player")[1]
    assert_not_nil(player)
    
    //Print("After player origin: %s", player:GetOrigin():tostring())
    assert_true(player:GetOrigin().x > playerStartX)
    
    // Make sure player is now one of the class names specified
    local teamJoinWorked = false
    for index, name in ipairs(classNames) do
        if player:isa(name) then
            teamJoinWorked = true
            break
        end
    end
    
    assert_true(teamJoinWorked)
    
    DestroyEntity(teamJoin)
    DestroyEntity(player)
    
    RunOneUpdate(.01)

end

/*
function testTeamJoin()

    // Don't need these
    DestroyEntity(marinePlayer)
    DestroyEntity(alienPlayer)
    RunUpdate(.01)
    
    verifyTeamJoin(kTeam1Index, {"Marine"})
    verifyTeamJoin(kTeam2Index, {"Alien"})
    verifyTeamJoin(kRandomTeamType, {"Marine", "Alien"})
    verifyTeamJoin(kTeamReadyRoom, {"Spectator"})
    
end
*/