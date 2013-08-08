// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// DamageTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "DamageTest", package.seeall, lunit.testcase )

local marine = nil
local alien = nil

function GiveUpgrade(techId, teamNumber)

    local team = GetGamerules():GetTeam(teamNumber)
    if team ~= nil then
        return team:GetTechTree():GiveUpgrade(techId)
    end
    
    return false
    
end

// Reset game and put one player on each team
function setup()

    RunUpdate(.1)
       
    GetGamerules():ResetGame()
    
    marine = InitializeMarine()
    alien = InitializeAlien()

    GetGamerules():SetGameStarted()
    
    RunUpdate(.1)

end

function teardown()
    Cleanup()
end

// Test radius damage
function test1()

    // Get Skulk
    local skulk = GetEntitiesIsa("Skulk")[1]
    assert_not_nil(skulk)
    
    // Reduce armor to 0 to make damage calculation easier
    skulk:SetArmor(0)
        
    // Damage origin
    local distFromSkulk = 10
    local damageRadius = 20
    local damage = 50

    local damageOrigin = Vector(skulk:GetOrigin())
    damageOrigin.x = damageOrigin.x + distFromSkulk    
    
    local entities = GetEntitiesWithMixinWithinRangeAreVisible("Live", kAlienTeamType, damageOrigin, damageRadius)
    
    // Set cheats on to force damage
    RadiusDamage(entities, damageOrigin, damageRadius, damage, marine)
    
    local correctSkulkHealth = skulk:GetMaxHealth() - damage/2
    assert_equal(correctSkulkHealth, skulk:GetHealth())    
    
end


// Test marine doing damage to skulk and vice-versa
//function test2()
//end

// Test ammo/armor ugprades
//function test3()
//end

//Test damage animations for extractor
function test4()

    //Set up the Extractors
    local extractors = GetEntitiesIsa("Extractor")
    assert_not_nil(extractors)
    
    local extractor = extractors[1]
    assert_not_nil(extractor)
    
    //Damage origin
    local distFromExtractor = 10
    local damageRadius = 20
    local damage = 50
    
    local damageOrigin = Vector(extractor:GetOrigin())
    
    damageOrigin.x = damageOrigin.x + damageRadius
    
    local entities = GetEntitiesIsaInRadius("Structure", kMarineTeamType, damageOrigin, damageRadius, false)
    
    //assert_equal(Extractor.kHurtEffect, extractor:GetAnimation())
    
end

// Test marine and armor 123 upgrades
function test5()

    // Marine armor should go up with new upgrades
    assert_equal(Marine.kHealth, marine:GetHealth())
    assert_equal(Marine.kBaseArmor, marine:GetArmor())
    assert_equal(Marine.kBaseArmor, marine:GetMaxArmor())
    
    // Hurt marine by half to make sure values change accordingly when we give upgrades
    marine:TakeDamage(40)

    local healthPercent = marine:GetHealthScalar()
    local armorPercent = marine:GetArmorScalar()

    assert_true(GiveUpgrade(kTechId.Armor1, 1))
    assert_float_equal(Marine.kBaseArmor + Marine.kArmorPerUpgradeLevel, marine:GetMaxArmor())
    assert_float_equal(armorPercent, marine:GetArmorScalar())

    assert_true(GiveUpgrade(kTechId.Armor2, 1))
    assert_float_equal(Marine.kBaseArmor + 2*Marine.kArmorPerUpgradeLevel, marine:GetMaxArmor())
    assert_float_equal(armorPercent, marine:GetArmorScalar())

    assert_true(GiveUpgrade(kTechId.Armor3, 1))
    assert_float_equal(Marine.kBaseArmor + 3*Marine.kArmorPerUpgradeLevel, marine:GetMaxArmor())
    assert_float_equal(armorPercent, marine:GetArmorScalar())    
    
end

// Test marine damage upgrades
function test6()

    // Test rifle damage
    assert_equal(Rifle.kDamage, GetGamerules():GetUpgradedDamage(marine, Rifle.kDamage, kDamageType.Normal))
    
    // Test weapons/123
    assert_true(GiveUpgrade(kTechId.Weapons1, 1))
    assert_equal(Rifle.kDamage * kWeapons1DamageScalar, GetGamerules():GetUpgradedDamage(marine, Rifle.kDamage, kDamageType.Normal))

    // Make sure melee damage isn't affected
    assert_equal(Axe.kDamage, GetGamerules():GetUpgradedDamage(marine, Axe.kDamage, kDamageType.Structural))
    
    assert_true(GiveUpgrade(kTechId.Weapons2, 1))
    assert_equal(Rifle.kDamage * kWeapons2DamageScalar, GetGamerules():GetUpgradedDamage(marine, Rifle.kDamage, kDamageType.Normal))
    assert_equal(Axe.kDamage, GetGamerules():GetUpgradedDamage(marine, Axe.kDamage, kDamageType.Structural))

    assert_true(GiveUpgrade(kTechId.Weapons3, 1))
    assert_equal(Rifle.kDamage * kWeapons3DamageScalar, GetGamerules():GetUpgradedDamage(marine, Rifle.kDamage, kDamageType.Normal))
    assert_equal(Axe.kDamage, GetGamerules():GetUpgradedDamage(marine, Axe.kDamage, kDamageType.Structural))
    
