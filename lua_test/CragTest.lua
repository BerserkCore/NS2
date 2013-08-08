// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// CragTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "CragTest", package.seeall, lunit.testcase )

local marinePlayer, alienPlayer = nil

function setup()

    SetPrintEnabled(true, "CragTest")
    
    GetGamerules():ResetGame()
    
    marinePlayer = InitializeMarine()
    alienPlayer = InitializeAlien()   

    GetGamerules():SetGameStarted()
    
    RunOneUpdate(1)
    
    assert_not_equal(Entity.invalidId, marinePlayer:GetId())
    assert_not_equal(Entity.invalidId, alienPlayer:GetId())
    
    assert_equal("Skulk", alienPlayer:GetClassName())
    assert_equal("Marine", marinePlayer:GetClassName())
        
end

function teardown()    
    Cleanup()    
end

function testCrag()

    RunOneUpdate()
    
    local crag = CreateStructure(kTechId.Crag, 2)
    assert_not_nil(crag)
    
    crag:SetConstructionComplete()
    assert_equal(crag:GetMaxHealth(), crag:GetHealth())
    assert_equal(crag:GetMaxArmor(), crag:GetArmor())
    
    // Turn off thinking so we can test with full control
    crag:SetNextThink(0)
    
    local cragOrigin = GetPointOnGround()
    //Print("CragOrigin: %s, PlayerOrigin: %s, Distance: %.2f", ToString(cragOrigin), ToString(alienPlayer:GetOrigin()), (cragOrigin - alienPlayer:GetOrigin()):GetLength())
    crag:SetOrigin(Vector(cragOrigin.x, cragOrigin.y + .2, cragOrigin.z))
    
    // Check that no targets are in range
    SpawnPlayerAtPoint(alienPlayer, Vector(cragOrigin.x, cragOrigin.y, cragOrigin.z + Crag.kHealRadius + .01), nil)
    RunOneUpdate(.1)
    local targets = crag:GetSortedTargetList()
    assert_equal(0, table.count(sortedList))

    // Still none, because not hurt
    SpawnPlayerAtPoint(alienPlayer, Vector(cragOrigin.x, cragOrigin.y, cragOrigin.z + Crag.kHealRadius - .01), nil)
    targets = crag:GetSortedTargetList()
    assert_equal(0, table.count(targets))    
    
    // Now we should have one
    assert_not_equal(Entity.invalidId, alienPlayer:GetId())
    
    alienPlayer:SetHealth(alienPlayer:GetHealth() - 10)
    targets = crag:GetSortedTargetList()
    assert_equal(1, table.count(targets))
    assert_equal(alienPlayer, targets[1])
    
    // Check that it heals targets with proper precedence
    crag:SetHealth(crag:GetHealth() - 20)
    targets = crag:GetSortedTargetList()
    assert_equal(2, table.count(targets))
    assert_equal(alienPlayer, targets[1])
    assert_equal(crag, targets[2])
    
    // Move alien player just out of range of umbra
    SpawnPlayerAtPoint(alienPlayer, Vector(cragOrigin.x, cragOrigin.y, cragOrigin.z + Crag.kUmbraRadius + .01), nil)
    
    // Trigger umbra
    crag:TriggerUmbra()
    
    // Update just team instead of calling RunUpdate(), so player doesn't fall
    alienPlayer:GetTeam():UpdateGameEffects(.5)
    assert_true(crag:GetIsUmbraActive())
    
    // See if friendly entities are now umbraed
    assert_true(crag:GetGameEffectMask(kGameEffect.InUmbra))
    assert_false(alienPlayer:GetGameEffectMask(kGameEffect.InUmbra))
    assert_false(marinePlayer:GetGameEffectMask(kGameEffect.InUmbra))
    
    // Move closer, update
    SpawnPlayerAtPoint(alienPlayer, Vector(cragOrigin.x, cragOrigin.y, cragOrigin.z + Crag.kUmbraRadius - .01), nil)
    
    // Update just team instead of calling RunUpdate(), so player doesn't fall
    alienPlayer:GetTeam():UpdateGameEffects(.01)
    assert_true(crag:GetIsUmbraActive())
    assert_true(alienPlayer:GetGameEffectMask(kGameEffect.InUmbra))
    assert_true(alienPlayer:GetGameEffectMask(kGameEffect.InUmbra))
    assert_false(marinePlayer:GetGameEffectMask(kGameEffect.InUmbra))
    
    // Run umbra duration out and make sure no longer active
    RunOneUpdate(Crag.kUmbraDuration + 1)
    
    assert_false(crag:GetIsUmbraActive())
    assert_false(crag:GetGameEffectMask(kGameEffect.InUmbra))
    assert_false(alienPlayer:GetGameEffectMask(kGameEffect.InUmbra))
    assert_false(marinePlayer:GetGameEffectMask(kGameEffect.InUmbra))
    
    /*
    // Make sure we're at full health before checking umbra effects
    assert_equal(marinePlayer:GetMaxHealth(), marinePlayer:GetHealth())
    
    // Ready? Set up marine to fire at alien.
    local alienOrigin = Vector(alienPlayer:GetOrigin())
    local marineOrigin = Vector(alienOrigin.x, alienOrigin.y, alienOrigin.z + 4)
    SpawnPlayerAtPoint(marinePlayer, marineOrigin, nil)
    
    // Aim.
    local viewVecToAlien = GetNormalizedVector(alienPlayer:GetOrigin() - (marinePlayer:GetOrigin() + marinePlayer:GetViewOffset()))
    SetViewAnglesFromVector(marinePlayer, viewVecToAlien)
    
    // Fire a bunch of bullets at player and make sure some bullets were blocked
    local rifle = marinePlayer:GetWeaponInHUDSlot(1)
    assert_not_nil(rifle)
    assert_equal("Rifle", rifle:GetClassName())
    
    local numBullets = 100
    local numHits = 0
    for i = 1, numBullets do
    
        if rifle:FireBullets(marinePlayer, 1, 0, 1000) then

            numHits = numHits + 1
            
            alienPlayer:SetHealth(alienPlayer:GetMaxHealth())
            
        end
        
    end
    
    Print("Num hits: %d/%d", numHits, numBullets)
    assert_true(numHits > 0) 
    assert_true(numHits < numBullets)*/
    
end