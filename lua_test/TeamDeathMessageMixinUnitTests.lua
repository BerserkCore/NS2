// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TeamDeathMessageMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockLiveEntity.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/TeamDeathMessageMixin.lua")
module( "TeamDeathMessageMixinUnitTests", package.seeall, lunit.testcase )

class 'MockTeam'

function MockTeam:OnKill()
    self.onKillCalled = true
end

function MockTeam:SendCommand(command)
    self.deathMessageCommand = command
end

function setup()
end

function TestDeathMessageOnKill()

    local mockTeam = MockTeam()
    
    InitMixin(mockTeam, TeamDeathMessageMixin)
    
    local targetEntity = CreateMockLiveEntity()
    targetEntity:AddFunction("GetSendDeathMessage"):SetReturnValues({true})
    targetEntity:AddFunction("GetTechId"):SetReturnValues({4})
    InitMixin(targetEntity, { type = "Team" })
    targetEntity:AddFunction("GetTeamNumber"):SetReturnValues({1})
    
    local damage = 10
    local killer = CreateMockLiveEntity()
    killer:AddFunction("GetOwner"):SetReturnValues({nil})
    killer:AddFunction("GetTechId"):SetReturnValues({5})
    InitMixin(killer, { type = "Team" })
    killer:AddFunction("GetTeamNumber"):SetReturnValues({2})
    
    local doer = CreateMockLiveEntity()
    doer:AddFunction("GetDeathIconIndex"):SetReturnValues({3})
    local point = Vector(0, 0, 0)
    local direction = Vector(0, 0, 1)
    mockTeam:OnKill(targetEntity, damage, killer, doer, point, direction)
    
    assert_true(mockTeam.onKillCalled)
    
    assert_equal("deathmsg 0 5 2 3 0 4 1", mockTeam.deathMessageCommand)

end