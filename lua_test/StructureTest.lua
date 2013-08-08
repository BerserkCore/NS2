// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// StructureTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "StructureTest", package.seeall, lunit.testcase )

function setup()

    SetPrintEnabled(true, "StructureTest")
    
    GetGamerules():ResetGame()    
    GetGamerules():SetGameStarted()
    RunOneUpdate(10)
    
end

function teardown()    
    Cleanup()    
end

function testIPStart()

    // Make sure structures look up their power points properly
    local powerPoints = GetGamerules():GetEntities("PowerPoint")
    assert_true(table.count(powerPoints) > 0)
    
    local ip = GetGamerules():GetEntities("InfantryPortal")[1]
    assert_not_nil(ip)
    assert_not_nil(ip:GetPowerPoint())

end

// Spawn structure and make sure we have proper data for it
function verifyStructure(techId, teamNumber, checkInitialEnergy, checkMaxEnergy, checkSpawn)

    // Create test string we use as default for LookupTechData so we can see what's failing
    local testString = string.format("verifyStructure(%s, %s)", EnumToString(kTechId, techId), tostring(teamNumber))
        
    // Verify data first
    local buildTime = LookupTechData(techId, kTechDataBuildTime, testString)
    assert_not_equal(testString, buildTime)
    assert_true(buildTime > 0)
    
    local displayName = LookupTechData(techId, kTechDataDisplayName, testString)
    assert_not_equal(testString, displayName)
    
    local mapName = LookupTechData(techId, kTechDataMapName, testString)
    assert_not_equal(testString, mapName)
    
    local modelName = LookupTechData(techId, kTechDataModel, testString)
    assert_not_equal(testString, modelName)

    local cost = LookupTechData(techId, kTechDataCostKey, testString)
    assert_not_equal(testString, cost, testString)
    assert_true(cost > 0, testString)

    local maxHealth = LookupTechData(techId, kTechDataMaxHealth, testString)
    assert_not_equal(testString, maxHealth, testString)
    assert_true(maxHealth > 0)
    
    if checkInitialEnergy then
    
        // Check for initial and max energy, to make sure techdata is set properly
        local initialEnergy = LookupTechData(techId, kTechDataInitialEnergy)
        assert_not_nil(initialEnergy, testString)
        
    end
    
    if checkMaxEnergy then
    
        local maxEnergy = LookupTechData(techId, kTechDataMaxEnergy)
        assert_not_nil(maxEnergy, testString)        
        
    end
    
    // Now build it to make sure it deploys correctly
    local structure = CreateStructure(techId, teamNumber)
    assert_not_nil(structure, testString)    
    assert_equal(structure:GetMapName(), mapName, testString)
    assert_equal(structure:GetModelName(), modelName, testString)
    
    assert_equal(0, structure:GetBuiltFraction(), testString)
    assert_equal(techId, structure:GetTechId(), testString)
    
    if checkSpawn then
        assert_equal(structure:GetSpawnAnimation(), structure:GetAnimation(), testString)
    end

    // Set to built, verify status
    structure:SetConstructionComplete()
    
    local deployAnimation = structure:GetDeployAnimation()
    if deployAnimation ~= "" then
        //assert_equal(deployAnimation, structure:GetAnimation(), testString)
    end
        
    assert_equal(maxHealth, structure:GetHealth(), testString)
    
end

