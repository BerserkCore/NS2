// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Fade.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Role: Surgical striker, harassment
//
// The Fade should be a fragile, deadly-sharp knife. Wielded properly, it's force is undeniable. But
// used clumsily or without care will only hurt the user. Make sure Fade isn't better than the Skulk 
// in every way (notably, vs. Structures). To harass, he must be able to stay out in the field
// without continually healing at base, and needs to be able to use blink often.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/Weapons/Alien/SwipeBlink.lua")
Script.Load("lua/Weapons/Alien/Vortex.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/CelerityMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/BabblerClingMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")

class 'Fade' (Alien)

Fade.kMapName = "fade"

Fade.kModelName = PrecacheAsset("models/alien/fade/fade.model")
local kViewModelName = PrecacheAsset("models/alien/fade/fade_view.model")
local kFadeAnimationGraph = PrecacheAsset("models/alien/fade/fade.animation_graph")

Shared.PrecacheSurfaceShader("models/alien/fade/fade.surface_shader")

local kViewOffsetHeight = 1.7
Fade.XZExtents = 0.4
Fade.YExtents = 1.05
Fade.kHealth = kFadeHealth
Fade.kArmor = kFadeArmor
// ~350 pounds.
local kMass = 158
local kJumpHeight = 1.4
local kMaxSpeed = 5.2

local kFadeScanDuration = 4

local kShadowStepCooldown = 0.73
local kShadowStepForce = 4

local kShadowStepSpeed = 30

local kBlinkSpeed = 14.8

// Delay before you can blink again after a blink.
local kMinEnterEtherealTime = 0.4

if Server then
    Script.Load("lua/Fade_Server.lua")
elseif Client then    
    Script.Load("lua/Fade_Client.lua")
end

local networkVars =
{
    isScanned = "boolean",
    shadowStepping = "boolean",
    timeShadowStep = "private compensated time",
    shadowStepDirection = "private vector",
    shadowStepSpeed = "private compensated interpolated float",
    
    etherealStartTime = "private time",
    etherealEndTime = "private time",
    
    // True when we're moving quickly "through the ether"
    ethereal = "boolean",
    
    landedAfterBlink = "private compensated boolean",  
}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(CelerityMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(BabblerClingMixin, networkVars)

function Fade:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kFadeFov })
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, BabblerClingMixin)
    
    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
    
    self.shadowStepDirection = Vector()
    
    if Server then
    
        self.timeLastScan = 0
        self.isBlinking = false
        self.timeShadowStep = 0
        self.shadowStepping = false
        
    end
    
    self.etherealStartTime = 0
    self.etherealEndTime = 0
    self.ethereal = false
    self.landedAfterBlink = true
    
end

function Fade:OnInitialized()

    Alien.OnInitialized(self)
    
    self:SetModel(Fade.kModelName, kFadeAnimationGraph)
    
    if Client then
    
        self.blinkDissolve = 0
        
        self:AddHelpWidget("GUIFadeShadowStepHelp", 2)
        self:AddHelpWidget("GUIFadeBlinkHelp", 2)
        self:AddHelpWidget("GUIFadeDoubleJumpHelp", 2)
        
    end
    
end

function Fade:OnDestroy()

    Alien.OnDestroy(self)
    
    if Client then
        self:DestroyTrailCinematic()
    end
    
end

function Fade:GetPlayerControllersGroup()
    return PhysicsGroup.BigPlayerControllersGroup
end

function Fade:GetInfestationBonus()
    return kFadeInfestationSpeedBonus
end

function Fade:GetCarapaceSpeedReduction()
    return kFadeCarapaceSpeedReduction
end

function Fade:MovementModifierChanged(newMovementModifierState, input)

    if newMovementModifierState then
        self:TriggerShadowStep(input.move)
    end
    
end

function Fade:GetHeadAttachpointName()
    return "fade_tongue2"
end

// Prevents reseting of celerity.
function Fade:OnSecondaryAttack()
end

function Fade:GetBaseArmor()
    return Fade.kArmor
end

function Fade:GetBaseHealth()
    return Fade.kHealth
end

function Fade:GetHealthPerBioMass()
    return kFadeHealthPerBioMass
end

function Fade:GetArmorFullyUpgradedAmount()
    return kFadeArmorFullyUpgradedAmount
