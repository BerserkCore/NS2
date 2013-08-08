// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TechTreeUnitTests.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("MockMagic.lua")
Script.Load("MockShared.lua")
Script.Load("MockGamerules.lua")
Script.Load("MockTechTree.lua")
Script.Load("lua/TechNode.lua")
Script.Load("lua/TechTree.lua")
Script.Load("lua/TechTree_Server.lua")

module( "TechTreeUnitTests", package.seeall, lunit.testcase )

local gTechTree = TechTree()

// Tests begin.
function setup()

    MockServer()    
    MockMagic.CreateGlobalMock("LookupTechData"):GetFunction():SetReturnValues({0})
    MockMagic.CreateGlobalMock("GetEntitiesForTeam"):GetFunction():SetReturnValues({{}}) // Return empty table
    CreateMockGamerules()
    
    MockTechType()
    MockTechId()
    
    gTechTree:Initialize()
    
    // Set up basic tech tree
    gTechTree:AddBuildNode(kTechId.Armory, kTechId.None, kTechId.None)
    gTechTree:AddBuildNode(kTechId.ArmsLab, kTechId.Armory, kTechId.None)  
    gTechTree:AddResearchNode(kTechId.Armor1, kTechId.ArmsLab, kTechId.None)
    gTechTree:ComputeAvailability()
    
end

function teardown()
end

function GetTechNode(id)
    return gTechTree:GetTechNode(id)
end

function SetHasTech(id, state)

    local techNode = GetTechNode(id)
    assert_not_nil(techNode)
    
    techNode:SetHasTech(state)
    
    gTechTree:ComputeAvailability()
    
end

function testNoPrereqResearch()

    local armor1Node = GetTechNode(kTechId.Armor1)
    assert_not_nil(armor1Node)
    assert_false(armor1Node:GetAvailable())
    
end

function testNotAvailable()
    assert_false(gTechTree:GetTechAvailable(kTechId.Armor1))
end

function testAvailable()

    SetHasTech(kTechId.Armory, true)
    assert_false(gTechTree:GetTechAvailable(kTechId.Armor1))
    
    SetHasTech(kTechId.ArmsLab, true)
    assert_true(gTechTree:GetTechAvailable(kTechId.Armor1))
    
end

function testUnsupported()

    SetHasTech(kTechId.Armory, true)
    SetHasTech(kTechId.ArmsLab, true)
    SetHasTech(kTechId.ArmsLab, false)
    assert_false(gTechTree:GetTechAvailable(kTechId.Armor1))
    
end

function testAvailableWithStructures()

    assert_false(gTechTree:GetTechAvailable(kTechId.ArmsLab))
    
    gTechTree:Update({kTechId.Armory}, true)
    
    assert_true(gTechTree:GetTechAvailable(kTechId.ArmsLab))
    
end

function testAvailableWithResearch()

    gTechTree:Update({kTechId.Armory, kTechId.ArmsLab}, true)
    
    local techNode = GetTechNode(kTechId.Armor1)
    assert_false(gTechTree:GetHasTech())
    
    techNode:SetResearched(true)    
    
    gTechTree:Update({kTechId.Armory, kTechId.ArmsLab}, true)    
    assert_true(gTechTree:GetHasTech(kTechId.Armor1))
    
    assert_false(gTechTree:GetTechAvailable(kTechId.Armor1))
    
end

function testNonActiveAfterLostSupport()

    local techNode = GetTechNode(kTechId.Armor1)
    techNode:SetResearched(true)   
    
    gTechTree:Update({kTechId.Armory, kTechId.ArmsLab}, true)    
    assert_true(gTechTree:GetHasTech(kTechId.Armor1))
    
    // Power goes out or building destroyed
    gTechTree:Update({kTechId.Armory}, true)    
    assert_false(gTechTree:GetHasTech(kTechId.Armor1))
    
end

function testMultipleDependentResearch()

    gTechTree:AddResearchNode(kTechId.Armor2, kTechId.Armor1, kTechId.None)
    
    local armor1 = GetTechNode(kTechId.Armor1)
    armor1:SetResearched(true)
    
    local armor2 = GetTechNode(kTechId.Armor2)
    armor2:SetResearched(true)
    
    gTechTree:Update({kTechId.ArmsLab, kTechId.Armory}, true)    
    assert_true(gTechTree:GetHasTech(kTechId.Armor1))
    assert_true(gTechTree:GetHasTech(kTechId.Armor2))
    
    gTechTree:Update({kTechId.Armory}, true)    
    assert_false(gTechTree:GetHasTech(kTechId.Armor1))
    assert_false(gTechTree:GetHasTech(kTechId.Armor2))
    
end