// Build all structures and make sure they deploy and are initialized properly.
function test4()

    // Build all marine and alien structures for each team
    for teamNumber = 1, 2 do
    
        verifyStructure(kTechId.Extractor, teamNumber, false, false, true)
        verifyStructure(kTechId.Armory, teamNumber, false, false, true)
        verifyStructure(kTechId.Sentry, teamNumber, false, false, true)
        verifyStructure(kTechId.CommandStation, teamNumber, true, true, true)
        verifyStructure(kTechId.InfantryPortal, teamNumber, false, false, true)
        verifyStructure(kTechId.Observatory, teamNumber, true, true, true)
        verifyStructure(kTechId.RoboticsFactory, teamNumber, false, false, true)
        
        verifyStructure(kTechId.Harvester, teamNumber, false, false, true)
        
        verifyStructure(kTechId.Crag, teamNumber, true, true, false)
        verifyStructure(kTechId.MatureCrag, teamNumber, false, true, false)
        
        verifyStructure(kTechId.Whip, teamNumber, true, true, false)
        verifyStructure(kTechId.MatureWhip, teamNumber, false, true, false)
        
        verifyStructure(kTechId.Shade, teamNumber, true, true, false)
        verifyStructure(kTechId.MatureShade, teamNumber, false, true, false)
        
        verifyStructure(kTechId.Shift, teamNumber, true, true, false)
        verifyStructure(kTechId.MatureShift, teamNumber, false, true, false)
        
        verifyStructure(kTechId.Hydra, teamNumber, false, false, false)
        verifyStructure(kTechId.Hive, teamNumber, true, true, true)
        verifyStructure(kTechId.Egg, teamNumber, false, false, false)
        verifyStructure(kTechId.Cocoon, teamNumber, false, false, false)
        
    end
    
end

function verifyAutoBuild(techId, teamNumber, shouldAutoBuildHeal)

    local testString = string.format("verifyStructure (%d, %d, %s) (%s)", techId, teamNumber, tostring(shouldAutoBuildHeal), LookupTechData(techId, kTechDataDisplayName))
    
    local structure = CreateStructure(techId, teamNumber)
    assert_not_nil(structure, testString)    
    
    local buildTime = LookupTechData(techId, kTechDataBuildTime)
    assert_not_nil(buildTime, testString)
    assert_true(buildTime > 0, testString)
    
    assert_equal(0, structure:GetBuiltFraction(), testString)
    
    // Not sure why the timing is off here slightly for the harvester but it surely has to do with the testbed and server frame-rate, don't care
    RunUpdate(buildTime + AlienTeam.kAutoBuildHealInterval + 1)
    assert_equal(shouldAutoBuildHeal, structure:GetIsBuilt(), testString)
    
    RunUpdate(3)
    assert_equal(shouldAutoBuildHeal, structure:GetIsBuilt(), testString)
    
    // Apply damage to it
    local kDamage = 50
    local woundedHealth = structure:GetHealth() - kDamage
    structure:SetHealth(woundedHealth)
    assert_equal(structure:GetHealth(), woundedHealth, testString)
    
    local energy = structure:GetEnergy()
    local maxEnergy = structure:GetMaxEnergy()
    
    local maxHealth = LookupTechData(techId, kTechDataMaxHealth)
    assert_true(maxHealth > 0)
  
    // AlienTeam.kAutoHealRate per second
    local seconds = 2.0
    for index = 1, 2 do
    
        if shouldAutoBuildHeal then
            structure:GetTeam():PerformAutoBuildHeal()
        end
        
        if structure:isa("Crag") then
            structure:PerformHealing()
        end
        
        structure:UpdateEnergy(1)
        
    end
    
    // Make sure energy is coming back
    if maxEnergy ~= 0 then
        assert_float_equal(energy + seconds*kEnergyUpdateRate, structure:GetEnergy(), testString)
    end
    
    if shouldAutoBuildHeal then
    
        // Crags also heal themselves, so allow for him to heal self if that's what we're testing
        local cragAmount = ConditionalValue(structure:isa("Crag"), Crag.kHealAmount, 0)
        //Print("%.2f, %.2f, %.2f, %.2f", woundedHealth, seconds, AlienTeam.kAutoHealRate + cragAmount, maxHealth)
        assert_float_equal(math.min(woundedHealth + seconds * (AlienTeam.kAutoHealRate + cragAmount), maxHealth), structure:GetHealth(), testString)
        
    else
        assert_float_equal(structure:GetHealth(), woundedHealth, testString)
    end
    
    // Destroy structure now so crags don't interfere with later tests 
    DestroyEntity(structure)
    RunUpdate(.1)
    
