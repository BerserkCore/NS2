// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TimedCallbackMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/TimedCallbackMixin.lua")
module( "TimedCallbackMixinUnitTests", package.seeall, lunit.testcase )

// Create test class and test mixin.
class 'TimedCallbackTestClass' (Entity)

TimedCallbackTestClass.kTest1Rate = 1
TimedCallbackTestClass.kTest2Rate = 2
TimedCallbackTestClass.kRunOnceRate = 0.5

function TimedCallbackTestClass:Setup()

    InitMixin(self, TimedCallbackMixin)
    
    self.totalTime1 = 0
    self.totalTime2 = 0
    self.runOnceTime = 0
    
end

function TimedCallbackTestClass:TestCallback1(currentRate)

    self.totalTime1 = self.totalTime1 + currentRate
    // Return true to allow the callback to continue and a rate
    // to change to (or same rate to keep it the same).
    return true, TimedCallbackTestClass.kTest1Rate

end

function TimedCallbackTestClass:TestCallback2(currentRate)

    self.totalTime2 = self.totalTime2 + currentRate
    // A second, change rate, parameter isn't needed. It will
    // just continue at the currentRate.
    return true

end

function TimedCallbackTestClass:RunOnceCallback(currentRate)

    self.runOnceTime = self.runOnceTime + currentRate
    // Returning false cancels the callback.
    return false

end

PrepareClassForMixin(TimedCallbackTestClass, TimedCallbackMixin)

// Tests begin.
function setup()
end

function teardown()
end

function TestAddTimedCallback()

    local testClassInstance = TimedCallbackTestClass()
    testClassInstance:Setup()

    // Ensure all the TimedCallbackMixin functions are present.
    assert_equal(TimedCallbackMixin.AddTimedCallback, testClassInstance.AddTimedCallback)
    assert_equal(TimedCallbackMixin.OnUpdate, testClassInstance.OnUpdate)

    // Ensure object state is as we expect.
    assert_equal(0, testClassInstance.totalTime1)
    
    testClassInstance:AddTimedCallback(TimedCallbackTestClass.TestCallback1, TimedCallbackTestClass.kTest1Rate)
    
    // Callback not called until Update.
    assert_equal(0, testClassInstance.totalTime1)
    
    // Run an update at half the rate.
    testClassInstance:OnUpdate(TimedCallbackTestClass.kTest1Rate / 2)
    
    // The callback shouldn't have been called yet.
    assert_equal(0, testClassInstance.totalTime1)
    
    // Run another half update rate.
    testClassInstance:OnUpdate(TimedCallbackTestClass.kTest1Rate / 2)
    
    // The callback should have been called by now.
    assert_equal(TimedCallbackTestClass.kTest1Rate, testClassInstance.totalTime1)

end

function TestAddMultipleTimedCallbacks()

    local testClassInstance = TimedCallbackTestClass()
    testClassInstance:Setup()
    
    testClassInstance:AddTimedCallback(TimedCallbackTestClass.TestCallback1, TimedCallbackTestClass.kTest1Rate)
    testClassInstance:AddTimedCallback(TimedCallbackTestClass.TestCallback2, TimedCallbackTestClass.kTest2Rate)
    testClassInstance:AddTimedCallback(TimedCallbackTestClass.RunOnceCallback, TimedCallbackTestClass.kRunOnceRate)
    
    // Ensure object state is as we expect.
    assert_equal(0, testClassInstance.totalTime1)
    assert_equal(0, testClassInstance.totalTime2)
    assert_equal(0, testClassInstance.runOnceTime)
    
    // Run a few updates to make sure each time is as we expect.
    testClassInstance:OnUpdate(0.5)
    
    assert_equal(0, testClassInstance.totalTime1)
    assert_equal(0, testClassInstance.totalTime2)
    assert_equal(0.5, testClassInstance.runOnceTime)
    
    testClassInstance:OnUpdate(0.5)
    
    assert_equal(1, testClassInstance.totalTime1)
    assert_equal(0, testClassInstance.totalTime2)
    // runOnceTime isn't updated as it returns false and so
    // only runs once.
    assert_equal(0.5, testClassInstance.runOnceTime)
    
    testClassInstance:OnUpdate(1)
    
    assert_equal(2, testClassInstance.totalTime1)
    assert_equal(2, testClassInstance.totalTime2)
    assert_equal(0.5, testClassInstance.runOnceTime)
    
end