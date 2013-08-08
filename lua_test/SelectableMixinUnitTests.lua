// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// SelectableMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/SelectableMixin.lua")
module( "SelectableMixinUnitTests", package.seeall, lunit.testcase )

local selectableEntity = nil
local testPlayer = nil

// Tests begin.
function setup()

    selectableEntity = CreateMockEntity()
    
    InitMixin(selectableEntity, SelectableMixin)
    
    testPlayer = CreateMockPlayerEntity()
    testPlayer:AddFunction("GetTeamNumber"):SetReturnValues({1})
    
end

function TestSelectableMixinOnGetIsSelectable()


    assert_false(selectableEntity:GetIsSelectable(testPlayer))
    
    local team = { number = 1 }
    InitMixin(selectableEntity, { type = "Team", GetTeamNumber = function() return team.number end })
    assert_true(selectableEntity:GetIsSelectable(testPlayer))
    
    team.number = 2
    assert_false(selectableEntity:GetIsSelectable(testPlayer))
    team.number = 1
    
    function selectableEntity:OnGetIsSelectable(selectableTable, byPlayer)
        selectableTable.selectable = self.testSelectableFlag
    end
    
    selectableEntity.testSelectableFlag = true
    assert_true(selectableEntity:GetIsSelectable(testPlayer))
    
    selectableEntity.testSelectableFlag = false
    assert_false(selectableEntity:GetIsSelectable(testPlayer))

end