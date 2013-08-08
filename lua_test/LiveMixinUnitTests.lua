// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// LiveMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockGamerules.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("MockMagic.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/BalanceMisc.lua")
Script.Load("lua/TechTreeConstants.lua")
Script.Load("lua/DamageTypes.lua")
Script.Load("lua/NS2Utility.lua")
module( "LiveMixinUnitTests", package.seeall, lunit.testcase )

// Create test class and test mixin.
class 'LiveTestClass' (Entity)

LiveTestClass.networkVars = { }

// The initializer of LiveMixin depends on this function being present.
function LiveTestClass:GetTechId()
    return 0
end

function LiveTestClass:GetCanTakeDamage()
    return true
end

function LiveTestClass:GetCanGiveDamage()
    return true
end

function LiveTestClass:GetTeamNumber()
    return 1
end

// OnTakeDamage expected by LiveMixin.
function LiveTestClass:OnTakeDamage(damage, attacker, doer, point)

    self.damageTaken = damage
    self.doerOfDamage = doer
    self.pointOfDamage = point
    
end

// OnKill expected by LiveMixin.
function LiveTestClass:OnKill(damage, attacker, doer, point, direction)

    self.killDamage = damage
    self.killAttacker = attacker
    self.killDoer = doer
    self.killPoint = point
    self.killDirection = direction
    
end

function LiveTestClass:TriggerEffects(param)

    if not self.functionCount then
        self.functionCount = 0
    end
    self.functionCount = self.functionCount + 1
    
end

local function MockServerLiveDependencies()

    local serverMock = MockServer()
    
    MockMagic.CreateGlobalMock("BuildGiveDamageIndicatorMessage"):GetFunction():SetReturnValues({"MockMessage"})
    
    local gamerulesMock = CreateMockGamerules()
    
    MockMagic.CreateGlobalMockValue("kBaseArmorAbsorption", 0.7)
    
    return serverMock, gamerulesMock
    
end

local defaultTechDataReturn = 100

local liveTestObject = nil
local mockAttacker = nil
local mockDoer = nil

local kHealthPointsPerArmor = 2

function setup()

    // Need to Mock LookupTechData() for the LiveMixin initializer.
    MockMagic.CreateGlobalMock("LookupTechData"):GetFunction():SetReturnValues({ defaultTechDataReturn })
    MockMagic.CreateGlobalMock("GetFriendlyFire"):GetFunction():SetReturnValues({ false })
    
    MockShared()
    
    MockServer()
    Script.Load("lua/LiveMixin.lua", true)
    
    liveTestObject = LiveTestClass()
    InitMixin(liveTestObject, LiveMixin, { kHealth = defaultTechDataReturn, kArmor = defaultTechDataReturn })
    InitMixin(liveTestObject, { type = "Team" })
    function liveTestObject:GetTeamNumber() return 1 end
    
    mockAttacker = CreateMockLiveEntity()
    InitMixin(mockAttacker, { type = "Team" })
    mockAttacker:AddFunction("GetTeamNumber"):SetReturnValues({ 2 })
    mockDoer = CreateMockPlayerEntity()
    mockDoer:AddFunction("GetDamageType"):SetReturnValues({ kDamageType.Normal })
    mockDoer:AddFunction("GetDeathIconIndex"):SetReturnValues({ 1 })
    
end

function TestLiveNetworkFieldsPresent()

    assert_equal(true, liveTestObject.alive)
    // All values should be 
    assert_equal(defaultTechDataReturn, liveTestObject.health)
    assert_equal(defaultTechDataReturn, liveTestObject.maxHealth)
    assert_equal(defaultTechDataReturn, liveTestObject.armor)
    assert_equal(defaultTechDataReturn, liveTestObject.maxArmor)

end

function TestGetHealthDescription()
    
    local healthDescription, healthScalar = liveTestObject:GetHealthDescription()
    assert_equal("Health  100/100  Armor 100/100", healthDescription)
    assert_equal(1, healthScalar)
    
    liveTestObject:SetHealth(50)
    liveTestObject:SetMaxHealth(75)
    liveTestObject:SetArmor(25)
    liveTestObject:SetMaxArmor(50)
    
    healthDescription, healthScalar = liveTestObject:GetHealthDescription()
    assert_equal("Health  50/75  Armor 25/50", healthDescription)
    // Health scalar factors in the health and armor based on kHealthPointsPerArmor.
    assert_float_equal(0.571, healthScalar)

end

function TestGetHealthScalar()

    assert_equal(1, liveTestObject:GetHealthScalar())
    
    liveTestObject:SetHealth(50)
    liveTestObject:SetArmor(50)
    assert_equal(0.5, liveTestObject:GetHealthScalar())
    
end

