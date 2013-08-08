// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// CommonMocks.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Loads common mock script interfaces used in many tests.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

/**
 * Simple utility function that adds the GetClassName() and isa() functions to the passed
 * in mock.
 */
function SetMockType(mockToType, setType)

    local getClassNameFunction = mockToType:GetFunction("GetClassName")
    if not getClassNameFunction then getClassNameFunction = mockToType:AddFunction("GetClassName") end
    getClassNameFunction:SetReturnValues({ setType })
    
    local isaFunction = mockToType:GetFunction("isa")
    if not isaFunction then isaFunction = mockToType:AddFunction("isa") end
    isaFunction:AddCall(function (mockToType, typeName) if typeName == setType then return true end end)
    
end

Script.Load("MockShared.lua")
Script.Load("MockClient.lua")
Script.Load("MockServer.lua")
Script.Load("MockLocale.lua")
Script.Load("MockMove.lua")
Script.Load("MockEntity.lua")