// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TracerMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/TracerMixin.lua")
Script.Load("lua/Vector.lua")
module( "TracerMixinUnitTests", package.seeall, lunit.testcase )

function setup()
end

function teardown()
end

function TestTriggerTracer()

    local randomMock = MockMagic.CreateGlobalMock("RandomMaker")
    local testEntity = CreateMockEntity()
    testEntity:AddFunction("GetBarrelPoint"):SetReturnValues({Vector(0, 0, 1)})
    InitMixin(testEntity, TracerMixin, { kTracerPercentage = 0.2, kRandomProvider = randomMock })
    
    randomMock:GetFunction():SetReturnValues({0.3})
    testEntity:TriggerTracer(Vector(0, 0, 10))
    local createTracerMock = MockMagic.CreateGlobalMock("CreateTracer")
    testEntity:OnUpdateRender()
    
    local createTracerCallHistory = createTracerMock:GetFunction():GetCallHistory()
    assert_equal(0, #createTracerCallHistory)
    
    randomMock:GetFunction():SetReturnValues({0.1})
    testEntity:TriggerTracer(Vector(0, 0, 10))
    testEntity:OnUpdateRender()
    
    assert_equal(1, #createTracerCallHistory)
    assert_equal(3, #createTracerCallHistory[1].passedParameters)
    assert_equal(Vector(0, 0, 1), createTracerCallHistory[1].passedParameters[1])
    assert_equal(Vector(0, 0, 10), createTracerCallHistory[1].passedParameters[2])
    assert_equal(Vector(0, 0, 75), createTracerCallHistory[1].passedParameters[3])

end