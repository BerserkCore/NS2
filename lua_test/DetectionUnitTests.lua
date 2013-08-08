// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// DetectionUnitTests.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockMagic.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/DetectorMixin.lua")

module( "DetectionUnitTests", package.seeall, lunit.testcase )

local detector = nil
local detectable = nil

function createDetector()

    local detector = CreateMockEntity()
    
    detector:AddFunction("GetTeamNumber"):AddCall(function() return 1 end)
    detector:AddFunction("GetDetectionRange"):AddCall(function() return 10 end)
    detector:AddFunction("GetOrigin"):AddCall(function() return Vector(0, 0, 0) end)

    InitMixin(detector, DetectorMixin)

    return detector
    
end

function createDetectable()

    local detectable = CreateMockEntity()
    
    detectable:AddFunction("OnDetectedChange"):AddCall(function(param) end)
    detectable:AddFunction("GetTeamNumber"):AddCall(function() return 2 end)
    detectable:AddFunction("GetOrigin"):AddCall(function() return Vector(0, 0, 0) end)
    detectable:AddFunction("SetCoords")
    
    InitMixin(detectable, DetectableMixin)

    return detectable
    
end

function setup()

    MockMagic.CreateGlobalMock("Event"):AddFunction("Hook")
    MockServer()
    Script.Load("lua/DetectableMixin.lua", true)
    
    detector = createDetector()
    detectable = createDetectable()
    
    MockMagic.CreateGlobalMock("GetEnemyTeamNumber"):GetFunction():AddCall(function(team) return (team == 1 and 2) or 1 end)
    MockMagic.CreateGlobalMock("GetEntitiesWithMixinForTeamWithinRange"):GetFunction():AddCall(
        function(mixin, teamNumber, origin, range)
            return { detectable }
        end)
    
end

function TestInitiallyUndetected()
    assert_false(detectable:GetIsDetected())
end

function TestDetectionExpire()

    // Set detected
    detectable:SetDetected(true)
    
    detectable:OnUpdate(DetectableMixin.kResetDetectionInterval - .01)
    assert_true(detectable:GetIsDetected())
    
    detectable:OnUpdate(.01)
    assert_false(detectable:GetIsDetected())
    
end

function TestDetectInRange()

    detectable:AddFunction("GetOrigin"):AddCall(function() return Vector(0, 0, 9) end)    
    
    detector:OnUpdate(DetectorMixin.kUpdateDetectionInterval - .1)
    assert_false(detectable:GetIsDetected())
    
    detector:OnUpdate(.1)
    assert_true(detectable:GetIsDetected())
    
end

function TestDetectedParameters()

    detectable:AddFunction("GetOrigin"):AddCall(function() return Vector(0, 0, 9) end)    
    
    detector:OnUpdate(DetectorMixin.kUpdateDetectionInterval)
    
    assert_equal(1, table.count(detectable:GetFunction("OnDetectedChange"):GetCallHistory()))
    assert_equal(2, table.count(detectable:GetFunction("OnDetectedChange"):GetCallHistory()[1].passedParameters))
    assert_equal(true, detectable:GetFunction("OnDetectedChange"):GetCallHistory()[1].passedParameters[2])
    
end