function TestGetSetHealth()

    assert_equal(defaultTechDataReturn, liveTestObject:GetHealth())
    
    liveTestObject:SetHealth(20)
    assert_equal(20, liveTestObject:GetHealth())
    
    liveTestObject:SetHealth(0)
    assert_equal(0, liveTestObject:GetHealth())
    
    // Cannot go above the max.
    liveTestObject:SetHealth(liveTestObject:GetMaxHealth() + 10)
    assert_equal(liveTestObject:GetMaxHealth(), liveTestObject:GetHealth())
    
    // Can go below 0.
    liveTestObject:SetHealth(-20)
    assert_equal(-20, liveTestObject:GetHealth())

end

function TestGetSetMaxHealth()

    assert_equal(defaultTechDataReturn, liveTestObject:GetMaxHealth())
    assert_equal(defaultTechDataReturn, liveTestObject:GetHealth())
    
    // Changing the max does not change the health.
    liveTestObject:SetMaxHealth(20)
    assert_equal(20, liveTestObject:GetMaxHealth())
    assert_equal(defaultTechDataReturn, liveTestObject:GetHealth())
    
    assert_not_error(function() liveTestObject:SetMaxHealth(LiveMixin.kMaxHealth) end)
    assert_error(function() liveTestObject:SetMaxHealth(LiveMixin.kMaxHealth + 1) end)
    assert_error(function() liveTestObject:SetMaxHealth(0) end)
    assert_error(function() liveTestObject:SetMaxHealth(-1) end)

end

function TestGetArmorScalar()

    assert_equal(1, liveTestObject:GetArmorScalar())
    
    liveTestObject:SetArmor(50)
    liveTestObject:SetMaxArmor(100)
    assert_equal(0.5, liveTestObject:GetArmorScalar())

end

function TestGetSetArmor()

    assert_equal(defaultTechDataReturn, liveTestObject:GetArmor())
    
    liveTestObject:SetArmor(20)
    assert_equal(20, liveTestObject:GetArmor())
    
    liveTestObject:SetArmor(0)
    assert_equal(0, liveTestObject:GetArmor())
    
    // Cannot go above the max.
    liveTestObject:SetArmor(liveTestObject:GetMaxArmor() + 10)
    assert_equal(liveTestObject:GetMaxArmor(), liveTestObject:GetArmor())
    
    // Can go below 0.
    liveTestObject:SetArmor(-20)
    assert_equal(-20, liveTestObject:GetArmor())

end

function TestGetSetMaxArmor()

    assert_equal(defaultTechDataReturn, liveTestObject:GetMaxArmor())
    assert_equal(defaultTechDataReturn, liveTestObject:GetArmor())
    
    // Changing the max does not change the armor.
    liveTestObject:SetMaxArmor(20)
    assert_equal(20, liveTestObject:GetMaxArmor())
    assert_equal(defaultTechDataReturn, liveTestObject:GetArmor())
    
    assert_not_error(function() liveTestObject:SetMaxArmor(LiveMixin.kMaxArmor) end)
    assert_error(function() liveTestObject:SetMaxArmor(LiveMixin.kMaxArmor + 1) end)
    assert_error(function() liveTestObject:SetMaxArmor(-1) end)
    assert_not_error(function() liveTestObject:SetMaxArmor(0) end)

end

function TestHeal()

    // Cannot heal if not alive
    liveTestObject:SetIsAlive(false)
    assert_false(liveTestObject:Heal(10))
    assert_equal(defaultTechDataReturn, liveTestObject:GetHealth())
    liveTestObject:SetIsAlive(true)
    
    // Cannot heal if already at full health.
    liveTestObject:SetHealth(50)
    liveTestObject:SetMaxHealth(50)
    assert_false(liveTestObject:Heal(10))
    assert_equal(50, liveTestObject:GetHealth())
    
    // Cannot overheal.
    liveTestObject:SetHealth(50)
    liveTestObject:SetMaxHealth(60)
    assert_true(liveTestObject:Heal(15))
    assert_equal(60, liveTestObject:GetHealth())
    
    // Can negative heal.
    liveTestObject:SetHealth(50)
    liveTestObject:SetMaxHealth(50)
    assert_true(liveTestObject:Heal(-10))
    assert_equal(40, liveTestObject:GetHealth())
    // But not below 0.
    assert_true(liveTestObject:Heal(-50))
    assert_equal(0, liveTestObject:GetHealth())

end

function TestIsAlive()

    assert_true(liveTestObject:GetIsAlive())
    liveTestObject:SetIsAlive(false)
    assert_false(liveTestObject:GetIsAlive())

end

