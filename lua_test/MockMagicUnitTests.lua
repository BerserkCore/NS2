// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockMagicUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("TestInclude.lua")
Script.Load("MockMagic.lua")
module( "MockMagicUnitTests", package.seeall, lunit.testcase )

function setup()
end

function teardown()
end

function TestCreateLocalMockObject()

    // A local mock is not registered in the global scope but can be
    // accessed from the returned object.
    local localMock = MockMagic.CreateMock()
    local mockFunction = localMock:AddFunction("TestFunction")
    
    // localMock is passed into TestFunction as the first parameter due to ":".
    assert_equal(nil, localMock:TestFunction(1, true, "Test"))
    
    mockFunction:SetReturnValues({4})
    
    assert_equal(4, localMock.TestFunction())
    
    // All the normal mock utilities work as expected.
    assert_equal(2, table.count(mockFunction:GetCallHistory()))

    assert_true(table.getIsEquivalent({}, mockFunction:GetCallHistory()[1].passedParameters))
    assert_true(table.getIsEquivalent({localMock, 1, true, "Test"}, mockFunction:GetCallHistory()[2].passedParameters))

end

function TestCreateGlobalMockObject()

    assert_equal(nil, TestMock)
    local mockObject = MockMagic.CreateGlobalMock("TestMock")
    
    // Returns the same object if called again.
    local mockObject2 = MockMagic.CreateGlobalMock("TestMock")
    assert_equal(mockObject, mockObject2)
    
    // Ensure it was installed in the global scope.
    assert_equal(mockObject, TestMock)
    assert_not_equal(nil, TestMock)
    
    // Destroying it removes it from the global scope.
    assert_equal(true, MockMagic.DestroyMock(mockObject))
    assert_equal(nil, TestMock)
    
    assert_equal(false, MockMagic.DestroyMock(mockObject))

end

function TestCreateGlobalMockValue()

    assert_equal(nil, kGlobalTestValue)
    
    local globalMockValue = MockMagic.CreateGlobalMockValue("kGlobalTestValue", 82.3)
    
    assert_equal(82.3, kGlobalTestValue)
    
    // Trying to create it again will return the existing mock without modifying it.
    local globalMockValue2 = MockMagic.CreateGlobalMockValue("kGlobalTestValue", "Hello")
    
    assert_equal(globalMockValue, globalMockValue2)
    assert_equal(82.3, kGlobalTestValue)
    
    MockMagic.DestroyMock(globalMockValue)
    
    assert_equal(nil, kGlobalTestValue)

end

function TestCreateMockFunction()

    // A mock can act as a function
    local mockObject = MockMagic.CreateGlobalMock("GlobalFunctionTest")
    assert_equal(nil, GlobalFunctionTest())
    
    // nil can be passed in to return the function for the mock object.
    local mockFunction = mockObject:GetFunction()
    // At which point it can be used like any other mock function.
    mockFunction:SetReturnValues({123})
    assert_equal(123, GlobalFunctionTest())
    
    assert_equal(2, table.count(mockFunction:GetCallHistory()))
    
    GlobalFunctionTest("passed parameter")
    
    assert_equal(3, table.count(mockFunction:GetCallHistory()))
    assert_equal("passed parameter", mockFunction:GetCallHistory()[1].passedParameters[1])
    
    assert_true(MockMagic.DestroyMock(mockObject))
    
end

function TestMockAddFunctionToObject()

    local mockObject = MockMagic.CreateGlobalMock("TestMock")
    
    assert_equal(nil, TestMock.TestFunction)
    
    local mockFunction = mockObject:AddFunction("TestFunction")
    
    assert_not_equal(nil, mockFunction)
    
    assert_equal("function", type(TestMock.TestFunction))
    
    assert_equal(mockFunction, mockObject:GetFunction("TestFunction"))
    assert_equal(nil, mockObject:GetFunction("NoFunction"))
    
    mockObject:RemoveFunction(mockFunction)
    
    assert_equal(nil, TestMock.TestFunction)
    
    MockMagic.DestroyMock(mockObject)

end

function TestMockAddValueToObject()

    local mockObject = MockMagic.CreateGlobalMock("TestMock")
    
    assert_equal(nil, TestMock.TestValue)
    
    mockObject:SetValue("TestValue", 1)
    
    assert_equal(1, TestMock.TestValue)
    
    mockObject:SetValue("TestValue", "Hello")
    
    assert_equal("Hello", TestMock.TestValue)

end

