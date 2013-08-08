// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// BaseMoveMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
module( "BaseMoveMixinUnitTests", package.seeall, lunit.testcase )

// Create test class with mixin.
class 'BaseMoveTestClass' (Entity)

BaseMoveTestClass.networkVars =
{
}

PrepareClassForMixin(BaseMoveTestClass, BaseMoveMixin)

function BaseMoveTestClass:Setup()

    InitMixin(self, BaseMoveMixin, { kGravity = -10 })
    
end

// Required by the BaseMoveMixin.
function BaseMoveTestClass:UpdateMove()
end

// Tests begin.
function setup()
end

function teardown()
end

function TestVelocity()

    local testMover = BaseMoveTestClass()
    assert_equal(nil, testMover.velocity)
    testMover:Setup()
    assert_not_equal(nil, testMover.velocity)

    assert_equal(Vector(0, 0, 0), testMover:GetVelocity())
    
    testMover:SetVelocity(Vector(1, -5.2, 0))
    assert_equal(Vector(1, -5.2, 0), testMover:GetVelocity())

end

function TestGravity()

    local testMover = BaseMoveTestClass()
    assert_equal(nil, testMover.gravityEnabled)
    testMover:Setup()
    assert_not_equal(nil, testMover.gravityEnabled)

    assert_equal(true, testMover:GetGravityEnabled())
    
    testMover:SetGravityEnabled(false)
    assert_equal(false, testMover:GetGravityEnabled())

end