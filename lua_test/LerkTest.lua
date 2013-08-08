// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// LerkTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "LerkTest", package.seeall, lunit.testcase )

local lerk = nil

function setup()

    SetPrintEnabled(true, "LerkTest")

    GetGamerules():ResetGame()
    GetGamerules():SetGameStarted()
    RunUpdate(.1)
    lerk = InitializePlayer(Lerk.kMapName, 2)
        
end

function teardown()
    Cleanup()
end

function test1()

    assert_equal(Lerk.kModelName, lerk:GetModelName())
    
    assert_equal(Lerk.kHealth, lerk:GetHealth())
    assert_equal(Lerk.kHealth, lerk:GetMaxHealth())
    
    assert_equal(Lerk.kArmor, lerk:GetArmor())
    assert_equal(Lerk.kArmor, lerk:GetMaxArmor())

    // Make sure we have valid view model
    assert_not_nil(lerk:GetViewModelEntity())    
    assert_not_equal(0, lerk:GetViewModelEntity():GetModelIndex()) 
    
end

// Make sure spores do damage properly and don't stack
function testSpores()

    local marine = InitializeMarine(true)
    
    local spawnOrigin = GetPointOnGround()
    SpawnPlayerAtPoint(marine, spawnOrigin, nil)
    
    // Create spore cloud just outside of range
    local spores = CreateEntity(SporeCloud.kMapName, Vector(spawnOrigin.x, spawnOrigin.y, spawnOrigin.z + SporeCloud.kDamageRadius + .1), 2)
    
    RunUpdate(SporeCloud.kThinkInterval)
    assert_equal(marine:GetMaxHealth(), marine:GetHealth())
    
    spores:SetOrigin(Vector(spawnOrigin.x, spawnOrigin.y, spawnOrigin.z + SporeCloud.kDamageRadius - .1))
    RunUpdate(SporeCloud.kThinkInterval)
    
    local damage, armorUsed, healthUsed = marine:ComputeDamage(SporeCloud.kDamage, spores:GetDamageType())
    assert_float_equal(marine:GetMaxHealth() - healthUsed, marine:GetHealth())
    
    // Create another and make sure we're still being damaged by only 1
    local spores2 = CreateEntity(SporeCloud.kMapName, Vector(spawnOrigin.x, spawnOrigin.y, spawnOrigin.z), 2)
    RunUpdate(SporeCloud.kThinkInterval)
    assert_float_equal(marine:GetMaxHealth() - 2*healthUsed, marine:GetHealth())

    RunUpdate(SporeCloud.kThinkInterval)
    assert_float_equal(marine:GetMaxHealth() - 3*healthUsed, marine:GetHealth())    
    
end

// Make sure lerk zoom doesn't take energy
function testZoom()

    local spikes = lerk:GetActiveWeapon()
    assert_not_nil(spikes)
    assert_equal("Spikes", spikes:GetClassName())
    assert_equal(0, spikes:GetSecondaryEnergyCost())

end
