// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockLiveEntity.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks Live entity objects (entities with the LiveMixin) for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("MockLiveEntity.lua")

function CreateMockPlayerEntity()

    local mockPlayerEntity = CreateMockLiveEntity()
    SetMockType(mockPlayerEntity, "Player")
    
    mockPlayerEntity:AddFunction("SetControllingPlayer")
    mockPlayerEntity:AddFunction("SendEntityChanged")
    mockPlayerEntity:AddFunction("GetOwner")
    
    InitMixin(mockPlayerEntity, { type = "Team" })
    
    return mockPlayerEntity
    
end