end

function verifyDamageType(mapName, primaryDamageType, secondaryDamageType)

    assert_not_nil(mapName)
    assert_not_nil(primaryDamageType)
    
    local error = string.format("verifyDamageType(%s, %s)", mapName, EnumToString(kDamageType, primaryDamageType))
    
    local ent = CreateEntity(mapName, Vector(0, 0, 0), 1)
    assert_not_nil(ent, error)
    
    local techId = ent:GetTechId()
    assert_not_equal(kTechId.None, techId, error)
    
    local damageType = ent:GetDamageType()
    assert_not_nil(damageType, error)
    
    assert_equal(primaryDamageType, damageType, error)
    
    if secondaryDamageType then

        ent:PerformSecondaryAttack(marine)
        assert_equal(secondaryDamageType, ent:GetDamageType(), error)
        
        ent:PerformPrimaryAttack(marine)
        assert_equal(primaryDamageType, ent:GetDamageType(), error)
        
    end
    
end

function verifyDamage(damage, damageType, techId, teamNumber, properDamage, properArmorUsed, properHealthUsed)

    local errorString = string.format("verifyDamage(%.2f, %s, %s, %d, %.2f, %s, %s)", damage, EnumToString(kDamageType, damageType), EnumToString(kTechId, techId), teamNumber, properDamage, ToString(properArmorUsed), ToString(properHealthUsed))
    
    local mapName = LookupTechData(techId, kTechDataMapName)
    assert_not_nil(mapName, errorString)
    
    local ent = CreateEntity(mapName, Vector(0, 0, 0), teamNumber)
    assert_not_nil(ent, errorString)
    
    local damage, armorUsed, healthUsed = ent:ComputeDamage(damage, damageType)
    assert_float_equal(properDamage, damage, errorString)
    
    if properArmorUsed then
        assert_float_equal(properArmorUsed, armorUsed, errorString)
    end

    if properHealthUsed then
        assert_float_equal(properHealthUsed, healthUsed, errorString)
    end

end

