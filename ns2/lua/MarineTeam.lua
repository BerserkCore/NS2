// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MarineTeam.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// This class is used for teams that are actually playing the game, e.g. Marines or Aliens.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Marine.lua")
Script.Load("lua/PlayingTeam.lua")

class 'MarineTeam' (PlayingTeam)

// How often to send the "No IPs" message to the Marine team in seconds.
local kSendNoIPsMessageRate = 20

local kCannotSpawnSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/need_ip")

function MarineTeam:ResetTeam()

    local commandStructure = PlayingTeam.ResetTeam(self)
    
    self.updateMarineArmor = false
    
    if self.brain ~= nil then
        self.brain:Reset()
    end
    
    return commandStructure
    
end

function MarineTeam:OnResetComplete()

    //adjust first power node    
    local initialTechPoint = self:GetInitialTechPoint()
    for index, powerPoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do
    
        if powerPoint:GetLocationName() == initialTechPoint:GetLocationName() then
            powerPoint:SetConstructionComplete()
        end
        
    end
    
end

function MarineTeam:GetTeamType()
    return kMarineTeamType
end

function MarineTeam:GetIsMarineTeam()
    return true 
end

function MarineTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)
    
    self.respawnEntity = Marine.kMapName
    
    self.updateMarineArmor = false
    
    self.lastTimeNoIPsMessageSent = Shared.GetTime()
    
end

function MarineTeam:GetHasAbilityToRespawn()

    // Any active IPs on team? There could be a case where everyone has died and no active
    // IPs but builder bots are mid-construction so a marine team could theoretically keep
    // playing but ignoring that case for now
    local spawningStructures = GetEntitiesForTeam("InfantryPortal", self:GetTeamNumber())
    
    for index, current in ipairs(spawningStructures) do
    
        if current:GetIsBuilt() and current:GetIsPowered() then
            return true
        end
        
    end        
    
    return false
    
end

function MarineTeam:OnRespawnQueueChanged()

    local spawningStructures = GetEntitiesForTeam("InfantryPortal", self:GetTeamNumber())
    
    for index, current in ipairs(spawningStructures) do
    
        if current:GetIsBuilt() and current:GetIsPowered() then
            current:FillQueueIfFree()
        end
        
    end        
    
end

// Clear distress flag for all players on team, unless affected by distress beaconing Observatory. 
// This function is here to make sure case with multiple observatories and distress beacons is
// handled properly.
function MarineTeam:UpdateGameMasks(timePassed)

    local beaconState = false
    
    for obsIndex, obs in ipairs(GetEntitiesForTeam("Observatory", self:GetTeamNumber())) do
    
        if obs:GetIsBeaconing() then
        
            beaconState = true
            break
            
        end
        
    end
    
    for playerIndex, player in ipairs(self:GetPlayers()) do
    
        if player:GetGameEffectMask(kGameEffect.Beacon) ~= beaconState then
            player:SetGameEffectMask(kGameEffect.Beacon, beaconState)
        end
        
    end
    
end

local function CheckForNoIPs(self)

    if Shared.GetTime() - self.lastTimeNoIPsMessageSent >= kSendNoIPsMessageRate then
    
        self.lastTimeNoIPsMessageSent = Shared.GetTime()
        if Shared.GetEntitiesWithClassname("InfantryPortal"):GetSize() == 0 then
        
            self:ForEachPlayer(function(player) StartSoundEffectForPlayer(kCannotSpawnSound, player) end)
            SendTeamMessage(self, kTeamMessageTypes.CannotSpawn)
            
        end
        
    end
    
end

