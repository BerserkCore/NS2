// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TableUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/Utility.lua")
module( "UtilityUnitTests", package.seeall, lunit.testcase )

function setup()
end

function teardown()
end

function TestCopy()

    assert_equal(nil, Copy(nil))
    assert_equal("A String", Copy("A String"))
    local testTable = { "Value", Apple = "Red", 12, true }
    local copiedTestTable = Copy(testTable)
    // Equivalent.
    assert(table.getIsEquivalent(testTable, copiedTestTable))
    // But not the same table (not the same address).
    assert_not_equal(testTable, copiedTestTable)
    assert_equal(true, Copy(true))
    assert_equal(false, Copy(false))
    assert_equal(15, Copy(15))
    local numberVar = 3.14
    assert_equal(3.14, Copy(numberVar))
    local testFunction = function () return true end
    assert_equal(testFunction, Copy(testFunction))

end

function TestStringTrim()

    assert_equal("Hello", StringTrim("Hello"))
    assert_equal("Hello", StringTrim(" Hello"))
    assert_equal("Hello", StringTrim("Hello "))
    assert_equal("Hello", StringTrim("  Hello  "))
    
    assert_equal("Hello World", StringTrim("Hello World"))
    assert_equal("Hello World", StringTrim(" Hello World"))
    assert_equal("Hello World", StringTrim("Hello World "))
    assert_equal("Hello World", StringTrim("  Hello World  "))

end

function TestMathScaleDown()

    assert_equal(30, math.scaledown(30, 1000, 1000))
    assert_equal(30, math.scaledown(30, 5000, 1000))
    assert_equal(15, math.scaledown(30, 1000, 2000))

end

function TestMathRound()

    assert_equal(1, math.round(1, 0))
    assert_equal(101.1, math.round(101.11, 1))
    assert_equal(100, math.round(100.499, 0))
    assert_equal(101, math.round(100.5, 0))
    assert_equal(100.5, math.round(100.499, 2))

end

function TestMathPercentf()

    assert_equal(10, math.percentf(50, 20))
    assert_equal(75, math.percentf(75, 100))
    assert_equal(0.5, math.percentf(25, 2))
    assert_equal(-20, math.percentf(50, -40))

end

function TestColorValue()

    assert_equal(0, ColorValue(0))
    assert_equal(0.5, math.round(ColorValue(128), 1))
    assert_equal(1, ColorValue(255))

end

function TestAlphaValue()

    assert_equal(0, AlphaValue(0))
    assert_equal(0.5, AlphaValue(50))
    assert_equal(1, AlphaValue(100))

end

function TestGetAnglesDifference()

    assert_equal(0, GetAnglesDifference(0, 0))
    assert_equal(0, GetAnglesDifference(0, 4 * math.pi))
    assert_float_equal(0.1, GetAnglesDifference(0, 2 * math.pi + 0.1))
    assert_float_equal(math.pi - 0.1, GetAnglesDifference(0, math.pi - 0.1))
    assert_equal(-0.7, GetAnglesDifference(0, -0.7))
    
end

function TestTrimName()

    // Leading and trailing whitespace is removed and double
    // quote characters " are replaced with single quote characters '
    assert_equal("Murphy", TrimName("  \"Murphy\""))
    assert_equal("First Nick Last", TrimName("First \"Nick\" Last"))
    assert_equal("Murphy     Name ", TrimName("\"\"\"Murphy     Name \"\"\""))

end

function TestRadianDifference()

    assert_equal(1, RadianDiff(3, 2))
    assert_equal(-1, RadianDiff(0, 1))
    assert_equal(0, RadianDiff(0, math.pi * 2))
    assert_equal(-math.pi, RadianDiff(-math.pi * 2, -math.pi))
    assert_equal(1, RadianDiff(1, math.pi * 2))

end