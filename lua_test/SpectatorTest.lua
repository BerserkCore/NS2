// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// SpectatorTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "SpawnTest", package.seeall, lunit.testcase )

Script.Load("UtilityTest.lua")

local marine = nil

function setup()

    SetPrintEnabled(true, "SpectatorTest")
    
    RunUpdate(.1)
       
    GetGamerules():ResetGame()
    
    marine = InitializeMarine()

    GetGamerules():SetGameStarted()
    
    RunUpdate(.1)    
    
end

function teardown()   
    Cleanup()
end

function TestNextSpectatorMode()

    local spectator = {}
    Spectator.kSpectatorMode = enum('Mode1', 'Mode2', 'Mode3')

end

function smokeTestSpect()

    // Create spectator
    marine:TakeDamage(1000)
    assert_false(marine:GetIsAlive())
    RunOneUpdate(10)
    
    local spectator = GetGamerules():GetTeam1():GetPlayer(1)
    assert_not_nil(spectator)
    assert_true(spectator:isa("Spectator"))
    
    // Make sure he's not visible
    assert_false(spectator:GetIsVisible())
    RunOneUpdate(1)
    assert_false(spectator:GetIsVisible())
    
    assert_equal("", spectator:GetModelName())
    
end