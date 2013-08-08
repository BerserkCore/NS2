// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\JetpackMarine.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at
//
//    Thanks to twiliteblue for initial input.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Marine.lua")
Script.Load("lua/Jetpack.lua")

class 'JetpackMarine' (Marine)

JetpackMarine.kMapName = "jetpackmarine"

JetpackMarine.kModelName = PrecacheAsset("models/marine/male/male.model")
JetpackMarine.kBlackArmorModelName = PrecacheAsset("models/marine/male/male_special.model")

JetpackMarine.kJetpackStart = PrecacheAsset("sound/NS2.fev/marine/common/jetpack_start")
JetpackMarine.kJetpackEnd = PrecacheAsset("sound/NS2.fev/marine/common/jetpack_end")
JetpackMarine.kJetpackPickupSound = PrecacheAsset("sound/NS2.fev/marine/common/pickup_jetpack")
local kJetpackLoop = PrecacheAsset("sound/NS2.fev/marine/common/jetpack_on")

// for animation only
JetpackMarine.kAnimFlySuffix = "_jetpack"
JetpackMarine.kAnimTakeOffSuffix = "_jetpack_takeoff"
JetpackMarine.kAnimLandSuffix = "_jetpack_land"

JetpackMarine.kJetpackNode = "JetPack"

if Server then
    Script.Load("lua/JetpackMarine_Server.lua")
elseif Client then
    Script.Load("lua/JetpackMarine_Client.lua")
end

JetpackMarine.kJetpackFuelReplenishDelay = .8
JetpackMarine.kJetpackGravity = -16
JetpackMarine.kJetpackTakeOffTime = .39

local kFlySpeed = 9
local kFlyFriction = 0.0
local kFlyAcceleration = 28

JetpackMarine.kJetpackMode = enum( {'Disabled', 'TakeOff', 'Flying', 'Landing'} )

local networkVars =
{
    // jetpack fuel is dervived from the three variables jetpacking, timeJetpackingChanged and jetpackFuelOnChange
    // time since change has the kJetpackFuelReplenishDelay subtracted if not jetpacking
    // jpFuel = Clamp(jetpackFuelOnChange + time since change * gain/loss rate, 0, 1)
    // If jetpack is currently active and affecting our movement. If active, use loss rate, if inactive use gain rate
    jetpacking = "boolean",
    // when we last changed state of jetpack
    timeJetpackingChanged = "time",
    // amount of fuel when we last changed jetpacking state
    jetpackFuelOnChange = "float (0 to 1 by 0.01)",
    
    startedFromGround = "boolean",
    
    equipmentId = "entityid",
    jetpackMode = "enum JetpackMarine.kJetpackMode",
    
    jetpackLoopId = "entityid",
    
    hasFuelUpgrade = "private boolean"
}

function JetpackMarine:OnCreate()

    Marine.OnCreate(self)
    
    self.jetpackMode = JetpackMarine.kJetpackMode.Disabled
    
    self.jetpackLoopId = Entity.invalidId
    
end

local function InitEquipment(self)

    assert(Server)  

    self.jetpackFuelOnChange = 1
    self.timeJetpackingChanged = Shared.GetTime()
    self.jetpacking = false
    
    StartSoundEffectOnEntity(JetpackMarine.kJetpackPickupSound, self)
    
    self.jetpackLoop = Server.CreateEntity(SoundEffect.kMapName)
    self.jetpackLoop:SetAsset(kJetpackLoop)
    self.jetpackLoop:SetParent(self)
    self.jetpackLoopId = self.jetpackLoop:GetId()
    
    local jetpack = CreateEntity(JetpackOnBack.kMapName, self:GetAttachPointOrigin(Jetpack.kAttachPoint), self:GetTeamNumber())
    jetpack:SetParent(self)
    jetpack:SetAttachPoint(Jetpack.kAttachPoint)
    self.equipmentId = jetpack:GetId()
    
end

function JetpackMarine:OnInitialized()

    // Using the Jetpack is very important. This is
    // a priority before anything else for the JetpackMarine.
    if Client then
        self:AddHelpWidget("GUIMarineJetpackHelp", 2)
    end
    
    Marine.OnInitialized(self)
    
    if Server then
       InitEquipment(self)
    end
    
end

function JetpackMarine:OnDestroy()

    Marine.OnDestroy(self)
    
    self.equipmentId = Entity.invalidId
    self.jetpackLoopId = Entity.invalidId
    if Server then
    
        // The children have already been destroyed.
        self.jetpackLoop = nil
        
    end
    
end

function JetpackMarine:GetHasEquipment()
    return true
end

