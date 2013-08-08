// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// GorgeTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "GorgeTest", package.seeall, lunit.testcase )

local gorge = nil

function setup()

    SetPrintEnabled(true, "GorgeTest")

    GetGamerules():ResetGame()

    gorge = InitializePlayer(Gorge.kMapName, 2)
        
end

function teardown()
    Cleanup()
    gorge = nil
end

function test1()

    assert_equal(Gorge.kModelName, gorge:GetModelName())
    
    assert_equal(Gorge.kHealth, gorge:GetHealth())
    assert_equal(Gorge.kHealth, gorge:GetMaxHealth())
    
    assert_equal(Gorge.kArmor, gorge:GetArmor())
    assert_equal(Gorge.kArmor, gorge:GetMaxArmor())

    // Make sure we have valid view model
    assert_not_nil(gorge:GetViewModelEntity())    
    assert_not_equal(0, gorge:GetViewModelEntity():GetModelIndex()) 
    
end
