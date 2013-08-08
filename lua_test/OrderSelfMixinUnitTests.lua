// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// OrderSelfMixinUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockOrder.lua")
Script.Load("MockLiveEntity.lua")
Script.Load("MockStructureEntity.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/TimedCallbackMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/OrderSelfMixin.lua")
Script.Load("lua/Entity.lua")
module( "OrderSelfMixinUnitTests", package.seeall, lunit.testcase )

// Create test class and test mixin.
class 'OrderSelfTestClass' (Entity)
OrderSelfTestClass.networkVars = { }

function OrderSelfTestClass:GetTeamNumber()
    return 1
end

function OrderSelfTestClass:GetOrigin()
    return self.origin
end

function OrderSelfTestClass:OnOrderComplete(completedOrder)
    self.completedOrderType = completedOrder:GetType()
end

function OrderSelfTestClass:GetExtents()
    return Vector(1, 1, 1)
end

function OrderSelfTestClass:GetOwner()
    return self
end

local orderSelfTestObject = nil

function setup()
    
    orderSelfTestObject = OrderSelfTestClass()
    orderSelfTestObject.origin = Vector(0, 0, 0)
    InitMixin(orderSelfTestObject, { type = "Team" })
    InitMixin(orderSelfTestObject, TimedCallbackMixin)
    InitMixin(orderSelfTestObject, OrdersMixin, { kMoveOrderCompleteDistance = 0.01 })
    InitMixin(orderSelfTestObject, OrderSelfMixin, { kPriorityAttackTargets = { "Harvester", "Hydra" } })
    
    local mockCreateOrderFunction = MockMagic.CreateGlobalMock("CreateOrder"):GetFunction()
    mockCreateOrderFunction:AddCall(function(orderType, targetId, targetOrigin, orientation) return CreateMockOrder(orderType, targetId, targetOrigin, orientation) end)
    
    local mockDestroyEntityFunction = MockMagic.CreateGlobalMock("DestroyEntity")
    
    MockMagic.CreateGlobalMock("GetGroundAt"):GetFunction():AddCall(function(entity, position) return position end)
    
    MockMagic.CreateGlobalMock("GetEnemyTeamNumber"):GetFunction():AddCall(function(team) return (team == 1 and 2) or 1 end)
    
end

// Auto defend orders have been temporarily removed.
/*function TestOrderSelfToDefend()

    local mockDefendEntity = CreateMockStructureEntity()
    mockDefendEntity.built = true
    function mockDefendEntity:GetTeamNumber() return 1 end
    mockDefendEntity.origin = Vector(5, 0, 5)

    local currentTime = 10.3
    MockShared():GetFunction("GetTime"):SetReturnValues({currentTime})
    
    orderSelfTestObject:OnUpdate(2)

    assert_equal(0, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)
    
    mockDefendEntity.timeOfLastDamage = currentTime
    mockDefendEntity.lastDamageAttackerId = 23
    orderSelfTestObject:OnUpdate(2)

    assert_equal(1, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)

end*/

// Auto copy orders have been temporarily removed.
/*function TestOrderSelfCopyFromNearbyPlayer()

    local mockPlayerEntity = CreateMockPlayerEntity()
    mockPlayerEntity:AddFunction("GetExtents"):SetReturnValues({Vector(1, 1, 1)})
    InitMixin(mockPlayerEntity, OrdersMixin, { kMoveOrderCompleteDistance = 0.01 })
    function mockPlayerEntity:GetTeamNumber() return 1 end
    mockPlayerEntity.origin = Vector(25, 0, 25)
    
    orderSelfTestObject:OnUpdate(2)
    
    assert_equal(0, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)
    
    mockPlayerEntity:GiveOrder(kTechId.Move, 0, Vector(15, 0, 15))
    orderSelfTestObject:OnUpdate(2)
    
    // The player was too far away.
    assert_equal(0, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)
    
    mockPlayerEntity.origin = Vector(5, 0, 5)
    orderSelfTestObject:OnUpdate(2)
    
    // The player was close enough to copy.
    assert_equal(1, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)
    
end

function TestOrderSelfDontCopyMoveOrderIfTooClose()

    local mockPlayerEntity = CreateMockPlayerEntity()
    mockPlayerEntity:AddFunction("GetExtents"):SetReturnValues({Vector(1, 1, 1)})
    InitMixin(mockPlayerEntity, OrdersMixin, { kMoveOrderCompleteDistance = 0.01 })
    function mockPlayerEntity:GetTeamNumber() return 1 end
    mockPlayerEntity.origin = Vector(0, 0, 0)
    
    mockPlayerEntity:GiveOrder(kTechId.Move, 0, Vector(8, 0, 0))
    orderSelfTestObject:OnUpdate(2)
    
    // The order was too close to the orderSelfTestObject to copy.
    assert_equal(0, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)
    
    mockPlayerEntity:GiveOrder(kTechId.Move, 0, Vector(15, 0, 0))
    orderSelfTestObject:OnUpdate(2)
    
    // The move order was far enough away from the orderSelfTestObject to copy.
    assert_equal(1, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)
    
end*/

