// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// NS2UtilityUnitTests.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("MockMagic.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/NS2Utility.lua")
module( "NS2UtilityUnitTests", package.seeall, lunit.testcase )

local attacker = nil
local defender = nil

function setup()

    attacker = CreateMockLiveEntity()
    attacker:AddFunction("GetCanTakeDamage"):SetReturnValues({true})
    attacker:AddFunction("GetOwner"):SetReturnValues({nil})
    attacker:AddFunction("GetTeamNumber"):SetReturnValues({1})
    InitMixin(attacker, { type = "Team" })

    defender = CreateMockLiveEntity()
    defender:AddFunction("GetCanTakeDamage"):SetReturnValues({true})
    defender:AddFunction("GetOwner"):SetReturnValues({nil})
    defender:AddFunction("GetTeamNumber"):SetReturnValues({2})
    InitMixin(defender, { type = "Team" })
    
end

function teardown()
end

function TestSelfDamage()
    assert_true(CanEntityDoDamageTo(attacker, attacker, false, false, false))
end

function TestCommStationTrapFriendlies()
    
    defender:AddFunction("GetTeamNumber"):SetReturnValues({1})    
    SetMockType(attacker, "CommandStation")
    assert_true(CanEntityDoDamageTo(attacker, defender, false, false, false))
    
end

function TestFriendlyFire()
    
    defender:AddFunction("GetTeamNumber"):SetReturnValues({1})
    assert_false(CanEntityDoDamageTo(attacker, defender, false, false, false))
    assert_true(CanEntityDoDamageTo(attacker, defender, false, false, true))
    
end

function TestInfestationVerticalSize()

    local floater = CreateMockLiveEntity()
    assert_equal(1, GetInfestationVerticalSize(floater))

    // Spawn height    
    floater:AddFunction("GetTechId"):SetReturnValues({1})

    MockMagic.CreateGlobalMock("LookupTechData"):GetFunction():SetReturnValues({10})
    assert_equal(10, GetInfestationVerticalSize(floater))
    
    // Hover height set, but smaller than spawn height
    floater:AddFunction("GetHoverHeight"):SetReturnValues({9})
    assert_equal(10, GetInfestationVerticalSize(floater))
    
    // Hover height set, bigger than spawn height
    floater:GetFunction("GetHoverHeight"):SetReturnValues({11})
    assert_equal(11, GetInfestationVerticalSize(floater))

end


