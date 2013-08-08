// Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Onos.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Gore attack should send players flying (doesn't have to be ragdoll). Stomp will stun
// marines in range and blow up mines.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/Weapons/Alien/Gore.lua")
Script.Load("lua/Weapons/Alien/BoneShield.lua")
Script.Load("lua/Alien.lua")
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

class 'Onos' (Alien)

Onos.kMapName = "onos"
Onos.kModelName = PrecacheAsset("models/alien/onos/onos.model")
Onos.kViewModelName = PrecacheAsset("models/alien/onos/onos_view.model")

local kOnosAnimationGraph = PrecacheAsset("models/alien/onos/onos.animation_graph")

local kChargeStart = PrecacheAsset("sound/NS2.fev/alien/onos/wound_serious")

local kRumbleSound = PrecacheAsset("sound/NS2.fev/alien/onos/rumble")

Onos.kJumpForce = 20
Onos.kJumpVerticalVelocity = 8

Onos.kJumpRepeatTime = .25
Onos.kViewOffsetHeight = 2.5
Onos.XExtents = .7
Onos.YExtents = 1.2
Onos.ZExtents = .4
Onos.kMass = 453 // Half a ton
Onos.kJumpHeight = 1.15

// triggered when the momentum value has changed by this amount (negative because we trigger the effect when the onos stops, not accelerates)
Onos.kMomentumEffectTriggerDiff = 3

Onos.kGroundFrictionForce = 3

// used for animations and sound effects
Onos.kMaxSpeed = 6.2
Onos.kChargeSpeed = 10.5

Onos.kHealth = kOnosHealth
Onos.kArmor = kOnosArmor
Onos.kChargeEnergyCost = kChargeEnergyCost

Onos.kChargeUpDuration = 0.5
Onos.kChargeDelay = 1.0

// mouse sensitivity scalar during charging
Onos.kChargingSensScalar = 0

Onos.kStoopingCheckInterval = 0.3
Onos.kStoopingAnimationSpeed = 2
Onos.kYHeadExtents = 0.7
Onos.kYHeadExtentsLowered = 0.0

local kAutoCrouchCheckInterval = 0.4

if Server then
    Script.Load("lua/Onos_Server.lua")
elseif Client then
    Script.Load("lua/Onos_Client.lua")
end

local networkVars =
{
    directionMomentum = "private float",
    stooping = "boolean",
    stoopIntensity = "compensated interpolated float",
    charging = "private boolean",
    rumbleSoundId = "entityid"
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

function Onos:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kOnosFov })
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, TunnelUserMixin)
    
    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
    
    self.directionMomentum = 0
    
    self.altAttack = false
    self.stooping = false
    self.charging = false
    self.stoopIntensity = 0
    self.timeLastCharge = 0
    self.timeLastChargeEnd = 0
    self.chargeSpeed = 0
    
    if Client then
        self:SetUpdates(true)
    elseif Server then
    
        self.rumbleSound = Server.CreateEntity(SoundEffect.kMapName)
        self.rumbleSound:SetAsset(kRumbleSound)
        self.rumbleSound:SetParent(self)
        self.rumbleSound:Start()
        self.rumbleSoundId = self.rumbleSound:GetId()
        
    end
    
end

function Onos:OnInitialized()

    Alien.OnInitialized(self)
    
    self:SetModel(Onos.kModelName, kOnosAnimationGraph)
    
    self:AddTimedCallback(Onos.UpdateStooping, Onos.kStoopingCheckInterval)

end

function Onos:GetPlayerControllersGroup()
    return PhysicsGroup.BigPlayerControllersGroup
end

function Onos:GetAcceleration()
    return 3.6
end

function Onos:GetAirControl()
    return 0.2
end

