// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// OrdersMixinUnitTests.lua
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
module( "OrdersMixinUnitTests", package.seeall, lunit.testcase )

// Create test class and test mixin.
class 'OrdersTestClass' (Entity)
OrdersTestClass.networkVars = { }

function OrdersTestClass:OnOrderComplete(completedOrder)

    self.completedOrderType = completedOrder:GetType()

end

function OrdersTestClass:GetOrigin()
    return self.origin
end

function OrdersTestClass:GetTeam()
    
    local mockTeam = MockMagic.CreateMock()
    mockTeam:AddFunction("TriggerAlert")
    mockTeam:AddFunction("GetTeamType"):SetReturnValues({1})
    return mockTeam
    
end

function OrdersTestClass:Reset()
    self.wasReset = true
end

function OrdersTestClass:OnKill()
    self.killed = true
end

function OrdersTestClass:GetExtents()
    return Vector(1, 1, 1)
end

function OrdersTestClass:GetOwner()
    return self
end

local ordersTestObject = nil

function setup()

    MockServer()
    MockEntitySharedFunctions()
    
    Script.Load("lua/OrdersMixin.lua", true)
    
    ordersTestObject = OrdersTestClass()
    ordersTestObject.origin = Vector(0, 0, 0)
    InitMixin(ordersTestObject, OrdersMixin, { kMoveOrderCompleteDistance = 0.01 })
    
    local mockCreateOrderFunction = MockMagic.CreateGlobalMock("CreateOrder"):GetFunction()
    mockCreateOrderFunction:AddCall(function(orderType, targetId, targetOrigin, orientation) return CreateMockOrder(orderType, targetId, targetOrigin, orientation) end)
    
    local mockDestroyEntityFunction = MockMagic.CreateGlobalMock("DestroyEntity")
    
    MockMagic.CreateGlobalMock("GetGroundAt"):GetFunction():AddCall(function(entity, position) return position end)
    
end

function TestGetHasOrder()

    assert_false(ordersTestObject:GetHasOrder())
    
    local orderType = kTechId.Move
    local targetId = 100
    local targetOrigin = Vector(0, 0, 0)
    ordersTestObject:GiveOrder(orderType, targetId, targetOrigin)
    
    assert_true(ordersTestObject:GetHasOrder())
    
    ordersTestObject:ClearOrders()
    
    assert_false(ordersTestObject:GetHasOrder())

end

function TestTransferOrders()
    
    local physicsMaskMock = MockMagic.CreateGlobalMock("PhysicsMask")
    physicsMaskMock:SetValue("AIMovement", 1)
    
    local copyOrdersObject = OrdersTestClass()
    InitMixin(copyOrdersObject, OrdersMixin, { kMoveOrderCompleteDistance = 0.01 })
    
    local orderType = kTechId.Move
    local targetId = 100
    local targetOrigin = Vector(0, 0, 0)
    ordersTestObject:GiveOrder(orderType, targetId, targetOrigin)
    
    assert_true(ordersTestObject:GetHasOrder())
    assert_false(copyOrdersObject:GetHasOrder())
    
    ordersTestObject:TransferOrders(copyOrdersObject)
    
    assert_false(ordersTestObject:GetHasOrder())
    assert_true(copyOrdersObject:GetHasOrder())

end

function TestIgnoreOrders()

    assert_false(ordersTestObject:GetHasOrder())
    
    ordersTestObject:SetIgnoreOrders(true)
    
    local orderType = kTechId.Move
    local targetId = 100
    local targetOrigin = Vector(0, 0, 0)
    assert_equal(kTechId.None, ordersTestObject:GiveOrder(orderType, targetId, targetOrigin))
    
    assert_false(ordersTestObject:GetHasOrder())
    
    ordersTestObject:SetIgnoreOrders(false)
    
    local orderType = kTechId.Move
    local targetId = 100
    local targetOrigin = Vector(0, 0, 0)
    ordersTestObject:GiveOrder(orderType, targetId, targetOrigin)
    
    assert_true(ordersTestObject:GetHasOrder())
    
end

function TestGiveOrder()

    assert_false(ordersTestObject:GetHasOrder())
    
    local orderType = kTechId.Move
    local targetId = 100
    local targetOrigin = Vector(0, 0, 0)
    local orientation = Vector(1, 0, 0)
    local clearExisting = false
    local insertFirst = false
    
    ordersTestObject:GiveOrder(orderType, targetId, targetOrigin, orientation, clearExisting, insertFirst)
    assert_true(ordersTestObject:GetHasOrder())
    assert_equal(kTechId.Move, ordersTestObject:GetCurrentOrder():GetType())
    assert_equal(1, ordersTestObject:GetNumOrders())
    
    orderType = kTechId.Attack
    insertFirst = true
    ordersTestObject:GiveOrder(orderType, targetId, targetOrigin, orientation, clearExisting, insertFirst)
    assert_true(ordersTestObject:GetHasOrder())
    assert_equal(kTechId.Attack, ordersTestObject:GetCurrentOrder():GetType())
    assert_equal(2, ordersTestObject:GetNumOrders())
    
    orderType = kTechId.Weld
    clearExisting = true
    insertFirst = false
    ordersTestObject:GiveOrder(orderType, targetId, targetOrigin, orientation, clearExisting, insertFirst)
    assert_true(ordersTestObject:GetHasOrder())
    assert_equal(kTechId.Weld, ordersTestObject:GetCurrentOrder():GetType())
    assert_equal(1, ordersTestObject:GetNumOrders())
    
    orderType = kTechId.Build
    // clearExisting and insert first default to true if nil.
    clearExisting = nil
    insertFirst = nil
    ordersTestObject:GiveOrder(orderType, targetId, targetOrigin, orientation, clearExisting, insertFirst)
    assert_true(ordersTestObject:GetHasOrder())
    assert_equal(kTechId.Build, ordersTestObject:GetCurrentOrder():GetType())
    assert_equal(1, ordersTestObject:GetNumOrders())
    
