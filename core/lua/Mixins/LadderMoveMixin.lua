// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Mixins\LadderMoveMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

LadderMoveMixin = CreateMixin( LadderMoveMixin )
LadderMoveMixin.type = "LadderMove"

LadderMoveMixin.networkVars =
{
    onLadder = "compensated boolean",
}

LadderMoveMixin.expectedCallbacks =
{
    GetCrouchSpeedScalar = ""
}

local kLadderAcceleration = 25
local kLadderFriction = 9
local kLadderMaxSpeed = 5

function LadderMoveMixin:__initmixin()

    self.onLadder = false

end

function LadderMoveMixin:SetIsOnLadder(onLadder)
    self.onLadder = onLadder    
end

function LadderMoveMixin:GetIsOnLadder()
    return self.onLadder
end

function LadderMoveMixin:ModifyGravityForce(gravityTable)

    if self.onLadder then
        gravityTable.gravity = 0
    end

end

function LadderMoveMixin:ModifyVelocity(input, velocity, deltaTime)

    if self.onLadder then
        
        // apply friction
        local newVelocity = SlerpVector(velocity, Vector(0,0,0), -velocity:GetLength() * deltaTime * kLadderFriction)
        VectorCopy(newVelocity, velocity)
    
        local wishDir = self:GetViewCoords():TransformVector(input.move)
        if wishDir.y ~= 0 then     
            wishDir.y = GetSign(wishDir.y)            
        end
        
        local currentSpeed = velocity:DotProduct(wishDir)
        local addSpeed = math.max(0, kLadderMaxSpeed - currentSpeed)
        if addSpeed > 0 then
        
            local accelSpeed = math.min(addSpeed, deltaTime * kLadderAcceleration)
            velocity:Add(accelSpeed * wishDir)
        
        end
    
    end

end
/*
function LadderMoveMixin:OnUpdateAnimationInput(modelMixin)

    PROFILE("LadderMoveMixin:OnUpdateAnimationInput")
    
    if self.onLadder then
        modelMixin:SetAnimationInput("move", "climb")
    end
    
end    
*/ 