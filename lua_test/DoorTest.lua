// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// DoorTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "DoorTest", package.seeall, lunit.testcase )

local marinePlayer, alienPlayer = nil

function setup()

    SetPrintEnabled(true, "DoorTest")

    GetGamerules():ResetGame()
    
    marinePlayer = InitializeMarine()
    alienPlayer = InitializeAlien()   

    GetGamerules():SetGameStarted()
    RunOneUpdate(10)
        
end

function teardown()    
    Cleanup()    
end

// Door tests
function testDoor()

    // Create door
    local location = Vector(10, 10, 10)
    local door = CreateEntity(Door.kMapName, location)
    assert_not_nil(door)
    
    // Check state
    assert_equal(Door.kState.Closed, door:GetState())
    
    /*
    // Have player use door to make it close
    local marine = InitializeMarine()
    marine:SetOrigin( Vector(location.x, location.y, location.z - 1) )
    assert_true(door:GetCanBeUsed())
    
    assert_true(door:OnUse(marine, .1))
    assert_false(door:GetCanBeUsed())
    RunOneUpdate(1)
    assert_true(door:GetCanBeUsed())
    assert_equal(Door.kState.Closed, door:GetState())
    
    // Open door
    assert_true(door:OnUse(marine, .1))
    assert_false(door:GetCanBeUsed())
    RunOneUpdate(1)
    assert_true(door:GetCanBeUsed())
    assert_equal(Door.kState.Opened, door:GetState())
    
    Server.DestroyEntity(marine)
    
    // Weld door
    assert_true(door:OnWeld(nil, 1))
    
    // Make sure door starts closing
    assert_equal(Door.kState.Close, door:GetState())
    assert_equal(Door.kStateAnim[Door.kState.Close], door:GetAnimation())
    
    RunOneUpdate(4)
    
    assert_equal(Door.kState.Closed, door:GetState())
    assert_equal(Door.kStateAnim[Door.kState.Closed], door:GetAnimation())
    
    assert_true(door:OnWeld(1))
    assert_equal(Door.kState.Closed, door:GetState())
    
    // Weld door very close to completion
    assert_true(door:OnWeld(Door.kDefaultWeldTime - 1 - .05))
    assert_equal(Door.kState.Closed, door:GetState())

    // Weld door to completion
    assert_true(door:OnWeld(.06))
    assert_equal(Door.kState.Welded, door:GetState())
    assert_false(door:GetCanBeUsed())

    // TODO: Apply lots of damage to door, make sure it stops functioning, but isn't deleted  

    // Cleanup door as it won't be deleted on its own
    Server.DestroyEntity(door)
    */

end