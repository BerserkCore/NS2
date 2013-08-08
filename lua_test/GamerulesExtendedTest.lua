// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// GamerulesExtendedTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "GamerulesExtendedTest", package.seeall, lunit.testcase )

Script.Load("UtilityTest.lua")
Script.Load("lua/Gamerules_Global.lua")

local marinePlayer = nil
local alienPlayer = nil

function setup()

    SetPrintEnabled(true, "GamerulesExtendedTest")

    RunUpdate(.1)

    GetGamerules():ResetGame()
    
    marinePlayer = InitializeMarine()
    alienPlayer = InitializeAlien()        
    
    GetGamerules():SetGameStarted()
    
    RunUpdate(1)
    
    assert_not_equal(marinePlayer:GetId(), Entity.invalidId)
    assert_not_equal(alienPlayer:GetId(), Entity.invalidId)
    
end

function teardown()
    Cleanup()
end

// Test game effect masks and stackable game effects
function testGameEffects()

    // Test flags
    assert_false(marinePlayer:GetGameEffectMask(kGameEffect.InUmbra))
    assert_true(marinePlayer:SetGameEffectMask(kGameEffect.InUmbra, true))
    assert_true(marinePlayer:GetGameEffectMask(kGameEffect.InUmbra))
    
    assert_false(marinePlayer:SetGameEffectMask(kGameEffect.InUmbra, true))
    
    assert_true(marinePlayer:SetGameEffectMask(kGameEffect.Cloaked, true))
    assert_true(marinePlayer:GetGameEffectMask(kGameEffect.Cloaked))
    assert_true(marinePlayer:GetGameEffectMask(kGameEffect.InUmbra))
    
    assert_true(marinePlayer:SetGameEffectMask(kGameEffect.InUmbra, false))
    assert_false(marinePlayer:GetGameEffectMask(kGameEffect.InUmbra))
    
    assert_true(marinePlayer:GetGameEffectMask(kGameEffect.Cloaked))
    assert_true(marinePlayer:SetGameEffectMask(kGameEffect.Cloaked, false))
    assert_false(marinePlayer:GetGameEffectMask(kGameEffect.Cloaked))
    
    // Test stackable effects
    local kCloaked = "cloaking"
    assert_equal(0, marinePlayer:GetStackableGameEffectCount(kCloaked))
    
    marinePlayer:AddStackableGameEffect(kCloaked)
    assert_equal(1, marinePlayer:GetStackableGameEffectCount(kCloaked))

    marinePlayer:AddStackableGameEffect(kCloaked)
    assert_equal(2, marinePlayer:GetStackableGameEffectCount(kCloaked))
    
    local kBuildSpeed = "buildspeed"
    marinePlayer:AddStackableGameEffect(kBuildSpeed)
    assert_equal(1, marinePlayer:GetStackableGameEffectCount(kBuildSpeed))
    
    marinePlayer:AddStackableGameEffect(kBuildSpeed)
    assert_equal(2, marinePlayer:GetStackableGameEffectCount(kBuildSpeed))
    
    // Replace player and make sure game effects come across
    local newMarinePlayer = marinePlayer:Replace(Marine.kMapName, 1, false)
    RunOneUpdate(.1)
    assert_equal(2, newMarinePlayer:GetStackableGameEffectCount(kCloaked))
    assert_equal(2, newMarinePlayer:GetStackableGameEffectCount(kBuildSpeed))
    
    newMarinePlayer:ClearStackableGameEffects()
    assert_equal(0, newMarinePlayer:GetStackableGameEffectCount(kCloaked))
    assert_equal(0, newMarinePlayer:GetStackableGameEffectCount(kBuildSpeed))
    
    // Test game effects that expire over time
    newMarinePlayer:AddStackableGameEffect(kBuildSpeed, duration)
    assert_equal(1, newMarinePlayer:GetStackableGameEffectCount(kBuildSpeed))    

    local duration = 2
    newMarinePlayer:AddStackableGameEffect(kBuildSpeed, duration)
    assert_equal(2, newMarinePlayer:GetStackableGameEffectCount(kBuildSpeed))    
    
    RunUpdate(1.9)
    assert_equal(2, newMarinePlayer:GetStackableGameEffectCount(kBuildSpeed))    
    
    RunUpdate(.2)
    assert_equal(1, newMarinePlayer:GetStackableGameEffectCount(kBuildSpeed))    
    
    RunUpdate(2)
    assert_equal(1, newMarinePlayer:GetStackableGameEffectCount(kBuildSpeed))    
    
end

function testMultiples()

    // Make sure duplicates from the same source entity don't get added
    local kBuildSpeed = "buildspeed"
    local count = marinePlayer:GetStackableGameEffectCount(kBuildSpeed)
    marinePlayer:AddStackableGameEffect(kBuildSpeed, duration, alienPlayer)
    assert_equal(count + 1, marinePlayer:GetStackableGameEffectCount(kBuildSpeed))    
    
    marinePlayer:AddStackableGameEffect(kBuildSpeed, duration, alienPlayer)
    assert_equal(count + 1, marinePlayer:GetStackableGameEffectCount(kBuildSpeed))    

    marinePlayer:AddStackableGameEffect(kBuildSpeed, duration, nil)
    assert_equal(count + 2, marinePlayer:GetStackableGameEffectCount(kBuildSpeed))    

end

function testLocations()

    assert_true(marinePlayer:SetLocationName("Marine Start West"))
    assert_equal(marinePlayer:GetLocationName(), "Marine Start West")    
    
    assert_true(marinePlayer:SetLocationName("Alien Start"))
    assert_equal(marinePlayer:GetLocationName(), "Alien Start")    
    
    assert_false(marinePlayer:SetLocationName("Invalid Name", true))
    assert_equal(marinePlayer:GetLocationName(), "")    
    
end

function testResetLocations()

    // Make sure locations stay set through round reset
    local powerPoint = GetEntitiesIsa("PowerPoint")[1]
    assert_not_nil(powerPoint)
    local powerPointLocationName = powerPoint:GetLocationName()
    assert_not_nil(powerPointLocationName)
    
    GetGamerules():ResetGame()
    
    powerPoint = GetEntitiesIsa("PowerPoint")[1]
    assert_not_nil(powerPoint)
    local resetPowerPointLocationName = powerPoint:GetLocationName()
    assert_not_nil(resetPowerPointLocationName)
    
    assert_equal(powerPointLocationName, resetPowerPointLocationName)
    
    GetGamerules():ResetGame()
    
    powerPoint = GetEntitiesIsa("PowerPoint")[1]
    assert_not_nil(powerPoint)
    local resetPowerPointLocationName = powerPoint:GetLocationName()
    assert_not_nil(resetPowerPointLocationName)
    
    assert_equal(powerPointLocationName, resetPowerPointLocationName)

end

function verifyPointsOnKill(attacker, techId, teamNumber, pointValue)

    // Remember score before
    local startScore = attacker:GetScore()
    
    // Create entity and kill it from attacker
    local mapName = LookupTechData(techId, kTechDataMapName)    
    assert_not_nil(mapName, EnumToString(kTechId, techId))
    
    local errorMessage = string.format("verifyPointsOnKill(%s, %d, %d)", mapName, teamNumber, pointValue)    
    local ent = CreateEntity(mapName, Vector(0, 0, 0), teamNumber)
    
    // Check score changed if team is different
    assert_not_nil(ent, errorMessage)
    ent:OnKill(1, attacker, nil, ent:GetOrigin(), nil)
    
    // Only give points to enemies that kill entity
    if attacker:GetTeamNumber() == GetEnemyTeamNumber(ent:GetTeamNumber()) then
        assert_equal(startScore + pointValue, attacker:GetScore(), errorMessage)
    else
        assert_equal(startScore, attacker:GetScore(), errorMessage)
    end
    
end

function testScores()

    for teamNumber = 1, 2 do
    
        verifyPointsOnKill(marinePlayer, kTechId.Marine, teamNumber, kMarinePointValue)
        
        verifyPointsOnKill(marinePlayer, kTechId.Skulk, teamNumber, kSkulkPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.Gorge, teamNumber, kGorgePointValue)
        verifyPointsOnKill(marinePlayer, kTechId.Lerk, teamNumber, kLerkPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.Fade, teamNumber, kFadePointValue)
        verifyPointsOnKill(marinePlayer, kTechId.Onos, teamNumber, kOnosPointValue)
        
        verifyPointsOnKill(marinePlayer, kTechId.Drifter, teamNumber, kDrifterPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.MAC, teamNumber, kMACPointValue)
        
        verifyPointsOnKill(marinePlayer, kTechId.Armory, teamNumber, kArmoryPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.AdvancedArmory, teamNumber, kAdvancedArmoryPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.Sentry, teamNumber, kSentryPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.MASC, teamNumber, kMASCPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.InfantryPortal, teamNumber, kInfantryPortalPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.Observatory, teamNumber, kObservatoryPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.RoboticsFactory, teamNumber, kRoboticsFactoryPointValue)
        
        verifyPointsOnKill(marinePlayer, kTechId.Extractor, teamNumber, kExtractorPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.Harvester, teamNumber, kHarvesterPointValue)        
        
        verifyPointsOnKill(marinePlayer, kTechId.PowerPoint, teamNumber, kPowerPointPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.Hydra, teamNumber, kHydraPointValue)
        
        verifyPointsOnKill(marinePlayer, kTechId.Shift, teamNumber, kShiftPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.MatureShift, teamNumber, kMatureShiftPointValue)
        
        verifyPointsOnKill(marinePlayer, kTechId.Shade, teamNumber, kShadePointValue)
        verifyPointsOnKill(marinePlayer, kTechId.MatureShade, teamNumber, kMatureShadePointValue)
        
        verifyPointsOnKill(marinePlayer, kTechId.Whip, teamNumber, kWhipPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.MatureWhip, teamNumber, kMatureWhipPointValue)
        
        verifyPointsOnKill(marinePlayer, kTechId.Crag, teamNumber, kCragPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.MatureCrag, teamNumber, kMatureCragPointValue)
        
        verifyPointsOnKill(marinePlayer, kTechId.Hive, teamNumber, kHivePointValue)
        verifyPointsOnKill(marinePlayer, kTechId.HiveMass, teamNumber, kHiveMassPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.HiveColony, teamNumber, kHiveColonyPointValue)
        
        verifyPointsOnKill(marinePlayer, kTechId.CommandStation, teamNumber, kCommandStationPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.CommandFacility, teamNumber, kCommandFacilityPointValue)
        verifyPointsOnKill(marinePlayer, kTechId.CommandCenter, teamNumber, kCommandCenterPointValue)

    end
    
end