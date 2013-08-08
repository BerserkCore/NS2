// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// VectorTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
Script.Load("lua/Vector.lua")
module( "VectorUnitTests", package.seeall, lunit.testcase )

local v0
local v1

function setup()
    v0 = Vector(10, 20, 30)
    v1 = Vector(2, 3, 4)
end

function teardown()
end

// vector addition
function test1()

    local v = v0 + v1
    
    assert_equal(v.x, 12)
    assert_equal(v.y, 23)
    assert_equal(v.z, 34)
    
    assert_equal(Vector(12, 23, 34), v)
    assert_not_equal(Vector(11, 23, 34), v)
    assert_not_equal(Vector(12, 22, 34), v)
    assert_not_equal(Vector(12, 23, 33), v)
    
end

// vector multiplication
function test2()

    local v = v0 * 2
    
    assert_equal(v.x, 20)
    assert_equal(v.y, 40)
    assert_equal(v.z, 60)
    
end

// operator ==
function test3()
    
    local v1 = Vector(10, 20, 30)
    local v2 = Vector(10, 20, 30)
    
    assert(v1 == v2)
    
end



// Test vector functions
function test5()

    local v1 = Vector(1, 0, 0)
    assert(v1:GetLength() == 1)
    
    local v2 = Vector(-1, 0, 0)
    assert(v2:GetLength() == 1)
    
    local v3 = Vector(-2, 5, 7)
    assert(math.abs(v3:GetLengthSquared() - 78) < kEpsilon)
    assert(math.abs(v3:GetLength() - 8.83176) < kEpsilon)
    
    local unit = v3:GetUnit()
    assert(math.abs(unit:GetLength() - 1) < kEpsilon)
    
end

function test6()

    local v1 = Vector(1, 0, 0)
    local v2 = Vector(0, 1, 0)
    
    assert_equal(0, v1:GetProjection(v2):GetLength())
    
    local v3 = Vector(1, 1, 0)
    local results = v3:GetProjection(v1)
    assert_equal(v1, results)
    
    results = v1:GetProjection(v3)
    assert_equal(v3, results)
    
end