function JetpackMarine:GetFuel()

    local dt = Shared.GetTime() - self.timeJetpackingChanged
    local rate = self.hasFuelUpgrade and -kUpgradedJetpackUseFuelRate or -kJetpackUseFuelRate
    
    if not self.jetpacking then
        rate = kJetpackReplenishFuelRate
        dt = math.max(0, dt - JetpackMarine.kJetpackFuelReplenishDelay)
    end
    return Clamp(self.jetpackFuelOnChange + rate * dt, 0, 1)
    
end

function JetpackMarine:GetJetpack()

    if Server then
    
        -- There is a case where this function is called after the JetpackMarine has been
        -- destroyed but we don't have reproduction steps.
        if not self:GetIsDestroyed() and self.equipmentId == Entity.invalidId then
            InitEquipment(self)
        end
        
        -- Help us track down this problem.
        if self:GetIsDestroyed() then
        
            DebugPrint("Warning - JetpackMarine:GetJetpack() was called after the JetpackMarine was destroyed")
            DebugPrint(Script.CallStack())
            
        end
        
    end

    return Shared.GetEntity(self.equipmentId)
    
end

function JetpackMarine:OnEntityChange(oldId, newId)

    if oldId == self.equipmentId and newId then
        self.equipmentId = newId
    end

end

function JetpackMarine:HasJetpackDelay()

    if (Shared.GetTime() - self.timeJetpackingChanged > JetpackMarine.kJetpackFuelReplenishDelay) then
        return false
    end
    
    return true
    
end

function JetpackMarine:HandleJetpackStart()

    self.jetpackFuelOnChange = self:GetFuel()
    self.jetpacking = true
    self.timeJetpackingChanged = Shared.GetTime()
    
    self.startedFromGround = self:GetIsOnGround()
    
    local jetpack = self:GetJetpack()    
    if jetpack then
        self:GetJetpack():SetIsFlying(true)
    end
    
    
end

function JetpackMarine:HandleJetPackEnd()

    StartSoundEffectOnEntity(JetpackMarine.kJetpackEnd, self)
    
    if Server then
        self.jetpackLoop:Stop()
    end
    self.jetpackFuelOnChange = self:GetFuel()
    self.timeJetpackingChanged = Shared.GetTime()
    self.jetpacking = false
    
    local animName = self:GetWeaponName() .. JetpackMarine.kAnimLandSuffix
    
    local jetpack = self:GetJetpack()
    if jetpack then
        self:GetJetpack():SetIsFlying(false)
    end
    
end

// needed for correct fly pose
function JetpackMarine:GetWeaponName()

    local currentWeapon = self:GetActiveWeaponName()
    
    if currentWeapon then
        return string.lower(currentWeapon)
    else
        return nil
    end
    
end

function JetpackMarine:GetMaxBackwardSpeedScalar()
    if not self:GetIsOnGround() then
        return 1
    end

    return Player.GetMaxBackwardSpeedScalar(self)
end

function JetpackMarine:UpdateJetpack(input)

    if Server then
        self.hasFuelUpgrade = GetHasTech(self, kTechId.JetpackFuelTech, true) == true
    end
    
    local jumpPressed = (bit.band(input.commands, Move.Jump) ~= 0)
    
    self:UpdateJetpackMode()
    
    // handle jetpack start, ensure minimum wait time to deal with sound errors
    if not self.jetpacking and (Shared.GetTime() - self.timeJetpackingChanged > 0.2) and jumpPressed and self:GetFuel()> 0 then
    
        self:HandleJetpackStart()
        
        if Server then
            self.jetpackLoop:Start()
        end
        
    end
    
    // handle jetpack stop, ensure minimum flight time to deal with sound errors
    if self.jetpacking and (Shared.GetTime() - self.timeJetpackingChanged) > 0.2 and (self:GetFuel()== 0 or not jumpPressed) then
        self:HandleJetPackEnd()
    end
    
    if Client then
    
        local jetpackLoop = Shared.GetEntity(self.jetpackLoopId)
        if jetpackLoop then
            jetpackLoop:SetParameter("fuel", self:GetFuel(), 1)
        end
        
    end

end

// required to not stick to the ground during jetpacking
function JetpackMarine:ComputeForwardVelocity(input)

    // Call the original function to get the base forward velocity.
    local forwardVelocity = Marine.ComputeForwardVelocity(self, input)
    
    if self:GetIsJetpacking() then
        forwardVelocity = forwardVelocity + Vector(0, 2, 0) * input.time
    end
    
    return forwardVelocity
    
end

function JetpackMarine:HandleButtons(input)

    self:UpdateJetpack(input)
    Marine.HandleButtons(self, input)
    
end

function JetpackMarine:GetAirFriction()
    return kFlyFriction    
end

function JetpackMarine:GetAirControl()
    return 0
end

