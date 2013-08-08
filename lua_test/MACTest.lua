// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MACTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "MACTest", package.seeall, lunit.testcase )

local mac = nil

function setup()

    SetPrintEnabled(true, "MACTest")

    GetGamerules():ResetGame()
    
    RunUpdate(.1)

    mac = CreateEntity(MAC.kMapName, nil, 1)
    
    mac:SetPathingEnabled(false)
    
    RunOneUpdate(5)
        
end

function teardown()
    Cleanup()
    mac = nil
end

function test1()

    assert_equal(MAC.kModelName, mac:GetModelName())
    
    assert_equal(MAC.kHealth, mac:GetHealth())
    assert_equal(MAC.kHealth, mac:GetMaxHealth())
    
    assert_equal(MAC.kArmor, mac:GetArmor())
    assert_equal(MAC.kArmor, mac:GetMaxArmor())
    
end

// Create MAC and give it a right click order to the nearest door
// Make sure it's turned into a weld order and eventually welds it shut
function testWelding()

    local doors = GetEntitiesIsa("Door")
    assert(table.count(doors) > 0)
    
    local door = doors[1]
    assert_not_nil(door)
    assert_equal(Door.kState.Closed, door:GetState())
    
    // Oopen door
    door:SetState(Door.kState.Open, nil)

    local doorOrigin = door:GetOrigin()
    local startOrigin = doorOrigin + Vector(MAC.kWeldDistance * 2, 0, 0)
    mac:SetOrigin(startOrigin)
    
    local order = CreateOrder(kTechId.Default, door:GetId(), door:GetOrigin(), nil)
    mac:OverrideOrder(order)
    
    assert_equal(kTechId.Weld, order:GetType())
    mac:SetOrder(order)
    
    // MAC starts welding when he gets MAC.kWeldDistance away from target origin
    // Not exact because of how OnThink() works. 
    
    // Move until we get in range to weld
    while (mac:GetOrigin() - doorOrigin):GetLength() > MAC.kWeldDistance do
        RunUpdate(.1)
    end
       
    // Make sure MAC closes door before welding
    assert_equal(Door.kState.Close, door:GetState())
    RunUpdate(1.0)
    assert_equal(Door.kState.Closed, door:GetState())
    
    local weldTime = door:GetWeldTime()
    RunUpdate(weldTime + 1)
    
    assert_equal(Door.kState.Welded, door:GetState())
    
    local canBeWeldedNow, canBeWeldedFuture = door:GetCanBeWelded()
    assert_false(canBeWeldedNow)
    assert_false(canBeWeldedFuture)
    
end

function testRepair()

    // Wound team structure, make sure MAC repairs it with a right-click and with a repair order
    local extractor = GetEntitiesIsa("Extractor", 1)[1]
    assert_not_nil(extractor)
    
    assert_equal(extractor:GetMaxHealth(), extractor:GetHealth())
    local damage = 1000
    extractor:SetHealth(extractor:GetMaxHealth() - 1000)
    assert_equal(extractor:GetMaxHealth() - damage, extractor:GetHealth())
    
    assert_false(mac:GetHasOrder())

    local preRepairHealth = extractor:GetHealth()    
    
    mac:GiveOrder(kTechId.Default, extractor:GetId(), extractor:GetOrigin())
    assert_equal(kTechId.Weld, mac:GetCurrentOrder():GetType())
    assert_true(mac:GetHasOrder())
    
    RunUpdate(9)
    
    assert_not_equal(extractor:GetHealth(), preRepairHealth)

    mac:GiveOrder(kTechId.Weld, extractor:GetId(), extractor:GetOrigin())    
    assert_equal(kTechId.Weld, mac:GetCurrentOrder():GetType())
    assert_true(mac:GetHasOrder())
    
    RunUpdate(20)
    
    assert_equal(extractor:GetHealth(), extractor:GetMaxHealth())    
    assert_false(mac:GetHasOrder())
        
end

function testAttack()

    // Attack harvester
    local harvester = GetEntitiesIsa("Harvester", 2)[1]
    assert_not_nil(harvester)
    assert_equal(harvester:GetHealth(), harvester:GetMaxHealth())    

    mac:GiveOrder(kTechId.Default, harvester:GetId(), harvester:GetOrigin())
    assert_true(mac:GetHasOrder())
    assert_equal(kTechId.Attack, mac:GetCurrentOrder():GetType())
    
    RunUpdate(20)
    assert_not_equal(harvester:GetHealth(), harvester:GetMaxHealth())    
    
end

function weldOrderTest()

    local powerNode = GetEntitiesIsa("PowerPoint")[1]
    assert_not_nil(powerNode)

    // Fully healed power node default order is move to    
    mac:GiveOrder(kTechId.Default, powerNode:GetId(), powerNode:GetOrigin())
    assert_true(mac:GetHasOrder())
    assert_equal(kTechId.Move, mac:GetCurrentOrder():GetType())

    // Wound power node and make sure default order is to weld it
    powerNode:SetHealth(powerNode:GetHealth() - 10)    
    mac:GiveOrder(kTechId.Default, powerNode:GetId(), powerNode:GetOrigin())
    assert_true(mac:GetHasOrder())
    assert_equal(kTechId.Weld, mac:GetCurrentOrder():GetType())
    
    // Now kill power point and make sure we can repair
    powerNode:TakeDamage(10000)
    assert_false(powerNode:GetIsPowered())
    
    mac:GiveOrder(kTechId.Default, powerNode:GetId(), powerNode:GetOrigin())
    assert_true(mac:GetHasOrder())
    assert_equal(kTechId.Weld, mac:GetCurrentOrder():GetType())    
    
    assert_equal(GetOrderTargetIsWeldTarget(mac:GetCurrentOrder(), mac:GetTeamNumber()), powerNode)
    
    // Make sure power node welding actually works
    local startHealth = powerNode:GetHealth()
    RunUpdate(6)
    assert_true(powerNode:GetHealth() > startHealth)
    
end

// Make sure MACs build properly
/*function testBuild()

    // Give order to build an armory
    assert_equal(0, table.count(GetEntitiesIsa("Armory", 1)))
    local position = Vector(GetEntitiesIsa("CommandStation")[1]:GetOrigin()) + Vector(2, 0, 0)
    
    mac:GiveOrder(kTechId.Build, kTechId.Armory, position)
    
    RunUpdate(10)
    
    assert_equal(1, table.count(GetEntitiesIsa("Armory", 1)))
    
    assert_true(GetEntitiesIsa("Armory", 1)[1]:GetIsBuilt())
    
end
*/

function testEngagementDistance()

    local distance, success = GetEngagementDistance(kTechId.CommandStation, true)
    assert_true(success)
    assert_equal(kCommandStationEngagementDistance, distance)

    distance, success = GetEngagementDistance(kTechId.InfantryPortal, true)
    assert_true(success)
    assert_equal(kInfantryPortalEngagementDistance, distance)

    distance, success = GetEngagementDistance(kTechId.Marine, true)
    assert_true(success)
    assert_equal(kPlayerEngagementDistance, distance)
    
    local extractors = GetEntitiesIsa("Extractor") 
    assert_not_nil(extractors[1])
    distance, success = GetEngagementDistance(extractors[1]:GetId())
    assert_true(success)
    assert_equal(kExtractorEngagementDistance, distance)
    
    local commStations = GetEntitiesIsa("CommandStation") 
    assert_not_nil(commStations[1])
    distance, success = GetEngagementDistance(commStations[1]:GetId())
    assert_true(success)
    assert_equal(kCommandStationEngagementDistance, distance)
    
end