local function SpawnInfantryPortal(self, techPoint)

    local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
    
    local spawnPoint = nil
    
    // First check the predefined spawn points. Look for a close one.
    for p = 1, #Server.infantryPortalSpawnPoints do
    
        local predefinedSpawnPoint = Server.infantryPortalSpawnPoints[p]
        if (predefinedSpawnPoint - techPointOrigin):GetLength() <= kInfantryPortalAttachRange then
            spawnPoint = predefinedSpawnPoint
        end
        
    end
    
    // Fallback on the random method if there is no nearby spawn point.
    if not spawnPoint then
    
        for i = 1, 50 do
        
            local origin = CalculateRandomSpawn(nil, techPointOrigin, kTechId.InfantryPortal, true, kInfantryPortalMinSpawnDistance * 1, kInfantryPortalMinSpawnDistance * 2.5, 3)
            
            if origin then
                spawnPoint = origin - Vector(0, 0.1, 0)
            end
            
        end
        
    end
    
    if spawnPoint then
    
        local ip = CreateEntity(InfantryPortal.kMapName, spawnPoint, self:GetTeamNumber())
        
        SetRandomOrientation(ip)
        ip:SetConstructionComplete()
        
    end
    
end

local function GetArmorLevel(self)

    local armorLevels = 0
    
    local techTree = self:GetTechTree()
    if techTree then
    
        if techTree:GetHasTech(kTechId.Armor3) then
            armorLevels = 3
        elseif techTree:GetHasTech(kTechId.Armor2) then
            armorLevels = 2
        elseif techTree:GetHasTech(kTechId.Armor1) then
            armorLevels = 1
        end
    
    end
    
    return armorLevels

end

function MarineTeam:Update(timePassed)

    PlayingTeam.Update(self, timePassed)
    
    // Update distress beacon mask
    self:UpdateGameMasks(timePassed)    

    if GetGamerules():GetGameStarted() then
        CheckForNoIPs(self)
    end
    
    local newArmorLevel = GetArmorLevel(self)
    if self.armorLevel ~= newArmorLevel then
    
        self.armorLevel = newArmorLevel
    
        for index, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do
            player:UpdateArmorAmount(self.armorLevel)
        end
    
    end
    
end

function MarineTeam:GetHasPoweredPhaseGate()
    return self.hasPoweredPG == true    
end

