// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//
// TimedEmitterUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("TestInclude.lua")
Script.Load("MockMagic.lua")
Script.Load("MockEntity.lua")
Script.Load("MockShared.lua")
Script.Load("MockServer.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/Mixins/SignalListenerMixin.lua")
module( "TimedEmitterUnitTests", package.seeall, lunit.testcase )

local timedEmitter = nil
local mockListener = nil

function setup()

    MockShared()
    MockServer()
    
    Script.Load("lua/TimedEmitter.lua", true)
    
    timedEmitter = Server.CreateEntity(TimedEmitter.kMapName)
    
    timedEmitter:SetEmitTime(1)
    timedEmitter:SetEmitOnce(true)
    timedEmitter:SetEmitChannel(42)
    timedEmitter:SetEmitMessage("Hello")
    timedEmitter:SetSignalRange(5)
    
    mockListener = CreateMockEntity()
    InitMixin(mockListener, SignalListenerMixin)
    mockListener:SetOrigin(Vector(4, 0, 0))
    mockListener:RegisterSignalListener(function(self, message) self.messageReceived = message end, "Hello")
    mockListener:SetListenChannel(42)
    
end

function TestSetEmitTime()

    assert_error(function() timedEmitter:SetEmitTime("soon") end)
    assert_error(function() timedEmitter:SetEmitTime(-10) end)
    assert_not_error(function() timedEmitter:SetEmitTime(5) end)
    
end

function TestEmitOnce()

    timedEmitter:OnUpdate(0.5)
    
    assert_equal(nil, mockListener.messageReceived)
    
    timedEmitter:OnUpdate(0.6)
    
    assert_equal("Hello", mockListener.messageReceived)
    mockListener.messageReceived = nil
    
    timedEmitter:OnUpdate(1.2)
    
    // It should have only emitted once.
    assert_equal(nil, mockListener.messageReceived)
    
end

function TestEmitContinuously()

    timedEmitter:SetEmitOnce(false)
    
    timedEmitter:OnUpdate(0.5)
    
    assert_equal(nil, mockListener.messageReceived)
    
    timedEmitter:OnUpdate(0.6)
    
    assert_equal("Hello", mockListener.messageReceived)
    mockListener.messageReceived = nil
    
    timedEmitter:OnUpdate(1.2)
    
    assert_equal("Hello", mockListener.messageReceived)
    mockListener.messageReceived = nil
    
    timedEmitter:OnUpdate(0.3)
    
    // Not enough time has passed yet
    assert_equal(nil, mockListener.messageReceived)
    
    timedEmitter:OnUpdate(0.6)
    
    assert_equal("Hello", mockListener.messageReceived)
    
end