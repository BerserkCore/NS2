// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MocGamerules.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks the Gamerules script interface for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function CreateMockGamerules()

    local gamerulesMock = MockMagic.CreateMock()
    SetMockType(gamerulesMock, "Gamerules")
    gamerulesMock:AddFunction("CanEntityDoDamageTo"):SetReturnValues({true})
    gamerulesMock:AddFunction("GetUpgradedDamage"):AddCall(function (gamerulesObj, attacker, doer, damage, damageType) return damage end)
    gamerulesMock:AddFunction("GetDamageMultiplier"):SetReturnValues({1})
    gamerulesMock:AddFunction("OnKill")
    gamerulesMock:AddFunction("GetAllTech"):SetReturnValues({false})

    // GetGamerules() simply returns the gamerulesMock object.
    local getGamerulesMock = MockMagic.CreateGlobalMock("GetGamerules")
    getGamerulesMock:GetFunction():SetReturnValues({gamerulesMock})
    
    return gamerulesMock
    
end