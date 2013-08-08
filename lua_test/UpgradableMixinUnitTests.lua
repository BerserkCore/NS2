// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// UpgradableMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/UpgradableMixin.lua")
Script.Load("lua/TechTreeConstants.lua")

module( "UpgradableMixinUnitTests", package.seeall, lunit.testcase )

class 'TestUpgradesEntity' (Entity)
TestUpgradesEntity.networkVars = { }

function TestUpgradesEntity:SetTechId(setTechId)
    self.techId = setTechId
end

function TestUpgradesEntity:GetTechId()
    return self.techId
end

function TestUpgradesEntity:OnPreUpgradeToTechId(newTechId)
    self.currentTechIdInPre = self.techId
    self.newTechId = newTechId
end

function TestUpgradesEntity:OnGiveUpgrade(newUpgradeId)
    self.lastGivenUpgrade = newUpgradeId
end

function TestUpgradesEntity:Reset()
    self.resetCalled = true
end

function TestUpgradesEntity:OnKill()
    self.killed = true
end

PrepareClassForMixin(TestUpgradesEntity, UpgradableMixin)

local testUpgradesEntity = nil

// Tests begin.
function setup()

    testUpgradesEntity = TestUpgradesEntity()
    InitMixin(testUpgradesEntity, UpgradableMixin)
    
end

function teardown()
end

function TestUpgradableNetworkFieldsPresent()

    assert_equal(kTechId.None, testUpgradesEntity.upgrade1)
    assert_equal(kTechId.None, testUpgradesEntity.upgrade2)
    assert_equal(kTechId.None, testUpgradesEntity.upgrade3)

end

function TestUpgradeToTechId()

    assert_equal(nil, testUpgradesEntity.techId)
    assert_equal(nil, testUpgradesEntity.currentTechIdInPre)
    assert_equal(nil, testUpgradesEntity.newTechId)
    
    testUpgradesEntity:UpgradeToTechId(kTechId.Marine)
    
    assert_equal(kTechId.Marine, testUpgradesEntity.techId)
    assert_equal(nil, testUpgradesEntity.currentTechIdInPre)
    assert_equal(kTechId.Marine, testUpgradesEntity.newTechId)

end

function TestGiveUpgrade()

    local mockUpgrades = { 4, 8, 15, 16, 23, 42, 43 }
    
    for i, v in ipairs(mockUpgrades) do
        assert_false(testUpgradesEntity:GetHasUpgrade(v))
    end
    
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrades[1]))
    assert_equal(mockUpgrades[1], testUpgradesEntity.lastGivenUpgrade)
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrades[2]))
    assert_equal(mockUpgrades[2], testUpgradesEntity.lastGivenUpgrade)
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrades[3]))
    assert_equal(mockUpgrades[3], testUpgradesEntity.lastGivenUpgrade)
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrades[4]))
    assert_equal(mockUpgrades[4], testUpgradesEntity.lastGivenUpgrade)
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrades[5]))
    assert_equal(mockUpgrades[5], testUpgradesEntity.lastGivenUpgrade)
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrades[6]))
    assert_equal(mockUpgrades[6], testUpgradesEntity.lastGivenUpgrade)
    
    // Only 3 upgrades allowed.
    assert_error(function() testUpgradesEntity:GiveUpgrade(mockUpgrades[7]) end)
    
    // Cannot have the same upgrade twice.
    assert_error(function() testUpgradesEntity:GiveUpgrade(mockUpgrades[1]) end)
    
    assert_equal(mockUpgrades[6], testUpgradesEntity.lastGivenUpgrade)

end

function TestGetHasUpgrade()

    local mockUpgrade1 = 42
    local mockUpgrade2 = 45
    
    assert_false(testUpgradesEntity:GetHasUpgrade(mockUpgrade1))
    assert_false(testUpgradesEntity:GetHasUpgrade(mockUpgrade2))
    
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrade1))
    
    assert_true(testUpgradesEntity:GetHasUpgrade(mockUpgrade1))
    assert_false(testUpgradesEntity:GetHasUpgrade(mockUpgrade2))

end

function TestGetUpgrades()

    local mockUpgrade1 = 28
    local mockUpgrade2 = 35
    
    assert_equal(0, #testUpgradesEntity:GetUpgrades())
    
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrade1))
    
    assert_equal(1, #testUpgradesEntity:GetUpgrades())
    assert_equal(mockUpgrade1, testUpgradesEntity:GetUpgrades()[1])
    
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrade2))
    
    assert_equal(2, #testUpgradesEntity:GetUpgrades())
    assert_equal(mockUpgrade1, testUpgradesEntity:GetUpgrades()[1])
    assert_equal(mockUpgrade2, testUpgradesEntity:GetUpgrades()[2])

end

function TestUpgradeableMixinResetClearsUpgrades()

    local mockUpgrade1 = 83
    local mockUpgrade2 = 44
    
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrade1))
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrade2))
    
    assert_equal(2, #testUpgradesEntity:GetUpgrades())
    assert_equal(nil, testUpgradesEntity.resetCalled)
    
    testUpgradesEntity:Reset()
    
    assert_equal(0, #testUpgradesEntity:GetUpgrades())
    assert_true(testUpgradesEntity.resetCalled)
    assert_equal(nil, testUpgradesEntity.killed)

end

function TestUpgradeableMixinKillClearsUpgrades()

    local mockUpgrade1 = 83
    local mockUpgrade2 = 44
    
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrade1))
    assert_true(testUpgradesEntity:GiveUpgrade(mockUpgrade2))
    
    assert_equal(2, #testUpgradesEntity:GetUpgrades())
    assert_equal(nil, testUpgradesEntity.resetCalled)
    assert_equal(nil, testUpgradesEntity.killed)
    
    testUpgradesEntity:OnKill()
    
    assert_equal(0, #testUpgradesEntity:GetUpgrades())
    assert_equal(nil, testUpgradesEntity.resetCalled)
    assert_true(testUpgradesEntity.killed)

end