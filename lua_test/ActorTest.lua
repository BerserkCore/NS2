// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ActorTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "ActorTest", package.seeall, lunit.testcase )

// Reset game and put one player on each team
function setup()
    SetPrintEnabled(true, "ActorTest")
end

function teardown()
    Cleanup()
end

function testPoseParams()

    local model = Server.CreateEntity(Actor.kMapName)
    model:SetModel(Gorge.kViewModelName)
    
    // Test fake param
    assert_false(model:SetPoseParam("health_spr2", .5))
    
    // Test basic setting
    assert_true(model:SetPoseParam("health_spray", .5))
    assert_float_equal(.5, model:GetPoseParam("health_spray"))
    
    // Test a bit more
    assert_true(model:SetPoseParam("health_spray", 0))
    assert_true(model:SetPoseParam("health_spray", 1))
    assert_float_equal(1, model:GetPoseParam("health_spray"))

end

