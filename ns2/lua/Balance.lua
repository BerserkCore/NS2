// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Balance.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/BalanceHealth.lua")
Script.Load("lua/BalanceMisc.lua")

kTransformResourcesTime = 15
kTransformResourcesCost = 15
kTransformResourcesRate = 1

// commander has  to stay in command structure for the first kCommanderMinTime seconds of each round
kCommanderMinTime = 30

// commanders wont receive personal resources for X seconds after logging out
kCommanderResourceBlockTime = 30

kAutoBuildRate = 0.3

kUseGradualMeleeAttacks = false

// setting to true will prevent any placement and construction of marine structures on infested areas
kPreventMarineStructuresOnInfestation = false
kCorrodeMarineStructureArmorOnInfestation = true

kInfestationCorrodeDamagePerSecond = 15

kMaxSupply = 200
kSupplyPerTechpoint = 100

// used as fallback
kDefaultBuildTime = 8

// MARINE COSTS
kCommandStationCost = 15

kExtractorCost = 10

kExtractorArmorCost = 5
kExtractorArmorResearchTime = 20

kInfantryPortalCost = 20

kArmoryCost = 10
kArmsLabCost = 20

kAdvancedArmoryUpgradeCost = 30
kPrototypeLabCost = 40

kSentryCost = 5
kPowerNodeCost = 0

kMACCost = 5
kMineCost = 15
kDropMineCost = 15
kMineResearchCost  = 10
kTechEMPResearchCost = 0
kTechMACSpeedResearchCost = 10

kWelderTechResearchTime = 15

kShotgunCost = 20
kShotgunDropCost = 20
kShotgunTechResearchCost = 20

kGrenadeLauncherCost = 15
kGrenadeLauncherDropCost = 15
kGrenadeLauncherTechResearchCost = 15
kDetonationTimeTechResearchCost = 15

kAdvancedWeaponryResearchCost = 10

kFlamethrowerCost = 25
kFlamethrowerDropCost = 25
kFlamethrowerTechResearchCost = 20
kFlamethrowerRangeTechResearchCost = 10

kRoboticsFactoryCost = 10
kUpgradeRoboticsFactoryCost = 5
kUpgradeRoboticsFactoryTime = 20
kARCCost = 10
kARCSplashTechResearchCost = 15
kARCArmorTechResearchCost = 15
kWelderTechResearchCost = 0
kWelderCost = 3
kWelderDropCost = 5


kJetpackCost = 15
kJetpackDropCost = 15
kJetpackTechResearchCost = 25
kJetpackFuelTechResearchCost = 15
kJetpackArmorTechResearchCost = 15

kExosuitTechResearchCost = 30
kExosuitLockdownTechResearchCost = 20

kExosuitCost = 40
kExosuitDropCost = 50
kClawRailgunExosuitCost = 40
kDualExosuitCost = 60
kDualRailgunExosuitCost = 60

kDualMinigunTechResearchCost = 20
kClawRailgunTechResearchCost = 20
kDualRailgunTechResearchCost = 20

kCatPackTechResearchCost = 20
kWeapons1ResearchCost = 20
kWeapons2ResearchCost = 30
kWeapons3ResearchCost = 40

kArmor1ResearchCost = 20
kArmor2ResearchCost = 30
kArmor3ResearchCost = 40
kNanoArmorResearchCost = 20

kRifleUpgradeTechResearchCost = 10

kObservatoryCost = 10
kPhaseGateCost = 15
kPhaseTechResearchCost = 10

kResearchBioMassOneCost = 20
kBioMassOneTime = 25
kResearchBioMassTwoCost = 30
kBioMassTwoTime = 40
kResearchBioMassThreeCost = 70
kBioMassThreeTime = 60
kResearchBioMassFourCost = 100
kBioMassFourTime = 80

kHiveCost = 40

kHarvesterCost = 8

kShellCost = 20
kCragCost = 15

kSpurCost = 20
kShiftCost = 15

kVeilCost = 20
kShadeCost = 15

