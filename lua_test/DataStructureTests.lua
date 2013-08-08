// ========= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// DataStructureTests.lua
//
//    Created by:   Marc Delorme (marc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com ==========================

Script.Load("TestInclude.lua")
Script.Load("lua/DataStructure.lua")
module( "DataStructureTests", package.seeall, lunit.testcase )



// Before each test
function setup()

end

// After each test
function teardown()

end

function TestStack()

    local stack = NewStack()
    local uselessFunc = function () return 0 end
    
    stack:Push("Paris") // 'Paris'
    stack:Push("San Francisco") // 'Paris', 'San Francisco'
    
    assert_equal("San Francisco",stack:Head()) // 'Paris', 'San Francisco'
    assert_equal("San Francisco",stack:Pop()) // 'Paris'

    stack:Push(uselessFunc) // 'Paris', uselessFunc

    assert_equal(uselessFunc, stack:Pop()) // 'Paris'
    assert_equal("Paris", stack:Pop()) // empty
    
    assert_equal(#stack, 0)
    
end