// Auto attack orders have been temporarily removed.
/*function TestOrderSelfAttackEnemyStructureSightedClose()

    local mockAttackEntity = CreateMockStructureEntity()
    function mockAttackEntity:GetTeamNumber() return 2 end
    mockAttackEntity.origin = Vector(20, 0, 20)
    mockAttackEntity.sighted = false
    
    orderSelfTestObject:OnUpdate(2)

    // Too far away and not sighted.
    assert_equal(0, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)
    
    mockAttackEntity.origin = Vector(5, 0, 5)
    mockAttackEntity.sighted = false
    // Close enough but not sighted.
    orderSelfTestObject:OnUpdate(2)

    assert_equal(0, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)
    
    mockAttackEntity.origin = Vector(20, 0, 20)
    mockAttackEntity.sighted = false
    // Sighted but not close enough.
    orderSelfTestObject:OnUpdate(2)

    assert_equal(0, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)
    
    mockAttackEntity.origin = Vector(5, 0, 5)
    mockAttackEntity.sighted = true
    // Sighted and close enough.
    orderSelfTestObject:OnUpdate(2)

    assert_equal(1, orderSelfTestObject:GetNumOrders())
    assert_equal(nil, orderSelfTestObject.completedOrderType)

end

function TestOrderSelfAttackEnemyStructureLowHealthPriority()

    local mockAttackEntityHighHealth = CreateMockStructureEntity()
    function mockAttackEntityHighHealth:GetTeamNumber() return 2 end
    mockAttackEntityHighHealth.origin = Vector(5, 0, 5)
    mockAttackEntityHighHealth.sighted = true
    mockAttackEntityHighHealth.healthScalar = 1
    
    local mockAttackEntityLowHealth1 = CreateMockStructureEntity()
    function mockAttackEntityLowHealth1:GetTeamNumber() return 2 end
    mockAttackEntityLowHealth1.origin = Vector(6, 0, 6)
    mockAttackEntityLowHealth1.sighted = true
    mockAttackEntityLowHealth1.healthScalar = 0.3
    
    // Priority is always the target with the lowest health below the defined threshold in OrderSelfMixin.
    local mockAttackEntityLowHealth2 = CreateMockStructureEntity()
    function mockAttackEntityLowHealth2:GetTeamNumber() return 2 end
    mockAttackEntityLowHealth2.origin = Vector(7, 0, 7)
    mockAttackEntityLowHealth2.sighted = true
    mockAttackEntityLowHealth2.healthScalar = 0.2
    
    orderSelfTestObject:OnUpdate(2)

    assert_equal(1, orderSelfTestObject:GetNumOrders())
    assert_equal(mockAttackEntityLowHealth2:GetId(), orderSelfTestObject:GetCurrentOrder():GetParam())

end

function TestOrderSelfAttackEnemyStructureHighHealthPriority()

    // If none of the targets are below the defined threshold in OrderSelfMixin then it will fallback on the closest.
    local mockAttackEntityHighHealth = CreateMockStructureEntity()
    function mockAttackEntityHighHealth:GetTeamNumber() return 2 end
    mockAttackEntityHighHealth.origin = Vector(5, 0, 5)
    mockAttackEntityHighHealth.sighted = true
    mockAttackEntityHighHealth.healthScalar = 1
    
    local mockAttackEntityLowHealth1 = CreateMockStructureEntity()
    function mockAttackEntityLowHealth1:GetTeamNumber() return 2 end
    mockAttackEntityLowHealth1.origin = Vector(6, 0, 6)
    mockAttackEntityLowHealth1.sighted = true
    mockAttackEntityLowHealth1.healthScalar = 0.8

    local mockAttackEntityLowHealth2 = CreateMockStructureEntity()
    function mockAttackEntityLowHealth2:GetTeamNumber() return 2 end
    mockAttackEntityLowHealth2.origin = Vector(7, 0, 7)
    mockAttackEntityLowHealth2.sighted = true
    mockAttackEntityLowHealth2.healthScalar = 0.7
    
    orderSelfTestObject:OnUpdate(2)
    
    assert_equal(1, orderSelfTestObject:GetNumOrders())
    assert_equal(mockAttackEntityHighHealth:GetId(), orderSelfTestObject:GetCurrentOrder():GetParam())

end

function TestOrderSelfAttackEnemyStructurePriorityAttackTargetsHighHealth()

    local mockAttackEntityHighHealth = CreateMockStructureEntity()
    function mockAttackEntityHighHealth:GetTeamNumber() return 2 end
    mockAttackEntityHighHealth.origin = Vector(5, 0, 5)
    mockAttackEntityHighHealth.sighted = true
    mockAttackEntityHighHealth.healthScalar = 1
    
    local mockAttackEntityLowHealth1 = CreateMockStructureEntity()
    function mockAttackEntityLowHealth1:GetTeamNumber() return 2 end
    mockAttackEntityLowHealth1.origin = Vector(6, 0, 6)
    mockAttackEntityLowHealth1.sighted = true
    mockAttackEntityLowHealth1.healthScalar = 0.8

    // The kPriorityAttackTargets are prioritized before any other high health target.
    local mockHarvester = CreateMockStructureEntity()
    SetMockType(mockHarvester, "Harvester")
    function mockHarvester:GetTeamNumber() return 2 end
    mockHarvester.origin = Vector(7, 0, 7)
    mockHarvester.sighted = true
    mockHarvester.healthScalar = 1
    
    // The closest kPriorityAttackTargets is prioritized.
    local mockHydra = CreateMockStructureEntity()
    SetMockType(mockHydra, "Hydra")
    function mockHydra:GetTeamNumber() return 2 end
    mockHydra.origin = Vector(6, 0, 7)
    mockHydra.sighted = true
    mockHydra.healthScalar = 0.8
    
    orderSelfTestObject:OnUpdate(2)

    assert_equal(1, orderSelfTestObject:GetNumOrders())
    assert_equal(mockHydra:GetId(), orderSelfTestObject:GetCurrentOrder():GetParam())

end

function TestOrderSelfAttackEnemyStructurePriorityAttackTargetsLowHealth()

    local mockAttackEntityHighHealth = CreateMockStructureEntity()
    function mockAttackEntityHighHealth:GetTeamNumber() return 2 end
    mockAttackEntityHighHealth.origin = Vector(5, 0, 5)
    mockAttackEntityHighHealth.sighted = true
    mockAttackEntityHighHealth.healthScalar = 1
    
    // Low health targets are always prioritized before kPriorityAttackTargets.
    local mockAttackEntityLowHealth1 = CreateMockStructureEntity()
    function mockAttackEntityLowHealth1:GetTeamNumber() return 2 end
    mockAttackEntityLowHealth1.origin = Vector(6, 0, 6)
    mockAttackEntityLowHealth1.sighted = true
    mockAttackEntityLowHealth1.healthScalar = 0.3

    local mockHarvester = CreateMockStructureEntity()
    SetMockType(mockHarvester, "Harvester")
    function mockHarvester:GetTeamNumber() return 2 end
    mockHarvester.origin = Vector(7, 0, 7)
    mockHarvester.sighted = true
    mockHarvester.healthScalar = 1
    
    local mockHydra = CreateMockStructureEntity()
    SetMockType(mockHydra, "Hydra")
    function mockHydra:GetTeamNumber() return 2 end
    mockHydra.origin = Vector(6, 0, 7)
    mockHydra.sighted = true
    mockHydra.healthScalar = 0.8
    
    orderSelfTestObject:OnUpdate(2)

    assert_equal(1, orderSelfTestObject:GetNumOrders())
    assert_equal(mockAttackEntityLowHealth1:GetId(), orderSelfTestObject:GetCurrentOrder():GetParam())

end*/