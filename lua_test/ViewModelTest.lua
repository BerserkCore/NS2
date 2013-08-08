// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ViewModelTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "ViewModelTest", package.seeall, lunit.testcase )

local marine = nil

function setup()

    SetPrintEnabled(true, "ViewModelTest")
    
    GetGamerules():ResetGame()
    
    RunUpdate()
    
    assert_equal(0, table.count(GetEntitiesIsa("Player")))
    
    assert_equal(0, table.count(GetEntitiesIsa("ViewModel")))

    marine = InitializePlayer(Marine.kMapName, 1)
    
    assert_equal(1, table.count(GetEntitiesIsa("ViewModel")))
    
    local viewModel = marine:GetViewModelEntity()
    assert_not_nil(viewModel)

    assert_equal(0, viewModel:GetPoseParam(Weapon.kSwingYaw))

    RunOneUpdate(.1)    
    
end

function teardown()
    Cleanup()
end

function testPoseParams()

    assert_equal(1, table.count(GetEntitiesIsa("ViewModel")))
    
    local viewModel = marine:GetViewModelEntity()
    assert_not_nil(viewModel)
    
    assert_equal(0, viewModel:GetPoseParam(Weapon.kSwingYaw))
    
    local move = Move()
    move:Clear()
    move.yaw = 1
    
    marine:UpdateWeaponSwing(move)
    
    assert_float_equal(20, viewModel:GetPoseParam(Weapon.kSwingYaw))    
    assert_float_equal(0, viewModel:GetPoseParam(Weapon.kSwingPitch))       
    
    assert_true(viewModel:GetAnimationLength("idle") > 0)

end

function verifyWeaponViewModel(mapName, draw, idle, attack)

    marine = GetEntitiesIsa("Marine")[1]
    
    marine:RemoveWeapons()

    RunOneUpdate(2)

    // Give player weapon and switch to it
    marine:GiveItem(mapName)
    
    RunOneUpdate()
    
    // Sanity checks
    local childEntities = GetChildEntities(marine, "Weapon")
    assert(table.count(childEntities) > 0)
    
    local weapons = marine:GetHUDOrderedWeaponList()
    assert(table.count(weapons) > 0)
    
    // Make sure we can switch to it
    marine:SetActiveWeapon(mapName)
    
    local weapon = marine:GetViewModelEntity()    
    
    assert_true(GetAnimationInTable(weapon:GetAnimation(), draw), mapName)
    
    local length = weapon:GetAnimationLength()
    assert_true(length > 0)
    
    RunOneUpdate(length - .1)
    assert_true(GetAnimationInTable(weapon:GetAnimation(), draw), mapName)

    // Idle should start    
    RunOneUpdate(.111)
    assert_false(GetAnimationInTable(weapon:GetAnimation(), draw), mapName)
    assert_true(GetAnimationInTable(weapon:GetAnimation(), idle), mapName)
    
    // Idle should loop
    length = weapon:GetAnimationLength()
    assert_true(length > 0)
    RunOneUpdate(length + .1)
    assert_true(GetAnimationInTable(weapon:GetAnimation(), idle), mapName)
    
    // Fire
    local move = Move()
    move:Clear()
    move.commands = bit.bor(move.commands, Move.PrimaryAttack) 
    RunUpdate(.3, move)
    
    local attackAnim = weapon:GetAnimation()
    assert_true(GetAnimationInTable(attackAnim, attack), mapName)
    local attackLen = weapon:GetAnimationLength()
    
    move:Clear()
    RunUpdate(attackLen + GetMinServerUpdateInterval(), move)
    assert_true(GetAnimationInTable(weapon:GetAnimation(), idle), mapName)
        
end

function testViewModels()
    
    verifyWeaponViewModel(Shotgun.kMapName, Shotgun.kAnimDrawTable, Shotgun.kAnimIdleTable, Shotgun.kAnimPrimaryAttackTable)
    verifyWeaponViewModel(Rifle.kMapName, Weapon.kAnimDraw, Rifle.kAnimIdleTable, Rifle.kAnimPrimaryAttackTable)   
    verifyWeaponViewModel(Pistol.kMapName, Weapon.kAnimDraw, Pistol.kAnimIdleTable, Pistol.kAnimPrimaryAttackTable)
    //verifyWeaponViewModel(Flamethrower.kMapName, Weapon.kAnimDraw, Flamethrower.kAnimIdleTable, Flamethrower.kFireAnimTable)

end