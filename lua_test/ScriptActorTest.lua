// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ScriptActorTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "ScriptActorTest", package.seeall, lunit.testcase )

local skulk = nil

function setup()

    SetPrintEnabled(true, "ScriptActorTest")

    RunUpdate(.1)
       
    GetGamerules():ResetGame()
    
    skulk = InitializeAlien()    

    GetGamerules():SetGameStarted()
    
    RunUpdate(.1)
    
end

function teardown()
    Cleanup()
end

// Test entity changing to make sure hooks get called
function testEntityLists()

    // Make sure skulk is in both player and entity list
    assert_not_nil(table.find(GetGamerules():GetAllPlayers(), skulk))
    assert_not_nil(table.find(GetGamerules():GetAllScriptActors(), skulk))
    assert_not_nil(table.find(GetGamerules():GetPlayers( skulk:GetTeamNumber() ), skulk))
    assert_nil(table.find(GetGamerules():GetPlayers( GetEnemyTeamNumber(skulk:GetTeamNumber()) ), skulk))

    // Replace skulk with gorge
    local gorge = skulk:Replace(Gorge.kMapName)    
    assert_not_nil(gorge)
    assert_equal("Gorge", gorge:GetClassName())
    
    // Make sure OnEntityChanged is called and lists are updated
    assert_not_nil(table.find(GetGamerules():GetAllPlayers(), gorge))
    assert_not_nil(table.find(GetGamerules():GetAllScriptActors(), gorge))
    assert_not_nil(table.find(GetGamerules():GetPlayers( gorge:GetTeamNumber() ), gorge))
    assert_nil(table.find(GetGamerules():GetPlayers( GetEnemyTeamNumber(gorge:GetTeamNumber()) ), gorge))

end