kWhipCost = 10
kEvolveBombardCost = 5

kGorgeCost = 5
kGorgeEggCost = 7
kLerkCost = 25
kLerkEggCost = 40
kFadeCost = 40
kFadeEggCost = 70
kOnosCost = 60
kOnosEggCost = 100

kSkulkUpgradeCost = 0
kGorgeUpgradeCost = 2
kLerkUpgradeCost = 3
kFadeUpgradeCost = 5
kOnosUpgradeCost = 8

kHydraCost = 3
kClogCost = 0
kGorgeTunnelCost = 5
kGorgeTunnelBuildTime = 10

kEnzymeCloudDuration = 3

kCarapaceCost = 0
kRegenerationCost = 0
kCamouflageCost = 0
kAuraCost = 0
kSilenceCost = 0
kAdrenalineCost = 0
kCelerityCost = 0

kPlayingTeamInitialTeamRes = 60
kMaxTeamResources = 200

kPlayerInitialIndivRes = 20
kCommanderInitialIndivRes = 20
kMaxPersonalResources = 100

kResourceTowerResourceInterval = 6
kTeamResourcePerTick = 1

kPlayerResPerInterval = 0.1 // was 1.25, but players now also get res while dead

kKillRewardMin = 0
kKillRewardMax = 0
kKillTeamReward = 0


// MARINE DAMAGE
kRifleDamage = 10
kRifleDamageType = kDamageType.Normal
kRifleClipSize = 50


kRifleMeleeDamage = 10
kRifleMeleeDamageType = kDamageType.Normal


kPistolDamage = 25
kPistolDamageType = kDamageType.Light
kPistolClipSize = 10
// not used yet
kPistolMinFireDelay = 0.1

kPistolAltDamage = 40


kWelderDamagePerSecond = 30
kWelderDamageType = kDamageType.Flame
kWelderFireDelay = 0.2

kSelfWeldAmount = 5
kMarineArmorWeldRate = 20

kAxeDamage = 25
kAxeDamageType = kDamageType.Structural


kGrenadeLauncherGrenadeDamage = 165
kGrenadeLauncherGrenadeDamageType = kDamageType.Structural
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 6
kGrenadeLifetime = 2.0
kGrenadeUpgradedLifetime = 1.5

kShotgunDamage = 10
kShotgunDamageType = kDamageType.Normal
kShotgunClipSize = 8
kShotgunBulletsPerShot = 17
kShotgunRange = 30

kNadeLauncherClipSize = 4

kFlamethrowerDamage = 23
kBurnDamagePerSecond = 2
kFlamethrowerDamageType = kDamageType.Flame
kFlamethrowerClipSize = 50
kFlamethrowerRange = 9
kFlamethrowerUpgradedRange = 11.5

kBurnDamagePerStackPerSecond = 3
kFlamethrowerMaxStacks = 20
kFlamethrowerBurnDuration = 6
kFlamethrowerStackRate = 0.4
kFlameRadius = 1.8
kFlameDamageStackWeight = 0.5

kExoDualGunModifier = 0.7

kMinigunDamage = 25
kMinigunDamageType = kDamageType.Heavy
kMinigunClipSize = 250

kClawDamage = 30
kClawDamageType = kDamageType.Structural

kRailgunDamage = 50
kRailgunChargeDamage = 150
kRailgunDamageType = kDamageType.Structural

kMACAttackDamage = 5
kMACAttackDamageType = kDamageType.Normal
kMACAttackFireDelay = 0.6


kMineDamage = 125
kMineDamageType = kDamageType.Light

kSentryAttackDamageType = kDamageType.Normal
kSentryAttackBaseROF = .15
kSentryAttackRandROF = 0.0
kSentryAttackBulletsPerSalvo = 1
kConfusedSentryBaseROF = 2.0

kSentryDamage = 5

kARCDamage = 450
kARCDamageType = kDamageType.Splash // splash damage hits friendly arcs as well
kARCRange = 26
kARCMinRange = 7

