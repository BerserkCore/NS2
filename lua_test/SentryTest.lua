// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// SentryTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "SentryTest", package.seeall, lunit.testcase )

// Reset game and put one player on each team
function setup()

    SetPrintEnabled(true, "SentryTest")
    
    GetGamerules():ResetGame()
    RunUpdate(1)
    
end

function teardown()
    Cleanup()
end

function createSentryAndCrag(sentryOrigin, cragOrigin)

    local sentry = CreateStructure(kTechId.Sentry, 1, true)
    assert_not_nil(sentry)
    sentry:SetOrigin(sentryOrigin)    
    assert_not_equal(sentry:GetId(), Entity.invalidId)
    
    local crag = CreateStructure(kTechId.Crag, 2, true)
    crag:SetOrigin(cragOrigin)
    assert_not_equal(crag:GetId(), Entity.invalidId)
    
    local direction = GetNormalizedVector(crag:GetEngagementPoint() - sentry:GetModelOrigin())
    SetAnglesFromVector(sentry, direction)

    assert_true(sentry:GetIsPowered())
    assert_true(sentry:GetIsBuilt())    
    
    return sentry, crag

end

function testDualTargeting()

    local commandStation = GetEntitiesIsa("CommandStation", kTeam1Index)[1]
    assert_not_nil(commandStation)

    // Create sentry and crag and make sure sentry targets it
    local sentry, crag = createSentryAndCrag(commandStation:GetOrigin() + Vector(-2, 0, 0), commandStation:GetOrigin() + Vector(-2, 0, 2))
    assert_false(sentry:GetHasTarget())
    RunUpdate(5)
    assert_true(sentry:GetHasTarget())
    assert_equal(sentry:GetTarget():GetId(), crag:GetId())
    
    // Make sure sentry is aiming towards center of crag
    sentry:OnThink()
    local targetDirection = sentry:GetTargetDirection()
    assert_not_nil(targetDirection)
    
    local toCragCenter = GetNormalizedVector(crag:GetEngagementPoint() - sentry:GetAttachPointOrigin(Sentry.kMuzzleNode))
    local dot = targetDirection:DotProduct(toCragCenter)
    assert_float_equal(1, dot)
    
    // Now create another sentry and crag and make sure they don't interfere targeting in any way
    local sentry2, crag2 = createSentryAndCrag(commandStation:GetOrigin() + Vector(2, 0, 0), commandStation:GetOrigin() + Vector(2, 0, 2))
    assert_false(sentry2:GetHasTarget())
    RunUpdate(5)
    assert_true(sentry2:GetHasTarget())  
    assert_equal(sentry2:GetTarget():GetId(), crag2:GetId())
    
end