function TestTakeDamageServer()

    local serverMock, gamerulesMock = MockServerLiveDependencies()
    
    local point = Vector(0, 0, 0)
    local direction = Vector(0, 0, 1)
    
    assert_equal(liveTestObject:GetMaxHealth(), liveTestObject:GetHealth())
    assert_equal(liveTestObject:GetMaxArmor(), liveTestObject:GetArmor())
    assert_true(liveTestObject:GetIsAlive())
    // Not enough damage to trigger death. Damage is taken through health and armor.
    local damage, armorUsed, healthUsed = GetDamageByType(liveTestObject, mockAttacker, mockDoer, liveTestObject:GetMaxHealth() / 2, kDamageType.Normal)
    assert_equal(liveTestObject:GetMaxHealth() / 2, damage)
    assert_false(liveTestObject:TakeDamage(damage, mockAttacker, mockDoer, point, direction, armorUsed, healthUsed))
    
    assert_true(liveTestObject:GetHealth() < liveTestObject:GetMaxHealth())
    assert_true(liveTestObject:GetArmor() < liveTestObject:GetMaxArmor())
    assert_true(liveTestObject:GetIsAlive())
    
    // Check to make sure armor is treated differently than health
    local healthPoints = 2
    local armorPoints = 5
    liveTestObject:SetArmor(0)
    liveTestObject:SetHealth(liveTestObject:GetMaxHealth() - healthPoints)
    liveTestObject:AddHealth(healthPoints + armorPoints, false)
    assert_equal(liveTestObject:GetHealth(), liveTestObject:GetMaxHealth())
    assert_equal(liveTestObject:GetArmor(), armorPoints)
    
    // Kill the liveTestObject now through taking damage.
    local killDamageAmount = liveTestObject:GetMaxHealth() * 5
    local damage, armorUsed, healthUsed = GetDamageByType(liveTestObject, mockAttacker, mockDoer, killDamageAmount, kDamageType.Normal)
    assert_equal(killDamageAmount, damage)
    assert_true(liveTestObject:TakeDamage(damage, mockAttacker, mockDoer, point, direction, armorUsed, healthUsed))
    
    assert_equal(1, table.count(gamerulesMock:GetFunction("OnKill"):GetCallHistory()))
    assert_true(table.getIsEquivalent({gamerulesMock, liveTestObject, killDamageAmount, mockAttacker, mockDoer, point, direction}, gamerulesMock:GetFunction("OnKill"):GetCallHistory()[1].passedParameters))
    assert_equal(killDamageAmount, liveTestObject.killDamage)
    assert_equal(mockAttacker, liveTestObject.killAttacker)
    assert_equal(mockDoer, liveTestObject.killDoer)
    assert_equal(point, liveTestObject.killPoint)
    assert_equal(direction, liveTestObject.killDirection)
    
end

function TestGetLastDamage()

    local sharedMock = MockShared()
    local getTimeMock = sharedMock:GetFunction("GetTime")
    local currentTime = 1.5
    getTimeMock:SetReturnValues({currentTime})
    
    MockServerLiveDependencies()
    
    local point = Vector(0, 0, 0)
    local direction = Vector(0, 0, 1)
    
    local lastDamageTime = liveTestObject:GetTimeOfLastDamage()
    local lastDamageEntityId = liveTestObject:GetAttackerIdOfLastDamage()
    assert_equal(nil, lastDamageTime)
    assert_equal(Entity.invalidId, lastDamageEntityId)
    
    local damage, armorUsed, healthUsed = GetDamageByType(liveTestObject, mockAttacker, mockDoer, 10, kDamageType.Normal)
    assert_equal(10, damage)
    liveTestObject:TakeDamage(damage, mockAttacker, mockDoer, point, direction, armorUsed, healthUsed)
    
    lastDamageTime = liveTestObject:GetTimeOfLastDamage()
    lastDamageEntityId = liveTestObject:GetAttackerIdOfLastDamage()
    assert_equal(currentTime, lastDamageTime)
    assert_equal(mockAttacker:GetId(), lastDamageEntityId)
    
end

function TestLiveMixinCanGiveAndTakeDamage()

    local mockLiveEntity = CreateMockEntity()
    mockLiveEntity:AddFunction("GetTechId"):SetReturnValues({1})
    InitMixin(mockLiveEntity, LiveMixin, { })
    
    assert_true(mockLiveEntity:GetCanTakeDamage())
    assert_false(mockLiveEntity:GetCanGiveDamage())
    
    // Provided functions can override the behavior.
    mockLiveEntity:AddFunction("GetCanTakeDamageOverride"):SetReturnValues({false})
    mockLiveEntity:AddFunction("GetCanGiveDamageOverride"):SetReturnValues({true})
    
    assert_false(mockLiveEntity:GetCanTakeDamage())
    assert_true(mockLiveEntity:GetCanGiveDamage())
    
end