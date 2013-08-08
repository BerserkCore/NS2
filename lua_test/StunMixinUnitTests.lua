// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// StunMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/StunMixin.lua")
module( "StunMixinUnitTests", package.seeall, lunit.testcase )

local MockVelocityMixin = { }
MockVelocityMixin.type = "VelocityChanger"

function MockVelocityMixin:SetVelocity(velocity)
    self.velocity = velocity
end

function MockVelocityMixin:GetVelocity() return self.velocity end

// Create test class and test mixin.
class 'StunTestClass' (Entity)

StunTestClass.networkVars = { }

PrepareClassForMixin(StunTestClass, StunMixin)

function StunTestClass:Setup()

    InitMixin(self, MockVelocityMixin)
    InitMixin(self, StunMixin)

end

function StunTestClass:GetMass()
    return 1
end

local getTimeMock = nil
// Tests begin.
function setup()

    getTimeMock = MockShared():GetFunction("GetTime")

end

function teardown()
end

function TestStunDampensVelocity()

    local testClassInstance = StunTestClass()
    testClassInstance:Setup()

    getTimeMock:SetReturnValues({0})
    
    testClassInstance:SetVelocity(Vector(0, 1, 0))
    
    // Not stunned yet so velocity should be unaffected.
    assert_equal(Vector(0, 1, 0), testClassInstance.velocity)
    
    testClassInstance:SetKnockback(1, 0, Vector(0, 0, 1), 1, 2)
    
    // Now it is stunned. Downward velocity is not dampened.
    assert_equal(Vector(0, 1, 0), testClassInstance.velocity)

end

function TestGetIsStunned()

    local testClassInstance = StunTestClass()
    testClassInstance:Setup()
    
    getTimeMock:SetReturnValues({0})
    
    assert_false(testClassInstance:GetIsStunned())
    
    testClassInstance:SetKnockback(1, 0, Vector(0, 0, 1), 1, 2)
    
    assert_true(testClassInstance:GetIsStunned())
    
    getTimeMock:SetReturnValues({2})
    
    assert_false(testClassInstance:GetIsStunned())

end