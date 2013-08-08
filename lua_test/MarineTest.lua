// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MarineTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "MarineTest", package.seeall, lunit.testcase )

local marine = nil

function setup()

    SetPrintEnabled(true, "MarineTest")

    RunUpdate(.1)
       
    GetGamerules():ResetGame()
    
    marine = InitializeMarine()    

    GetGamerules():SetGameStarted()
    
    RunUpdate(.1)
        
end

function teardown()
    Cleanup()
    marine = nil
end

function test1()

    assert_equal(Marine.kModelName, marine:GetModelName())
    
    // Make sure we have valid view model
    assert_not_nil(marine:GetViewModelEntity())    
    assert_not_equal(0, marine:GetViewModelEntity():GetModelIndex()) 

end


// Default loadout, view models and weapon switching
function test3()   

    // Make sure we only have one view model entity
    local viewModels = GetChildEntities(marine, "ViewModel")
    assert_equal(1, table.count(viewModels))
    
    // Test view model to be the rifle view model
    local viewModel = marine:GetViewModelEntity()
    assert_not_nil(viewModel)
    assert_equal(Shared.GetModelIndex(Rifle.kViewModelName), viewModel:GetModelIndex())

    // Switch weapons to pistol
    RunOneUpdate(2)
    assert_true(marine:SwitchWeapon(2))
    
end

/*
function testSprint()

    // Let draw animation finish
    RunOneUpdate(3)
    
    // Make sure sprinting animations work
    local move = Move()
    move:Clear()
    move.x = 1
    move.z = 1
    RunUpdate(1, move)
    
    move.commands = Move.MovementModifier
    RunUpdate(.2, move)

    //assert_true(marine.desiredRunning)
    
    local viewModel = marine:GetViewModelEntity()
    assert_not_nil(viewModel)
    assert_equal(Weapon.kSprintStart, viewModel:GetAnimation())    
    
    RunUpdate(2, move)
    assert_equal(Weapon.kAnimSprint, viewModel:GetAnimation())    
    
    move.commands = 0
    RunUpdate(.1, move)
    assert_false(marine.desiredRunning)
    assert_equal(Weapon.kSprintEnd, viewModel:GetAnimation())    

end*/

function testJump()

    assert_not_equal(Entity.invalidId, marine:GetId())
    RunOneUpdate(1)
    assert_true(marine:GetIsOnGround())

    // Make sure wall running and gravity work 
    local move = BuildMove(Move.Jump)
    RunUpdate(.2, move)
    assert_false(marine:GetIsOnGround())
    
    RunOneUpdate(5)
    assert_true(marine:GetGravityForce() < 0)
    assert_true(marine:GetIsOnGround())
    
end

function testReloadExploit()

    // Make sure we only have one view model entity
    local viewModels = GetChildEntities(marine, "ViewModel")
    assert_equal(1, table.count(viewModels))
    
    // Make sure reload doesn't finish if weapon switch interrupts it
    local rifle = marine:GetActiveWeapon()
    assert_not_nil(rifle)
    assert_equal("Rifle", rifle:GetClassName())
    assert_false(rifle:CanReload())
    
    rifle:SetClip(0)
    assert_equal(0, rifle:GetClip())
    assert_true(rifle:CanReload())
    assert_true(marine:GetCanNewActivityStart())
    rifle:OnReload(marine)
    RunOneUpdate(.2)
    assert_equal(0, rifle:GetClip())
    
    // Switch to pistol, interrupting reload
    assert_true(marine:SwitchWeapon(2))
    RunOneUpdate(2)
    
    // Go back to rifle and make sure the reload didn't finish
    assert_true(marine:SwitchWeapon(1))
    RunOneUpdate(2)
    assert_equal(0, rifle:GetClip())
    
    // Now let reload finish
    assert_true(rifle:CanReload())
    assert_true(marine:GetCanNewActivityStart())
    rifle:OnReload(marine)
    RunOneUpdate(3)
    assert_equal(rifle:GetClipSize(), rifle:GetClip())

end