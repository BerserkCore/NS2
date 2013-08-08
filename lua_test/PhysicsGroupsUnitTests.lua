// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// PhysicsGroupsUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/PhysicsGroups.lua")

module( "PhysicsGroupsUnitTests", package.seeall, lunit.testcase )

function TestCreateGroupsFilterMask()

    assert_equal(bit.bnot(math.pow(2, PhysicsGroup.WeaponGroup - 1)), CreateMaskExcludingGroups(PhysicsGroup.WeaponGroup))
    assert_equal(bit.bnot(math.pow(2, PhysicsGroup.WeaponGroup - 1) + math.pow(2, PhysicsGroup.PlayerControllersGroup - 1)), CreateMaskExcludingGroups(PhysicsGroup.WeaponGroup, PhysicsGroup.PlayerControllersGroup))
    
end

function TestCreateGroupsAllowedMask()

    assert_equal(math.pow(2, PhysicsGroup.CommanderUnitGroup - 1), CreateMaskIncludingGroups(PhysicsGroup.CommanderUnitGroup))
    assert_equal(math.pow(2, PhysicsGroup.WeaponGroup - 1) + math.pow(2, PhysicsGroup.RagdollGroup - 1), CreateMaskIncludingGroups(PhysicsGroup.WeaponGroup, PhysicsGroup.RagdollGroup))
    
end