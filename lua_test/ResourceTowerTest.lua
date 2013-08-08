// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ResourceTowerTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "ResourceTowerTest", package.seeall, lunit.testcase )

local marinePlayer, alienPlayer = nil

function setup()

    SetPrintEnabled(true, "ResourceTowerTest")
    
    GetGamerules():ResetGame()
    
    marinePlayer = InitializeMarine()
    alienPlayer = InitializeAlien()   

    GetGamerules():SetGameStarted()
    RunOneUpdate(10)
        
end

function teardown()    
    Cleanup()   
    marinePlayer = nil
    alienPlayer  = nil 
end

// Extractors
function test1()

    // Verify extractor created
    local extractors = GetEntitiesIsa("Extractor")
    assert_not_nil(extractors)
    
    local extractor = extractors[1]
    assert_not_nil(extractor)
    assert_equal(kTeam1Index, extractor:GetTeamNumber())
    
    assert_true(extractor:GetIsBuilt())
    RunOneUpdate(2)
    assert_equal(Structure.kAnimActive, extractor:GetAnimation())
    
    RunOneUpdate(30)
    
    // Make sure animation still playing
    assert_equal(Structure.kAnimActive, extractor:GetAnimation())
    
end