end

// Make sure alien structures auto-build and auto-heal and marine structures don't.
function test5()

    verifyAutoBuild(kTechId.Whip, 2, true)
    //verifyAutoBuild(kTechId.Shade, 2, true)
    verifyAutoBuild(kTechId.Shift, 2, true) 
    verifyAutoBuild(kTechId.Harvester, 2, true)
    
    // Create some marine structures and make sure they don't   
    verifyAutoBuild(kTechId.Extractor, 1, false)   

    // Do crag last so it doesn't heal other structures
    verifyAutoBuild(kTechId.Crag, 2, true)
    
    verifyAutoBuild(kTechId.Hydra, 2, true)
    
end

function verifyPartialBuildHealth(techId, teamNumber)

    local debugString = LookupTechData(techId, kTechDataDisplayName, testString)
    
    local structure = CreateStructure(techId, teamNumber)
    assert_not_nil(structure)    

    local maxHealth = LookupTechData(techId, kTechDataMaxHealth)
    assert_true(maxHealth > 0, debugString)
    assert_equal(maxHealth * Structure.kStartHealthScalar, structure:GetHealth(), debugString)
    
    local buildTime = LookupTechData(techId, kTechDataBuildTime)
    
    assert_true(structure:Construct(buildTime/2), debugString)
    assert_float_equal(maxHealth * (Structure.kStartHealthScalar + (1 - Structure.kStartHealthScalar)/2), structure:GetHealth(), debugString)

    assert_true(structure:Construct(buildTime/4), debugString)
    assert_float_equal(maxHealth * (Structure.kStartHealthScalar + (1 - Structure.kStartHealthScalar)*.75), structure:GetHealth(), debugString)

    assert_true(structure:Construct(buildTime/4), debugString)
    assert_true(structure:GetIsBuilt(), debugString)
    assert_float_equal(maxHealth, structure:GetHealth(), debugString)

end

// Make sure partially built structures gain health properly
function test6()

    for teamNum = 1, 2 do
    
        verifyPartialBuildHealth(kTechId.Armory, teamNum)
        verifyPartialBuildHealth(kTechId.Hive, teamNum)
        verifyPartialBuildHealth(kTechId.Extractor, teamNum)
        verifyPartialBuildHealth(kTechId.Crag, teamNum)
        verifyPartialBuildHealth(kTechId.Harvester, teamNum)
        verifyPartialBuildHealth(kTechId.CommandStation, teamNum)
        
    end
    
end

function verifyStructureUpgrade(startId, upgradeId, finalId, testEnergy)

    local errorMessage = string.format("verifyStructureUpgrade(%s, %s, %s, %s)", EnumToString(kTechId, startId), EnumToString(kTechId, upgradeId), EnumToString(kTechId, finalId), ToString(testEnergy))
    local structure = CreateStructure(startId, 2, true)
    assert_not_nil(structure)
    
    local healthScalar = .4
    local startHealth = structure:GetHealth()
    
    local energyScalar = .7
    local startEnergy = structure:GetEnergy()
    
    structure:SetHealth( structure:GetMaxHealth() * healthScalar )
    structure:SetEnergy( structure:GetMaxEnergy() * energyScalar )
    
    assert_true(structure:OnResearchComplete(structure, upgradeId), errorMessage)
    
    assert_equal(finalId, structure:GetTechId(), errorMessage)
    
    assert_not_equal(structure:GetHealth(), startHealth, errorMessage)
    
    assert_float_equal(structure:GetHealth(), LookupTechData(finalId, kTechDataMaxHealth) * healthScalar, errorMessage)
    
    if testEnergy then
        assert_float_equal(structure:GetEnergy(), LookupTechData(finalId, kTechDataMaxEnergy) * energyScalar, errorMessage)
    end
    
