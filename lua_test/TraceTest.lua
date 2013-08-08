// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TraceTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "TraceTest", package.seeall, lunit.testcase )

Script.Load("UtilityTest.lua")

function setup()
    SetPrintEnabled(true, "TraceTest")
    GetGamerules():ResetGame()
    RunOneUpdate(1)
end

function teardown()   
    Cleanup()
end

function testTrace()

    local hive = GetEntitiesIsa("Hive")[1]
    assert_not_nil(hive)
    
    local endPoint = Vector(hive:GetOrigin())
    local startPoint = endPoint - Vector(8, 2, 8)
    
    // Create fake entity to filter with as we have to pass an entity filter
    local drifter = CreateEntity(Drifter.kMapName)
    
    // Make sure we hit the hive.
    local trace = Shared.TraceRay(startPoint, endPoint, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOne(drifter))
    assert_equal(hive, trace.entity)
    assert_float_not_equal(1, trace.fraction)
    
    // Test filtering out a marine.
    local marine = InitializeMarine()
    marine:RemoveChildren()
    RunOneUpdate(.5)
    
    trace = Shared.TraceRay(startPoint, endPoint, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOne(marine))
    assert_not_nil(trace.entity)
    assert_equal(hive, trace.entity)
    assert_float_not_equal(1, trace.fraction)

    // Make sure tracing "through" the entity works
    // Kill drifters spawning near hive first to make sure they're not hit
    local drifters = GetEntitiesIsa("Drifter")
    for index, drifter in ipairs(drifters) do 
        DestroyEntity(drifter)
    end
    
    trace = Shared.TraceRay(startPoint, endPoint, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(hive, marine))
    assert_nil(trace.entity)
    assert_float_equal(1, trace.fraction)
    
    // Test with marine player
    endPoint = Vector(marine:GetOrigin())
    startPoint = endPoint + Vector(0, 5, 0)
    
    trace = Shared.TraceRay(startPoint, endPoint, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOne(hive))
    assert_not_nil(trace.entity)
    assert_equal(marine, trace.entity)
    assert_float_not_equal(1, trace.fraction)
    
end

// Make sure trace to power point returns proper normal
function testPowerNodeTrace()

    local marine = InitializeMarine()

    // Get nearest power node
    local powerPoint = nil
    local nearestDistance = nil
    for index, node in ipairs(GetEntitiesIsa("PowerPoint")) do
    
        local dist = (node:GetOrigin() - marine:GetOrigin()):GetLength()
        if not nearestDistance or (dist < nearestDistance) then
            powerPoint = node
            nearestDistance = dist
        end
        
    end

    assert_not_nil(powerPoint)
    marine:SetOrigin(powerPoint:GetOrigin() + Vector(0, 5, 0))
    
    local pickVec = GetNormalizedVector(marine:GetEyePos() - powerPoint:GetModelOrigin())
    local trace = GetCommanderPickTarget(marine, pickVec, false, false)
    
    local dotProduct = trace.normal:DotProduct(Vector(0, 1, 0))
    assert_true(dotProduct > 0)
    
    //assert_true(GetIsBuildPickVecLegal(kTechId.Default, marine, pickVec, nil))
    
end

// Gorge hydra type trace

// Skulk wall walking type test
function testTraceBox()

end
        


