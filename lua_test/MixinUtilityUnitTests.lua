// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MixinUtilityUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
module( "MixinUtilityUnitTests", package.seeall, lunit.testcase )

// Create test class and test mixin.
class 'MixinUtilityTestClass'

function MixinUtilityTestClass:Setup()

    self.calls = 0
    
end

function MixinUtilityTestClass:Return1()

    self.calls = self.calls + 1
    return 1

end

MixinUtilityTestClass.testTable =
{
    initialField1           = "integer",
    initialField2           = "float"
}

local TestMixin = { }
TestMixin.type = "Test"

// __prepareclass() is called as a result of calling PrepareClassForMixin() to tell
// the Mixin it was added to a new class (happens per class, not per instance).
// Can be used for things like adding network fields from the Mixin to the class.
function TestMixin.__prepareclass(toClass)
    
    if toClass.testTable then
        local addTableFields =
        {
            testField1          = "integer",
            testField2          = "boolean"
        }
        
        for k, v in pairs(addTableFields) do
            toClass.testTable[k] = v
        end
    end
    
end

function TestMixin:__initmixin()

    self.testMixinInited = true

end

function TestMixin:Return2()

    self.calls = self.calls + 1
    return 2

end

local TestMixin2 = { }
TestMixin2.type = "Test2"

function TestMixin2:__initmixin()

    self.testMixin2Inited = true

end

function TestMixin2:Return3()

    self.calls = self.calls + 1
    return 3

end

// Tests begin.
function setup()
end

function teardown()
end

function TestRemoveMixin()    
    local mockEntity = CreateMockEntity()
    function mockEntity:DoSomething()
    end
    
    local savedDoSomething = mockEntity.DoSomething
    
    MockMixin = {}
    MockMixin.type = "Mockery"
    function MockMixin:DoSomething() return "I sware, I have done something" end
    function MockMixin:DoNothing() return nil end
    
    MockMixin2 = {}
    MockMixin2.type = "Mockery2"
    function MockMixin2:DoSomething() return "I sware, I have done something again!!!!" end
    
    // Insert
    InitMixin(mockEntity, MockMixin)
    assert_true(mockEntity['DoSomething__functions'] ~= nil)
    assert_true(mockEntity.DoSomething ~= nil)
    assert_true(mockEntity.DoNothing ~= nil)
    assert_true(savedDoSomething ~= MockMixin.DoSomething)

    // Remove
    RemoveMixin(mockEntity, MockMixin)
    assert_true(mockEntity.DoNothing == nil)
    assert_true(mockEntity['DoSomething__functions'] == nil)
    assert_true(savedDoSomething == mockEntity.DoSomething)
    
    // Insert 2 mixins
    InitMixin(mockEntity, MockMixin)
    InitMixin(mockEntity, MockMixin2)

    // Remove just 1 mixin
    RemoveMixin(mockEntity, MockMixin)
    assert_true(mockEntity.DoNothing == nil)
    assert_true(mockEntity['DoSomething__functions'] ~= nil)
    assert_true(savedDoSomething ~= mockEntity.DoSomething)
end

function TestInitMixin()
    
    local testClassInstance = MixinUtilityTestClass()
    testClassInstance:Setup()
    
    // Ensure the state of this class is as we expect before adding the mixin.
    assert_equal(0, testClassInstance.calls)
    assert_equal(MixinUtilityTestClass.Return1, testClassInstance.Return1)
    assert_equal(nil, testClassInstance.Return2)
    
    // Ensure the Return1 function is working as expected.
    assert_equal(1, testClassInstance:Return1())
    assert_equal(1, testClassInstance.calls)
    
    assert_equal(2, table.countkeys(testClassInstance.testTable))
    
    assert_equal(nil, testClassInstance.testMixinInited)
    
    // Prepare the class for this mixin.
    PrepareClassForMixin(MixinUtilityTestClass, TestMixin)
    
    // Time to add the Mixin to the class instance.
    InitMixin(testClassInstance, TestMixin)

    assert_equal(true, testClassInstance.testMixinInited)
    
    // Ensure the state is as we expect after adding the mixin.
    assert_equal(MixinUtilityTestClass.Return1, testClassInstance.Return1)
    assert_equal(TestMixin.Return2, testClassInstance.Return2)
    
    // Ensure the Return2 function is working as expected.
    assert_equal(2, testClassInstance:Return2())
    assert_equal(2, testClassInstance.calls)
    
    // Ensure __prepareclass() was called during PrepareClassForMixin().
    assert_equal(4, table.countkeys(testClassInstance.testTable))
    
    assert_equal(nil, testClassInstance.testMixin2Inited)
    // Time to add the second Mixin.
    InitMixin(testClassInstance, TestMixin2)
    assert_equal(true, testClassInstance.testMixin2Inited)
    
    // Ensure the Return3 function is working as expected.
    assert_equal(3, testClassInstance:Return3())
    assert_equal(3, testClassInstance.calls)
    
