// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// PlayerTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "PlayerTest", package.seeall, lunit.testcase )

local marine 

// Reset game and put one player on each team
function setup()

    SetPrintEnabled(true, "PlayerTest")

    RunUpdate(.1)
       
    GetGamerules():ResetGame()
    
    player = InitializeMarine()    

    GetGamerules():SetGameStarted()
    
    RunUpdate(1)
    
    assert_not_equal(player:GetId(), Entity.invalidId)
    
end

function teardown()
    Cleanup()
end

// Test player replacement without children
function test1()

    local marinePlayer = player:Replace(Marine.kMapName, 1, false)

    assert_true(marinePlayer:isa("Marine"))
    assert_equal(kTeam1Index, marinePlayer:GetTeamNumber())

    // Count child entities
    local weapons = GetChildEntities(marinePlayer, "Weapon")
    assert_equal(3, table.count(weapons))
    
    local viewModels = GetChildEntities(marinePlayer, "ViewModel")
    assert_equal(1, table.count(viewModels))

    // Now delete the rifle
    local rifle = GetChildEntities(marinePlayer, "Rifle")[1]
    assert_not_nil(rifle)
    DestroyEntity(rifle)
    
    weapons = GetChildEntities(marinePlayer, "Weapon")
    assert_equal(2, table.count(weapons))

    local newMarinePlayer = marinePlayer:Replace(Marine.kMapName, 1, true)
    numWeapons = GetChildEntities(newMarinePlayer, "Weapon")
    assert_equal(2, table.count(numWeapons))
    
    viewModels  = GetChildEntities(newMarinePlayer, "ViewModel")
    assert_equal(1, table.count(viewModels ))
    
    // Now replace with a new marine and make sure we have all our weapons again
    local newNewMarinePlayer = newMarinePlayer:Replace(Marine.kMapName, 1, false)
    numWeapons = GetChildEntities(newNewMarinePlayer, "Weapon")
    assert_equal(3, table.count(numWeapons))
    
    viewModels = GetChildEntities(newNewMarinePlayer, "ViewModel")
    assert_equal(1, table.count(viewModels))
    
end

function testJump()

    // Make sure we're on the ground
    RunOneUpdate(2)
    assert_true(player:GetIsOnGround())

    local startOrigin = Vector(player:GetOrigin())
    
    // Make sure we jump up
    local move = Move()
    move:Clear()    
    move.commands = bit.bor(move.commands, Move.Jump) 
    
    RunUpdate(.3, move)
    assert_false(player:GetIsStuck())
    assert_true(player:GetOrigin().y > startOrigin.y)
    
    move:Clear()
    RunUpdate(3, move)
    
    // and land back where we started
    assert_false(player:GetIsStuck())
    assert_float_equal(player:GetOrigin().x, startOrigin.x)
    assert_float_equal(player:GetOrigin().y, startOrigin.y)
    assert_float_equal(player:GetOrigin().z, startOrigin.z)
    assert_true(player:GetIsOnGround())

end

function testCrouch()

    assert_not_equal(Entity.invalidId, player:GetId())
    
    // Crouch then move and make sure we're not stuck
    local startOrigin = Vector(player:GetOrigin())
    assert_float_equal(0, player:GetCrouchAmount())
    local startExtents = player:GetExtentsFromCrouch(player:GetCrouchAmount())

    // Crouch for 1 second    
    local move = Move()
    move:Clear()    
    move.commands = bit.bor(move.commands, Move.Crouch)     
    RunUpdate(.5, move)
    RunUpdate(.5, move)
    
    // Make sure crouch data updated properly
    assert_not_equal(Entity.invalidId, player:GetId())
    
    local crouchedOrigin = Vector(player:GetOrigin())
    local crouchScalar = player:GetCrouchAmount()
    assert_float_equal(1, crouchScalar)
    assert_false(player:GetIsStuck())
    
    // Make sure our extents shrank
    local crouchedExtents = player:GetExtentsFromCrouch(crouchScalar)
    assert_true(crouchedOrigin.y < startOrigin.y)
    
    // Stand and move forward for 1 second
    move:Clear()    
    move.move.z = 1
    RunUpdate(.5, move)
    RunUpdate(.5, move)
    
    local newOrigin = Vector(player:GetOrigin())
    assert_false(player:GetIsStuck())

    // Should be uncrouched
    assert_float_equal(0, player:GetCrouchAmount())
    
    // Should be in a new place
    //assert_float_not_equal(crouchedOrigin.x, newOrigin.x)
    
    // Hold crouch for a bit and make sure everything is correct
    //move:Clear()    
    //move.commands = bit.bor(move.commands, Move.Crouch)     
    //RunUpdate(3, move)
    
