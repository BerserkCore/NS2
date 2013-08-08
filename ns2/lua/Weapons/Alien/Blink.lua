// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Weapons\Alien\Blink.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Blink - Attacking many times in a row will create a cool visual "chain" of attacks, 
// showing the more flavorful animations in sequence. Base class for swipe and vortex,
// available at tier 2.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")

class 'Blink' (Ability)

Blink.kMapName = "blink"

// initial force added when starting blink
local kEtherealForce = 13.5
// always add a little above top speed
local kBlinkAddForce = 0.3
local kEtherealVerticalForce = 2

local networkVars =
{
}

function Blink:OnInitialized()

    Ability.OnInitialized(self)
    
    self.secondaryAttacking = false
    self.timeBlinkStarted = 0
    
end

function Blink:OnHolster(player)

    Ability.OnHolster(self, player)
    
    self:SetEthereal(player, false)
    
end

function Blink:GetHasSecondary(player)
    return true // player:GetHasTwoHives()
end

function Blink:GetSecondaryAttackRequiresPress()
    return true
end

local function TriggerBlinkOutEffects(self, player)

    // Play particle effect at vanishing position.
    if not Shared.GetIsRunningPrediction() then
    
        self:TriggerEffects("blink_out", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
        
        if Client and player:GetIsLocalPlayer() then
            self:TriggerEffects("blink_out_local", { effecthostcoords = Coords.GetTranslation(player:GetOrigin()) })
        end
        
    end
    
end

local function TriggerBlinkInEffects(self, player)

    if not Shared.GetIsRunningPrediction() then
        self:TriggerEffects("blink_in", { effecthostcoords = Coords.GetTranslation(player:GetOrigin()) })
    end
    
end

function Blink:GetIsBlinking()

    local player = self:GetParent()
    
    if player then
        return player:GetIsBlinking()
    end
    
    return false
    
end

// Cannot attack while blinking.
function Blink:GetPrimaryAttackAllowed()
    return not self:GetIsBlinking()
end

function Blink:GetSecondaryEnergyCost(player)
    return kStartBlinkEnergyCost
end

function Blink:OnSecondaryAttack(player)

    local minTimePassed = not player:GetRecentlyBlinked()
    local hasEnoughEnergy = player:GetEnergy() > kStartBlinkEnergyCost
    if not player.etherealStartTime or minTimePassed and hasEnoughEnergy and self:GetBlinkAllowed() then
    
        // Enter "ether" fast movement mode, but don't keep going ethereal when button still held down after
        // running out of energy.
        if not self.secondaryAttacking then
        
            self:SetEthereal(player, true)
            
            self.timeBlinkStarted = Shared.GetTime()
            
            self.secondaryAttacking = true
            
            TEST_EVENT("Blink started")
            
        end
        
    end
    
    Ability.OnSecondaryAttack(self, player)
    
end

function Blink:OnSecondaryAttackEnd(player)

    if player.ethereal then
    
        self:SetEthereal(player, false)
        TEST_EVENT("Blink ended, button released")
        
    end
    
    Ability.OnSecondaryAttackEnd(self, player)
    
    self.secondaryAttacking = false
    
end

function Blink:SetEthereal(player, state)

    // Enter or leave ethereal mode.
    if player.ethereal ~= state then
    
        if state then
        
            player.etherealStartTime = Shared.GetTime()
            TriggerBlinkOutEffects(self, player)
            player:AddHealth(kHealthOnBlink)
            
            local currentVelocity = player:GetViewCoords().zAxis:DotProduct(player:GetVelocity())
            
            local celerityLevel = GetHasCelerityUpgrade(player) and GetSpurLevel(player:GetTeamNumber()) or 0
            local maxSpeed = kEtherealForce + celerityLevel * 1
            
            // need to handle celerity different for the fade. blink is a big part of the basic movement, celerity wont be significant enough if not considered here
            local celerityMultiplier = 1 + celerityLevel * 0.7

            local addSpeed = Clamp(maxSpeed - currentVelocity, 0, maxSpeed) + kBlinkAddForce * celerityMultiplier
            local newVelocity = player:GetViewCoords().zAxis * addSpeed + player:GetVelocity()
            if player:GetIsOnGround() then
                newVelocity.y = math.max(newVelocity.y, kEtherealVerticalForce)
            end
            
            player:SetVelocity(newVelocity)
            player.onGround = false
            player.jumping = true
            
        else
        
            TriggerBlinkInEffects(self, player)
            player.etherealEndTime = Shared.GetTime()
            
        end
        
        player.ethereal = state        
        player:SetEthereal(state)
        
        // Give player initial velocity in direction we're pressing, or forward if not pressing anything.
        if player.ethereal then
        
            // Deduct blink start energy amount.
            player:DeductAbilityEnergy(kStartBlinkEnergyCost)
            player:TriggerBlink()
            
        else
            player:OnBlinkEnd()
        end
        
    end
    
end

function Blink:ProcessMoveOnWeapon(player, input)
 
    if self:GetIsActive() and player.ethereal then
    
        // Decrease energy while in blink mode.
        // Don't deduct energy for blink for a short time to make sure that when we blink,
        // we always get at least a short blink out of it.
        if Shared.GetTime() > (self.timeBlinkStarted + 0.08) then
        
            local energyCost = input.time * kBlinkEnergyCost
            player:DeductAbilityEnergy(energyCost)
            
        end
        
    end
    
    // End blink mode if out of energy or when dead
    if (player:GetEnergy() == 0 or not player:GetIsAlive()) and player.ethereal then
    
        self:SetEthereal(player, false)
        TEST_EVENT("Blink ended, out of energy")
        
    end
    
end

function Blink:OnUpdateAnimationInput(modelMixin)

    local player = self:GetParent()
    if self:GetIsBlinking() then
        modelMixin:SetAnimationInput("move", "blink")
    end
    
end

Shared.LinkClassToMap("Blink", Blink.kMapName, networkVars)