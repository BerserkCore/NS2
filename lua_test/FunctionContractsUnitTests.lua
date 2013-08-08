// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// FunctionContractsUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockLiveEntity.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/FunctionContracts.lua")
module( "UtilityUnitTests", package.seeall, lunit.testcase )

function setup()
end

function teardown()
end

function TestFunctionTypes()

    local upVal1 = 123
    local function TestTypes(arg1, arg2, arg3, arg4)
        // Local variables shouldn't affect anything.
        local localVar = nil
        // Up value shouldn't affect anything.
        upVal1 = upVal1 + 1
        if arg1 == 100 then
            return false
        end
        return CreateMockEntity()
    end
    AddFunctionContract(TestTypes, { Arguments = { "number", "table", "Entity", "Vector" }, Returns = { "Entity" } })
    
    SetFunctionContractsEnabled(false)
    
    // Will not generate an error until contracts are enabled.
    assert_not_error(function() TestTypes() end)
    assert_not_error(function() TestTypes(100, { }, CreateMockEntity(), Vector()) end)
    
    SetFunctionContractsEnabled(true)
    
    // The correct way to call the function should generate no errors.
    assert_not_error(function() TestTypes(1, { }, CreateMockEntity(), Vector()) end)
    
    // Missing arguments.
    assert_error(function() TestTypes(1, { }) end)
    // First argument is not a number.
    assert_error(function() TestTypes(true, { }, CreateMockEntity(), Vector()) end)
    // Second argument is not a table.
    assert_error(function() TestTypes(1, nil, CreateMockEntity(), Vector()) end)
    // Third argument is not an Entity.
    assert_error(function() TestTypes(1, { }, CreateMockMove(), Vector()) end)
    // Fourth argument is not a Vector.
    assert_error(function() TestTypes(1, { }, CreateMockMove(), "hello") end)
    // Return is not an Entity.
    assert_error(function() TestTypes(100, { }, CreateMockEntity()) end)

end

function TestFunctionVariableReturnType()

    local function ReturnNumberOrNil(returnNumber, returnBoolean)
        if returnBoolean then
            return false
        end
        if returnNumber then
            return 1, "string"
        else
            return nil, "string"
        end
    end
    // A number or nil is expected as the first return value and string as the second.
    AddFunctionContract(ReturnNumberOrNil, { Arguments = { "boolean", "boolean" }, Returns = { { "number", "nil" }, "string" } })
    
    SetFunctionContractsEnabled(false)
    
    // Should not error until contracts are enabled.
    assert_not_error(function() ReturnNumberOrNil(false, true) end)
    
    SetFunctionContractsEnabled(true)
    
    // This will error as a boolean is returned with no second parameter.
    assert_error(function() ReturnNumberOrNil(false, true) end)
    // These satisfy the contract.
    assert_not_error(function() ReturnNumberOrNil(true, false) end)
    assert_not_error(function() ReturnNumberOrNil(false, false) end)

end

function TestFunctionContractRegistersTwice()

    local function RegisterdTwiceFunction() end
    
    assert_not_error(function() AddFunctionContract(RegisterdTwiceFunction, { Arguments = { }, Returns = { } }) end)
    assert_error(function() AddFunctionContract(RegisterdTwiceFunction, { Arguments = { }, Returns = { } }) end)

end

function TestContractDataFormat()

    local function GenerateCorrectFunction()
        return function (arg1, arg2) return true end
    end
    assert_not_error(function() AddFunctionContract(GenerateCorrectFunction(), { Arguments = { "number", "number" }, Returns = { "boolean" } }) end)
    // Any other elements are ignored.
    assert_not_error(function() AddFunctionContract(GenerateCorrectFunction(), { Arguments = { "number", "number" }, Returns = { "boolean" }, DoesNothing = { "whatever" } }) end)
    
    local function GenerateIncorrectFunction()
        return function (arg1, arg2) return true end
    end
    assert_error(function() AddFunctionContract(nil, { Arguments = { }, Returns = { } }) end)
    assert_error(function() AddFunctionContract(GenerateIncorrectFunction(), { Arguments = { "number", "number" } }) end)
    assert_error(function() AddFunctionContract(GenerateIncorrectFunction(), { Returns = { "boolean" } }) end)
    assert_error(function() AddFunctionContract(GenerateIncorrectFunction(), { }) end)
    assert_error(function() AddFunctionContract(GenerateIncorrectFunction()) end)

end

function TestTypeIsA()

    local function PassInPlayerEntity(arg1)
        return true
    end
    AddFunctionContract(PassInPlayerEntity, { Arguments = { "Entity" }, Returns = { "boolean" } })

    SetFunctionContractsEnabled(true)
    
    // Player isa Entity.
    local playerEntity = CreateMockPlayerEntity()
    assert_not_error(function() PassInPlayerEntity(playerEntity) end)

end

function TestUserdataVsUserdata()

    class 'Userdata1' (Entity)
    
    local function PassInUserdata(arg1)
        return true
    end
    AddFunctionContract(PassInUserdata, { Arguments = { "userdata" }, Returns = { "boolean" } })
    
    SetFunctionContractsEnabled(true)
    
    local userdataObject = Userdata1()
    assert_not_error(function() PassInUserdata(userdataObject) end)

end

function TestUserdataOrTableAsArgumentHasIsA()

    class 'EntityHasIsA' (Entity)
    
    local function PassInUserdataOrTable(arg1)
        return true
    end
    AddFunctionContract(PassInUserdataOrTable, { Arguments = { { "userdata", "table" } }, Returns = { "boolean" } })
    
    SetFunctionContractsEnabled(true)
    
    local entityHasIsA = EntityHasIsA()
    assert_not_error(function() PassInUserdataOrTable(entityHasIsA) end)

end