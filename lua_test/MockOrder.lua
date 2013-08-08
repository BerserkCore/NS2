// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockOrder.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks Order objects for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("MockEntity.lua")

function CreateMockOrder(orderType, targetId, targetOrigin, orientation)

    local mockOrder = CreateMockEntity()
    SetMockType(mockOrder, "Order")
    mockOrder:AddFunction("GetType"):SetReturnValues({orderType})
    mockOrder:AddFunction("GetParam"):SetReturnValues({targetId})
    mockOrder:AddFunction("GetLocation"):SetReturnValues({targetOrigin})
    mockOrder:AddFunction("SetLocation")
    mockOrder:AddFunction("GetOrientation"):SetReturnValues({orientation})
    mockOrder:AddFunction("SetType")
    mockOrder:AddFunction("SetOwner")
    mockOrder.orderTime = 0
    mockOrder:AddFunction("GetOrderTime"):SetReturnValues({mockOrder.orderTime})
    
    return mockOrder
    
end