// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//
// SignalMixinsUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("TestInclude.lua")
Script.Load("MockEntity.lua")
Script.Load("MockMagic.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/Mixins/SignalEmitterMixin.lua")
Script.Load("lua/Mixins/SignalListenerMixin.lua")
module( "SignalMixinsUnitTests", package.seeall, lunit.testcase )

local emitterEntity = nil
local listenerEntity = nil

function setup()

    emitterEntity = CreateMockEntity()
    InitMixin(emitterEntity, SignalEmitterMixin)
    
    listenerEntity = CreateMockEntity()
    InitMixin(listenerEntity, SignalListenerMixin)
    
end

function TestEmitSignal()

    listenerEntity:RegisterSignalListener(function(self, message) self.messageReceived = message end)
    
    emitterEntity:EmitSignal(0, "Hello")
    
    assert_equal("Hello", listenerEntity.messageReceived)
    
end

function TestListenForMessage()

    listenerEntity:RegisterSignalListener(function(self, message) self.messageReceived = message end, "Specific Message")
    
    emitterEntity:EmitSignal(0, "Different Message")
    
    assert_equal(nil, listenerEntity.messageReceived)
    
    emitterEntity:EmitSignal(0, "Specific Message")
    
    assert_equal("Specific Message", listenerEntity.messageReceived)
    
end

function TestSetSignalRange()

    assert_error(function() emitterEntity:SetSignalRange("really far!") end)
    assert_error(function() emitterEntity:SetSignalRange(-5) end)
    assert_not_error(function() emitterEntity:SetSignalRange(5) end)
    assert_equal(5, emitterEntity:GetSignalRange())
    
end

function TestEmitSignalTooFar()

    listenerEntity:SetOrigin(Vector(10, 0, 0))
    listenerEntity:RegisterSignalListener(function(self, message) self.messageReceived = message end)
    
    emitterEntity:SetSignalRange(9)
    emitterEntity:EmitSignal(0, "Hello")
    
    assert_equal(nil, listenerEntity.messageReceived)
    
end

function TestChannels()

    assert_equal(0, listenerEntity:GetListenChannel())
    assert_error(function() listenerEntity:SetListenChannel("two") end)
    assert_error(function() listenerEntity:SetListenChannel(-1) end)
    assert_not_error(function() listenerEntity:SetListenChannel(2) end)
    assert_equal(2, listenerEntity:GetListenChannel())
    
    listenerEntity:RegisterSignalListener(function(self, message) self.messageReceived = message end)
    
    emitterEntity:EmitSignal(0, "Hello")
    
    assert_equal(nil, listenerEntity.messageReceived)
    
    emitterEntity:EmitSignal(2, "Hello")
    
    assert_equal("Hello", listenerEntity.messageReceived)
    
end