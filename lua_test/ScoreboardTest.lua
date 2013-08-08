// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ScoreboardTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "ScoreboardTest", package.seeall, lunit.testcase )

// Test scoreboard 
function test1()

    SetPrintEnabled(true, "ScoreboardTest")
    
    local playerName = "Charlie"
    local entNum = 101
    local teamNum = 1
    local score = 2
    local kills = 4
    local deaths = 7
    
    Scoreboard_SetPlayerData(playerName, entNum, teamNum, score, kills, deaths)
    
    local scoreData = GetScoreData({teamNum})
    assert_true(scoreData ~= {})
    assert_true(type(scoreData) == "table")
    assert_equal(playerName, scoreData[1])
    assert_equal(score, scoreData[2])
    assert_equal(kills, scoreData[3])    
    assert_equal(deaths, scoreData[4]) 
    assert_equal(0, scoreData[5]) 
    
    local newPing = 100
    Scoreboard_SetLocalPlayerData(playerName, kScoreboardDataIndexPing, newPing)
    assert_equal(newPing, Scoreboard_GetPlayerData(entNum, kScoreboardDataIndexPing))
    
    // Add 2nd player
    playerName = "Charlie2"
    entNum = 104
    Scoreboard_SetPlayerData(playerName, entNum, teamNum, score, kills, deaths)
    
    scoreData = GetScoreData({teamNum})
    assert_true(scoreData ~= {})
    assert_true(type(scoreData) == "table")
    assert_equal(playerName, scoreData[6])
    assert_equal(10, table.count(scoreData))

    // Test get player name functionality
    playerName = "ChubbyBunny"
    entNum = 102
    teamNum = 2
    score = 3
    kills = 1
    deaths = 0
    
    Scoreboard_SetPlayerData(playerName, entNum, teamNum, score, kills, deaths)
    
    assert_equal(playerName, Scoreboard_GetPlayerData(entNum, kScoreboardDataIndexName))
    assert_equal(score, Scoreboard_GetPlayerData(entNum, kScoreboardDataIndexScore))
    assert_equal(nil, Scoreboard_GetPlayerData(103, kScoreboardDataIndexName))

end


