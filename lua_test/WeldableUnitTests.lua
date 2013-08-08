// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// WeldableUnitTests.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockMagic.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/WeldableMixin.lua")
module( "WeldableUnitTests", package.seeall, lunit.testcase )

local weldable = nil
local welder = nil

local kMaxHealth = 100
local kMaxArmor = 50

function setup()

    weldable = CreateMockEntity()
    weldable:AddFunction("GetTeamNumber"):SetReturnValues({1})
    weldable:AddFunction("OnWeld")
    
    local mockLive = {type = "Live"}
    function mockLive:GetHealth()  return kMaxHealth end 
    function mockLive:GetMaxHealth()  return kMaxHealth end 
    function mockLive:GetArmor()  return kMaxArmor end 
    function mockLive:GetMaxArmor()  return kMaxArmor end 
    InitMixin(weldable, mockLive)
    
    InitMixin(weldable, { type = "Team" })
    
    InitMixin(weldable, WeldableMixin)    
    
    welder = CreateMockEntity()
    welder:AddFunction("GetTeamNumber"):SetReturnValues({1})
    
end

function teardown()
end

function TestGetCanBeWelded()    

    assert_false(weldable:GetCanBeWelded(welder))
    
    weldable:AddFunction("GetArmor"):SetReturnValues({kMaxArmor/2})
    assert_true(weldable:GetCanBeWelded(welder))

    weldable:AddFunction("GetArmor"):SetReturnValues({kMaxArmor})
    weldable:AddFunction("GetHealth"):SetReturnValues({kMaxHealth/2})
    assert_true(weldable:GetCanBeWelded(welder))

end