end

function TestOrdersMixinResetClearsOrders()

    assert_false(ordersTestObject:GetHasOrder())
    
    local targetId = 100
    local targetOrigin = Vector(0, 0, 0)
    assert_equal(kTechId.Move, ordersTestObject:GiveOrder(kTechId.Move, targetId, targetOrigin, nil, false))
    assert_equal(kTechId.Build, ordersTestObject:GiveOrder(kTechId.Build, targetId, targetOrigin, nil, false))
    assert_equal(kTechId.Attack, ordersTestObject:GiveOrder(kTechId.Attack, targetId, targetOrigin, nil, false))
    assert_equal(kTechId.Weld, ordersTestObject:GiveOrder(kTechId.Weld, targetId, targetOrigin, nil, false))
    
    assert_true(ordersTestObject:GetHasOrder())
    assert_equal(4, ordersTestObject:GetNumOrders())
    
    // ClearOrders() will be called through this reset.
    ordersTestObject:Reset()
    
    assert_false(ordersTestObject:GetHasOrder())
    assert_equal(0, ordersTestObject:GetNumOrders())
    
    // Ensure the original Reset() function was still called.
    assert_true(ordersTestObject.wasReset)

end

function TestOrdersMixinKillClearsOrders()

    assert_false(ordersTestObject:GetHasOrder())
    
    local targetId = 100
    local targetOrigin = Vector(0, 0, 0)
    assert_equal(kTechId.Move, ordersTestObject:GiveOrder(kTechId.Move, targetId, targetOrigin, nil, false))
    assert_equal(kTechId.Build, ordersTestObject:GiveOrder(kTechId.Build, targetId, targetOrigin, nil, false))
    assert_equal(kTechId.Attack, ordersTestObject:GiveOrder(kTechId.Attack, targetId, targetOrigin, nil, false))
    assert_equal(kTechId.Weld, ordersTestObject:GiveOrder(kTechId.Weld, targetId, targetOrigin, nil, false))
    
    assert_true(ordersTestObject:GetHasOrder())
    assert_equal(4, ordersTestObject:GetNumOrders())
    
    // ClearOrders() will be called through this reset.
    ordersTestObject:OnKill()
    
    assert_false(ordersTestObject:GetHasOrder())
    assert_equal(0, ordersTestObject:GetNumOrders())
    
    // Ensure the original Reset() function was still called.
    assert_true(ordersTestObject.killed)

end

function TestGetHasSpecifiedOrder()

    local orphanedOrder = CreateMockOrder(kTechId.Move, 100, Vector(0, 0, 0), Vector(1, 0, 0))
    assert_false(ordersTestObject:GetHasSpecifiedOrder(orphanedOrder))
    
    ordersTestObject:GiveOrder(kTechId.Move, 100, Vector(0, 0, 0))
    assert_true(ordersTestObject:GetHasSpecifiedOrder(ordersTestObject:GetCurrentOrder()))

end

function TestGetCurrentOrder()

    assert_equal(nil, ordersTestObject:GetCurrentOrder())
    
    ordersTestObject:GiveOrder(kTechId.Move, 100, Vector(0, 0, 0))
    assert_equal(kTechId.Move, ordersTestObject:GetCurrentOrder():GetType())
    
end

function TestClearCurrentOrder()

    assert_equal(kTechId.Move, ordersTestObject:GiveOrder(kTechId.Move, 100, Vector(0, 0, 0), nil, false, false))
    assert_equal(kTechId.Build, ordersTestObject:GiveOrder(kTechId.Build, 100, Vector(0, 0, 0), nil, false, false))
    
    assert_equal(kTechId.Move, ordersTestObject:GetCurrentOrder():GetType())
    
    ordersTestObject:ClearCurrentOrder()
    
    assert_equal(kTechId.Build, ordersTestObject:GetCurrentOrder():GetType())
    
    ordersTestObject:ClearCurrentOrder()
    
    assert_equal(nil, ordersTestObject:GetCurrentOrder())

end

