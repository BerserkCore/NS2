// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Alien_Server.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/AlienUpgradeManager.lua")

function Alien:TriggerEnzyme(duration)

    if not self:GetIsOnFire() then
        self.timeWhenEnzymeExpires = duration + Shared.GetTime()
    end
    
end

function Alien:CancelEnzyme()

    if self.timeWhenEnzymeExpires > Shared.GetTime() then        
        self.timeWhenEnzymeExpires = Shared.GetTime()
    end
    
end

function Alien:Reset()

    Player.Reset(self)
    
    self.oneHive = false
    self.twoHives = false
    self.threeHives = false
    
end

function Alien:OnProcessMove(input)
    
    self.hasAdrenalineUpgrade = GetHasAdrenalineUpgrade(self)
    
    // need to clear this value or spectators would see the hatch effect every time they cycle through players
    if self.hatched and self.creationTime + 3 < Shared.GetTime() then
        self.hatched = false
    end
    
    Player.OnProcessMove(self, input)
    
    // In rare cases, Player.OnProcessMove() above may cause this entity to be destroyed.
    // The below code assumes the player is not destroyed.
    if not self:GetIsDestroyed() then
    
        // Calculate two and three hives so abilities for abilities        
        UpdateAbilityAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId())

        self.enzymed = self.timeWhenEnzymeExpires > Shared.GetTime()
        self.electrified = self.timeElectrifyEnds > Shared.GetTime()

        self:UpdateAutoHeal()
        self:UpdateSilenceLevel()
        
    end
    
end

function Alien:UpdateSilenceLevel()

    if GetHasSilenceUpgrade(self) then
        self.silenceLevel = GetVeilLevel(self:GetTeamNumber())
    else
        self.silenceLevel = 0
    end

end

function Alien:UpdateAutoHeal()

    PROFILE("Alien:UpdateAutoHeal")

    if self:GetIsHealable() and ( not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() ) then

        local healRate = 1
        local hasRegenUpgrade = GetHasRegenerationUpgrade(self)
        local shellLevel = GetShellLevel(self:GetTeamNumber())
        local maxHealth = self:GetBaseHealth()
        
        if hasRegenUpgrade and shellLevel > 0 then
            healRate = Clamp(kAlienRegenerationPercentage * maxHealth, kAlienMinRegeneration, kAlienMaxRegeneration) * (shellLevel/3)
        else
            healRate = Clamp(kAlienInnateRegenerationPercentage * maxHealth, kAlienMinInnateRegeneration, kAlienMaxInnateRegeneration) 
        end
        
        if self:GetIsInCombat() then
            healRate = healRate * kAlienRegenerationCombatModifier
        end

        self:AddHealth(healRate, false, false, not hasRegenUpgrade)  
        self.timeLastAlienAutoHeal = Shared.GetTime()
    
    end 

end

function Alien:GetDamagedAlertId()
    return kTechId.AlienAlertLifeformUnderAttack
end

// Morph into new class or buy upgrade.
function Alien:ProcessBuyAction(techIds)

    ASSERT(type(techIds) == "table")
    ASSERT(table.count(techIds) > 0)

    local success = false
    local healthScalar = self:GetHealth() / self:GetMaxHealth()
    local armorScalar = self:GetMaxArmor() == 0 and 1 or self:GetArmor() / self:GetMaxArmor()
    local totalCosts = 0
    
    local upgradeIds = {}
    local lifeFormTechId = nil
    for _, techId in ipairs(techIds) do
        
        if LookupTechData(techId, kTechDataGestateName) then
            lifeFormTechId = techId
        else
            table.insertunique(upgradeIds, techId)
        end
        
    end

    local oldLifeFormTechId = self:GetTechId()
    
    local upgradesAllowed = true
    local upgradeManager = AlienUpgradeManager()
    upgradeManager:Populate(self)
    // add this first because it will allow switching existing upgrades
    if lifeFormTechId then
        upgradeManager:AddUpgrade(lifeFormTechId)
    end
    for _, newUpgradeId in ipairs(techIds) do

        if newUpgradeId ~= kTechId.None and not upgradeManager:AddUpgrade(newUpgradeId, true) then
            upgradesAllowed = false 
            break
        end
        
    end

    if upgradesAllowed then
    
        // Check for room
        local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
        local newLifeFormTechId = upgradeManager:GetLifeFormTechId()
        local newAlienExtents = LookupTechData(newLifeFormTechId, kTechDataMaxExtents)
        local physicsMask = PhysicsMask.Evolve
        local position = self:GetOrigin()
        -- Add a bit to the extents when looking for a clear space to spawn.
        local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
        
        local evolveAllowed = self:GetIsOnGround()
        evolveAllowed = evolveAllowed and GetHasRoomForCapsule(eggExtents + spawnBufferExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self)
        evolveAllowed = evolveAllowed and GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, position + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self)
        
        // If not on the ground for the buy action, attempt to automatically
        // put the player on the ground in an area with enough room for the new Alien.
        if not evolveAllowed then
        
            for index = 1, 100 do
            
                local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, math.max(newAlienExtents.x, newAlienExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
                if spawnPoint then
                
                    self:SetOrigin(spawnPoint)
                    position = spawnPoint
                    evolveAllowed = true
                    break
                    
                end
                
            end
            
        end

        if evolveAllowed then

            local newPlayer = self:Replace(Embryo.kMapName)
            position.y = position.y + Embryo.kEvolveSpawnOffset
            newPlayer:SetOrigin(position)
            
            // Clear angles, in case we were wall-walking or doing some crazy alien thing
            local angles = Angles(self:GetViewAngles())
            angles.roll = 0.0
            angles.pitch = 0.0
            newPlayer:SetOriginalAngles(angles)
            
            // Eliminate velocity so that we don't slide or jump as an egg
            newPlayer:SetVelocity(Vector(0, 0, 0))                
            newPlayer:DropToFloor()
            
            newPlayer:SetResources(upgradeManager:GetAvailableResources())
            newPlayer:SetGestationData(upgradeManager:GetUpgrades(), self:GetTechId(), self:GetHealthFraction(), self:GetArmorScalar())
            
            if oldLifeFormTechId and lifeFormTechId and oldLifeFormTechId ~= lifeFormTechId then
                newPlayer.oneHive = false
                newPlayer.twoHives = false
                newPlayer.threeHives = false
            end
            
            success = true
            
        end    
        
    end
    
    if not success then
        self:TriggerInvalidSound()
    end    
    
    return success
    
end

function Alien:GetTierOneTechId()
    return kTechId.None
end

function Alien:GetTierTwoTechId()
    return kTechId.None
end

function Alien:GetTierThreeTechId()
    return kTechId.None
end

function Alien:OnKill(attacker, doer, point, direction)

    Player.OnKill(self, attacker, doer, point, direction)
    
    self.storedHyperMutationCost = 0
    self.oneHive = false
    self.twoHives = false
    self.threeHives = false
    
end

function Alien:CopyPlayerDataFrom(player)

    Player.CopyPlayerDataFrom(self, player)
    
    self.oneHive = player.oneHive
    self.twoHives = player.twoHives
    self.threeHives = player.threeHives
    
    if self:GetTeamType() == kAlienTeamType then
    
        self.storedHyperMutationTime = player.storedHyperMutationTime
        self.storedHyperMutationCost = player.storedHyperMutationCost
        
    end
    
end