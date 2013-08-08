// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockStructureEntity.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks Structure entity objects for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("MockLiveEntity.lua")

function CreateMockStructureEntity()

    local mockStructureEntity = CreateMockLiveEntity()
    SetMockType(mockStructureEntity, "Structure")
    mockStructureEntity:SetValue("built", false)
    mockStructureEntity:AddFunction("SetIsBuilt"):AddCall(function(setBuilt) mockStructureEntity.built = setBuilt end)
    mockStructureEntity:AddFunction("GetIsBuilt"):AddCall(function() return mockStructureEntity.built end)
    
    InitMixin(mockStructureEntity, { type = "Team" })
    
    return mockStructureEntity
    
end