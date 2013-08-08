// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// BitwiseTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "BitwiseUnitTests", package.seeall, lunit.testcase )

function setup()
end

function teardown()
end

// Logical Or
function test1()

    assert_equal( bit.bor(1, 2), 3 )
    
end

// Logical And
function test2()

    assert_equal( bit.band(2, 2), 2)
    assert_equal( bit.band(3, 2), 2)
    assert_equal( bit.band(4, 2), 0)
    
end

// Bit shifting
function test3()

    assert_equal( bit.lshift(1, 2), 4)
    assert_equal( bit.rshift(5, 2), 1)
    
end