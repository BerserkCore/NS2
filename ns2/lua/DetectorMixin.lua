// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\DetectorMixin.lua    
//    
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

DetectorMixin = { }
DetectorMixin.type = "Detector"

// Should be smaller than DetectableMixin:kResetDetectionInterval
DetectorMixin.kUpdateDetectionInterval = .5

DetectorMixin.expectedCallbacks =
{
    // Returns integer for team number
    GetTeamNumber = "",
    
    // Returns 0 if not active currently
    GetDetectionRange = "Return range of the detector.",
    
    GetOrigin = "Detection origin",
}

function DetectorMixin:__initmixin()
    self.timeSinceLastDetected = 0        
end

local function PerformDetection(self)

    // Get list of Detectables in range
    local range = self:GetDetectionRange()
    
    if range > 0 then

        local teamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
        local origin = self:GetOrigin()    
        local detectables = GetEntitiesWithMixinForTeamWithinRange("Detectable", teamNumber, origin, range)
        
        for index, detectable in ipairs(detectables) do
        
            // Mark them as detected
            detectable:SetDetected(true)
        
        end
        
    end
    
end

local function SharedUpdate(self, deltaTime)

    self.timeSinceLastDetected = self.timeSinceLastDetected + deltaTime
    
    if self.timeSinceLastDetected >= DetectorMixin.kUpdateDetectionInterval then
    
        PerformDetection(self)    
        self.timeSinceLastDetected = self.timeSinceLastDetected - DetectorMixin.kUpdateDetectionInterval
        
    end
    
end

function DetectorMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end

function DetectorMixin:OnUpdate(deltaTime)
    SharedUpdate(self, deltaTime)
end

