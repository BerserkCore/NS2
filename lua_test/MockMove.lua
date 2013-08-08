// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockMove.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks the Move script interface for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================


Move = enum({ 'Q', 'W', 'E', 'R', 'A', 'S', 'D', 'F', 'Z', 'X', 'C', 'V', 'Minimap' })

function CreateMockMove()

    local moveMock = MockMagic.CreateMock()
    SetMockType(moveMock, "Move")
    moveMock:SetValue("move", Vector(0, 0, 0))
    moveMock:SetValue("pitch", 0)
    moveMock:SetValue("yaw", 0)
    moveMock:SetValue("time", 0)
    moveMock:SetValue("commands", 0)
    return moveMock
    
end