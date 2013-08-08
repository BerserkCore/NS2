// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// PowerPointTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "PowerPointTest", package.seeall, lunit.testcase )

// Reset game and put one player on each team
function setup()

    SetPrintEnabled(true, "PowerPointTest")

    RunUpdate(.1)
       
    GetGamerules():ResetGame()
    
    GetGamerules():SetGameStarted()
    
    RunUpdate(.1)
    
end

function teardown()
    Cleanup()
end

function verifyPoweredStructure(techId)

    local errorMsg = EnumToString(kTechId, techId)
    
    // Build structure within range power point
    local powerPoints = GetEntitiesIsa("PowerPoint")
    assert_true(table.count(powerPoints) > 0, errorMsg)
    
    local powerPoint = powerPoints[1]
    assert_not_nil(powerPoint, errorMsg)
    assert_equal(powerPoint:GetClassName(), "PowerPoint", errorMsg)
    
    // Make sure it starts at full health
    assert_float_equal(PowerPoint.kHealth, powerPoint:GetHealth())
    assert_float_equal(1.0, powerPoint:GetBuiltFraction())
    
    local mac = CreateEntity(MAC.kMapName, Vector(0, 0, 0), 1)
    assert_not_nil(mac)
    
    local order = CreateOrder(kTechId.Default, powerPoint:GetId(), nil, nil)
    mac:OverrideOrder(order)
    assert_equal(kTechId.Move, order:GetType())
    
    local structure1 = CreateStructure(kTechId.InfantryPortal, 1, true)
    assert_not_nil(structure1, errorMsg)
    structure1:SetOrigin(powerPoint:GetOrigin() + Vector(2, 0, 0))
    assert_not_equal(structure1:GetLocationName(), "")
    
    structure1:SetConstructionComplete()
    assert_true(structure1:GetIsBuilt())
    assert_true(structure1:GetIsActive(), errorMsg)   
    
    // Destroy power node and make sure structure stops working
    powerPoint:OnKill()
    powerPoint.health = 0
    
    assert_false(structure1:GetIsActive(), errorMsg)
    
    // Build new structure near dead power node, make sure it's not active by default
    local structure2 = CreateStructure(kTechId.InfantryPortal, 1, true)
    assert_not_nil(structure2, errorMsg)
    structure2:SetOrigin(powerPoint:GetOrigin() + Vector(0, 0, 2))
    
    structure2:SetConstructionComplete()
    assert_false(structure2:GetIsActive(), errorMsg)   
    
    // Test order giving to node
    local order2 = CreateOrder(kTechId.Default, powerPoint:GetId(), nil, nil)
    mac:OverrideOrder(order2)
    assert_not_equal(kTechId.None, order2:GetType())
    assert_equal(kTechId.Weld, order2:GetType())
    
    mac:SetOrder(order2, false, false)
    
    // Have MAC repair power node
    RunUpdate(40)

    assert_true(powerPoint:GetHealth() > 0)    
    assert_true(powerPoint:GetIsPowered())
    
    // Make sure both structures are functioning
    assert_true(structure1:GetIsActive(), errorMsg)   
    assert_true(structure2:GetIsActive(), errorMsg)   
    
    // Make sure power node has proper values
    local healthPercentage = powerPoint:GetHealthScalar()
    assert_float_equal(1, healthPercentage)
    
end

function testPower()

    verifyPoweredStructure(kTechId.InfantryPortal)
    verifyPoweredStructure(kTechId.Extractor)
    verifyPoweredStructure(kTechId.Harvester)
    
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

end
