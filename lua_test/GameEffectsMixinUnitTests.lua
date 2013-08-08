// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// GameEffectsMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/GameEffectsMixin.lua")
module( "GameEffectsMixinUnitTests", package.seeall, lunit.testcase )

class 'MockGameEffectsEntity' (Entity)
MockGameEffectsEntity.networkVars = { }

function MockGameEffectsEntity:OnGameEffectMaskChanged(effect, state)

    self.effectChangeHistory = self.effectChangeHistory or { }
    table.insert(self.effectChangeHistory, { Effect = effect, State = state })

end

function MockGameEffectsEntity:OnKill()
    self.killed = true
end

PrepareClassForMixin(MockGameEffectsEntity, GameEffectsMixin)

local mockGameEffectEntity = nil

// Tests begin.
function setup()

    mockGameEffectEntity = MockGameEffectsEntity()
    InitMixin(mockGameEffectEntity, GameEffectsMixin)

end

function TestGameEffectsMixinSetGameEffectMask()

    assert_equal(false, mockGameEffectEntity:GetGameEffectMask(kGameEffect.OnFire))
    
    assert_equal(false, mockGameEffectEntity:SetGameEffectMask(kGameEffect.OnFire, false))
    assert_equal(true, mockGameEffectEntity:SetGameEffectMask(kGameEffect.OnFire, true))
    assert_equal(false, mockGameEffectEntity:SetGameEffectMask(kGameEffect.OnFire, true))
    
    assert_equal(true, mockGameEffectEntity:GetGameEffectMask(kGameEffect.OnFire))
    
    // Ensure OnGameEffectMaskChanged was called only once with the expected values.
    assert_equal(1, #mockGameEffectEntity.effectChangeHistory)
    assert_equal(kGameEffect.OnFire, mockGameEffectEntity.effectChangeHistory[1].Effect)
    assert_equal(true, mockGameEffectEntity.effectChangeHistory[1].State)

end

function TestGameEffectsMixinClearGameEffects()

    mockGameEffectEntity:SetGameEffectMask(kGameEffect.OnFire, true)
    
    assert_equal(true, mockGameEffectEntity:GetGameEffectMask(kGameEffect.OnFire))
    
    mockGameEffectEntity:ClearGameEffects()
    
    assert_equal(false, mockGameEffectEntity:GetGameEffectMask(kGameEffect.OnFire))
    
    assert_equal(2, #mockGameEffectEntity.effectChangeHistory)
    assert_equal(kGameEffect.OnFire, mockGameEffectEntity.effectChangeHistory[1].Effect)
    assert_equal(true, mockGameEffectEntity.effectChangeHistory[1].State)
    assert_equal(kGameEffect.OnFire, mockGameEffectEntity.effectChangeHistory[2].Effect)
    assert_equal(false, mockGameEffectEntity.effectChangeHistory[2].State)

end

function TestGameEffectsMixinClearGameEffectsOnKill()

    mockGameEffectEntity:SetGameEffectMask(kGameEffect.OnFire, true)
    
    assert_equal(true, mockGameEffectEntity:GetGameEffectMask(kGameEffect.OnFire))
    
    mockGameEffectEntity:OnKill()
    
    assert_equal(false, mockGameEffectEntity:GetGameEffectMask(kGameEffect.OnFire))
    
    assert_equal(true, mockGameEffectEntity.killed)

end