function TestMockFunctionAddCalls()

    local mockObject = MockMagic.CreateGlobalMock("TestMock")
    local mockFunction = mockObject:AddFunction("TestFunction")
    local testCall = function (firstParam) firstParam[1] = firstParam[1] + 1 end
    // Call the passed in function when this mock function is called.
    mockFunction:AddCall(testCall)
    
    local testValue = { 0 }
    TestMock.TestFunction(testValue)
    assert_equal(1, testValue[1])
    
    assert_true(mockFunction:RemoveCall(testCall))
    
    assert_false(mockFunction:RemoveCall(testCall))
    
    TestMock.TestFunction(testValue)
    assert_equal(1, testValue[1])
    
    mockFunction:AddCall(testCall)
    local testCall2 = function(firstParam, secondParam)
                        firstParam[1] = firstParam[1] + 1
                        secondParam[1] = false
                      end
    mockFunction:AddCall(testCall2)
    
    local testValue2 = { true }
    TestMock.TestFunction(testValue, testValue2)
    assert_equal(3, testValue[1])
    assert_equal(false, testValue2[1])
    
    MockMagic.DestroyMock(mockObject)

end

function TestMockFunctionPassedParameters()

    local mockObject = MockMagic.CreateGlobalMock("TestMock")
    local mockObjectFunction = mockObject:AddFunction("TestFunction")
    
    assert_equal(0, table.count(mockObjectFunction:GetCallHistory()))
    
    TestMock.TestFunction(1, 2, 3)
    
    assert_equal(1, table.count(mockObjectFunction:GetCallHistory()))
    
    assert_true(table.getIsEquivalent({1, 2, 3}, mockObjectFunction:GetCallHistory()[1].passedParameters))
    
    TestMock.TestFunction("Woo")
    
    assert_equal(2, table.count(mockObjectFunction:GetCallHistory()))
    
    assert_true(table.getIsEquivalent({"Woo"}, mockObjectFunction:GetCallHistory()[1].passedParameters))
    assert_true(table.getIsEquivalent({1, 2, 3}, mockObjectFunction:GetCallHistory()[2].passedParameters))

end

function TestMockFunctionReturn()

    local mockObject = MockMagic.CreateGlobalMock("TestMock")
    local mockFunction = mockObject:AddFunction("TestFunction")
    
    // Mock functions return nothing by default.
    assert_equal(nil, TestMock.TestFunction())
    
    mockFunction:SetReturnValues({42})
    
    assert_equal(42, TestMock.TestFunction())
    
    mockFunction:SetReturnValues({true, 82.1, "Blue"})
    
    assert_true(table.getIsEquivalent({true, 82.1, "Blue"}, {TestMock.TestFunction()}))

    MockMagic.DestroyMock(mockObject)

end

function TestMockReturnValueFromCall()

    local mockObject = MockMagic.CreateGlobalMock("TestMock")
    local mockFunction = mockObject:AddFunction("TestFunction")
    
    local testCall = function () return "From Call!" end
    mockFunction:AddCall(testCall)
    assert_equal("From Call!", TestMock.TestFunction())
    
    mockFunction:SetReturnValues({"From return values!"})
    assert_equal("From return values!", TestMock.TestFunction())
    
    mockFunction:SetReturnValues({})
    assert_equal("From Call!", TestMock.TestFunction())
    
    MockMagic.DestroyMock(mockObject)

end

function TestOverrideExisting()

    // TestExistingTable refers to the local modules global namespace.
    assert_true(TestExistingTable == nil)
    // _G["TestExistingTable"] refers to Lua's global namespace.
    assert_true(_G["TestExistingTable"] == nil)
    
    // We need to use Lua's global namespace for this test to work correct
    // in this test module.
    _G["TestExistingTable"] = { }
    // After _G["TestExistingTable"] has been defined, referring to it directly
    // as TestExistingTable works fine.
    local existingTableBeforeMock = TestExistingTable
    
    local mockedExistingTable = MockMagic.CreateGlobalMock("TestExistingTable")
    
    // CreateGlobalMock() overrides the existing table with the mock one.
    assert_true(existingTableBeforeMock ~= TestExistingTable)
    
    MockMagic.DestroyMock(mockedExistingTable)
    
    // DestroyMock() reverts to the value before calling CreateGlobalMock().
    assert_true(existingTableBeforeMock == TestExistingTable)

end

function TestDestroyAllMocks()

    assert_equal(0, MockMagic.GetNumberOfMocks())
    
    MockMagic.CreateGlobalMock("MockOne")
    MockMagic.CreateMock("MockTwo")
    MockMagic.CreateMock("MockThree")
    
    assert_equal(3, MockMagic.GetNumberOfMocks())
    
    MockMagic.DestroyAllMocks()
    
    assert_equal(0, MockMagic.GetNumberOfMocks())

end