end

// A mixin can only be added to a class instance once but can be initialized on
// the instance multiple times.
function TestOnlyAddMixinOnce()

    class 'TestOnlyAddMixinOnceClass'
    local testOnlyAddMixinOnceClassInstance = TestOnlyAddMixinOnceClass()
    assert_equal(0, NumberOfMixins(testOnlyAddMixinOnceClassInstance))
    
    local TestOnlyAddMixinOnceMixin = { }
    TestOnlyAddMixinOnceMixin.type = "TestAddOnceMixin"

    function TestOnlyAddMixinOnceMixin:__initmixin()

        if self.mixinInited == nil then
            self.mixinInited = 0
        end
        self.mixinInited = self.mixinInited + 1

    end

    assert_equal(nil, testOnlyAddMixinOnceClassInstance.mixinInited)
    
    InitMixin(testOnlyAddMixinOnceClassInstance, TestOnlyAddMixinOnceMixin)
    
    assert_equal(1, NumberOfMixins(testOnlyAddMixinOnceClassInstance))
    assert_equal(1, testOnlyAddMixinOnceClassInstance.mixinInited)
    
    InitMixin(testOnlyAddMixinOnceClassInstance, TestOnlyAddMixinOnceMixin)
    
    assert_equal(1, NumberOfMixins(testOnlyAddMixinOnceClassInstance))
    assert_equal(2, testOnlyAddMixinOnceClassInstance.mixinInited)

end

function TestMixinData()

    local TestDataMixin = { }
    TestDataMixin.type = "Test"
    function TestDataMixin:AFunctionUsingData()
        return self.__mixindata.TestData
    end
    
    class 'TestDataMixinClass'
    local testDataMixinObject = TestDataMixinClass()
    InitMixin(testDataMixinObject, TestDataMixin, { TestData = "Badger!" })
    
    assert_equal("Badger!", testDataMixinObject:AFunctionUsingData())
    
    // The mixindata table should be present even if data is not passed in.
    class 'TestDataMixinClass2'
    local testDataMixinObject2 = TestDataMixinClass2()
    InitMixin(testDataMixinObject2, TestDataMixin)
    
    assert_equal(nil, testDataMixinObject2:AFunctionUsingData())

end

// If the mixin expects the class it is mixed into to support a callback it
// should specify the callback in the expectedCallbacks list.
function TestMixinExpectedCallbacks()

    local TestCallbackMixin = { }
    TestCallbackMixin.type = "Callback"
    TestCallbackMixin.expectedCallbacks = { OnCallback1 = "The first test callback", OnCallback2 = "The second test callback" }
    
    class 'TestNoCallbacksMixinClass'
    local testNoCallbackMixinObject = TestNoCallbacksMixinClass()
    
    assert_error(function() InitMixin(testNoCallbackMixinObject, TestCallbackMixin) end)
    
    class 'TestCallbacksMixinClass'
    function TestCallbacksMixinClass:OnCallback1() end
    function TestCallbacksMixinClass:OnCallback2() end
    local testCallbackMixinObject = TestCallbacksMixinClass()
    
    assert_not_error(function() InitMixin(testCallbackMixinObject, TestCallbackMixin) end)

end

function TestMixinExpectedConstants()

    local TestConstantsMixin = { }
    TestConstantsMixin.type = "Constants"
    TestConstantsMixin.expectedConstants = { Constant1 = "The first test constant", Constant2 = "The second test constant" }
    
    class 'TestConstantsMixinClass'
    local testConstantsMixinObject = TestConstantsMixinClass()
    
    assert_error(function() InitMixin(testConstantsMixinObject, TestConstantsMixin, { }) end)
    
    assert_not_error(function() InitMixin(testConstantsMixinObject, TestConstantsMixin, { Constant1 = 1, Constant2 = true }) end)

end

function TestMixinExpectedMixins()

    local TestExpectedMixinsMixin = { }
    TestExpectedMixinsMixin.type = "ExpectedMixins"
    TestExpectedMixinsMixin.expectedMixins = { ExampleExpectedMixin = "A test expected Mixin." }
    
    local testInstance = { }
    assert_error(function() InitMixin(testInstance, TestExpectedMixinsMixin) end)
    
    local TestExampleExpectedMixin = { }
    TestExampleExpectedMixin.type = "ExampleExpectedMixin"
    
    local testInstance2 = { }
    InitMixin(testInstance2, TestExampleExpectedMixin)
    assert_not_error(function() InitMixin(testInstance2, TestExpectedMixinsMixin) end)