function Onos:GetGroundFriction()
    return 1.9 + (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.57
end

function Onos:GetCarapaceSpeedReduction()
    return kOnosCarapaceSpeedReduction
end

function Onos:GetCrouchShrinkAmount()
    return 0.4
end

function Onos:GetExtentsCrouchShrinkAmount()
    return 0.4
end

function Onos:GetIsCharging()
    return self.charging
end

function Onos:GetCanJump()

    local weapon = self:GetActiveWeapon()
    local stomping = weapon and HasMixin(weapon, "Stomp") and weapon:GetIsStomping()

    return Alien.GetCanJump(self) and not stomping
    
end

function Onos:GetCanCrouch()
    return Alien.GetCanCrouch(self) and not self.charging
end

function Onos:GetChargeFraction()
    return ConditionalValue(self.charging, math.min(1, (Shared.GetTime() - self.timeLastCharge) / Onos.kChargeUpDuration ), 0)
end

local function TriggerMomentumChangeEffects(entity, surface, direction, normal, extraEffectParams)

    if Client and math.abs(direction:GetLengthSquared() - 1) < 0.001 then
    
        local tableParams = { }
        
        tableParams[kEffectFilterDoerName] = entity:GetClassName()
        tableParams[kEffectSurface] = ConditionalValue(type(surface) == "string" and surface ~= "", surface, "metal")
        
        local coords = Coords.GetIdentity()
        coords.origin = entity:GetOrigin()
        coords.zAxis = direction
        coords.yAxis = normal
        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        
        tableParams[kEffectHostCoords] = coords
        
        // Add in extraEffectParams if specified
        if extraEffectParams then
        
            for key, element in pairs(extraEffectParams) do
                tableParams[key] = element
            end
            
        end
        
        GetEffectManager():TriggerEffects("momentum_change", tableParams)
        
    end
    
end

function Onos:EndCharge()

    local surface, normal = GetSurfaceAndNormalUnderEntity(self)

    // align zAxis to player movement
    local moveDirection = self:GetVelocity()
    moveDirection:Normalize()
    
    TriggerMomentumChangeEffects(self, surface, moveDirection, normal)
    
    self.charging = false
    self.chargeSpeed = 0
    self.timeLastChargeEnd = Shared.GetTime()

end

function Onos:PreUpdateMove(input, runningPrediction)
    // determines how manuverable the onos is. When not charging, manuverability is 1. 
    // when charging it goes towards zero as the speed increased. At zero, you can't strafe or change
    // direction.
    // The math.sqrt makes you drop manuverability quickly at the start and then drop it less and less
    // the 0.8 cuts manuverability to zero before the max speed is reached
    // Fiddle until it feels right. 
    // 0.8 allows about a 90 degree turn in atrium, ie you can start charging
    // at the entrance, and take the first two stairs before you hit the lockdown.
    local manuverability = ConditionalValue(self.charging, math.max(0, 0.8 - math.sqrt(self:GetChargeFraction())), 1)

    if self.charging then

        // fiddle here to determine strafing 
        input.move.x = input.move.x * math.max(0.3, manuverability)
        input.move.z = 1
        
        self:DeductAbilityEnergy(Onos.kChargeEnergyCost * input.time)
    
        local xzViewDirection = self:GetViewCoords().zAxis
        xzViewDirection.y = 0
        xzViewDirection:Normalize()
        
        // stop charging if out of energy, jumping or we have charged for a second and our speed drops below 4.5
        // - changed from 0.5 to 1s, as otherwise touchin small obstactles orat started stopped you from charging 
        if self:GetEnergy() == 0 or 
           self:GetIsJumping() or
          (self.timeLastCharge + 1 < Shared.GetTime() and self:GetVelocity():GetLengthXZ() < 4.5 ) then
    
            self:EndCharge()
            
        end
            
    end

    if self.autoCrouching then
        self.crouching = self.autoCrouching
    end 

    if Client and self == Client.GetLocalPlayer() then

        // Lower mouse sensitivity when charging, only affects the local player.
        Client.SetMouseSensitivityScalar(manuverability)
        
    end

end

function Onos:GetAngleSmoothRate()
    return 3
end

function Onos:PostUpdateMove(input, runningPrediction)

    if self.charging then
    
        local xzSpeed = self:GetVelocity():GetLengthXZ()
        if xzSpeed > self.chargeSpeed then
            self.chargeSpeed = xzSpeed
        end    
    
    end

end

function Onos:GetAirFriction()
    return 0.25
end

function Onos:TriggerCharge(move)

    if not self.charging and self.timeLastChargeEnd + Onos.kChargeDelay < Shared.GetTime() and self:GetIsOnGround() and not self:GetCrouching() then

        self.charging = true
        self.timeLastCharge = Shared.GetTime()
        
        if Server and not GetHasSilenceUpgrade(self) then
        
            StartSoundEffectAtOrigin(kChargeStart, self:GetOrigin())
            self:TriggerEffects("onos_charge")
        
        end
        
        self:TriggerUncloak()
    
    end
    
end

function Onos:HandleButtons(input)

    Alien.HandleButtons(self, input)
    
    if self:GetIsBoneShieldActive() then
    
        input.commands = bit.bor(input.commands, Move.Crouch)
    
    end

    if self.movementModiferState then
    
        self:TriggerCharge(input.move)
        
    else
    
        if self.charging then
            self:EndCharge()
        end
    
    end

end

// Required by ControllerMixin.
function Onos:GetMovePhysicsMask()
    return PhysicsMask.OnosMovement
end

function Onos:GetBaseArmor()
    return Onos.kArmor
end

function Onos:GetBaseHealth()
    return Onos.kHealth
end

function Onos:GetHealthPerBioMass()
    return kOnosHealtPerBioMass
end

function Onos:GetArmorFullyUpgradedAmount()
    return kOnosArmorFullyUpgradedAmount
end

function Onos:GetViewModelName()
    return Onos.kViewModelName
end

function Onos:AddEnergy(energy)

    if not self:GetIsBoneShieldActive() then
        Alien.AddEnergy(self, energy)
    end

end

function Onos:GetMaxViewOffsetHeight()
    return Onos.kViewOffsetHeight
end 

function Onos:GetMaxSpeed(possible)

    if possible then
        return Onos.kMaxSpeed
    end
    
    if self:GetIsBoneShieldActive() then
        return Onos.kMaxSpeed * 0.5
    end

    return ( Onos.kMaxSpeed + self:GetChargeFraction() * (Onos.kChargeSpeed - Onos.kMaxSpeed) )

end

// Half a ton
function Onos:GetMass()
    return Onos.kMass
end

function Onos:GetJumpHeight()
    return Onos.kJumpHeight
end

function Onos:GetHideArmorAmount()
    return kOnosHideArmor
end

function Onos:GetMaxBackwardSpeedScalar()
    return 0.5
end

local kStoopPos = Vector(0, 2.6, 0)
function Onos:UpdateStooping(deltaTime)

    local topPos = self:GetOrigin() + kStoopPos
    topPos.y = topPos.y + Onos.kYHeadExtents
    
    local xzDirection = self:GetViewCoords().zAxis
    xzDirection.y = 0
    xzDirection:Normalize()
    
    local trace = Shared.TraceRay(topPos, topPos + xzDirection * 4, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    
    if not self.stooping and not self.crouching then

        if trace.fraction ~= 1 then
        
            local stoopPos = self:GetEyePos()
            stoopPos.y = stoopPos.y + Onos.kYHeadExtentsLowered
            
            local traceStoop = Shared.TraceRay(stoopPos, stoopPos + xzDirection * 4, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
            if traceStoop.fraction == 1 then
                self.stooping = true                
            end
            
        end    

    elseif self.stoopIntensity == 1 and trace.fraction == 1 then
        self.stooping = false
    end

    
    return true

end

function Onos:UpdateAutoCrouch(move)
 
    local moveDirection = self:GetCoords():TransformVector(move)
    
    local extents = GetExtents(kTechId.Onos)
    local startPos1 = self:GetOrigin() + Vector(0, extents.y * self:GetCrouchShrinkAmount(), 0)
    
    local frontLeft = -self:GetCoords().xAxis * extents.x - self:GetCoords().zAxis * extents.z
    local backRight = self:GetCoords().xAxis * extents.x - self:GetCoords().zAxis * extents.z
    
    local startPos2 = self:GetOrigin() + frontLeft + Vector(0, extents.y * (1 - self:GetCrouchShrinkAmount()), 0)
    local startPos3 = self:GetOrigin() + backRight + Vector(0, extents.y * (1 - self:GetCrouchShrinkAmount()), 0)
    
    //DebugLine(startPos1, startPos1 + moveDirection * 3, 3, 1,1,1,1)
    //DebugLine(startPos2, startPos2 + moveDirection * 3, 3, 1,1,1,1)
    //DebugLine(startPos3, startPos3 + moveDirection * 3, 3, 1,1,1,1)
    
    local trace1 = Shared.TraceRay(startPos1, startPos1 + moveDirection * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    local trace2 = Shared.TraceRay(startPos2, startPos2 + moveDirection * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    local trace3 = Shared.TraceRay(startPos3, startPos3 + moveDirection * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    
    if trace1.fraction == 1 and trace2.fraction == 1 and trace3.fraction == 1 then
        self.crouching = true
        self.autoCrouching = true
    end

end

local function SharedUpdate(self, dt)

    if Client then
    
        local rumbleSound = Shared.GetEntity(self.rumbleSoundId)
        if rumbleSound then
            rumbleSound:SetParameter("speed", self:GetSpeedScalar(), 1)
        end
        
    end
    
end

function Onos:OnProcessMove(input)

    PROFILE("Onos:OnProcessMove")
    
    Alien.OnProcessMove(self, input)
    

    if self.stooping then    
        self.stoopIntensity = math.min(1, self.stoopIntensity + Onos.kStoopingAnimationSpeed * input.time)
    else    
        self.stoopIntensity = math.max(0, self.stoopIntensity - Onos.kStoopingAnimationSpeed * input.time)
    end
    
    SharedUpdate(self, input.time)
    
end

function Onos:OnUpdate(dt)

    Alien.OnUpdate(self, dt)
    
    SharedUpdate(self, dt)
    
end

function Onos:OnUpdatePoseParameters(viewModel)

    PROFILE("Onos:OnUpdatePoseParameters")
    
    Alien.OnUpdatePoseParameters(self, viewModel)
    
    self:SetPoseParam("stoop", self.stoopIntensity)
    
end

local kOnosHeadMoveAmount = 0.3
// Give dynamic camera motion to the player
function Onos:OnPostUpdateCamera(deltaTime) 

    local camOffsetHeight = 0
    
    if not self.currentCameraAnim then
        self.currentCameraAnim = 0
    end
    
    if not self:GetIsJumping() then
        camOffsetHeight = -self:GetMaxViewOffsetHeight() * self:GetCrouchShrinkAmount() * self:GetCrouchAmount()
    end
    
    if self:GetIsFirstPerson() then
    
        if not self:GetIsJumping() then

            local movementScalar = Clamp((self:GetVelocity():GetLength() / self:GetMaxSpeed(true)), 0.0, 0.8)
            local bobbing = ( math.cos((Shared.GetTime() - self:GetTimeGroundTouched()) * 7) - 1 )
            camOffsetHeight = camOffsetHeight + kOnosHeadMoveAmount * movementScalar * bobbing
            
        end
        
    end
    
    self.currentCameraAnim = Slerp(self.currentCameraAnim, camOffsetHeight, deltaTime * 0.5)    
    self:SetCameraYOffset(self.currentCameraAnim)

end

local kOnosEngageOffset = Vector(0, 1.3, 0)
function Onos:GetEngagementPointOverride()
    return self:GetOrigin() + kOnosEngageOffset
end

function Onos:OnClampSpeed(input, velocity)
    Player.OnClampSpeed(self, input, velocity)
end

function Onos:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    // TODO: consider impact point
    if self:GetIsBoneShieldActive() then
        
        //local maxAbsorbDamage = self:GetEnergy() * kBoneShieldDamageAbsorbPerEnergy
        //local fullDamage = damageTable.damage
        
        damageTable.damage = damageTable.damage * (1 - kBoneShieldAbsorbFraction) // + math.max(0, damageTable.damage - maxAbsorbDamage)
        //Print("modified damage: %s", ToString(damageTable.damage))
        //self:DeductAbilityEnergy((fullDamage - damageTable.damage) / kBoneShieldDamageAbsorbPerEnergy)
        
    end

end

function Onos:GetSurfaceOverride()

    if self:GetIsBoneShieldActive() then
        return "metal"
    end
    
    return "organic"
    
end

function Onos:GetIsBoneShieldActive()

    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and activeWeapon:isa("BoneShield") and activeWeapon.primaryAttacking then
        return true
    end    
    return false
    
end

function Onos:GetCrouchDesired(crouching)
    return self:GetIsBoneShieldActive()
end

Shared.LinkClassToMap("Onos", Onos.kMapName, networkVars)