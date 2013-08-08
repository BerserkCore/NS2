// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ResourceTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "ResourceTest", package.seeall, lunit.testcase )

local marinePlayer = nil
local alienPlayer = nil

// Reset game and put one player on each team
function setup()

    SetPrintEnabled(true, "ResourceTest")
    
    RunOneUpdate(1)
    
    GetGamerules():ResetGame()

    marinePlayer = InitializeMarine()
    alienPlayer = InitializeAlien()
    
    GetGamerules():SetGameStarted()
    
    RunOneUpdate(1)

end

function teardown()
    Cleanup()
    marinePlayer = nil
    alienPlayer  = nil
end

// Test resources setting on game-reset
function test1()

    // Test initial res
    assert_true(marinePlayer:GetResources() == kPlayerInitialResources)
    assert_true(alienPlayer:GetResources() == kPlayerInitialResources)
    assert_true(marinePlayer:GetTeamResources() == kPlayingTeamInitialTeamResources)
    assert_true(alienPlayer:GetTeamResources() == kPlayingTeamInitialTeamResources)
    
    // Sanity check
    local newResources = kPlayerInitialResources + 20
    marinePlayer:SetResources(newResources)
    
    // Make sure we start with proper team resources
    local startTeamResources = GetGamerules():GetTeam1():GetTeamResources()
    assert_true(startTeamResources == kPlayingTeamInitialTeamResources)
    
    // Set team resources
    local newTeamResources = kPlayingTeamInitialTeamResources + 20
    GetGamerules():GetTeam1():SetTeamResources(newTeamResources)
    assert_true(GetGamerules():GetTeam1():GetTeamResources() == newTeamResources)
    
    // Reset game and make sure we are back to original team resources
    GetGamerules():ResetGame()
    startTeamResources = GetGamerules():GetTeam1():GetTeamResources()
    assert_true(startTeamResources == kPlayingTeamInitialTeamResources)  
    
    local numPlayers = 0
    function TestInitialRes(player)
        assert_equal(kPlayerInitialResources, player:GetResources())
        numPlayers = numPlayers + 1
    end
    
    GetGamerules():GetTeam1():ForEachPlayer(TestInitialRes)
    GetGamerules():GetTeam2():ForEachPlayer(TestInitialRes)
    assert_equal(2, numPlayers)
    
end

// Check for game win when team has harvested enough 
/*function test2()

    GetGamerules():SetPreventGameEnd()

    marinePlayer:GetTeam():SetTeamResources(PlayingTeam.kObliterateVictoryTeamResourcesNeeded / 2)
    assert_true(GetGamerules():GetLosingTeam() == nil)
    assert_true(GetGamerules():GetGameStarted())
    
    marinePlayer:GetTeam():SetTeamResources(PlayingTeam.kObliterateVictoryTeamResourcesNeeded - 1)
    RunOneUpdate(1)
    assert_true(GetGamerules():GetLosingTeam() == nil)
    
    marinePlayer:GetTeam():SetTeamResources(PlayingTeam.kObliterateVictoryTeamResourcesNeeded)
    RunOneUpdate(1)
    assert_true(GetGamerules():GetLosingTeam() == GetGamerules():GetTeam2())

end*/



