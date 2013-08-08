// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TeamTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "TeamTest", package.seeall, lunit.testcase )

local marinePlayer = nil

function setup()
    SetPrintEnabled(true, "TeamTest")
    GetGamerules():ResetGame()
    marinePlayer = InitializeMarine()    
end

function teardown()   
    Cleanup()
    marinePlayer = nil
end

function test1()

    assert_equal(1, GetGamerules():GetTeam1():GetNumPlayers())
    
    assert_equal(kTeam1Index, marinePlayer:GetTeamNumber())
    
    assert_equal(0, GetGamerules():GetWorldTeam():GetNumPlayers())
    
    assert_equal(0, GetGamerules():GetTeam2():GetNumPlayers())
    
end

// Make sure ip created for marine
function test2()

    local alienPlayer = InitializeAlien()
    RunOneUpdate(10)
    
    local ips = GetEntitiesIsa("InfantryPortal", marinePlayer:GetTeamNumber())
    assert_not_nil(ips)
    assert_true(table.count(ips) == 1)
    
    local ip = ips[1]
    assert_not_nil(ip)
    assert_true(ip:GetIsBuilt())
    
    local commandStation = GetEntitiesIsa("CommandStation", -1)[1]
    assert_not_nil(commandStation)    
    local distFromStart = (commandStation:GetOrigin() - ip:GetOrigin()):GetLengthXZ()
    
    assert_true(distFromStart >= kInfantryPortalMinSpawnDistance)
    assert_true(distFromStart <= kInfantryPortalBuildDistance)
    
end

/*function testSpecialAlerts()

    local alienPlayer = InitializeAlien()
    RunOneUpdate(10)

    local alienTeam = alienPlayer:GetTeam()
    local alertName, alertTime = alienTeam:GetLastAlert()
    assert_nil(alertName, ToString(alertName))
    assert_nil(alertTime)
    
    // Test hive wound
    local hive = GetEntitiesIsa("Hive", -1)[1]
    assert_not_nil(hive)
    
    local maxHealth = LookupTechData(kTechId.Hive, kTechDataMaxHealth)
    assert(maxHealth > 0)
    
    hive:TakeDamage(maxHealth * (1 - Hive.kHiveDyingThreshold) - 1)
    
    alertName, alertTime = alienTeam:GetLastAlert()
    assert_not_nil(alertName)
    assert_not_nil(alertTime)
    assert_equal(Hive.kUnderAttackSound, alertName)
    assert_float_equal(Shared.GetTime(), alertTime)
    
    // Test hive dying sound 
    RunOneUpdate(PlayingTeam.kBaseAlertInterval + .2)
    hive:SetHealth( Hive.kHiveDyingThreshold * maxHealth - 1)
    hive:TakeDamage(maxHealth * (1 - Hive.kHiveDyingThreshold) - 1)
    
    alertName, alertTime = alienTeam:GetLastAlert()
    assert_not_nil(alertName)
    assert_not_nil(alertTime)
    assert_equal(Hive.kDyingSound, alertName)
    assert_float_equal(Shared.GetTime(), alertTime)

end*/

function testDeathMessage()

    local team = GetGamerules():GetTeam1()
    local commandStation = GetEntitiesIsa("CommandStation")[1]
    assert_not_nil(commandStation)
    
    local rifle = GetChildEntities(marinePlayer, "Rifle")[1]
    assert_not_nil(rifle)
    
    local pistol = GetChildEntities(marinePlayer, "Pistol")[1]
    assert_not_nil(pistol)
    
    local rifleIconIndex = rifle:GetDeathIconIndex()
    local pistolIconIndex = pistol:GetDeathIconIndex()
    
    // Rifle command station
    local deathMsg = string.format("deathmsg %d %d %d %d %d %d %d", 1, marinePlayer:GetId(), 1, rifleIconIndex, 0, kTechId.CommandStation, 1)
    assert_equal(team:GetDeathMessage(marinePlayer, rifleIconIndex, commandStation), deathMsg)
    
    // Rifle self
    deathMsg = string.format("deathmsg %d %d %d %d %d %d %d", 1, marinePlayer:GetId(), 1, rifleIconIndex, 1, marinePlayer:GetId(), 1)
    assert_equal(team:GetDeathMessage(marinePlayer, rifleIconIndex, marinePlayer), deathMsg)

    local hive = GetEntitiesIsa("Hive")[1]
    assert_not_nil(hive)

    // Pistol hive
    deathMsg = string.format("deathmsg %d %d %d %d %d %d %d", 1, marinePlayer:GetId(), 1, pistolIconIndex, 0, kTechId.Hive, 2)
    assert_equal(team:GetDeathMessage(marinePlayer, pistolIconIndex, hive), deathMsg)

    // Kill self
    deathMsg = string.format("deathmsg %d %d %d %d %d %d %d", 1, marinePlayer:GetId(), 1, 1, 1, marinePlayer:GetId(), 1)
    local returnedDeathMessage = team:GetDeathMessage(marinePlayer, 1, marinePlayer)
    assert_equal(returnedDeathMessage, deathMsg)
    
end
