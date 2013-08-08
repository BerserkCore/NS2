// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// DrifterTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "DrifterTest", package.seeall, lunit.testcase )

local drifter = nil

function setup()

    SetPrintEnabled(true, "DrifterTest")

    GetGamerules():ResetGame()

    drifter = CreateEntity(Drifter.kMapName, nil, 2)
        
end

function teardown()
    Cleanup()
    drifter = nil
end

function test1()

    assert_equal(Drifter.kModelName, drifter:GetModelName())
    
    assert_equal(Drifter.kHealth, drifter:GetHealth())
    assert_equal(Drifter.kHealth, drifter:GetMaxHealth())
    
    assert_equal(Drifter.kArmor, drifter:GetArmor())
    assert_equal(Drifter.kArmor, drifter:GetMaxArmor())
    
end
