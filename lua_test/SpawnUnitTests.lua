// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// SpawnUnitTests.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockMagic.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/NS2Utility.lua")

module( "SpawnUnitTests", package.seeall, lunit.testcase )

local sharedMock = nil
local ip = nil
local ip2 = nil

function createMarine(entId, origin, deathTime)

    local marine = CreateMockPlayerEntity()
    
    marine:AddFunction("GetId"):SetReturnValues({entId})    
    marine:AddFunction("GetOrigin"):SetReturnValues({origin})    
    marine:AddFunction("GetIsAlive"):SetReturnValues({deathTime == nil})    
    
    if deathTime ~= nil then
        marine:AddFunction("GetOriginOnDeath"):SetReturnValues({origin})
        marine:AddFunction("GetTimeOfDeath"):SetReturnValues({deathTime})
        marine:AddFunction("GetRespawnQueueEntryTime"):SetReturnValues({deathTime})
    end

    return marine
    
end

function createIP(origin, delayUntilRequeue, active)

    local portal = CreateMockEntity()
    
    SetMockType(portal, "InfantryPortal")    
    portal:AddFunction("GetOrigin"):AddCall(function() return Vector(origin) end)
    portal:AddFunction("GetDelayUntilNextQueue"):AddCall(function() return delayUntilRequeue end)
    portal:AddFunction("GetIsActive"):AddCall(function() return active end)
    
    return portal

end

function setup()

    sharedMock = MockShared()
    sharedMock:AddFunction("GetTime"):SetReturnValues({10})
    
    ip = createIP(Vector(0, 0, 0), 0, true)
    ip2 = createIP(Vector(10, 0, 0), 0, true)
    
end

function testGetPosition()

    local marine = createMarine(10, Vector(1, 0, 0), nil)
    assert_nil(marine.GetOriginOnDeath)
    
end