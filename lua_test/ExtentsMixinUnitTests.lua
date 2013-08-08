// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ExtentsMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/ExtentsMixin.lua")
module( "ExtentsMixinUnitTests", package.seeall, lunit.testcase )

// Create test class and test mixin.
class 'ExtentsMixinTestEntity' (Entity)

function ExtentsMixinTestEntity:GetTechId()
    return 111
end

// Tests begin.
function setup()
end

function teardown()
end

function TestExtentsMixinGetExtents()

    MockMagic.CreateGlobalMock("LookupTechData"):GetFunction():SetReturnValues({Vector(3, 3, 3)})
    
    local extentsMixinTestEntity = ExtentsMixinTestEntity()

    assert_not_error(function() InitMixin(extentsMixinTestEntity, ExtentsMixin) end)
    
    assert_equal(Vector(3, 3, 3), extentsMixinTestEntity:GetExtents())
    
    function extentsMixinTestEntity:GetExtentsOverride() return Vector(2, 2, 2) end
    
    assert_equal(Vector(3, 3, 3), extentsMixinTestEntity:GetMaxExtents())

end