end

// Make sure player trace capsules work properly with different physics systems
function testFloorPenetrate()

    RunOneUpdate(1)    
   
    local startPos = Vector(player:GetOrigin())
    assert_true(player:GetIsOnGround())
    
    assert_equal(.5, player:GetStepHeight())

    // Move player down step height while resting on ground (they shouldn't move)
    startPos = Vector(player:GetOrigin())
    player:PerformMovement(Vector(0, -player:GetStepHeight(), 0), 1)
    local endPos = player:GetOrigin()
    assert_float_equal(0, (startPos - endPos):GetLength())

    // Move player up step height while resting on ground (they should move up)
    startPos = Vector(player:GetOrigin())
    player:PerformMovement(Vector(0, player:GetStepHeight(), 0), 1)
    endPos = player:GetOrigin()
    
    assert_float_equal(player:GetStepHeight(), (startPos - endPos):GetLength())
    
end    

function testDisconnect()

    assert_equal(table.count(GetGamerules():GetEntities("Player")), 1)
    
    Shared.ConsoleCommand("addbot 1")
    assert_equal(table.count(GetGamerules():GetEntities("Player")), 2)
    
    Shared.ConsoleCommand("removebot 1")
    assert_equal(table.count(GetGamerules():GetEntities("Player")), 1)
    
end

function testWeaponSpawn()

    // Create a server full of players (turn on cheats so we join instantly)
    Shared.ConsoleCommand("cheats 1")
    //for i = 1, 5 do
    //    InitializeMarine()    
        InitializeAlien()    
    //end
    Shared.ConsoleCommand("cheats 0")
    
    local players = GetGamerules():GetEntities("Player")
    //assert_equal(table.count(players), 11)
    
    RunUpdate(.1)
    
    // Make sure they all have their starting weapons and view model
    for index, currentPlayer in ipairs(players) do
    
        // Verify view model and active weapon
        local className = currentPlayer:GetClassName()
        assert_not_nil(currentPlayer:GetViewModelEntity(), string.format("player %d, %s", index, className))
        assert_not_nil(currentPlayer:GetActiveWeapon(), string.format("player %d, %s", index, className))
        
    end
    
    // Reset the game
    for resetIndex = 1, 30 do
    
        GetGamerules():ResetGame()
        RunUpdate(1)
     
        // Make sure they all have their starting weapons and view model
        players = GetGamerules():GetEntities("Player")
        //assert_equal(table.count(players), 11)
        
        for index, currentPlayer in ipairs(players) do
        
            // Verify view model and active weapon
            local className = currentPlayer:GetClassName()
            assert_not_equal(className, "AlienSpectator")
            assert_not_equal(currentPlayer:GetId(), Entity.invalidId)
            
            assert_not_nil(currentPlayer:GetViewModelEntity(), string.format("reset #%d, player %d, %s", resetIndex, index, className))
            assert_not_nil(currentPlayer:GetActiveWeapon(), string.format("reset #%d, player %d, %s", resetIndex, index, className))

        end
        
    end
    
end

// Needs to return world surface in order to play footsteps
function testMaterialBelowPlayer()
    local material = player:GetMaterialBelowPlayer()
    assert_not_nil(material, "Traceline below player returned no material, footsteps won't play")
    assert_not_equal(material, "", "Traceline below player returned no material, footsteps won't play")
end