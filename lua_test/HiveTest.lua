// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// HiveTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "HiveTest", package.seeall, lunit.testcase )

local hive = nil
local marinePlayer, alienPlayer = nil

function setup()

    SetPrintEnabled(true, "HiveTest")

    GetGamerules():ResetGame()
    
    // Add players to each side so game doesn't reset
    marinePlayer = InitializeMarine()
    alienPlayer = InitializeAlien()   
    
    GetGamerules():SetGameStarted()

    RunOneUpdate(1)

    hive = GetEntitiesIsa("Hive")[1]
    assert_not_nil(hive)
    
    // The first hive starts with full complement of eggs
    assert_equal(Hive.kBaseNumEggs, hive:GetNumEggs())
    
end

function teardown()    
    Cleanup()    
end

function validateEggPosition(egg, hive)

    local diff = egg:GetOrigin() - hive:GetOrigin()
    assert_true(diff:GetLengthXZ() >= Hive.kEggMinSpawnRadius)
    assert_true(diff:GetLengthXZ() <= Hive.kEggMaxSpawnRadius)
    assert_true(math.abs(diff.y) <= Hive.kMaxEggDropDistance)

end

function testEggs()

    // Now kill all nearby eggs
    assert_equal(Hive.kBaseNumEggs, hive:KillEggs())
    
    assert_equal(0, hive:GetNumEggs())
    
    local newEgg = hive:SpawnEgg()
    assert_not_nil(newEgg)
    
    validateEggPosition(newEgg, hive)
    
    // It should create more on its own
    assert_equal(1, hive:GetNumEggs())
    RunOneUpdate(1)
    assert_equal(1, hive:GetNumEggs())
    
    RunOneUpdate(hive:GetEggSpawnTime() + 3)
    assert_equal(hive:GetNumDesiredEggs() - 1, hive:GetNumEggs())

    // ...but only up to the maximum
    RunOneUpdate(hive:GetEggSpawnTime() * 10)
    assert_equal(hive:GetNumDesiredEggs(), hive:GetNumEggs())

end

function killEgg()

    local success = false
    
    local eggs = GetEntitiesIsaInRadius("Egg", 2, Vector(hive:GetOrigin()), Hive.kEggMaxSpawnRadius, true)
    if table.count(eggs) > 0 then
    
        local egg = eggs[1]
        egg:TakeDamage(1000)
        success = true
        
    end
    
    return success
    
end

// test player spawning from eggs
function testEggSpawning()

   assert_equal(Hive.kHiveNumEggs, hive:GetNumEggs())
   
   local alienTeam = GetGamerules():GetTeam2()
   assert_true(alienTeam:GetHasAbilityToRespawn())
   
end

function testMassUpgrade()

    // Make sure we can upgrade second hive to mass even if we upgraded first
    local scalar = hive:GetHealthScalar()
    assert_equal(scalar, 1)
    
    assert_true(hive:Upgrade(kTechId.HiveMass))
    scalar = hive:GetHealthScalar()
    assert_equal(scalar, 1)
    
    assert_false(hive:Upgrade(kTechId.HiveMass))
    
    assert_true(hive:Upgrade(kTechId.HiveColony))
    scalar = hive:GetHealthScalar()
    assert_equal(scalar, 1)
    
    assert_equal(kHiveColonyHealth, hive:GetHealth())
    assert_equal(kHiveColonyHealth, hive:GetMaxHealth())
    
end