end

function TestMixinNetworkVars()

    local TestNetworkVarsMixin = { }
    TestNetworkVarsMixin.type = "NetworkVarsMixin"
    TestNetworkVarsMixin.networkVars = { testBool = "boolean", testInt = "integer (-1 to 2)" }
    
    local testClass = { }
    testClass.networkVars = { }
    PrepareClassForMixin(testClass, TestNetworkVarsMixin)
    
    assert_equal(2, table.countkeys(testClass.networkVars))

end

function TestMixinOverrideFunctions()

    local TestOverrideFunctionsMixin = { }
    TestOverrideFunctionsMixin.type = "OverrideFunctionsMixin"
    TestOverrideFunctionsMixin.overrideFunctions = { "TestOverrideFunction1", "TestOverrideFunction2" }
    
    local test1Passed = true
    function TestOverrideFunctionsMixin:TestOverrideFunction1()
    end
    
    local test2Passed = true
    function TestOverrideFunctionsMixin:TestOverrideFunction2()
    end
    
    local test3Passed = 0
    function TestOverrideFunctionsMixin:TestNormalFunction1()
        test3Passed = test3Passed + 1
    end
    
    local testInstance = { }
    
    function testInstance:TestOverrideFunction1()
        test1Passed = false
    end
    
    function testInstance:TestOverrideFunction2()
        test2Passed = false
    end
    
    function testInstance:TestNormalFunction1()
        test3Passed = test3Passed + 1
    end
    
    InitMixin(testInstance, TestOverrideFunctionsMixin)
    
    testInstance:TestOverrideFunction1()
    assert_equal(true, test1Passed)
    
    testInstance:TestOverrideFunction2()
    assert_equal(true, test2Passed)
    
    testInstance:TestNormalFunction1()
    assert_equal(2, test3Passed)

end

function TestHasMixin()

    class 'TestHasMixinClass'
    local testClassInstance = TestHasMixinClass()
    
    assert_false(HasMixin(testClassInstance, "Test"))
    
    InitMixin(testClassInstance, TestMixin)
    
    assert_true(HasMixin(testClassInstance, "Test"))

end

function TestDerivedClassesWithMixins()

    local TestBaseMixin = { }
    TestBaseMixin.type = "Base"
    
    class 'TestBaseClass'
    
    function TestBaseClass:Init()
    
        InitMixin(self, TestBaseMixin)
    
    end

    local testBaseClassInstance = TestBaseClass()
    
    assert_false(HasMixin(testBaseClassInstance, "Base"))
    testBaseClassInstance:Init()
    assert_true(HasMixin(testBaseClassInstance, "Base"))
    
    // Now ensure adding a mixin to the base adds it to the derived too.
    
    local TestDerivedMixin = { }
    TestDerivedMixin.type = "Derived"
    
    class 'TestDerivedClass' (TestBaseClass)
    
    function TestDerivedClass:Init()
    
        TestBaseClass.Init(self)
        
        InitMixin(self, TestDerivedMixin)
    
    end
    
    local testDerivedClassInstance = TestDerivedClass()
    assert_false(HasMixin(testDerivedClassInstance, "Base"))
    assert_false(HasMixin(testDerivedClassInstance, "Derived"))
    
    testDerivedClassInstance:Init()
    
    assert_true(HasMixin(testDerivedClassInstance, "Base"))
    assert_true(HasMixin(testDerivedClassInstance, "Derived"))

end

