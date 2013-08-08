// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockClient.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks the Client script interface for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local function MockRenderLight()

    // Check if the class name needs to be mocked.
    if not RenderLight then
        local renderLightClassNameMock = MockMagic.CreateGlobalMock("RenderLight")
        renderLightClassNameMock:SetValue("Type_Point", 1)
    end

    local renderLightMock = MockMagic.CreateMock()
    SetMockType(renderLightMock, "RenderLight")
    renderLightMock:AddFunction("SetType")
    renderLightMock:AddFunction("SetCastsShadows")
    renderLightMock:AddFunction("SetSpecular")
    renderLightMock:AddFunction("SetCoords")
    renderLightMock:AddFunction("SetRadius")
    renderLightMock:AddFunction("SetIntensity")
    renderLightMock:AddFunction("SetColor")
    renderLightMock:AddFunction("SetGroup")
    return renderLightMock

end

function MockClient()

    if Client then
        return MockMagic.CreateGlobalMock("Client")
    end
    
    local clientMock = MockMagic.CreateGlobalMock("Client")
    
    clientMock:AddFunction("CreateRenderLight"):AddCall(function() return MockRenderLight() end)
    
    return clientMock
    
end