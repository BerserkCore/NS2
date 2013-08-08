// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// LoopingSoundMixin.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("MockGamerules.lua")
Script.Load("MockMagic.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/LoopingSoundMixin.lua")

module( "LoopingSoundMixin", package.seeall, lunit.testcase )

class 'LoopingSoundTestClass' (Entity)
LoopingSoundTestClass.networkVars = { }

local testClass = nil
local mockPlayer = nil
local mockShared = nil
local loopingSoundName = "sound/test"
Entity.invalidId = -1
local kMockPlayer1Id = 10
local kMockPlayer2Id = kMockPlayer1Id + 1

// Required by LoopingSoundMixin
function LoopingSoundTestClass:OnStopLoopingSound()
end

function setup()

    mockPlayer = CreateMockPlayerEntity()
    mockPlayer:AddFunction("GetId"):SetReturnValues( { kMockPlayer1Id } )
    
    mockShared = MockShared()
    mockShared:AddFunction("PlaySound")    
    mockShared:AddFunction("StopSound")   
    mockShared:AddFunction("GetEntity"):SetReturnValues( { mockPlayer } )
    
    testClass = LoopingSoundTestClass()
    InitMixin(testClass, LoopingSoundMixin)    
    
end

function teardown()

end

function testPlay()

    assert_equal(Entity.invalidId, testClass:GetLoopingEntityId())
    
    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)
    
    assert(testClass:GetIsLoopingSoundPlaying())
    
    assert_equal(1, mockShared:GetFunction("PlaySound"):GetCallCount())
    
    assert_equal(kMockPlayer1Id, testClass:GetLoopingEntityId())
    
    
end

function testStop()

    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)
    
    testClass:StopLoopingSound()    
    
    assert_equal(1, mockShared:GetFunction("StopSound"):GetCallCount())
    
end

function testStopOnDestroy()

    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)
    
    testClass:OnDestroy()
    
    assert_false(testClass:GetIsLoopingSoundPlaying())

end

function testMultipleStartsSamePlayer()

    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)

    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)
    
    assert_equal(1, mockShared:GetFunction("PlaySound"):GetCallCount())

end

function testMultipleStartsDifferentPlayer()

    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)

    local mockPlayer2 = CreateMockPlayerEntity()
    mockPlayer:AddFunction("GetId"):SetReturnValues( { kMockPlayer2Id } )
    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)
    
    assert_equal(1, mockShared:GetFunction("StopSound"):GetCallCount())
    assert_equal(2, mockShared:GetFunction("PlaySound"):GetCallCount())

end

function testMultipleStops()

    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)

    testClass:StopLoopingSound()
    testClass:StopLoopingSound()
    
    assert_equal(1, mockShared:GetFunction("StopSound"):GetCallCount())

end

function testStopOnEntChange()

    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)
    
    // Do nothing
    testClass:OnEntityChange(kMockPlayer2Id, kMockPlayer1Id)
    assert_true(testClass:GetIsLoopingSoundPlaying())
    
    // Stop sound
    testClass:OnEntityChange(kMockPlayer1Id, kMockPlayer2Id)
    assert_false(testClass:GetIsLoopingSoundPlaying())
    
end

function testReplayAfterDestroy()

    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)
    testClass:OnDestroy()
    testClass:PlayLoopingSound(mockPlayer, loopingSoundName)
    assert_equal(2, mockShared:GetFunction("PlaySound"):GetCallCount())

end