function testDamageTypes()

    verifyDamageType(Rifle.kMapName, kDamageType.Normal)
    verifyDamageType(Pistol.kMapName, kDamageType.Heavy)
    verifyDamageType(Axe.kMapName, kDamageType.Structural)
    verifyDamageType(Shotgun.kMapName, kDamageType.Normal)
    verifyDamageType(Flamethrower.kMapName, kDamageType.Flame)
    verifyDamageType(Minigun.kMapName, kDamageType.Normal)
    
    verifyDamageType(BiteLeap.kMapName, kDamageType.Normal)
    verifyDamageType(Parasite.kMapName, kDamageType.Normal)
    //verifyDamageType(SpitSpray.kMapName, kDamageType.Normal, kDamageType.Light)  
    verifyDamageType(Spikes.kMapName, kDamageType.Normal, kDamageType.Normal)
    verifyDamageType(Gore.kMapName, kDamageType.Normal)
    
    verifyDamageType(MAC.kMapName, kDamageType.Normal)
    verifyDamageType(ARC.kMapName, kDamageType.StructuresOnly)    
    verifyDamageType(Sentry.kMapName, kDamageType.Light)
    
    verifyDamageType(Drifter.kMapName, kDamageType.Normal)
    verifyDamageType(HydraSpike.kMapName, kDamageType.Normal)
    
    // Now verify that damage is computed properly
    verifyDamage(10, kDamageType.Normal, kTechId.Skulk, 2, 10)
    verifyDamage(11, kDamageType.Normal, kTechId.InfantryPortal, 1, 11)
    verifyDamage(12, kDamageType.Normal, kTechId.Door, 0, 0)
    
    verifyDamage(10, kDamageType.Light, kTechId.Skulk, 2, 10, (10/kHealthPointsPerArmorLight)*kBaseArmorAbsorption, 10 - 10*kBaseArmorAbsorption)
    verifyDamage(kExtractorArmor, kDamageType.Light, kTechId.Extractor, 1, kExtractorArmor, kExtractorArmor*kBaseArmorAbsorption/kHealthPointsPerArmorLight, kExtractorArmor - kExtractorArmor*kBaseArmorAbsorption)

    verifyDamage(5, kDamageType.Heavy, kTechId.Skulk, 2, 5, 5 * kBaseArmorAbsorption, 5 - (5 * kBaseArmorAbsorption))
    verifyDamage(kInfantryPortalArmor*2, kDamageType.Heavy, kTechId.InfantryPortal, kInfantryPortalArmor*2, kInfantryPortalArmor * kBaseArmorAbsorption, kInfantryPortalArmor * 2 - (kBaseArmorAbsorption * kInfantryPortalArmor))
    
    verifyDamage(10, kDamageType.Puncture, kTechId.Skulk, 2, 10 * kPuncturePlayerDamageScalar)
    verifyDamage(11, kDamageType.Puncture, kTechId.InfantryPortal, 1, 11)
    verifyDamage(12, kDamageType.Puncture, kTechId.Door, 0, 0)   
        
    verifyDamage(10, kDamageType.Structural, kTechId.Skulk, 2, 10)
    verifyDamage(12, kDamageType.Structural, kTechId.InfantryPortal, 1, 24)
    verifyDamage(13, kDamageType.Structural, kTechId.Door, 0, 0)
    
    verifyDamage(10, kDamageType.Gas, kTechId.Skulk, 2, 10)
    verifyDamage(12, kDamageType.Gas, kTechId.InfantryPortal, 1, 0)
    verifyDamage(13, kDamageType.Gas, kTechId.Door, 0, 0)
    verifyDamage(14, kDamageType.Gas, kTechId.Heavy, 1, 0)

    verifyDamage(10, kDamageType.Biological, kTechId.Skulk, 2, 10)
    verifyDamage(12, kDamageType.Biological, kTechId.InfantryPortal, 1, 0)
    verifyDamage(13, kDamageType.Biological, kTechId.Door, 0, 0)
    verifyDamage(13, kDamageType.Biological, kTechId.Marine, 1, 13)
    verifyDamage(13, kDamageType.Biological, kTechId.Heavy, 1, 0)
    verifyDamage(14, kDamageType.Biological, kTechId.Hive, 2, 14)
    verifyDamage(15, kDamageType.Biological, kTechId.Crag, 2, 15)
    
    verifyDamage(10, kDamageType.StructuresOnly, kTechId.Skulk, 2, 0)
    verifyDamage(12, kDamageType.StructuresOnly, kTechId.InfantryPortal, 1, 12)
    verifyDamage(13, kDamageType.StructuresOnly, kTechId.Door, 0, 0)

    // Skulks and heavies don't take damage when falling. Players that do 
    // take damage have no armor absorption.
    verifyDamage(10, kDamageType.Falling, kTechId.Skulk, 2, 0)
    verifyDamage(12, kDamageType.Falling, kTechId.Heavy, 1, 12)
    verifyDamage(13, kDamageType.Falling, kTechId.Door, 0, 0)
    verifyDamage(14, kDamageType.Falling, kTechId.Marine, 1, 14, 0)
    verifyDamage(15, kDamageType.Falling, kTechId.Gorge, 2, 15, 0)
    
    verifyDamage(10, kDamageType.Door, kTechId.Skulk, 2, 10)
    verifyDamage(12, kDamageType.Door, kTechId.InfantryPortal, 1, 12)
    verifyDamage(13, kDamageType.Door, kTechId.Door, 0, 13)

end

// Make sure marine vs. skulk is computed the same as in NS1
// 1 bite -> 77/3
// 2 bites -> 10/0
// 3 bites -> death
function testNS1BiteDamage()

    local biteLeap = alien:GetActiveWeapon()
    assert_not_nil(biteLeap)
    assert_equal("BiteLeap", biteLeap:GetClassName())
    
    assert_false(marine:TakeDamage(kBiteDamage, alien, biteLeap, nil, nil))
    assert_float_equal(77, math.floor(marine:GetHealth()))
    assert_float_equal(3, math.floor(marine:GetArmor()))

    assert_false(marine:TakeDamage(kBiteDamage, alien, biteLeap, nil, nil))
    assert_float_equal(10, math.floor(marine:GetHealth()))
    assert_float_equal(0, math.floor(marine:GetArmor()))
    
    assert_true(marine:TakeDamage(kBiteDamage, alien, biteLeap, nil, nil))
    
end

// 1 shot -> 68/6
// 2 shots -> 65/3
// 3 shots -> 61/0
// For some reason these are off by 1. 
function testNS1RifleDamage()

    local rifle = marine:GetActiveWeapon()
    assert_not_nil(rifle)
    assert_equal("Rifle", rifle:GetClassName())
    
    assert_false(alien:TakeDamage(kRifleDamage, marine, rifle, nil, nil))
    assert_float_equal(67, alien:GetHealth())
    assert_float_equal(6, math.floor(alien:GetArmor()))

    assert_false(alien:TakeDamage(kRifleDamage, marine, rifle, nil, nil))
    assert_float_equal(64, alien:GetHealth())
    assert_float_equal(3, math.floor(alien:GetArmor()))

    assert_false(alien:TakeDamage(kRifleDamage, marine, rifle, nil, nil))
    assert_float_equal(60, alien:GetHealth())
    assert_float_equal(0, math.floor(alien:GetArmor()))
    
end