end

function test7()

    // Test alien structures and their upgrades
    verifyStructureUpgrade(kTechId.Crag, kTechId.UpgradeCrag, kTechId.MatureCrag, true)
    verifyStructureUpgrade(kTechId.Whip, kTechId.UpgradeWhip, kTechId.MatureWhip, true)
    verifyStructureUpgrade(kTechId.Shift, kTechId.UpgradeShift, kTechId.MatureShift, true)
    verifyStructureUpgrade(kTechId.Shade, kTechId.UpgradeShade, kTechId.MatureShade, true)
    
    // Marine structures
    verifyStructureUpgrade(kTechId.Armory, kTechId.AdvancedArmoryUpgrade, kTechId.AdvancedArmory, false)
       
end

// Test upgrading of structures
function testCommandStationUpgrade()

    local commandStation = CreateStructure(kTechId.CommandStation, 1, true)
    assert_float_equal(kCommandStationHealth, commandStation:GetHealth())
    
    assert_true(commandStation:OnResearchComplete(commandStation, kTechId.CommandFacilityUpgrade))
    assert_equal(kTechId.CommandFacility, commandStation:GetTechId())
    assert_float_equal(kCommandFacilityHealth, commandStation:GetHealth())

    assert_true(commandStation:OnResearchComplete(commandStation, kTechId.CommandCenterUpgrade))
    assert_equal(kTechId.CommandCenter, commandStation:GetTechId())
    assert_float_equal(kCommandCenterHealth, commandStation:GetHealth())

end

function testHiveUpgrade()

    local hive = CreateStructure(kTechId.Hive, 1, true)
    assert_float_equal(kHiveHealth, hive:GetHealth())
    
    assert_true(hive:OnResearchComplete(hive, kTechId.HiveMassUpgrade))
    assert_equal(kTechId.HiveMass, hive:GetTechId())
    assert_float_equal(kHiveMassHealth, hive:GetHealth())

    assert_true(hive:OnResearchComplete(hive, kTechId.HiveColonyUpgrade))
    assert_equal(kTechId.HiveColony, hive:GetTechId())
    assert_float_equal(kHiveColonyHealth, hive:GetHealth())

end

function testArmories()

    local techTree = GetGamerules():GetTeam1():GetTechTree()
    techTree:ComputeAvailability()
    
    local armoryUpgradeNode = techTree:GetTechNode(kTechId.AdvancedArmoryUpgrade)
    assert_false(armoryUpgradeNode.available)
    
    // Create IP
    local ip = CreateStructure(kTechId.InfantryPortal, 1, true)
    assert_not_nil(ip)    
    techTree:ComputeAvailability()
    assert_false(armoryUpgradeNode.available)
    
    // Create second command station and upgrade original
    local commandStation2 = CreateStructure(kTechId.CommandStation, 1, true)
    assert_not_nil(commandStation2)
    commandStation2:OnResearchComplete(commandStation2, kTechId.CommandFacilityUpgrade)
    techTree:ComputeAvailability()
    assert_true(armoryUpgradeNode.available)

    local armory = CreateStructure(kTechId.Armory, 1, true)
    assert_equal(kTechId.Armory, armory:GetTechId())
    
    // Make sure we can upgrade to advanced armory
    local buttons = armory:GetTechButtons(kTechId.RootMenu)
    assert_not_nil(table.find(buttons, kTechId.AdvancedArmoryUpgrade))
    assert_nil(table.find(buttons, kTechId.PrototypeModule))    
    assert_nil(table.find(buttons, kTechId.WeaponsModule))    
    
    // It's an upgrade, so even after one armory upgraded, the tech is still available (for other armories)
    techTree:ComputeAvailability()
    assert_true(armoryUpgradeNode.available)
    
    armory:OnResearchComplete(armory, kTechId.AdvancedArmoryUpgrade)
    assert_equal(kTechId.AdvancedArmory, armory:GetTechId())
    assert_true(armoryUpgradeNode.available)
    
    buttons = armory:GetTechButtons(kTechId.RootMenu)
    assert_nil(table.find(buttons, kTechId.AdvancedArmoryUpgrade))
    assert_not_nil(table.find(buttons, kTechId.PrototypeModule))    
    assert_not_nil(table.find(buttons, kTechId.WeaponsModule))    
    
    techTree:ComputeAvailability()
    assert_true(armoryUpgradeNode.available)
    
    local secondArmory = CreateStructure(kTechId.Armory, 1, true)
    buttons = secondArmory:GetTechButtons(kTechId.RootMenu)
    assert_not_nil(table.find(buttons, kTechId.AdvancedArmoryUpgrade))
    assert_nil(table.find(buttons, kTechId.PrototypeModule))    
    assert_nil(table.find(buttons, kTechId.WeaponsModule))    
    
    techTree:ComputeAvailability()
    assert_true(armoryUpgradeNode.available)
    
