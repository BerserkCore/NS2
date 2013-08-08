// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// RagdollMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/PhysicsGroups.lua")
Script.Load("lua/Vector.lua")

module( "RagdollMixinUnitTests", package.seeall, lunit.testcase )

class 'RagdollMixinTestClass' (Entity)

function RagdollMixinTestClass:SetPhysicsType(setType)
    self.mockPhysicsType = setType
end

function RagdollMixinTestClass:GetPhysicsType()
    return self.mockPhysicsType
end

function RagdollMixinTestClass:SetPhysicsGroup(setGroup)
    self.mockPhysicsGroup = setGroup
end

function RagdollMixinTestClass:GetPhysicsGroup()
    return self.mockPhysicsGroup or PhysicsGroup.DefaultGroup
end

function RagdollMixinTestClass:GetPhysicsModel()
    return self.mockPhysicsModel
end

function RagdollMixinTestClass:SetAnimation(animName, forced)
    self.lastSetAnimation = { Name = animName, Forced = forced }
end

function RagdollMixinTestClass:GetAnimation()
    return self.animation or ""
end

function RagdollMixinTestClass:TriggerEffects(effectsName)
    self.lastTriggeredEffects = effectsName
end

function RagdollMixinTestClass:GetIsMapEntity()
    return self.mapEntity or false
end

function RagdollMixinTestClass:GetOrigin() return Vector() end

local ragdollMixinTestEntity = nil
local attacker = nil
local doer = nil
local mockDestroyEntity = nil

// Tests begin.
function setup()

    ragdollMixinTestEntity = RagdollMixinTestClass()
    
    local MockLiveMixin = { }
    MockLiveMixin.type = "Live"
    
    InitMixin(ragdollMixinTestEntity, MockLiveMixin)
    InitMixin(ragdollMixinTestEntity, RagdollMixin)
    
    ragdollMixinTestEntity.mockPhysicsModel = MockMagic.CreateMock()
    ragdollMixinTestEntity.mockPhysicsModel:AddFunction("AddImpulse")
    
    ragdollMixinTestEntity.mockPhysicsType = PhysicsType.Kinematic
    
    attacker = CreateMockEntity()
    doer = CreateMockEntity()
    SetMockType(doer, "ScaryMonster")
    
    mockDestroyEntity = MockMagic.CreateGlobalMock("DestroyEntity")

end

function teardown()
end

function TestRagdollMixinOnTakeDamageKinematic()

    ragdollMixinTestEntity:OnTakeDamage(5, attacker, doer, Vector(0, 0, 1))
    
    // Kinematic do not get impulse applied when taking damage.
    assert_equal(0, #ragdollMixinTestEntity.mockPhysicsModel:GetFunction("AddImpulse"):GetCallHistory())
    
end

function TestRagdollMixinOnTakeDamageDynamic()

    ragdollMixinTestEntity.mockPhysicsType = PhysicsType.Dynamic
    
    ragdollMixinTestEntity:OnTakeDamage(5, attacker, doer, Vector(0, 0, 1))
    
    assert_equal(1, #ragdollMixinTestEntity.mockPhysicsModel:GetFunction("AddImpulse"):GetCallHistory())
    assert_equal(ragdollMixinTestEntity.mockPhysicsModel, ragdollMixinTestEntity.mockPhysicsModel:GetFunction("AddImpulse"):GetCallHistory()[1].passedParameters[1])
    assert_equal(Vector(0, 0, 1), ragdollMixinTestEntity.mockPhysicsModel:GetFunction("AddImpulse"):GetCallHistory()[1].passedParameters[2])
    assert_equal(Vector(0, 0, -0.00125), ragdollMixinTestEntity.mockPhysicsModel:GetFunction("AddImpulse"):GetCallHistory()[1].passedParameters[3])

end