end

function Fade:GetMaxViewOffsetHeight()
    return kViewOffsetHeight
end

function Fade:GetViewModelName()
    return kViewModelName
end

function Fade:GetCanStep()
    return not self:GetIsBlinking()
end

function Fade:ModifyGravityForce(gravityTable)

    if self:GetIsBlinking() or self:GetIsOnGround() then
        gravityTable.gravity = 0
    end

end

function Fade:GetPerformsVerticalMove()
    return self:GetIsBlinking()
end

function Fade:GetAcceleration()
    return 20
end

function Fade:GetGroundFriction()
    return 5
end  

function Fade:GetAirControl()
    return 40
end   

function Fade:GetAirFriction()
    return 0.03
end 

function Fade:ModifyVelocity(input, velocity, deltaTime)

    if self:GetIsBlinking() then
    
        local wishDir = self:GetViewCoords().zAxis
        local maxSpeedTable = { maxSpeed = kBlinkSpeed, wishDir = wishDir }
        self:ModifyMaxSpeed(maxSpeedTable)  
        local prevSpeed = velocity:GetLength()
        local maxSpeed = math.max(prevSpeed, maxSpeedTable.maxSpeed)
        local maxSpeed = math.min(25, maxSpeed)    
        
        velocity:Add(wishDir * 40 * deltaTime)
        
        if velocity:GetLength() > maxSpeed then

            velocity:Normalize()
            velocity:Scale(maxSpeed)
            
        end 
        
        // additional acceleration when holding down blink to exceed max speed
        velocity:Add(wishDir * 3 * deltaTime)
        
    end

end

function Fade:GetCanJump()
    return self:GetIsOnGround() and not self:GetIsBlinking()
end

function Fade:GetIsShadowStepping()
    return self.shadowStepping
end

function Fade:GetMaxSpeed(possible)

    if possible then
        return kMaxSpeed
    end
    
    if self:GetIsBlinking() then
        return kBlinkSpeed
    end
    
    // Take into account crouching.
    return kMaxSpeed
    
end

function Fade:GetMass()
    return kMass
end

function Fade:GetJumpHeight()
    return kJumpHeight
end

function Fade:GetIsBlinking()
    return self.ethereal and self:GetIsAlive()
end

function Fade:GetRecentlyBlinked(player)
    return Shared.GetTime() - self.etherealEndTime < kMinEnterEtherealTime
end

function Fade:GetHasShadowStepCooldown()
    return self.timeShadowStep + kShadowStepCooldown > Shared.GetTime() or self:GetIsBlinking()
end

function Fade:GetMovementSpecialTechId()
    return kTechId.ShadowStep
end

function Fade:GetHasMovementSpecial()
    return self:GetTeamNumber() == kTeamReadyRoom or self.twoHives
end

function Fade:GetMovementSpecialEnergyCost()
    return kFadeShadowStepCost
end

function Fade:GetCollisionSlowdownFraction()
    return 0.05
end

function Fade:TriggerShadowStep(direction)

    if not self:GetHasMovementSpecial() then
        return
    end

    if direction:GetLength() == 0 then
        direction.z = 1
    end
    /*
    if direction.z == 1 then
        direction.x = 0
    end
    */
    local movementDirection = self:GetViewCoords():TransformVector(direction)    
    movementDirection:Normalize()

    if not self:GetIsBlinking() and not self:GetHasShadowStepCooldown() and self:GetEnergy() > kFadeShadowStepCost then
    
        // add small force in the direction we are stepping
        local currentSpeed = self:GetVelocity():GetLength()
        local shadowStepStrength = math.max(currentSpeed, 11) + 0.5
        self:SetVelocity(movementDirection * shadowStepStrength * self:GetSlowSpeedModifier())
        
        self.timeShadowStep = Shared.GetTime()
        self.shadowStepSpeed = kShadowStepSpeed
        self.shadowStepping = true
        self.shadowStepDirection = Vector(movementDirection)
        
        self:TriggerEffects("shadow_step", { effecthostcoords = Coords.GetLookIn(self:GetOrigin(), movementDirection) })
        
        self:DeductAbilityEnergy(kFadeShadowStepCost)
        self:TriggerUncloak()
        
    end
    
end