end

function testArmoryResupply()

    local marinePlayer = InitializeMarine(true)

    // Create armory, put player nearby
    local armory = CreateStructure(kTechId.Armory, 1, true)
    armory:SetOrigin(kMarineBaseOrigin)
    armory:SetConstructionComplete()

    // Move player just out of healing distance and hurt him
    marinePlayer:SetOrigin(Vector(kMarineBaseOrigin.x - Armory.kResupplyUseRange - 1, kMarineBaseOrigin.y, kMarineBaseOrigin.z))
    
    // Make sure not healed
    
    // Put player nearby, facing away 
    marinePlayer:SetOrigin(Vector(kMarineBaseOrigin.x - Armory.kResupplyUseRange, kMarineBaseOrigin.y, kMarineBaseOrigin.z))    
    
    // Shouldn't be healed
    
    // Now face armory, should be healed    

end

function testGetIsUpgradeTech()

    local marine = InitializeMarine(true)
    local techTree = marine:GetTechTree()
    assert_not_nil(techTree)
    
    techTree:ComputeAvailability()
    
    assert_true(GetTechUpgradesFromTech(kTechId.CommandFacility, kTechId.CommandStation), "1")
    assert_true(GetTechUpgradesFromTech(kTechId.CommandCenter, kTechId.CommandFacility), "2")
    assert_true(GetTechUpgradesFromTech(kTechId.CommandCenter, kTechId.CommandStation), "3")
    assert_false(GetTechUpgradesFromTech(kTechId.CommandCenter, kTechId.Hive), "4")
    assert_false(GetTechUpgradesFromTech(kTechId.CommandStation, kTechId.CommandFacility), "5")
    assert_false(GetTechUpgradesFromTech(kTechId.Armory, kTechId.CommandFacility), "6")
    
    assert_false(GetTechUpgradesFromTech(kTechId.Hive, kTechId.CommandStation), "7")
    assert_true(GetTechUpgradesFromTech(kTechId.HiveMass, kTechId.Hive), "8")
    assert_true(GetTechUpgradesFromTech(kTechId.HiveColony, kTechId.HiveMass), "9")
    assert_true(GetTechUpgradesFromTech(kTechId.HiveColony, kTechId.Hive), "10")
    assert_false(GetTechUpgradesFromTech(kTechId.HiveColony, kTechId.CommandStation), "11")

    local ids = techTree:ComputeUpgradedTechIdsSupportingId(kTechId.CommandStation)
    assert_equal(2, table.count(ids))
    
    local ents = GetEntsWithTechId({kTechId.CommandStation})
    assert_equal(1, table.count(ents))
    
end