function TestMixinUsesAlreadyDefinedFunction()

    local callOrder = { }

    class 'TestMixinUsesMyFunctionClass' (Entity)
    
    function TestMixinUsesMyFunctionClass:ExampleFunction(param)
        assert(param == 1, type(param))
        table.insert(callOrder, "class")
        return 11
    end
    
    local testMixinUsesMyFunctionInstance = TestMixinUsesMyFunctionClass()
    
    assert_equal(11, testMixinUsesMyFunctionInstance:ExampleFunction(1))
    assert_equal(1, table.count(callOrder))
    assert_equal("class", callOrder[1])
    table.clear(callOrder)

    local TestUseSameFunctionMixin = { }
    TestUseSameFunctionMixin.type = "UsesSameFunction"
    function TestUseSameFunctionMixin:ExampleFunction(param1, param2)
        assert(param1 == 1, type(param1))
        assert(param2 == "two", type(param2))
        table.insert(callOrder, "mixin")
        return 22
    end
    
    InitMixin(testMixinUsesMyFunctionInstance, TestUseSameFunctionMixin)
    
    assert_equal(11, testMixinUsesMyFunctionInstance:ExampleFunction(1, "two"))
    assert_equal(2, table.count(callOrder))
    assert_equal("class", callOrder[1])
    assert_equal("mixin", callOrder[2])
    table.clear(callOrder)
    
    local TestUseSameFunctionMixin2 = { }
    TestUseSameFunctionMixin2.type = "UsesSameFunction2"
    function TestUseSameFunctionMixin2:ExampleFunction(param1, param2, param3)
        assert(param1 == 1, type(param1))
        assert(param2 == "two", type(param2))
        assert(param3 == true, type(param3))
        table.insert(callOrder, "mixin2")
        return 33, "second"
    end
    
    InitMixin(testMixinUsesMyFunctionInstance, TestUseSameFunctionMixin2)
    
    local returnTable = { testMixinUsesMyFunctionInstance:ExampleFunction(1, "two", true) }
    // Only values from the base class are returned from functions that mixins hook into.
    assert_equal(1, #returnTable)
    assert_equal(11, returnTable[1])
    assert_equal(3, table.count(callOrder))
    assert_equal("class", callOrder[1])
    assert_equal("mixin", callOrder[2])
    assert_equal("mixin2", callOrder[3])

end

function TestMixinUsesAlreadyDefinedFunctionWithInheritance()

    class 'TestMixinUsesMyFunctionBaseClass' (Entity)
    function TestMixinUsesMyFunctionBaseClass:InitMixin(mixin)
        InitMixin(self, mixin)
    end
    function TestMixinUsesMyFunctionBaseClass:ExampleFunction()
        return 1
    end
    
    class 'TestMixinUsesMyFunctionChildClass' (TestMixinUsesMyFunctionBaseClass)
    function TestMixinUsesMyFunctionChildClass:InitMixin(mixin)
        TestMixinUsesMyFunctionBaseClass.InitMixin(self, mixin)
    end
    function TestMixinUsesMyFunctionChildClass:ExampleFunction()
        return 1 + TestMixinUsesMyFunctionBaseClass.ExampleFunction(self)
    end
    
    local testMixinUsesMyFunctionInstance = TestMixinUsesMyFunctionChildClass()
    
    assert_equal(2, testMixinUsesMyFunctionInstance:ExampleFunction())

    local TestUseSameFunctionMixin = { }
    TestUseSameFunctionMixin.type = "UsesSameFunction"
    function TestUseSameFunctionMixin:ExampleFunction()
        return 3
    end
    
    testMixinUsesMyFunctionInstance:InitMixin(TestUseSameFunctionMixin)
    
    assert_equal(2, testMixinUsesMyFunctionInstance:ExampleFunction())
    
    local TestUseSameFunctionMixin2 = { }
    TestUseSameFunctionMixin2.type = "UsesSameFunction2"
    function TestUseSameFunctionMixin2:ExampleFunction()
        return 4
    end
    
    testMixinUsesMyFunctionInstance:InitMixin(TestUseSameFunctionMixin2)
    
    assert_equal(2, testMixinUsesMyFunctionInstance:ExampleFunction())

end

function TestMixinAddTagToEntity()

    local addTagMock = MockMagic.CreateGlobalMock("Shared"):AddFunction("AddTagToEntity")
    
    local mockEntity = CreateMockEntity()
    
    local MockMixin = { }
    MockMixin.type = "Mockery"
    
    InitMixin(mockEntity, MockMixin)
    
    assert_equal(1, #addTagMock:GetCallHistory())
    assert_equal(2, #addTagMock:GetCallHistory()[1].passedParameters)
    assert_equal(mockEntity:GetId(), addTagMock:GetCallHistory()[1].passedParameters[1])
    assert_equal("Mockery", addTagMock:GetCallHistory()[1].passedParameters[2])

end

function TestPrepareClassForMixinPassesInExtraParams()

    local TestMixin = { }
    TestMixin.type = "Test"
    
    function TestMixin.__prepareclass(toClass, param1, param2, param3)
        toClass.param1 = param1
        toClass.param2 = param2
        toClass.param3 = param3
    end
    
    local TestClass = { }
    PrepareClassForMixin(TestClass, TestMixin, 1, false, "third")
    
    assert_equal(1, TestClass.param1)
    assert_equal(false, TestClass.param2)
    assert_equal("third", TestClass.param3)

end