function JetpackMarine:ModifyGravityForce(gravityTable)

    gravityTable.gravity = JetpackMarine.kJetpackGravity
    Marine.ModifyGravityForce(self, gravityTable)
    
end

function JetpackMarine:ModifyVelocity(input, velocity, deltaTime)

    if self:GetIsJetpacking() then
    
        if self.onGround then
            velocity:Scale(0.6)
            velocity.y = 2
        end
        
        local verticalAccel = 22
        if input.move:GetLength() == 0 then
            verticalAccel = 26
        end
    
        self.onGround = false
        local thrust = math.max(0, -velocity.y) / 6
        velocity.y = math.min(5, velocity.y + verticalAccel * deltaTime * (1 + thrust * 2.5))
 
    end
    
    if not self.onGround then
    
        // do XZ acceleration
        local prevXZSpeed = velocity:GetLengthXZ()
        local maxSpeed = math.max(kFlySpeed, prevXZSpeed)
        
        if not self:GetIsJetpacking() then
            maxSpeed = prevXZSpeed
        end
        
        local wishDir = self:GetViewCoords():TransformVector(input.move)
        local acceleration = 0
        wishDir.y = 0
        wishDir:Normalize()
        
        acceleration = kFlyAcceleration
        
        velocity:Add(wishDir * acceleration * self:GetInventorySpeedScalar() * deltaTime)

        if velocity:GetLengthXZ() > maxSpeed then
        
            local yVel = velocity.y
            velocity.y = 0
            velocity:Normalize()
            velocity:Scale(maxSpeed)
            velocity.y = yVel
            
        end 
        
        if self:GetIsJetpacking() then
            velocity:Add(wishDir * 0.7 * deltaTime)
        end
    
    end

end

function JetpackMarine:OverrideUpdateOnGround(onGround)
    return onGround and not self:GetIsJetpacking()
end

function JetpackMarine:GetCanJump()
    return false
end

function JetpackMarine:ModifyJump(input, velocity, jumpVelocity)
    jumpVelocity.y = 4
end

function JetpackMarine:GetCrouchSpeedScalar()

    if self:GetIsJetpacking() then
        return 0
    end
    
    return Player.kCrouchSpeedScalar
    
end

function JetpackMarine:GetIsTakingOffFromGround()
    return self.startedFromGround and (self.timeJetpackingChanged + JetpackMarine.kJetpackTakeOffTime > Shared.GetTime())
end

function JetpackMarine:UpdateJetpackMode()

    local newMode = JetpackMarine.kJetpackMode.Disabled

    if self:GetIsJetpacking() then
    
        if ((Shared.GetTime() - self.timeJetpackingChanged) < JetpackMarine.kJetpackTakeOffTime) and (( Shared.GetTime() - self.timeJetpackingChanged > 1.5 ) or self:GetIsOnGround() ) then

            newMode = JetpackMarine.kJetpackMode.TakeOff

        else

            newMode = JetpackMarine.kJetpackMode.Flying

        end
    end

    if newMode ~= self.jetpackMode then
        self.jetpackMode = newMode
    end

end

function JetpackMarine:GetJetPackMode()

    return self.jetpackMode

end

function JetpackMarine:GetIsJetpacking()
    return self.jetpacking and (self:GetFuel()> 0) and not self:GetIsStunned()
end

function JetpackMarine:OnClampSpeed(input, velocity)

    if self:GetIsJetpacking() then
        Player.OnClampSpeed(self, input, velocity)
    end
    
end

/**
 * Since Jetpack is a child of JetpackMarine, we need to manually
 * call ProcessMoveOnModel() on it so animations play properly.
 */
function JetpackMarine:ProcessMoveOnModel(input)

    local jetpack = self:GetJetpack()
    if jetpack then
        jetpack:ProcessMoveOnModel(input)
    end
    
end

function JetpackMarine:OnTag(tagName)

    PROFILE("JetpackMarine:OnTag")

    Marine.OnTag(self, tagName)
    
    if tagName == "fly_start" and self.startedFromGround then
        StartSoundEffectOnEntity(JetpackMarine.kJetpackStart, self)
    end

end

function JetpackMarine:FallingAfterJetpacking()
    return (self.timeJetpackingChanged + 1.5 > Shared.GetTime()) and not self:GetIsOnGround()
end

function JetpackMarine:OnUpdateAnimationInput(modelMixin)

    Marine.OnUpdateAnimationInput(self, modelMixin)
    
    if self:GetIsJetpacking() or self:FallingAfterJetpacking() then
        modelMixin:SetAnimationInput("move", "jetpack")
    end

end

function JetpackMarine:GetIsStunAllowed()
    return self:GetIsOnGround() and Marine.GetIsStunAllowed(self)
end

Shared.LinkClassToMap("JetpackMarine", JetpackMarine.kMapName, networkVars)