function Fade:OverrideInput(input)

    Alien.OverrideInput(self, input)
    
    if self:GetIsBlinking() then
    
        input.move.z = 1
        input.move.x = 0
        
    end
    
    return input
    
end

function Fade:OnProcessMove(input)

    Alien.OnProcessMove(self, input)
    
    if Server then
    
        if self.isScanned and self.timeLastScan + kFadeScanDuration < Shared.GetTime() then
            self.isScanned = false
        end
        
    end
    
    // move without manipulating velocity
    if self:GetIsShadowStepping() then
    
        self.shadowStepSpeed = math.max(0, self.shadowStepSpeed - input.time * 90)
        local completedMove, hitEntities, averageSurfaceNormal = self:PerformMovement(self.shadowStepDirection * self.shadowStepSpeed * input.time, 3)
        local breakShadowStep = false
        
        //stop when colliding with an enemy player
        if hitEntities then
        
            for _, entity in ipairs(hitEntities) do
            
                if entity:isa("Player") and GetAreEnemies(self, entity) then
                
                    breakShadowStep = true
                    break
                    
                end
            
            end
            
        end
        
        local enemyTeamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
        
        local function FilterFriendAndDead(entity)
            return HasMixin(entity, "Team") and entity:GetTeamNumber() == enemyTeamNumber and HasMixin(entity, "Live") and entity:GetIsAlive()
        end        
        
        // trigger break when enemy player is nearby
        if not breakShadowStep and self.shadowStepSpeed < 35 then
            breakShadowStep = #Shared.GetEntitiesWithTagInRange("class:Player", self:GetOrigin(), 1.8, FilterFriendAndDead) > 0
        end
        
        if breakShadowStep then
        
            self.shadowStepping = false
            self.shadowStepSpeed = 0
            local velocity = self:GetVelocity()
            velocity.x = 0
            velocity.z = 0
            self:SetVelocity(velocity)
            
        end
        
    end
    
end

function Fade:OnScan()

    if Server then
    
        self.timeLastScan = Shared.GetTime()
        self.isScanned = true
        
    end
    
end

function Fade:GetStepHeight()

    if self:GetIsBlinking() then
        return 2
    end
    
    return Player.GetStepHeight()
    
end

function Fade:SetDetected(state)

    if Server then
    
        if state then
        
            self.timeLastScan = Shared.GetTime()
            self.isScanned = true
            
        else
            self.isScanned = false
        end
        
    end
    
end

function Fade:TriggerBlink()
    self.ethereal = true
    self.landedAfterBlink = false
end

function Fade:OnBlinkEnd()
    self.ethereal = false
end

function Fade:PostUpdateMove(input, runningPrediction)

    if self.shadowStepSpeed == 0 then
        self.shadowStepping = false
    end

end
/*
function Fade:ModifyAttackSpeed(attackSpeedTable)
    attackSpeedTable.attackSpeed = attackSpeedTable.attackSpeed * 1.06
end
*/
function Fade:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, 0.8, 0)
end

if Server then

    function Fade:InitWeapons()

        Alien.InitWeapons(self)
        
        self:GiveItem(SwipeBlink.kMapName)
        self:SetActiveWeapon(SwipeBlink.kMapName)
        
    end

    function Fade:GetTierTwoTechId()
        return kTechId.ShadowStep
    end

    function Fade:GetTierThreeTechId()
        return kTechId.Vortex
    end

end

/*
function Fade:ModifyHeal(healTable)
    Alien.ModifyHeal(self, healTable)
    healTable.health = healTable.health * 1.7
end
*/

function Fade:GetAllowJumpAnimation()
    return not self:GetIsBlinking()
end

function Fade:OverrideVelocityGoal(velocityGoal)
    
    if not self:GetIsOnGround() and self:GetCrouching() then
        velocityGoal:Scale(0)
    end
    
end
/*
function Fade:HandleButtons(input)

    Alien.HandleButtons(self, input)
    
    if self:GetIsBlinking() then 
        input.commands = bit.bor(input.commands, Move.Crouch)    
    end

end
*/
function Fade:OnGroundChanged(onGround, impactForce, normal, velocity)

    Alien.OnGroundChanged(self, onGround, impactForce, normal, velocity)

    if onGround then
        self.landedAfterBlink = true
    end
    
end

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars)