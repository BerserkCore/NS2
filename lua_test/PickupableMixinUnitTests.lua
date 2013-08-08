// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// PickupableMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/TimedCallbackMixin.lua")
Script.Load("lua/PickupableMixin.lua")
module( "PickupableMixinUnitTests", package.seeall, lunit.testcase )

local pickupableEntity = nil
local destroyEntityMock = nil
local touchedEntity = nil
local getEntsWithinRangeMock = nil

function setup()

    MockServer()
    
    pickupableEntity = CreateMockEntity()
    pickupableEntity:AddFunction("GetIsValidRecipient"):AddCall(
        function(entity, recipient)
            return recipient:GetShellColor() == "Green"
        end)
    pickupableEntity:AddFunction("OnTouch"):AddCall(function(entity, recipient) touchedEntity = recipient end)
    
    InitMixin(pickupableEntity, TimedCallbackMixin)
    
    getEntsWithinRangeMock = MockMagic.CreateGlobalMock("GetEntitiesWithinRange")
    getEntsWithinRangeMock:GetFunction():SetReturnValues({ { } })
    InitMixin(pickupableEntity, PickupableMixin, { kRecipientType = "Turtle" })
    
    destroyEntityMock = MockMagic.CreateGlobalMock("DestroyEntity")
    
end

function teardown()
end

function TestPickupableMixinSelfDestroy()
    
    pickupableEntity:OnUpdate(10)
    
    assert_equal(0, #destroyEntityMock:GetFunction():GetCallHistory())
    
    pickupableEntity:OnUpdate(11)
    
    assert_equal(1, #destroyEntityMock:GetFunction():GetCallHistory())
    assert_equal(1, #destroyEntityMock:GetFunction():GetCallHistory()[1].passedParameters)
    assert_equal(pickupableEntity, destroyEntityMock:GetFunction():GetCallHistory()[1].passedParameters[1])

end

function TestPickupableMixinPickup()
    
    local badTurtle = CreateMockEntity()
    SetMockType(badTurtle, "Turtle")
    badTurtle:AddFunction("GetShellColor"):SetReturnValues({"Red"})
    
    local goodTurtle = CreateMockEntity()
    SetMockType(goodTurtle, "Turtle")
    goodTurtle:AddFunction("GetShellColor"):SetReturnValues({"Green"})
    
    MockMagic.DestroyMock(getEntsWithinRangeMock)
    MockMagic.CreateGlobalMock("GetEntitiesWithinRange"):GetFunction():AddCall(function(type, origin, range) return { badTurtle, goodTurtle } end)
    
    pickupableEntity:OnUpdate(0.11)
    
    assert_equal(goodTurtle, touchedEntity)
    assert_equal(1, #destroyEntityMock:GetFunction():GetCallHistory())

end