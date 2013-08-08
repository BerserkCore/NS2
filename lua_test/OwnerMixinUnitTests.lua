// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// OwnerMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockEntity.lua")
Script.Load("MockServer.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/OwnerMixin.lua")
module( "OwnerMixinUnitTests", package.seeall, lunit.testcase )

local ownedEntity = nil
function setup()

    MockServer()
    MockEntitySharedFunctions()
    
    ownedEntity = CreateMockEntity()
    InitMixin(ownedEntity, OwnerMixin)
    
end

function TestSetOwnerRequiresOwnerMixinEntity()

    local ownerEntity = CreateMockEntity()
    // The passed in Entity to SetOwner must have the OwnerMixin.
    assert_error(function() ownedEntity:SetOwner(ownerEntity) end)
    
    InitMixin(ownerEntity, OwnerMixin)
    assert_not_error(function() ownedEntity:SetOwner(ownerEntity) end)
    
end

function TestCannotSetSelfAsOwner()
    assert_error(function() ownedEntity:SetOwner(ownedEntity) end)
end

function TestClearOwner()

    local ownerEntity = CreateMockEntity()
    InitMixin(ownerEntity, OwnerMixin)
    
    assert_equal(nil, ownedEntity:GetOwner())
    
    ownedEntity:SetOwner(ownerEntity)
    assert_equal(ownerEntity, ownedEntity:GetOwner())
    
    ownedEntity:SetOwner(nil)
    assert_equal(nil, ownedEntity:GetOwner())
    
end

function TestOwnerChanges()

    local ownerEntity = CreateMockEntity()
    InitMixin(ownerEntity, OwnerMixin)
    
    ownedEntity:SetOwner(ownerEntity)
    
    local changedOwnerEntity = CreateMockEntity()
    InitMixin(changedOwnerEntity, OwnerMixin)
    
    ownedEntity:OnEntityChange(ownerEntity:GetId(), changedOwnerEntity:GetId())
    
    assert_equal(changedOwnerEntity, ownedEntity:GetOwner())
    
    ownedEntity:OnEntityChange(changedOwnerEntity:GetId(), Entity.invalidId)
    
    assert_equal(nil, ownedEntity:GetOwner())
    
end

function TestOwnerIsDestroyed()

    local ownerEntity = CreateMockEntity()
    InitMixin(ownerEntity, OwnerMixin)
    
    ownedEntity:SetOwner(ownerEntity)
    
    ownerEntity:OnDestroy()
    
    assert_equal(nil, ownedEntity:GetOwner())
    
end

function TestOwnerOfMultipleIsDestroyed()

    local ownerEntity = CreateMockEntity()
    InitMixin(ownerEntity, OwnerMixin)
    
    ownedEntity:SetOwner(ownerEntity)
    
    local ownedEntity2 = CreateMockEntity()
    InitMixin(ownedEntity2, OwnerMixin)
    ownedEntity2:SetOwner(ownerEntity)
    
    local ownedEntity3 = CreateMockEntity()
    InitMixin(ownedEntity3, OwnerMixin)
    ownedEntity3:SetOwner(ownerEntity)
    
    ownerEntity:OnDestroy()
    
    assert_equal(nil, ownedEntity:GetOwner())
    assert_equal(nil, ownedEntity2:GetOwner())
    assert_equal(nil, ownedEntity3:GetOwner())
    
end

function TestOwnedIsDestroyed()

    local ownerEntity = CreateMockEntity()
    InitMixin(ownerEntity, OwnerMixin)
    
    ownedEntity:SetOwner(ownerEntity)
    
    ownedEntity:OnDestroy()
    
    assert_equal(nil, ownedEntity:GetOwner())
    
end