local kDamagePerUpgradeScalar = 0.1
kWeapons1DamageScalar = 1 + kDamagePerUpgradeScalar
kWeapons2DamageScalar = 1 + kDamagePerUpgradeScalar * 2
kWeapons3DamageScalar = 1 + kDamagePerUpgradeScalar * 3

kNanoShieldDamageReductionDamage = 0.25

// ALIEN DAMAGE
kBiteDamage = 75
kBiteDamageType = kDamageType.Normal
kBiteEnergyCost = 5.85

kLeapEnergyCost = 45

kParasiteDamage = 10
kParasiteDamageType = kDamageType.Normal
kParasiteEnergyCost = 30

kXenocideDamage = 200
kXenocideDamageType = kDamageType.Normal
kXenocideRange = 14
kXenocideEnergyCost = 30

kGorgeArmorTunnelDamagePerSecond = 5

kSpitDamage = 30
kSpitDamageType = kDamageType.Light
kSpitEnergyCost = 7

kBabblerPheromoneEnergyCost = 7
kBabblerDamage = 10

kBabblerCost = 1
kBabblerEggBuildTime = 8
kNumBabblerEggsPerGorge = 3
kNumBabblersPerEgg = 3

// Also see kHealsprayHealStructureRate
kHealsprayDamage = 8
kHealsprayDamageType = kDamageType.Biological
kHealsprayFireDelay = 0.8
kHealsprayEnergyCost = 12
kHealsprayRadius = 3.5

kBileBombDamage = 55 // per second
kBileBombDamageType = kDamageType.Corrode
kBileBombEnergyCost = 20
kBileBombDuration = 5
// 200 inches in NS1 = 5 meters
kBileBombSplashRadius = 6

kWebBuildCost = 1
kWebbedDuration = 1

kLerkBiteDamage = 60
kBitePoisonDamage = 6 // per second
kPoisonBiteDuration = 6
kLerkBiteEnergyCost = 5
kLerkBiteDamageType = kDamageType.Normal

kUmbraEnergyCost = 27
kUmbraDuration = 5
kUmbraRadius = 6

kUmbraShotgunModifier = 0.64
kUmbraBulletModifier = 0.75
kUmbraMinigunModifier = 0.70

kSpikeMaxDamage = 9.3
kSpikeMinDamage = 9.3
kSpikeDamageType = kDamageType.Puncture
kSpikeEnergyCost = 1.4
kSpikesAttackDelay = 0.07
kSpikeMinDamageRange = 9
kSpikeMaxDamageRange = 2
kSpikesRange = 50
kSpikesPerShot = 1

kSporesDamageType = kDamageType.Gas
kSporesDustDamagePerSecond = 20
kSporesDustFireDelay = 0.36
kSporesDustEnergyCost = 8
kSporesDustCloudRadius = 2.5
kSporesDustCloudLifetime = 8

kSwipeDamage = 50
kSwipeDamageType = kDamageType.Puncture
kSwipeEnergyCost = 7

kVortexEnergyCost = 20
kVortexDuration = 3

kStartBlinkEnergyCost = 13
kBlinkEnergyCost = 32
kHealthOnBlink = 0

kGoreDamage = 100
kGoreDamageType = kDamageType.Structural
kGoreEnergyCost = 12

kBoneShieldEnergyPerSecond = 26
kStartBoneShieldCost = 10
kBoneShieldDamageAbsorbPerEnergy = 10

// bone shield absorbs maximum of 75% damage
kBoneShieldAbsorbFraction = 0.75

kPrimalScreamEnergyCost = 40

kStompEnergyCost = 30
kStompRange = 12
kDisruptMarineTime = 2
kDisruptMarineTimeout = 4
kShockwaveSpeed = 10

kDrifterAttackDamage = 5
kDrifterAttackDamageType = kDamageType.Normal
kDrifterAttackFireDelay = 0.6

kMelee1DamageScalar = 1.1
kMelee2DamageScalar = 1.2
kMelee3DamageScalar = 1.3

