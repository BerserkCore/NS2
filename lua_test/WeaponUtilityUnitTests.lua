// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// WeaponUtilityUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("MockMagic.lua")
Script.Load("lua/WeaponUtility.lua")
module( "WeaponUtilityUnitTests", package.seeall, lunit.testcase )

function setup()
end

function teardown()
end

function TestWeaponUtilityCalculateSpread()

    local direction = Coords()
    direction.xAxis = Vector(1, 0, 0)
    direction.yAxis = Vector(0, 1, 0)
    direction.zAxis = Vector(0, 0, 1)
    local spreadAmount = math.rad(60)
    local randomizer = function() return 0.5 end
    local spreadDirection = CalculateSpread(direction, spreadAmount, randomizer)
    assert_float_equal(-0.1428, spreadDirection.x)
    assert_float_equal(0, spreadDirection.y)
    assert_float_equal(0.9897, spreadDirection.z)

end