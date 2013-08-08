// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TeamMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockGamerules.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/TeamMixin.lua")
module( "TeamMixinUnitTests", package.seeall, lunit.testcase )

class 'TeamEntity' (Entity)

TeamEntity.networkVars =
{
}

PrepareClassForMixin(TeamEntity, TeamMixin)

local testTeamEntity = nil
// Tests begin.
function setup()

    testTeamEntity = TeamEntity()
    function testTeamEntity:OnTeamChange() self.onTeamChangedCalled = true end
    InitMixin(testTeamEntity, TeamMixin)
    
end

function TestTeamMixinSetTeamNumber()

    assert_equal(-1, testTeamEntity:GetTeamNumber())
    assert_equal(kNeutralTeamType, testTeamEntity:GetTeamType())
    assert_equal(nil, testTeamEntity.onTeamChangedCalled)
    
    testTeamEntity:SetTeamNumber(1)
    
    assert_equal(1, testTeamEntity:GetTeamNumber())
    assert_equal(kTeam1Type, testTeamEntity:GetTeamType())
    assert_equal(true, testTeamEntity.onTeamChangedCalled)
    
end

function TestTeamMixinGetTeam()

    local mockTeam = MockMagic.CreateMock()
    MockServer()
    CreateMockGamerules():AddFunction("GetTeam"):SetReturnValues({ mockTeam })
    MockMagic.CreateGlobalMock("GetHasGameRules"):GetFunction():SetReturnValues({true})
    
    assert_equal(mockTeam, testTeamEntity:GetTeam())
    
end