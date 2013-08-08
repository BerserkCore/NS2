// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//
// OrderUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("MockEntity.lua")
Script.Load("MockShared.lua")
Script.Load("MockServer.lua")
Script.Load("MockTechTree.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
module( "OrderUnitTests", package.seeall, lunit.testcase )

function setup()

    MockShared()
    MockServer()
    MockTechId()
    Script.Load("lua/Order.lua", true)
    
end

function TestOnEntityChange()

    local testOrder = Server.CreateEntity(Order.kMapName)
    
    testOrder:Initialize(kTechId.Move, 101)
    
    testOrder:OnEntityChange(101, 99)
    
    assert_equal(99, testOrder:GetParam())
    
    testOrder:OnEntityChange(99, nil)
    
    assert_equal(Entity.invalidId, testOrder:GetParam())
    
end

function TestOnEntityChangeIgnoredOnBuild()

    local testOrder = Server.CreateEntity(Order.kMapName)
    
    testOrder:Initialize(kTechId.Build, 101)
    
    testOrder:OnEntityChange(101, nil)
    
    assert_equal(101, testOrder:GetParam())
    
end