kWhipBombardDamage = 600
kWhipBombardDamageType = kDamageType.Corrode
kWhipBombardRadius = 6
kWhipBombardRange = 10
kWhipBombardROF = 6





// SPAWN TIMES
kMarineRespawnTime = 9

kAlienSpawnTime = 10
kEggGenerationRate = 13
kAlienEggsPerHive = 3

// BUILD/RESEARCH TIMES
kRecycleTime = 12
kArmoryBuildTime = 12
kAdvancedArmoryResearchTime = 90
kWeaponsModuleAddonTime = 40
kPrototypeLabBuildTime = 20
kArmsLabBuildTime = 17

kMACBuildTime = 5
kExtractorBuildTime = 11
kResourceUpgradeResearchTime = 30
kResourceUpgradeAmount = 0.3333

kInfantryPortalBuildTime = 7

kRifleUpgradeTechResearchTime = 20
kShotgunTechResearchTime = 30
kGrenadeLauncherTechResearchTime = 20
kDetonationTimeTechResearchTime = 60

kAdvancedWeaponryResearchTime = 35

kCommandStationBuildTime = 15

kSentryBatteryCost = 10
kSentryBatteryBuildTime = 5

kRoboticsFactoryBuildTime = 8
kARCBuildTime = 7
kARCSplashTechResearchTime = 30
kARCArmorTechResearchTime = 30

kNanoShieldDuration = 3
kSentryBuildTime = 3

kNanoShieldResearchCost = 15
kNanoSnieldResearchTime = 60

kMineResearchTime  = 20
kTechEMPResearchTime = 60
kTechMACSpeedResearchTime = 15

kJetpackTechResearchTime = 90
kJetpackFuelTechResearchTime = 60
kJetpackArmorTechResearchTime = 60
kExosuitTechResearchTime = 90
kExosuitLockdownTechResearchTime = 60
kExosuitUpgradeTechResearchTime = 60

kFlamethrowerTechResearchTime = 60
kFlamethrowerAltTechResearchTime = 60
kFlamethrowerRangeTechResearchTime = 60

kDualMinigunTechResearchTime = 60
kClawRailgunTechResearchTime = 60
kDualRailgunTechResearchTime = 60
kCatPackTechResearchTime = 15

kObservatoryBuildTime = 15
kPhaseTechResearchTime = 45
kPhaseGateBuildTime = 12

kWeapons1ResearchTime = 80
kWeapons2ResearchTime = 100
kWeapons3ResearchTime = 120
kArmor1ResearchTime = 80
kArmor2ResearchTime = 100
kArmor3ResearchTime = 120

kNanoArmorResearchTime = 60

kHiveBuildTime = 180

kDrifterBuildTime = 4
kHarvesterBuildTime = 38

kShellBuildTime = 18
kCragBuildTime = 25

kWhipBuildTime = 15
kEvolveBombardResearchTime = 15

kSpurBuildTime = 16
kShiftBuildTime = 18

kVeilBuildTime = 14
kShadeBuildTime = 18
kEvolveHallucinationsResearchTime = 30

kHydraBuildTime = 13
kCystBuildTime = 2.2

kSkulkGestateTime = 3
kGorgeGestateTime = 7
kLerkGestateTime = 15
kFadeGestateTime = 25
kOnosGestateTime = 30

kEvolutionGestateTime = 3

kGorgeTunnelResearchCost = 5
kGorgeTunnelResearchTime = 30
kSpikesResearchCost = 5
kSpikesResearchTime = 30
kLeapResearchCost = 20
kLeapResearchTime = 30
kBileBombResearchCost = 15
kBileBombResearchTime = 40
kShadowStepResearchCost = 15
kShadowStepResearchTime = 40
kUmbraResearchCost = 20
kUmbraResearchTime = 45
kBoneShieldResearchCost = 15
kBoneShieldResearchTime = 40
kSporesResearchCost = 20
kSporesResearchTime = 60
kStompResearchCost = 20
kStompResearchTime = 60
kXenocideResearchCost = 15
kXenocideResearchTime = 60
kVortexResearchCost = 15
kVortexResearchTime = 60
kWebResearchCost = 15
kWebResearchTime = 60

