// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// OnosTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "OnosTest", package.seeall, lunit.testcase )

local onos = nil

function setup()

    SetPrintEnabled(true, "OnosTest")

    GetGamerules():ResetGame()

    onos = InitializePlayer(Onos.kMapName, 2)
        
end

function teardown()
    Cleanup()
end

function test1()
    assert_equal(Onos.kModelName, onos:GetModelName())
    
    assert_equal(Onos.kHealth, onos:GetHealth())
    assert_equal(Onos.kHealth, onos:GetMaxHealth())
    
    assert_equal(Onos.kArmor, onos:GetArmor())
    assert_equal(Onos.kArmor, onos:GetMaxArmor())
    
    // Make sure we have valid view model
    assert_not_nil(onos:GetViewModelEntity())    
    assert_not_equal(0, onos:GetViewModelEntity():GetModelIndex()) 

end