function MarineTeam:InitTechTree()
   
   PlayingTeam.InitTechTree(self)
    
    // Marine tier 1
    self.techTree:AddBuildNode(kTechId.CommandStation,            kTechId.None,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.Extractor,                 kTechId.None,                kTechId.None)
    
    self.techTree:AddUpgradeNode(kTechId.ExtractorArmor)
    
    // Count recycle like an upgrade so we can have multiples
    self.techTree:AddUpgradeNode(kTechId.Recycle, kTechId.None, kTechId.None)
    
    self.techTree:AddPassive(kTechId.Welding)
    self.techTree:AddPassive(kTechId.SpawnMarine)
    self.techTree:AddPassive(kTechId.CollectResources)
    self.techTree:AddPassive(kTechId.Detector)
    
    self.techTree:AddSpecial(kTechId.TwoCommandStations)
    self.techTree:AddSpecial(kTechId.ThreeCommandStations)
    
    // When adding marine upgrades that morph structures, make sure to add to GetRecycleCost() also
    self.techTree:AddBuildNode(kTechId.InfantryPortal,            kTechId.None,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.Sentry,                    kTechId.RoboticsFactory,     kTechId.SentryBattery)
    self.techTree:AddBuildNode(kTechId.Armory,                    kTechId.CommandStation,      kTechId.None)  
    self.techTree:AddBuildNode(kTechId.ArmsLab,                   kTechId.None,                kTechId.None)  
    self.techTree:AddManufactureNode(kTechId.MAC,                 kTechId.None,                kTechId.None)
    
    self.techTree:AddTargetedActivation(kTechId.MedPack,             kTechId.None,                kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.AmmoPack,            kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Axe,                         kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Pistol,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Rifle,                       kTechId.None,                kTechId.None)

    self.techTree:AddBuildNode(kTechId.SentryBattery,             kTechId.RoboticsFactory,      kTechId.None)      
    
    self.techTree:AddOrder(kTechId.Defend)
    self.techTree:AddOrder(kTechId.FollowAndWeld)
    
    // Commander abilities
    self.techTree:AddResearchNode(kTechId.NanoShieldTech)
    self.techTree:AddTargetedActivation(kTechId.NanoShield,       kTechId.NanoShieldTech)
    self.techTree:AddTargetedActivation(kTechId.Scan,             kTechId.Observatory)
    self.techTree:AddTargetedActivation(kTechId.PowerSurge,       kTechId.RoboticsFactory)

    // Armory upgrades
    self.techTree:AddUpgradeNode(kTechId.AdvancedArmoryUpgrade,  kTechId.Armory)
    
    // arms lab upgrades
    
    self.techTree:AddResearchNode(kTechId.Armor1,                 kTechId.ArmsLab)
    self.techTree:AddResearchNode(kTechId.Armor2,                 kTechId.Armor1, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Armor3,                 kTechId.Armor2, kTechId.None)    
    self.techTree:AddResearchNode(kTechId.NanoArmor,              kTechId.None)
    
    self.techTree:AddResearchNode(kTechId.DetonationTimeTech,              kTechId.AdvancedArmory)
    self.techTree:AddResearchNode(kTechId.FlamethrowerRangeTech,              kTechId.AdvancedArmory)
    
    self.techTree:AddResearchNode(kTechId.Weapons1,               kTechId.ArmsLab)
    self.techTree:AddResearchNode(kTechId.Weapons2,               kTechId.Weapons1, kTechId.None)
    self.techTree:AddResearchNode(kTechId.Weapons3,               kTechId.Weapons2, kTechId.None)
    self.techTree:AddResearchNode(kTechId.CatPackTech,            kTechId.ArmsLab)
    
    // Marine tier 2
    self.techTree:AddUpgradeNode(kTechId.AdvancedArmory,               kTechId.Armory,        kTechId.None)
    self.techTree:AddResearchNode(kTechId.PhaseTech,                    kTechId.Observatory,        kTechId.None)
    self.techTree:AddBuildNode(kTechId.PhaseGate,                    kTechId.PhaseTech,        kTechId.None)


    self.techTree:AddBuildNode(kTechId.Observatory,               kTechId.InfantryPortal,       kTechId.Armory)      
    self.techTree:AddActivation(kTechId.DistressBeacon,           kTechId.Observatory)    
    
    // Build bot upgrades       
    self.techTree:AddActivation(kTechId.MACEMP,                 kTechId.None,                kTechId.None)        
    self.techTree:AddResearchNode(kTechId.MACEMPTech,          kTechId.RoboticsFactory,           kTechId.None)        
    self.techTree:AddResearchNode(kTechId.MACSpeedTech,           kTechId.InfantryPortal,            kTechId.None)        
    
    // Door actions
    self.techTree:AddBuildNode(kTechId.Door, kTechId.None, kTechId.None)
    self.techTree:AddActivation(kTechId.DoorOpen)
    self.techTree:AddActivation(kTechId.DoorClose)
    self.techTree:AddActivation(kTechId.DoorLock)
    self.techTree:AddActivation(kTechId.DoorUnlock)
    
    // Weapon-specific
    self.techTree:AddResearchNode(kTechId.ShotgunTech,           kTechId.Armory,              kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.Shotgun,                    kTechId.ShotgunTech,         kTechId.Armory)
    self.techTree:AddTargetedActivation(kTechId.DropShotgun,                    kTechId.ShotgunTech,         kTechId.Armory)
    
    self.techTree:AddResearchNode(kTechId.AdvancedWeaponry,           kTechId.AdvancedArmory,                   kTechId.None)    
    
    self.techTree:AddResearchNode(kTechId.GrenadeLauncherTech,           kTechId.AdvancedArmory,                   kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.GrenadeLauncher,                    kTechId.AdvancedArmory,             kTechId.AdvancedWeaponry)
    self.techTree:AddTargetedActivation(kTechId.DropGrenadeLauncher,                    kTechId.AdvancedArmory,             kTechId.AdvancedWeaponry)
    
    self.techTree:AddResearchNode(kTechId.FlamethrowerTech,              kTechId.AdvancedArmory,                   kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.Flamethrower,                       kTechId.AdvancedArmory,         kTechId.AdvancedWeaponry)
    self.techTree:AddTargetedActivation(kTechId.DropFlamethrower,                       kTechId.AdvancedArmory,         kTechId.AdvancedWeaponry)
    
    self.techTree:AddResearchNode(kTechId.MinesTech,        kTechId.Armory,           kTechId.None)
    self.techTree:AddTargetedBuyNode(kTechId.LayMines,      kTechId.MinesTech,        kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropMines,      kTechId.MinesTech,        kTechId.None)
    
    self.techTree:AddTargetedBuyNode(kTechId.Welder,         kTechId.None,        kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropWelder,         kTechId.None,        kTechId.None)
    
    // ARCs
    self.techTree:AddBuildNode(kTechId.RoboticsFactory,                    kTechId.InfantryPortal,              kTechId.None)  
    self.techTree:AddUpgradeNode(kTechId.UpgradeRoboticsFactory,           kTechId.Armory,              kTechId.RoboticsFactory) 
    self.techTree:AddBuildNode(kTechId.ARCRoboticsFactory,                 kTechId.Armory,              kTechId.RoboticsFactory)
    
    self.techTree:AddTechInheritance(kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory)
   
    self.techTree:AddManufactureNode(kTechId.ARC,                          kTechId.ARCRoboticsFactory,                kTechId.None)        
    self.techTree:AddActivation(kTechId.ARCDeploy)
    self.techTree:AddActivation(kTechId.ARCUndeploy)
    
    // Robotics factory menus
    self.techTree:AddMenu(kTechId.RoboticsFactoryARCUpgradesMenu)
    self.techTree:AddMenu(kTechId.RoboticsFactoryMACUpgradesMenu)
    
    self.techTree:AddMenu(kTechId.WeaponsMenu)
    
    // Marine tier 3
    self.techTree:AddBuildNode(kTechId.PrototypeLab,          kTechId.AdvancedArmory,              kTechId.None)        
    //self.techTree:AddResearchNode(kTechId.ARCSplashTech,           kTechId.RoboticsFactory,         kTechId.None)
    //self.techTree:AddResearchNode(kTechId.ARCArmorTech,           kTechId.RoboticsFactory,          kTechId.None)


    // Jetpack
    self.techTree:AddResearchNode(kTechId.JetpackTech,           kTechId.PrototypeLab, kTechId.None)
    self.techTree:AddResearchNode(kTechId.JetpackFuelTech,           kTechId.PrototypeLab, kTechId.JetpackTech)
    self.techTree:AddBuyNode(kTechId.Jetpack,                    kTechId.JetpackTech, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropJetpack,    kTechId.JetpackTech, kTechId.None)
    
    // Exosuit
    self.techTree:AddResearchNode(kTechId.ExosuitTech,           kTechId.PrototypeLab, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Exosuit,                    kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropExosuit,     kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.DualMinigunTech,       kTechId.ExosuitTech, kTechId.TwoCommandStations)
    self.techTree:AddResearchNode(kTechId.DualMinigunExosuit,    kTechId.DualMinigunTech, kTechId.TwoCommandStations)
    self.techTree:AddResearchNode(kTechId.ClawRailgunExosuit,    kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.DualRailgunTech,       kTechId.ExosuitTech, kTechId.TwoCommandStations)
    self.techTree:AddResearchNode(kTechId.DualRailgunExosuit,    kTechId.DualRailgunTech, kTechId.TwoCommandStations)
    
    self.techTree:AddResearchNode(kTechId.ExosuitLockdownTech,   kTechId.ExosuitTech, kTechId.TwoCommandStations)
    self.techTree:AddResearchNode(kTechId.ExosuitUpgradeTech,    kTechId.ExosuitTech, kTechId.TwoCommandStations)   
    
    self.techTree:AddActivation(kTechId.SocketPowerNode,    kTechId.None,   kTechId.None)
    
    self.techTree:SetComplete()

end

function MarineTeam:AwardPersonalResources(min, max, pointOwner)

    local resAwarded = math.random(min, max) 
    self:SplitPres(resAwarded)

end

function MarineTeam:SpawnInitialStructures(techPoint)

    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
    SpawnInfantryPortal(self, techPoint)
    
    return tower, commandStation
    
end

function MarineTeam:GetSpectatorMapName()
    return MarineSpectator.kMapName
end

function MarineTeam:OnBought(techId)

    local listeners = self.eventListeners['OnBought']

    if listeners then

        for _, listener in ipairs(listeners) do
            listener(techId)
        end

    end

end
