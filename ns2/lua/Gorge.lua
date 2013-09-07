// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Gorge.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Weapons/Alien/SpitSpray.lua")
Script.Load("lua/Weapons/Alien/InfestationAbility.lua")
Script.Load("lua/Weapons/Alien/DropStructureAbility.lua")
Script.Load("lua/Weapons/Alien/BabblerAbility.lua")
Script.Load("lua/Weapons/Alien/BileBomb.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/CelerityMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/BabblerClingMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/IdleMixin.lua")

class 'Gorge' (Alien)

if Server then    
    Script.Load("lua/Gorge_Server.lua")
end

local networkVars =
{
    bellyYaw = "private float",
    timeSlideEnd = "private time",
    startedSliding = "private boolean",
    sliding = "boolean",
    hasBellySlide = "private boolean"
}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(CelerityMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(BabblerClingMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)

Gorge.kMapName = "gorge"

Gorge.kModelName = PrecacheAsset("models/alien/gorge/gorge.model")
local kViewModelName = PrecacheAsset("models/alien/gorge/gorge_view.model")
local kGorgeAnimationGraph = PrecacheAsset("models/alien/gorge/gorge.animation_graph")

Gorge.kSlideLoopSound = PrecacheAsset("sound/NS2.fev/alien/gorge/slide_loop")
Gorge.kBuildSoundInterval = .5
Gorge.kBuildSoundName = PrecacheAsset("sound/NS2.fev/alien/gorge/build")

Gorge.kXZExtents = 0.5
Gorge.kYExtents = 0.475

local kMass = 80
local kJumpHeight = 1.2
local kStartSlideSpeed = 8.9
local kViewOffsetHeight = 0.6
local kMaxGroundSpeed = 6
local kMaxSlidingSpeed = 13
local kSlidingMoveInputScalar = 0.1
local kBuildingModeMovementScalar = 0.001
local kSlideCoolDown = 1.5

Gorge.kAirZMoveWeight = 2.5
Gorge.kAirStrafeWeight = 2.5
Gorge.kAirBrakeWeight = 0.1

local kGorgeBellyYaw = "belly_yaw"
local kGorgeLeanSpeed = 2

function Gorge:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kGorgeFov })
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, TunnelUserMixin)
    
    InitMixin(self, PredictedProjectileShooterMixin)
    
    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
    
    self.bellyYaw = 0
    self.timeSlideEnd = 0
    self.startedSliding = false
    self.sliding = false
    self.verticalVelocity = 0

end

function Gorge:OnInitialized()

    Alien.OnInitialized(self)
    
    self:SetModel(Gorge.kModelName, kGorgeAnimationGraph)
    
    if Server then
    
        self.slideLoopSound = Server.CreateEntity(SoundEffect.kMapName)
        self.slideLoopSound:SetAsset(Gorge.kSlideLoopSound)
        self.slideLoopSound:SetParent(self)
        
    elseif Client then
    
        self:AddHelpWidget("GUIGorgeHealHelp", 2)
        self:AddHelpWidget("GUIGorgeBellySlideHelp", 2)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
    end
    
    InitMixin(self, IdleMixin)
    
end

function Gorge:GetAirControl()
    return 5
end

function Gorge:GetCarapaceSpeedReduction()
    return kGorgeCarapaceSpeedReduction
end

if Client then

    function Gorge:GetHealthbarOffset()
        return 0.7
    end  

    function Gorge:OverrideInput(input)

        // Always let the DropStructureAbility override input, since it handles client-side-only build menu

        local buildAbility = self:GetWeapon(DropStructureAbility.kMapName)

        if buildAbility then
            input = buildAbility:OverrideInput(input)
        end
        
        return Player.OverrideInput(self, input)
        
    end
    
end

function Gorge:GetBaseArmor()
    return kGorgeArmor
end

function Gorge:GetBaseHealth()
    return kGorgeHealth
end

function Gorge:GetHealthPerBioMass()
    return kGorgeHealthPerBioMass
end

function Gorge:GetArmorFullyUpgradedAmount()
    return kGorgeArmorFullyUpgradedAmount
end

function Gorge:GetMaxViewOffsetHeight()
    return kViewOffsetHeight
end

function Gorge:GetCrouchShrinkAmount()
    return 0
end

function Gorge:GetExtentsCrouchShrinkAmount()
    return 0
end

function Gorge:GetViewModelName()
    return kViewModelName
end

function Gorge:GetJumpHeight()
    return kJumpHeight
end

function Gorge:GetIsBellySliding()
    return self.sliding
end
/*
function Gorge:GetCanJump()
    return not self:GetIsBellySliding()
end
*/
local function GetIsSlidingDesired(self, input)

    if bit.band(input.commands, Move.MovementModifier) == 0 then
        return false
    end
    
    if self.crouching then
        return false
    end
    
    if not self:GetHasMovementSpecial() then
        return false
    end
    
    if self:GetVelocity():GetLengthXZ() < 3 or self:GetIsJumping() then
    
        if self:GetIsBellySliding() then    
            return false
        end 
           
    else
        
        local zAxis = self:GetViewCoords().zAxis
        zAxis.y = 0
        zAxis:Normalize()
        
        if GetNormalizedVectorXZ(self:GetVelocity()):DotProduct( zAxis ) < 0.2 then
            return false
        end
    
    end
    
    return true

end

// Handle transitions between starting-sliding, sliding, and ending-sliding
local function UpdateGorgeSliding(self, input)

    PROFILE("Gorge:UpdateGorgeSliding")
    
    local slidingDesired = GetIsSlidingDesired(self, input)
    if slidingDesired and not self.sliding and self.timeSlideEnd + kSlideCoolDown < Shared.GetTime() and self:GetIsOnGround() and self:GetEnergy() >= kBellySlideCost then
    
        self.sliding = true
        self.startedSliding = true
        
        if Server then
            if not GetHasSilenceUpgrade(self) then
                self.slideLoopSound:Start()
            end
        end
        
        self:DeductAbilityEnergy(kBellySlideCost)
        self:PrimaryAttackEnd()
        self:SecondaryAttackEnd()
        
    end
    
    if not slidingDesired and self.sliding then
    
        self.sliding = false
        
        if Server then
            self.slideLoopSound:Stop()
        end
        
        self.timeSlideEnd = Shared.GetTime()
    
    end

    // Have Gorge lean into turns depending on input. He leans more at higher rates of speed.
    if self:GetIsBellySliding() then

        local desiredBellyYaw = 2 * (-input.move.x / kSlidingMoveInputScalar) * (self:GetVelocity():GetLength() / self:GetMaxSpeed())
        self.bellyYaw = Slerp(self.bellyYaw, desiredBellyYaw, input.time * kGorgeLeanSpeed)
        
    end
    
end

function Gorge:GetAirFriction()
    return 0.8
end

function Gorge:GetCanRepairOverride(target)
    return true
end

function Gorge:HandleButtons(input)

    PROFILE("Gorge:HandleButtons")
    
    Alien.HandleButtons(self, input)
    
    UpdateGorgeSliding(self, input)
    
end

function Gorge:OnUpdatePoseParameters(viewModel)

    PROFILE("Gorge:OnUpdatePoseParameters")
    
    Alien.OnUpdatePoseParameters(self, viewModel)
    
    self:SetPoseParam(kGorgeBellyYaw, self.bellyYaw * 45)
    
end

function Gorge:SetCrouchState(newCrouchState)
    self.crouching = newCrouchState
end

function Gorge:GetMaxSpeed(possible)
    return kMaxGroundSpeed
end

function Gorge:GetMaxBackwardSpeedScalar()
    return 0.5
end

function Gorge:GetAcceleration()
    return self:GetIsBellySliding() and 0 or 8
end

function Gorge:GetGroundFriction()
    
    if self:GetIsBellySliding() then
        return self:GetGameEffectMask(kGameEffect.OnInfestation) and 0.068 or 0.2
    end

    return 7
    
end

function Gorge:GetMass()
    return kMass
end

function Gorge:OnUpdateAnimationInput(modelMixin)

    PROFILE("Gorge:OnUpdateAnimationInput")
    
    Alien.OnUpdateAnimationInput(self, modelMixin)
    
    if self:GetIsBellySliding() then
        modelMixin:SetAnimationInput("move", "belly")
    end
    
