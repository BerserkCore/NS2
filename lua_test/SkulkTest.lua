// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// SkulkTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "SkulkTest", package.seeall, lunit.testcase )

local skulk = nil

function setup()
    
    StandardSetup("SkulkTest")
    
    skulk = InitializeAlien(true)
    
    RunUpdate(1)
    
    assert_not_equal(skulk:GetId(), Entity.invalidId)
    assert_true(skulk:GetCanNewActivityStart())
    
end

function teardown()
    Cleanup()
    skulk = nil
end

function test1()

    assert_equal(Skulk.kModelName, skulk:GetModelName())
    assert_float_equal(Skulk.kViewOffsetHeight, skulk:GetViewOffset().y)
    
    assert_float_equal(Skulk.kHealth, skulk:GetHealth())
    assert_float_equal(Skulk.kHealth, skulk:GetMaxHealth())
    
    assert_float_equal(Skulk.kArmor, skulk:GetArmor())
    assert_float_equal(Skulk.kArmor, skulk:GetMaxArmor())
    
    // Make sure we have valid view model
    assert_not_nil(skulk:GetViewModelEntity())    
    assert_not_equal(0, skulk:GetViewModelEntity():GetModelIndex()) 
    
end

// Smoke test of jumping and wall-running
function test2()

    RunOneUpdate(1)
    assert_true(skulk:GetIsOnGround())
    assert_false(skulk:GetIsWallWalking())

    // Make sure wall running and gravity work 
    local move = BuildMove(Move.Jump)
    RunUpdate(.2, move)
    assert_false(skulk:GetIsWallWalking())
    assert_false(skulk:GetIsOnGround())
    
    RunOneUpdate(1)
    assert_true(skulk:GetGravityForce() < 0)
    assert_false(skulk:GetIsWallWalking())
    assert_true(skulk:GetIsOnGround())

end

function test3()

    RunOneUpdate(1)
    assert_true(skulk:GetIsOnGround())
    assert_false(skulk:GetIsWallWalking())
    assert_false(skulk:GetIsLeaping())
    
    local move = BuildMove(Move.SecondaryAttack)
    RunUpdate(.2, move)
    assert_false(skulk:GetIsOnGround())
    assert_false(skulk:GetIsWallWalking())
    assert_true(skulk:GetIsLeaping())
    
    RunUpdate(3)
    assert_true(skulk:GetIsOnGround())
    assert_false(skulk:GetIsWallWalking())
    assert_false(skulk:GetIsLeaping())
    
end

function testBiteLeap()

    // Leap then bite
    assert_float_equal(skulk:GetEnergy(), 100)
    skulk:SecondaryAttack()
    
    assert_float_not_equal(skulk:GetEnergy(), 100)
    RunUpdate(.2)
    
    local energy = skulk:GetEnergy()
    skulk:PrimaryAttack()
    assert_float_not_equal(skulk:GetEnergy(), energy)
    
end
