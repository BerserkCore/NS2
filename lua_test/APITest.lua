// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// APITest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "APITest", package.seeall, lunit.testcase )

local marine = NULL

function setup()
    SetPrintEnabled(true, "APITest")
    marine = InitializeMarine()
end

function teardown()
    Cleanup()
end

function test1()

    local coords = Coords.GetTranslation(marine:GetOrigin())
    
    Shared.CreateEffect(nil, "", marine)
    
    Shared.CreateEffect(nil, "cinematics/alien/crag/heal.cinematic", marine)
    
    Shared.CreateEffect(nil, "cinematics/alien/crag/heal.cinematic", nil, coords)

end

