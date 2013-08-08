// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ScoringMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/ScoringMixin.lua")
module( "ScoringMixinUnitTests", package.seeall, lunit.testcase )

local mockScoreOwner = nil

// Tests begin.
function setup()

    mockScoreOwner = CreateMockPlayerEntity()
    mockScoreOwner:AddFunction("SetScoreboardChanged")
    InitMixin(mockScoreOwner, ScoringMixin)
    
end

function TestScoringGetScore()

    MockServer()
    
    assert_equal(0, mockScoreOwner:GetScore())
    
    mockScoreOwner:AddScore(10)
    
    assert_equal(10, mockScoreOwner:GetScore())

end

function TestScoringAddScore()

    local serverMock = MockServer()
    
    assert_equal(0, mockScoreOwner:GetScore())
    
    mockScoreOwner:AddScore(10)
    
    assert_equal(10, mockScoreOwner:GetScore())
    
    assert_equal(mockScoreOwner, serverMock:GetFunction("SendCommand"):GetCallHistory()[1].passedParameters[1])
    assert_equal("points 10 0", serverMock:GetFunction("SendCommand"):GetCallHistory()[1].passedParameters[2])
    
    mockScoreOwner:AddScore(10, 2)
    
    assert_equal(20, mockScoreOwner:GetScore())
    
    assert_equal(mockScoreOwner, serverMock:GetFunction("SendCommand"):GetCallHistory()[1].passedParameters[1])
    assert_equal("points 10 2", serverMock:GetFunction("SendCommand"):GetCallHistory()[1].passedParameters[2])
    
end

function TestScoringAddScoreFailsOnClient()

    MockClient()

    assert_equal(0, mockScoreOwner:GetScore())
    
    assert_error(function() mockScoreOwner:AddScore(10) end)
    
    assert_equal(0, mockScoreOwner:GetScore())

end