function testAttachRange()

    // IPs can only be built within a certain range of command stations
    local commandStations = GetEntitiesIsa("CommandStation")
    assert(table.count(commandStations) == 1)    
    local commandStation = commandStations[1]
    assert_not_nil(commandStation)
    
    local marine = InitializeMarine(true)
    local inRangePoint = commandStation:GetOrigin() + Vector(0, 0, kInfantryPortalAttachRange - .01)
    local outOfRangePoint = commandStation:GetOrigin() + Vector(0, 0, kInfantryPortalAttachRange + .01)

    local trace = Trace()
    trace:Clear()
    trace.entity = nil
    local snapRadius = 1
    
    assert_true(GetIsBuildLegal(kTechId.InfantryPortal, inRangePoint, snapRadius, marine), "1")
    
    assert_false(GetIsBuildLegal(kTechId.InfantryPortal, outOfRangePoint, snapRadius, marine), "2")
    
    // Upgrade to command facility and make sure it still counts
    commandStation:Upgrade(kTechId.CommandFacility)
    assert_true(GetIsBuildLegal(kTechId.InfantryPortal, inRangePoint, snapRadius, marine), "3")
    
    assert_false(GetIsBuildLegal(kTechId.InfantryPortal, outOfRangePoint, snapRadius, marine), "4")

end

function testSentry()

    // Create enemy sentry and enemy and make sure it targets it and hurts it
    local sentry = CreateStructure(kTechId.Sentry, 2, false)
    assert_not_nil(sentry)
    
    local extractor = GetEntitiesIsa("Extractor")[1]
    assert_not_nil(extractor)
    
    local sentryOrigin = Vector(extractor:GetOrigin()) + Vector(3, 0, 0)
    sentry:SetOrigin(sentryOrigin)
    
    // Aim towards extractore
    local sentryAngles = GetNormalizedVector(extractor:GetOrigin() - sentryOrigin)
    sentryAngles.pitch = 0
    sentryAngles.roll = 0
    SetAnglesFromVector(sentry, sentryAngles)
    
    RunUpdate(3)
    assert_nil(sentry:GetTarget())
    
    // Make sure power points power sentry 
    for index, powerPoint in ipairs(GetEntitiesIsa("PowerPoint")) do
        powerPoint:SetTeamNumber(2)
    end
    
    sentry:SetConstructionComplete()
    assert_true(sentry:GetIsActive())
    RunUpdate(5)

    assert_not_nil(sentry:GetTarget())
    assert_equal(extractor:GetId(), sentry:GetTarget():GetId())
    
    RunUpdate(4)
    assert_true(extractor:GetMaxHealth() > extractor:GetHealth())
    
    // Re-orient sentry and make sure it doesn't fire and then does fire
    local commandStation = GetEntitiesIsa("CommandStation")[1]
    assert_not_nil(commandStation)

    local lastHealth = extractor:GetHealth()
    
    sentry:GiveOrder(kTechId.SetTarget, commandStation:GetId())
    RunUpdate(.6)
    
    sentry:GiveOrder( kTechId.Attack, extractor:GetId() )
    RunUpdate(10)
    assert_not_nil(sentry:GetTarget())
    assert_equal(extractor:GetId(), sentry:GetTarget():GetId())    
    
    // It should start firing again
    assert_true(extractor:GetHealth() < lastHealth)
    
end

function testIPFunction()

    // Make sure IP is powered
    local ip = GetEntitiesIsa("InfantryPortal")[1]
    assert_not_nil(ip)
    
    assert_true(ip:GetIsPowered())
    assert_true(ip:GetIsActive())
    assert_true(ip:GetIsBuilt())
    
    // Kill all nodes, make sure it's not powered
    local powerPoints = GetEntitiesIsa("PowerPoint")
    for index, powerPoint in ipairs(powerPoints) do
        powerPoint:OnKill()
    end

    assert_false(ip:GetIsPowered())
    assert_false(ip:GetIsActive())
    
    // Restore nodes, make sure it's powered
    for index, powerPoint in ipairs(powerPoints) do
        powerPoint:OnConstructionComplete()
    end

    assert_true(ip:GetIsPowered())
    assert_true(ip:GetIsActive())
    
