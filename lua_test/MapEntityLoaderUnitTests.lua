// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MapEntityLoaderUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MapEntityLoader.lua")
module( "MapEntityLoaderUnitTests", package.seeall, lunit.testcase )

// Tests begin.
function setup()

    MockClient()
    
end

function teardown()
end

function TestLoadLight()

    local values = { }
    values.origin = Vector()
    values.angles = Angles()
    values.casts_shadows = true
    values.distance = 10
    values.intensity = 5
    values.color = Color(1, 1, 1, 1)
    values.ignorePowergrid = false
    
    local entityLists = { }
    local lightList = { }
    entityLists["light_point"] = lightList
    
    assert_equal(nil, Client.lightList)
    assert_equal(true, LoadMapEntity("light_point", "MainLightGroup", values))
    assert_equal(1, table.maxn(Client.lightList))
    
end