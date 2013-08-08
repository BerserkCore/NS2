// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockServer.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks the Server script interface for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("MockMagic.lua")

function MockServer()

    if Server then
        return MockMagic.CreateGlobalMock("Server")
    end
    
    local serverMock = MockMagic.CreateGlobalMock("Server")
    serverMock:AddFunction("SendCommand")
    serverMock:AddFunction("SendNetworkMessage")
    local function createEntityFunction(entityMapName)
    
        local entity = _G[Shared.mapToClass[entityMapName]]()
        entity:OnCreate()
        return entity
        
    end
    serverMock:AddFunction("CreateEntity"):AddCall(createEntityFunction)
    
    return serverMock
    
end