end

function Gorge:GetMovementSpecialTechId()
    return kTechId.BellySlide
end

function Gorge:GetHasMovementSpecial()
    return true // self.hasBellySlide or self:GetTeamNumber() == kTeamReadyRoom
end

function Gorge:ModifyVelocity(input, velocity, deltaTime)
    
    // Give a little push forward to make sliding useful
    if self.startedSliding then
    
        if self:GetIsOnGround() then
    
            local pushDirection = GetNormalizedVectorXZ(self:GetViewCoords().zAxis)
            
            local currentSpeed = math.max(0, pushDirection:DotProduct(velocity))
            
            local maxSpeedTable = { maxSpeed = kStartSlideSpeed }
            self:ModifyMaxSpeed(maxSpeedTable, input)
            
            local addSpeed = math.max(0, maxSpeedTable.maxSpeed - currentSpeed)
            local impulse = pushDirection * addSpeed

            velocity:Add(impulse)
        
        end
        
        self.startedSliding = false

    end
    
    if self:GetIsBellySliding() then
    
        local currentSpeed = velocity:GetLengthXZ()
        local prevY = velocity.y
        velocity.y = 0  
        
        local addVelocity = self:GetViewCoords():TransformVector(input.move)
        addVelocity.y = 0
        addVelocity:Normalize()
        addVelocity:Scale(deltaTime * 10)
        
        velocity:Add(addVelocity) 
        velocity:Normalize()
        velocity:Scale(currentSpeed)
        velocity.y = prevY
    
    end
    
end

function Gorge:GetPitchSmoothRate()
    return 1
end

function Gorge:GetPitchRollRate()
    return 3
end

local kMaxSlideRoll = math.rad(20)

function Gorge:GetDesiredAngles()

    local desiredAngles = Alien.GetDesiredAngles(self)
    
    if self:GetIsBellySliding() then
        desiredAngles.pitch = - self.verticalVelocity / 10 
        desiredAngles.roll = GetNormalizedVectorXZ(self:GetVelocity()):DotProduct(self:GetViewCoords().xAxis) * kMaxSlideRoll
    end
    
    return desiredAngles

end

function Gorge:PreUpdateMove(input, runningPrediction)

    self.prevY = self:GetOrigin().y

end

function Gorge:PostUpdateMove(input, runningPrediction)

    if self:GetIsBellySliding() and self:GetIsOnGround() then
    
        local velocity = self:GetVelocity()
    
        local yTravel = self:GetOrigin().y - self.prevY
        local xzSpeed = velocity:GetLengthXZ()
        
        xzSpeed = xzSpeed + yTravel * -4
        
        if xzSpeed < kMaxSlidingSpeed or yTravel > 0 then
        
            local directionXZ = GetNormalizedVectorXZ(velocity)
            directionXZ:Scale(xzSpeed)

            velocity.x = directionXZ.x
            velocity.z = directionXZ.z
            
            self:SetVelocity(velocity)
            
        end

        self.verticalVelocity = yTravel / input.time
    
    end

end

if Client then

    function Gorge:GetShowGhostModel()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetShowGhostModel()
        end
        
        return false
        
    end    

    function Gorge:GetGhostModelTechId()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetGhostModelTechId()
        end
        
    end

    function Gorge:GetGhostModelCoords()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetGhostModelCoords()
        end

    end
    
    function Gorge:GetLastClickedPosition()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon.lastClickedPosition
        end
        
    end

    function Gorge:GetIsPlacementValid()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetIsPlacementValid()
        end
    
    end

end

function Gorge:GetCanSeeDamagedIcon(ofEntity)
    return not ofEntity:isa("Cyst")
end

function Gorge:GetCanAttack()
    return Alien.GetCanAttack(self) and not self:GetIsBellySliding()
end

function Gorge:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, 0.28, 0)
end

if Server then

    function Gorge:OnProcessMove(input)
    
        Alien.OnProcessMove(self, input)
        
        self.hasBellySlide = GetIsTechAvailable(self:GetTeamNumber(), kTechId.BellySlide) == true or GetGamerules():GetAllTech()
    
    end

end


Shared.LinkClassToMap("Gorge", Gorge.kMapName, networkVars, true)