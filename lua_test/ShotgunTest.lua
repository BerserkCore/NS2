// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ShotgunTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "ShotgunTest", package.seeall, lunit.testcase )

local marine = nil
local shotgun = nil

function setup()

    SetPrintEnabled(true, "ShotgunTest")
    
    GetGamerules():ResetGame()
    GetGamerules():SetGameStarted()
    
    marine = InitializePlayer(Marine.kMapName, 1)
    
    shotgun = marine:GiveItem(Shotgun.kMapName)
    assert_not_nil(shotgun)
    
    RunOneUpdate(.1)
    assert_true(marine:SetActiveWeapon(Shotgun.kMapName))
    
    assert_equal(Shotgun.kMapName, shotgun:GetMapName())
            
end

function teardown()
    Cleanup()
    marine  = nil
    shotgun = nil
end

function testShotgunEmpty()

    // Fire until clip is empty, make sure games doesn't crash
    local move = Move()
    move:Clear()
    move.commands = bit.bor(move.commands, Move.PrimaryAttack) 
    RunUpdate(5, move)    

    // Make shotgun go empty and to fire it
    shotgun.ammo = 0
    shotgun.clip = 0
    
    local move = Move()
    move:Clear()
    move.commands = bit.bor(move.commands, Move.PrimaryAttack) 
    RunUpdate(1, move)
    
end

/*
function testShotgunReload()

    local viewModel = marine:GetViewModelEntity()
    assert_not_nil(viewModel)
    assert_equal(Shotgun.kViewModelName, viewModel:GetModelName())
    
    local time = viewModel:GetAnimationLength(Shotgun.kAnimReloadStart)
    assert_true(time > 0, tostring(time))

    // Test reload timing
    local startClip = Shotgun.kClipSize - 2
    shotgun.clip = startClip

    shotgun:OnReload(marine)
    
    RunUpdate(time + 5, move)
    
    assert_equal(shotgun.clip, startClip + 1)
    
    time = viewModel:GetAnimationLength(Shotgun.kAnimReloadShell)
    RunUpdate(time - .01, move)
    assert_equal(shotgun.clip, startClip + 1)
    
    RunUpdate(.02, move)
    assert_equal(shotgun.clip, startClip + 2)
    
end
*/

function testFalloffDamage()

    assert_float_equal(Shotgun.kMaxDamage, shotgun:GetBulletDamageForRange(Shotgun.kPrimaryMaxDamageRange))
    assert_float_equal(Shotgun.kMinDamage, shotgun:GetBulletDamageForRange(Shotgun.kPrimaryRange))
    
    assert_float_equal(Shotgun.kMaxDamage, shotgun:GetBulletDamageForRange(Shotgun.kPrimaryMaxDamageRange - .1))
    assert_float_equal(Shotgun.kMaxDamage, shotgun:GetBulletDamageForRange(0))
    
    assert_float_equal(Shotgun.kMinDamage, shotgun:GetBulletDamageForRange(Shotgun.kPrimaryRange + 1))
    assert_float_equal((Shotgun.kMinDamage + Shotgun.kMaxDamage)/2, shotgun:GetBulletDamageForRange((Shotgun.kPrimaryMaxDamageRange + Shotgun.kPrimaryRange)/2))
    
    assert_float_equal(Shotgun.kMinDamage, shotgun:GetBulletDamageForRange(Shotgun.kPrimaryRange + 1))
    
end