kCarapaceResearchTime = 15
kRegenerationResearchTime = 15
kAuraResearchTime = 15
kCamouflageResearchTime = 15
kSilenceResearchTime = 15
kCelerityResearchTime = 15
kHyperMutationResearchTime = 15
kAdrenalineResearchTime = 15
kPiercingResearchTime = 15

kFeintResearchTime = 15
kSapResearchTime = 15

kBoneShieldResearchTime = 20



kCommandStationInitialEnergy = 100  kCommandStationMaxEnergy = 250
kNanoShieldCost = 5
kNanoShieldCooldown = 10
kEMPCost = 50

kPowerSurgeCooldown = 20
kPowerSurgeDuration = 20
kPowerSurgeCost = 5

kArmoryInitialEnergy = 100  kArmoryMaxEnergy = 150

kAmmoPackCost = 1
kMedPackCost = 1
kMedPackCooldown = 0
kCatPackCost = 2

kHiveInitialEnergy = 50  kHiveMaxEnergy = 200
kMatureHiveMaxEnergy = 250
kCystCost = 1
kCystCooldown = 0.0

kDrifterInitialEnergy = 50
kDrifterMaxEnergy = 200

kEnzymeCloudCost = 2
kEnzymeCloudCooldown = 2

kHallucinationCloudCost = 1
kMucousMembraneCost = 1
kStormCost = 1
kDrifterAbilityCooldown = 5

kNutrientMistCost = 1
kNutrientMistCooldown = 2

kRuptureCost = 2
kRuptureCooldown = 2
kBoneWallCost = 3
kBoneWallCooldown = 10
// Note: If kNutrientMistDuration changes, there is a tooltip that needs to be updated.
kNutrientMistDuration = 15

// 100% + X (increases by 66%, which is 10 second reduction over 15 seconds)
kNutrientMistPercentageIncrease = 66
kNutrientMistMaturingIncrease = 66

kObservatoryInitialEnergy = 25  kObservatoryMaxEnergy = 100
kObservatoryScanCost = 3
kObservatoryDistressBeaconCost = 10
kScanCooldown = 1

kMACInitialEnergy = 50  kMACMaxEnergy = 150
kDrifterCost = 3

kCragInitialEnergy = 25  kCragMaxEnergy = 100 
kCragHealWaveCost = 3
kHealWaveCooldown = 6
kMatureCragMaxEnergy = 150

kHydraDamage = 15 // From NS1
kHydraAttackDamageType = kDamageType.Normal

kWhipInitialEnergy = 25  kWhipMaxEnergy = 100
kMatureWhipMaxEnergy = 150

kShiftInitialEnergy = 50  kShiftMaxEnergy = 150
kShiftHatchCost = 5
kShiftHatchRange = 11
kMatureShiftMaxEnergy = 200

kEchoHydraCost = 1
kEchoWhipCost = 1
kEchoTunnelCost = 5
kEchoCragCost = 1
kEchoShadeCost = 1
kEchoShiftCost = 1
kEchoVeilCost = 1
kEchoSpurCost = 1
kEchoShellCost = 1
kEchoHiveCost = 10
kEchoEggCost = 2
kEchoHarvesterCost = 1

kShadeInitialEnergy = 25  kShadeMaxEnergy = 100
kShadeInkCost = 3
kShadeInkCooldown = 12.8
kShadeInkDuration = 6.3
kMatureShadeMaxEnergy = 150

kEnergyUpdateRate = 0.5

// This is for CragHive, ShadeHive and ShiftHive
kUpgradeHiveCost = 10
kUpgradeHiveResearchTime = 20

kHiveBiomass = 1

kCragBiomass = 0
kShadeBiomass = 0
kShiftBiomass = 0
kWhipBiomass = 0
kHarvesterBiomass = 0
kShellBiomass = 0
kVeilBiomass = 0
kSpurBiomass = 0
