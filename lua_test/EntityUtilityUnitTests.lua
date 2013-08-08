// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// EntityUtilityUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/Entity.lua")
module( "EntityUtilityUnitTests", package.seeall, lunit.testcase )

local testEntity = nil
local children = nil

// Tests begin.
function setup()

    testEntity = CreateMockEntity()
    children = { CreateMockEntity(), CreateMockEntity(), CreateMockEntity() }
    
    testEntity:AddFunction("GetNumChildren"):AddCall(function() return #children end)
    testEntity:AddFunction("GetChildAtIndex"):AddCall(function(entity, index) return children[index + 1] end)
    
end

function teardown()
end

function TestGetEyePos()

    local mockEntity = CreateMockEntity()
    
    mockEntity.origin = Vector(1, -12, 3.4)
    assert_equal(Vector(1, -12, 3.4), GetEntityEyePos(mockEntity))
    
    mockEntity:AddFunction("GetEyePos"):SetReturnValues({ Vector(1, -10, 3.4) })
    assert_equal(Vector(1, -10, 3.4), GetEntityEyePos(mockEntity))
    
end

function TestGetViewAngles()

    local mockEntity = CreateMockEntity()
    
    mockEntity.angles = Angles(0, math.pi, math.pi / 2)
    assert_equal(Angles(0, math.pi, math.pi / 2), GetEntityViewAngles(mockEntity))
    
    mockEntity:AddFunction("GetViewAngles"):SetReturnValues({ Angles(math.pi / 4, 0, 0) })
    assert_equal(Angles(math.pi / 4, 0, 0), GetEntityViewAngles(mockEntity))
    
end

function TestForEachChildOfType()

    local childrenIterated = { }
    local function TestCallback(child) table.insert(childrenIterated, child) end
    
    ForEachChildOfType(testEntity, "NoChildrenType", TestCallback)
    
    assert_equal(0, #childrenIterated)
    
    ForEachChildOfType(testEntity, "Entity", TestCallback)
    
    assert_equal(3, #childrenIterated)
    assert_equal(children[1], childrenIterated[1])
    assert_equal(children[2], childrenIterated[2])
    assert_equal(children[3], childrenIterated[3])
    
    childrenIterated = { }
    
    ForEachChildOfType(testEntity, nil, TestCallback)
    
    assert_equal(3, #childrenIterated)
    assert_equal(children[1], childrenIterated[1])
    assert_equal(children[2], childrenIterated[2])
    assert_equal(children[3], childrenIterated[3])

end

function TestIterateEntityChildren()

    local childrenIterated = { }
    for i, child in ientitychildren(testEntity) do
        table.insert(childrenIterated, child)
    end
    
    assert_equal(3, #childrenIterated)
    assert_equal(children[1], childrenIterated[1])
    assert_equal(children[2], childrenIterated[2])
    assert_equal(children[3], childrenIterated[3])

end

function TestIterateEntityChildrenOfClass()

    SetMockType(children[1], "Godzilla")
    SetMockType(children[2], "KingKong")
    SetMockType(children[3], "Godzilla")
    table.insert(children, CreateMockEntity())
    SetMockType(children[4], "TurtleMonster")
    
    local childrenIterated = { }
    for i, child in ientitychildren(testEntity, "Godzilla") do
        table.insert(childrenIterated, child)
    end
    
    assert_equal(2, #childrenIterated)
    assert_equal(children[1], childrenIterated[1])
    assert_equal(children[3], childrenIterated[2])
    
    childrenIterated = { }
    for i, child in ientitychildren(testEntity, "Entity") do
        table.insert(childrenIterated, child)
    end
    
    assert_equal(4, #childrenIterated)
    assert_equal(children[1], childrenIterated[1])
    assert_equal(children[2], childrenIterated[2])
    assert_equal(children[3], childrenIterated[3])
    assert_equal(children[4], childrenIterated[4])

end