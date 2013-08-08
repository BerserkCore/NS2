// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ClipWeaponTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "ClipWeaponTest", package.seeall, lunit.testcase )

// Reset game and put one player on each team
local marine = nil
local rifle = nil
function setup()

    StandardSetup("ClipWeaponTest")

    marine = InitializeMarine(true)    
    
    RunOneUpdate(4)
    
    assert_true(marine:SetActiveWeapon(Rifle.kMapName))
    rifle = marine:GetActiveWeapon()
    assert_not_nil(rifle)
    
    RunOneUpdate(2)

end

function teardown()
    Cleanup()
end

function giveAmmoTest()

    assert_equal(rifle:GetClipSize(), rifle:GetClip())
    
    assert_true(rifle:GiveAmmo(1))

    assert_false(rifle:GiveAmmo(1))
    
    rifle:SetClip(0)
    
    assert_false(rifle:GiveAmmo(1))
    
    assert_equal(0, rifle:GetClip())
    
    local prevAmmo = rifle:GetAmmo()
    
    rifle:FillClip()
    
    assert_equal(rifle:GetClipSize(), rifle:GetClip())
    
    assert_equal(rifle:GetAmmo(), prevAmmo - rifle:GetClip())
    
end