end

function testTechPoint()

    // Make sure orientation of tech points and hives match up
    local techPoints = GetEntitiesIsa("TechPoint")
    local teamIndex = 0
    
    for index, techPoint in ipairs( techPoints ) do
    
        if not techPoint:GetAttached() then
            techPoint:SpawnCommandStructure(teamIndex + 1)
        end
        
        // Alternate between command stations and hives
        teamIndex = (teamIndex + 1) % 2
        
        local attached = techPoint:GetAttached()
        assert_not_nil(attached)
        assert_true(attached:isa("CommandStructure"))
        
        local attachedAngles = attached:GetAngles()
        local techPointAngles = techPoint:GetAngles()
        
        assert_equal(techPointAngles.yaw, attachedAngles.yaw)
        assert_equal(techPointAngles.pitch, attachedAngles.pitch)
        assert_equal(techPointAngles.roll, attachedAngles.roll)
        
    end
    
    assert_not_nil(techPoints)
    assert_true(table.count(techPoints) > 0)
    
end

/*function testTooManyUnits()

    // Count command station, tech points, power nodes, etc. Number 12 dictated
    // by map so may change if map changes.
    local kLoopFail = 17
        
    local marinePlayer = InitializeMarine(true)
    marinePlayer:SetResources( 1000 )
    
    // Get command station
    local commandStations = GetEntitiesIsa("CommandStation")
    assert(table.count(commandStations) == 1)    
    local commandStation = commandStations[1]
    assert_not_nil(commandStation)

    // Build lots of sentries in an outward spiral, until we hit limit
    local numIllegals = 0
    for i = 1, kMaxEntitiesInRadius do
    
        local angle = (i / 10.0) * math.pi*2
        local dist = 4 + i / 3
        local startPoint = commandStation:GetOrigin() + Vector( math.cos(angle)*dist, .1, math.sin(angle)*dist )

        // Illegal when we hit max. 
        local shouldBeLegal = ConditionalValue(i > kLoopFail, false, true)
        local isLegal = GetIsBuildLegal(kTechId.Sentry, startPoint, nil, marinePlayer, true)
        
        assert_equal(shouldBeLegal, isLegal, string.format("%s# %d", "loop", i))
        
        if shouldBeLegal then
        
            local sentry = CreateEntity(Sentry.kMapName, startPoint, 1)
            assert_not_nil(sentry)

        else 
            numIllegals = numIllegals + 1
        end
        
    end    
    
    assert_equal(kMaxEntitiesInRadius - kLoopFail + 1, numIllegals)

end*/

function testNoBuildOnEntity()

    // Create mac, try to build on it
    local marinePlayer = InitializeMarine(true)
    local commandStation = GetEntitiesIsa("CommandStation")[1]
    
    local macOrigin = commandStation:GetOrigin() + Vector(2, 0, 2)
    local mac = CreateEntity(MAC.kMapName, macOrigin, 1)
    assert_not_nil(mac)
 
    // Try to build an IP on top of him
    //for i = 1, 5 do
        //local ipOrigin = macOrigin + Vector(0, .5, 0) * i
        //assert_false(GetIsBuildLegal(kTechId.InfantryPortal, ipOrigin, nil, marinePlayer))
        //assert_false(GetIsBuildLegal(kTechId.InfantryPortal, Vector(macOrigin.x, macOrigin.y + i * .5, macOrigin.z), nil, marinePlayer))
    //end
    
    // Try to build in air
    
    // Build on ground nearby
    //assert_true(GetIsBuildLegal(kTechId.InfantryPortal, commandStation:GetOrigin() + Vector(3, 0, 3), nil, marinePlayer) )
    
end