function TestCompletedCurrentOrder()

    assert_equal(nil, ordersTestObject.completedOrderType)
    
    ordersTestObject:GiveOrder(kTechId.Move, 100, Vector(0, 0, 0))
    
    assert_equal(1, ordersTestObject:GetNumOrders())
    
    ordersTestObject:CompletedCurrentOrder()
    
    assert_equal(0, ordersTestObject:GetNumOrders())
    
    assert_equal(kTechId.Move, ordersTestObject.completedOrderType)

end

function TestUpdateMoveOrder()

    assert_equal(nil, ordersTestObject.completedOrderType)
    
    ordersTestObject:GiveOrder(kTechId.Move, 100, Vector(10, 0, 10))
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(1, ordersTestObject:GetNumOrders())
    assert_equal(nil, ordersTestObject.completedOrderType)
    
    ordersTestObject.origin = Vector(10, 0, 10)
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(0, ordersTestObject:GetNumOrders())
    assert_equal(kTechId.Move, ordersTestObject.completedOrderType)

end

function TestUpdateConstructOrder()

    assert_equal(nil, ordersTestObject.completedOrderType)
    
    local mockConstructEntity = CreateMockStructureEntity()
    mockConstructEntity.origin = Vector(10, 0, 10)
    
    ordersTestObject:GiveOrder(kTechId.Construct, mockConstructEntity:GetId(), mockConstructEntity:GetOrigin(), nil, false, false)
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(1, ordersTestObject:GetNumOrders())
    assert_equal(nil, ordersTestObject.completedOrderType)
    
    mockConstructEntity.built = true
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(0, ordersTestObject:GetNumOrders())
    assert_equal(kTechId.Construct, ordersTestObject.completedOrderType)

end

function TestUpdateAttackOrder()
    
    assert_equal(nil, ordersTestObject.completedOrderType)
    
    local mockAttackEntity = CreateMockLiveEntity()
    mockAttackEntity.origin = Vector(10, 0, 10)
    
    ordersTestObject:GiveOrder(kTechId.Attack, mockAttackEntity:GetId(), nil)
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(1, ordersTestObject:GetNumOrders())
    assert_equal(nil, ordersTestObject.completedOrderType)
    
    mockAttackEntity.alive = false
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(0, ordersTestObject:GetNumOrders())
    assert_equal(kTechId.Attack, ordersTestObject.completedOrderType)
    
end

function TestUpdateDefendOrder()

    assert_equal(nil, ordersTestObject.completedOrderType)
    
    local currentTime = 10.3
    MockShared():GetFunction("GetTime"):SetReturnValues({currentTime})
    
    local mockDefendEntity = CreateMockLiveEntity()
    mockDefendEntity.origin = Vector(30, 0, 30)
    mockDefendEntity.timeOfLastDamage = currentTime
    
    ordersTestObject:GiveOrder(kTechId.SquadDefend, mockDefendEntity:GetId(), nil)
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(1, ordersTestObject:GetNumOrders())
    assert_equal(nil, ordersTestObject.completedOrderType)
    
    // If the defend entity dies the order is cleared, not completed.
    mockDefendEntity.alive = false
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(0, ordersTestObject:GetNumOrders())
    assert_equal(nil, ordersTestObject.completedOrderType)
    
    mockDefendEntity.alive = true
    
    local orderType = ordersTestObject:GiveOrder(kTechId.SquadDefend, mockDefendEntity:GetId(), nil)
    assert_equal(kTechId.SquadDefend, orderType)
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(1, ordersTestObject:GetNumOrders())
    assert_equal(nil, ordersTestObject.completedOrderType)
    
    // If enough time has passed but the order entity is too far away, the order is cleared, not completed.
    MockShared():GetFunction("GetTime"):SetReturnValues({30})
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(0, ordersTestObject:GetNumOrders())
    assert_equal(nil, ordersTestObject.completedOrderType)

    ordersTestObject:GiveOrder(kTechId.SquadDefend, mockDefendEntity:GetId(), nil)
    
    // If enough time has passed and the order entity is close, the order is completed.
    mockDefendEntity.origin = Vector(2, 0, 2)
    
    assert_equal(1, ordersTestObject:GetNumOrders())
    assert_equal(nil, ordersTestObject.completedOrderType)
    
    ordersTestObject:OnUpdate(0.1)
    
    assert_equal(0, ordersTestObject:GetNumOrders())
    assert_equal(kTechId.SquadDefend, ordersTestObject.completedOrderType)

end

function TestUpdateAttackOrderOnNonLiveEntity()

    assert_equal(nil, ordersTestObject.completedOrderType)
    
    // Target is not live.
    local mockTargetEntity = CreateMockEntity()
    mockTargetEntity.origin = Vector(10, 0, 10)
    
    ordersTestObject:GiveOrder(kTechId.Attack, mockTargetEntity:GetId(), nil)
    
    ordersTestObject:OnUpdate(0.1)
    
    // An attack order to a non-live entity cannot be completed
    // and must be cleared in another way.
    assert_equal(1, ordersTestObject:GetNumOrders())
    assert_equal(nil, ordersTestObject.completedOrderType)

end