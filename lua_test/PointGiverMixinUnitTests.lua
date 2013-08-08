// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// PointGiverMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockLiveEntity.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/PointGiverMixin.lua")
module( "PointGiverMixinUnitTests", package.seeall, lunit.testcase )

local mockPointGiver = nil
local mockScoreOwner = nil
local mockTeam = nil

// Tests begin.
function setup()

    // LookupTechData used for determining the point value.
    MockMagic.CreateGlobalMock("LookupTechData"):GetFunction():SetReturnValues({17})
    
    mockPointGiver = CreateMockLiveEntity()
    mockPointGiver:AddFunction("GetTechId"):SetReturnValues({43})
    mockPointGiver:AddFunction("GetTeamNumber"):SetReturnValues({1})
    InitMixin(mockPointGiver, PointGiverMixin)
    
    mockScoreOwner = CreateMockPlayerEntity()
    mockScoreOwner:AddFunction("GetTeamNumber"):SetReturnValues({2})
    
    mockTeam = MockMagic.CreateMock()
    mockTeam:AddFunction("AwardPersonalResources")
    mockScoreOwner:AddFunction("GetTeam"):SetReturnValues({ mockTeam })
    
    local mockScoringMixin = { }
    mockScoringMixin.type = "Scoring"
    function mockScoringMixin:AddScore(scoreToAdd) self.score = scoreToAdd end
    function mockScoringMixin:AddKill() self.kills = (self.kills or 0) + 1 end
    InitMixin(mockScoreOwner, mockScoringMixin)
    
end

function teardown()
end

function TestPointGiverKillGivesPoints()

    assert_equal(17, mockPointGiver:GetPointValue())
    
    mockPointGiver:OnKill(100, mockScoreOwner, nil, nil, nil)
    
    assert_equal(mockPointGiver:GetPointValue(), mockScoreOwner.score)
    // Only killing a player type will award kills.
    assert_equal(nil, mockScoreOwner.kills)

end

function TestPointGiverNoPointsIfOnSameTeam()

    mockPointGiver:AddFunction("GetTeamNumber"):SetReturnValues({2})
    mockScoreOwner:AddFunction("GetTeamNumber"):SetReturnValues({2})
    
    assert_equal(17, mockPointGiver:GetPointValue())
    
    mockPointGiver:OnKill(100, mockScoreOwner, nil, nil, nil)
    
    assert_equal(nil, mockScoreOwner.score)
    assert_equal(nil, mockScoreOwner.kills)
    
end

function TestPointGiverDoNotAwardResForNonPlayer()

    mockScoreOwner:AddFunction("AwardResForKill"):AddCall(function(scoreOwner, checkGivesResEntity)
                                                            scoreOwner.res = 0
                                                            if checkGivesResEntity == mockPointGiver then
                                                                scoreOwner.res = 3
                                                            end
                                                            return scoreOwner.res
                                                          end)
    
    assert_equal(17, mockPointGiver:GetPointValue())
    
    mockPointGiver:OnKill(100, mockScoreOwner, nil, nil, nil)
    
    assert_equal(mockPointGiver:GetPointValue(), mockScoreOwner.score)
    assert_equal(nil, mockScoreOwner.kills)
    
    assert_equal(nil, mockScoreOwner.res)

end

function TestPointGiverAwardResForPlayer()
    
    assert_equal(17, mockPointGiver:GetPointValue())
    
    SetMockType(mockPointGiver, "Player")
    mockPointGiver:OnKill(100, mockScoreOwner, nil, nil, nil)
    
    assert_equal(mockPointGiver:GetPointValue(), mockScoreOwner.score)
    assert_equal(1, mockScoreOwner.kills)
    
    assert_equal(1, #mockTeam:GetFunction("AwardPersonalResources"):GetCallHistory())

end