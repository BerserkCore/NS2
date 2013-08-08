// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MapBlipMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockOrder.lua")
Script.Load("MockLiveEntity.lua")
Script.Load("MockStructureEntity.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")

Event = { }
Event.Hook = function() end
Script.Load("lua/MapBlipMixin.lua")
Event = nil

module( "MapBlipMixinUnitTests", package.seeall, lunit.testcase )

local function MockMapBlipClass()

    local mapBlipClassMock = MockMagic.CreateGlobalMock("MapBlip")
    mapBlipClassMock:SetValue("kMapName", "MapBlip")

end

local doorTestObject = nil

function setup()

    MockEntitySharedFunctions()
    
    local function CreateEntityMock(type)
        if type == "MapBlip" then
            local createdMapBlipMock = CreateMockEntity()
            SetMockType(createdMapBlipMock, type)
            createdMapBlipMock:AddFunction("SetOwner")
            return createdMapBlipMock
        end
    end
    MockMagic.CreateGlobalMock("Server"):AddFunction("CreateEntity"):AddCall(CreateEntityMock)
    
    local function DestroyEntityMock(entity)
        Shared.DestroyEntity(entity)
    end
    MockMagic.CreateGlobalMock("Server"):AddFunction("DestroyEntity"):AddCall(DestroyEntityMock)
    
    MockMapBlipClass()
    
    doorTestObject = CreateMockLiveEntity()
    SetMockType(doorTestObject, "Door")
    // Make sure the MapBlipMixin:OnDestroy() is called in addition to this one.
    doorTestObject:AddFunction("OnDestroy")
    doorTestObject:AddFunction("SetCoords")
    doorTestObject:AddFunction("SetAngles")
    doorTestObject:AddFunction("SetOrigin")
    
end

function TestBlipCreated()

    assert_equal(0, Shared.GetEntitiesWithClassname("MapBlip"):GetSize())

    InitMixin(doorTestObject, MapBlipMixin)
    
    assert_equal(1, Shared.GetEntitiesWithClassname("MapBlip"):GetSize())

end

function TestBlipDestroyed()

    InitMixin(doorTestObject, MapBlipMixin)
    
    assert_equal(1, Shared.GetEntitiesWithClassname("MapBlip"):GetSize())
    
    doorTestObject:OnDestroy()
    
    assert_equal(0, Shared.GetEntitiesWithClassname("MapBlip"):GetSize())
    assert_equal(1, table.count(doorTestObject:GetFunction("OnDestroy"):GetCallHistory()))
    
end