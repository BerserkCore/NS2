// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockLocale.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks the Locale script interface for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function MockLocale()

    local localeMock = MockMagic.CreateGlobalMock("Locale")
    
    localeMock:AddFunction("ResolveString"):AddCall(function(stringArg) return stringArg end)
    
    return localeMock
    
end