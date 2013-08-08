// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MapTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "PlayerTest", package.seeall, lunit.testcase )

local marine 

// Reset game and put one player on each team
function setup()

    SetPrintEnabled(true, "MapTest")

    RunUpdate(.1)
       
    GetGamerules():ResetGame()
    
    player = InitializeMarine()    

    GetGamerules():SetGameStarted()
    
    RunUpdate(.1)
    
end

function teardown()
    Cleanup()
end

function verifyMap(mapName)

    // Switch to map
    Shared.ConsoleCommand(string.format("map %s", mapName))
    
    local numEnts = table.count(GetEntitiesIsa("Trigger"))
    Print("numTriggers: %d", numEnts)
    assert(numEnts > 0)
    
end

// Test player replacement without children
function testMaps()
    verifyMap("dev_test")
    verifyMap("ns2_tram")
end

