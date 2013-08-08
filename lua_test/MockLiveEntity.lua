// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockLiveEntity.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks Live entity objects (entities with the LiveMixin) for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("MockEntity.lua")
Script.Load("lua/MixinUtility.lua")

function CreateMockLiveEntity(optionalClassName)

    local mockLiveMixin = { }
    mockLiveMixin.type = "Live"
    function mockLiveMixin:TakeDamage() self.damageTaken = true end
    local mockLiveEntity = CreateMockEntity()
    SetMockType(mockLiveEntity, "ScriptActor")
    InitMixin(mockLiveEntity, mockLiveMixin)
    mockLiveEntity:SetValue("alive", true)
    mockLiveEntity:AddFunction("SetIsAlive"):AddCall(function(setAlive) mockLiveEntity.alive = setAlive end)
    mockLiveEntity:AddFunction("GetIsAlive"):AddCall(function() return mockLiveEntity.alive end)
    
    mockLiveEntity:SetValue("healthScalar", 1)
    mockLiveEntity:AddFunction("GetHealthScalar"):AddCall(function() return mockLiveEntity.healthScalar end)

    mockLiveEntity:SetValue("timeOfLastDamage", nil)
    mockLiveEntity:SetValue("lastDamageAttackerId", -1)
    mockLiveEntity:AddFunction("GetTimeOfLastDamage"):AddCall(function() return mockLiveEntity.timeOfLastDamage, mockLiveEntity.lastDamageAttackerId end)
    
    mockLiveEntity:SetValue("hasUpgrade", false)
    mockLiveEntity:AddFunction("SetHasUpgrade"):AddCall(function(setHas) mockLiveEntity.hasUpgrade = setHas end)
    mockLiveEntity:AddFunction("GetHasUpgrade"):AddCall(function() return mockLiveEntity.hasUpgrade end)
    
    mockLiveEntity:AddFunction("GetOverkillHealth")
    
    mockLiveEntity:SetValue("sighted", false)
    mockLiveEntity:AddFunction("GetIsSighted"):AddCall(function() return mockLiveEntity.sighted end)
    
    mockLiveEntity:AddFunction("GetIsInCombat"):SetReturnValues({false})
    
    if type(optionalClassName) == "string" then
        SetMockType(mockLiveEntity, optionalClassName)
    end
    
    return mockLiveEntity
    
end