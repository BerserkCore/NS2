// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// CommandStructureTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "CommandStructureTest", package.seeall, lunit.testcase )

// Create a command station and hive as part of map load/reset
function setup()
    SetPrintEnabled(true, "CommandStructureTest")
    GetGamerules():ResetGame()    
    RunOneUpdate(.1)
end

function teardown()
    Cleanup()
end

// Can't use the word "test" or lunit will call it manually
function tryCommandStructure(structure, tier2UpgradeTechId, resultingTechId)

    local techTree = structure:GetTeam():GetTechTree()
    
    // Make sure it starts at level 1
    assert_equal(1, structure:GetLevel())
    
    local tech1 = structure:GetLevelTechId(1)
    local tech2 = structure:GetLevelTechId(2)
    local tech3 = structure:GetLevelTechId(3)
    
    // Make sure it can't be upgraded to level 2 or level 3
    local buttons = structure:GetTechButtons(kTechId.RootMenu)
    
    assert_nil(table.find(buttons, tech1))
    assert_not_nil(table.find(buttons, tech2))
    assert_nil(table.find(buttons, tech3))
    
    // We need another command station before we can upgrade
    assert_equal(false, techTree:GetTechSupported(tech2))
    
    // Make sure it can be upgraded to level 2 only
    buttons = structure:GetTechButtons(kTechId.RootMenu)
    
    assert_nil(table.find(buttons, tech1))
    assert_not_nil(table.find(buttons, tech2))
    assert_nil(table.find(buttons, tech3))
    
    // Upgrade it to a level 2 and have it finish right away
    local level1Health = structure:GetHealth()
    local level1MaxHealth = structure:GetMaxHealth()
    
    structure:OnResearchComplete(structure, tier2UpgradeTechId)
    
    // Make sure it is level 2 now
    assert_equal(resultingTechId, structure:GetTechId())
    
    buttons = structure:GetTechButtons(kTechId.RootMenu)
    
    assert_nil(table.find(buttons, tech1))
    assert_nil(table.find(buttons, tech2))
    
    assert_not_nil(table.find(buttons, tech3))
    
    // Make sure hitpoints have increased
    local level2Health = structure:GetHealth()
    local level2MaxHealth = structure:GetMaxHealth()

    assert_true(level2Health > level1Health)
    assert_true(level2MaxHealth > level1MaxHealth)
    
end

function test1()

    local commandStation = GetEntitiesIsa("CommandStructure", kTeam1Index)[1]
    assert_not_equal(nil, commandStation)    
    assert_true(commandStation:isa("CommandStation"))
    
    tryCommandStructure(commandStation, kTechId.CommandFacilityUpgrade, kTechId.CommandFacility)
    
    local hive = GetEntitiesIsa("CommandStructure", kTeam2Index)[1]
    assert_not_equal(nil, hive)
    assert_true(hive:isa("Hive"))    
    
    tryCommandStructure(hive, kTechId.HiveMassUpgrade, kTechId.HiveMass)
    
end

// Verify TwoHives tech and TwoCommandStations tech not supportive until spawned
function trySpecialTech(team, techId1, techId2)

    local techTree = team:GetTechTree()
    assert_equal(false, techTree:GetTechSupported(techId1))
    assert_equal(false, techTree:GetTechSupported(techId2))
    
    assert_not_nil(team.teamLocation)
    assert_true(team:SpawnCommandStructure(team.teamLocation))
    techTree:ComputeAvailability()
    
    assert_equal(true, techTree:GetTechSupported(techId1))
    assert_equal(false, techTree:GetTechSupported(techId2))

    assert_true(team:SpawnCommandStructure(team.teamLocation))
    techTree:ComputeAvailability()
    
    assert_equal(true, techTree:GetTechSupported(techId1))
    assert_equal(true, techTree:GetTechSupported(techId2))

end

function test2()
    trySpecialTech(GetGamerules():GetTeam1(), kTechId.TwoCommandStations, kTechId.ThreeCommandStations)
end

function test3()    
    trySpecialTech(GetGamerules():GetTeam2(), kTechId.TwoHives, kTechId.ThreeHives)
end

function tryCommandStructurePeons(player, commandStructureClassName, teamNumber, peonClassName, numPeons)

    // Make sure there are no MACs/Drifters at game start, and that they appear after player logs in for the first time
    local commandStructure = GetEntitiesIsa(commandStructureClassName, teamNumber)[1]
    assert_not_equal(nil, commandStructure)    

    assert_equal(0, table.count(GetEntitiesIsa(peonClassName)))
    
    player:SetOrigin(commandStructure:GetOrigin() + Vector(0, 1, 0))
    commandStructure:OnUse(player, .1, true)
    commandStructure:UpdateCommanderLogin(true)
    
    local ents = GetEntitiesIsa(peonClassName)
    assert_equal(numPeons, table.count(ents), peonClassName .. " => " .. table.tostring(ents))
    
    // Logout then log back in
    player = commandStructure:Logout()
    
    commandStructure:OnUse(player, .1, true)
    commandStructure:UpdateCommanderLogin(true)
    
    assert_equal(numPeons, table.count(GetEntitiesIsa(peonClassName)))

end

function testPeons()

    tryCommandStructurePeons(InitializeMarine(), "CommandStation", 1, "MAC", kInitialMACs)
    tryCommandStructurePeons(InitializeAlien(), "Hive", 2, "Drifter", kInitialDrifters)

end
