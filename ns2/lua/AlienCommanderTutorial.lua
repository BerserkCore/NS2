// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AlienCommanderTutorial.lua
//
// Created by: Andreas Urwalek (and@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommanderTutorialUtility.lua")

local buildCystString = "All structures need infestation. To expand it, you need to first select the build menu [1:BuildMenu], then select the Cyst [2:Cyst] icon and place it."
buildCystSteps = 
{
    { CompletionFunc = GetHasMenuSelected(kTechId.BuildMenu), HighlightButton = kTechId.BuildMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Cyst), HighlightButton = kTechId.Cyst, HighlightWorld = GetPointBetween(GetCommandStructureOrigin, GetClosestFreeResourcePoint) },
}
AddCommanderTutorialEntry(0, kAlienTeamType, buildCystString, buildCystSteps)


local infestNode = "You need a higher resource [CollectResources] income. Build a cyst [1:Cyst] next to the closest resource node, then once the infestation has spread over the node, select the harvester [2:Harvester] from the build menu and drop it on the resource node."
buildHarvesterSteps = 
{
    { CompletionFunc = GetHasPointInfested(GetClosestFreeResourcePoint), HighlightButton = kTechId.Cyst, HighlightWorld = GetClosestFreeResourcePoint },
    { CompletionFunc = GetHasTechUsed(kTechId.Harvester), HighlightButton = kTechId.Harvester, HighlightWorld = GetClosestFreeResourcePoint },
}
AddCommanderTutorialEntry(kHarvesterCost, kAlienTeamType, infestNode, buildHarvesterSteps)


local drifterConstruct = "You can increase the grow rate of any structure by using Drifters [1:DrifterEgg], which can be build on infestation. Drifters will automatically search for ungrown structures in range, but you can also manually order them."
drifterConstructSteps = 
{
    { CompletionFunc = GetHasTechUsed(kTechId.DrifterEgg), HighlightButton = kTechId.DrifterEgg, HighlightWorld = GetClosestUnbuiltStructurePosition() },
}
AddCommanderTutorialEntry(kDrifterCost, kAlienTeamType, drifterConstruct, drifterConstructSteps)


local upgradeHive = "Your team needs upgrades. You first need to select the Hive [1:Hive] , then chose one of the three hive types [2:CragHive] [2:ShadeHive] [2:ShiftHive]."
hiveUpgradeSteps =
{
    { CompletionFunc = GetHasUnitSelected(kTechId.Hive), HighlightWorld = GetCommandStructureOrigin },
    { CompletionFunc = GetHasTechUsed({kTechId.UpgradeToCragHive, kTechId.UpgradeToShiftHive, kTechId.UpgradeToShadeHive}), HighlightButton = {kTechId.UpgradeToCragHive, kTechId.UpgradeToShiftHive, kTechId.UpgradeToShadeHive} },
}
AddCommanderTutorialEntry(kUpgradeHiveCost, kAlienTeamType, upgradeHive, hiveUpgradeSteps, nil, GetHasUnit(kTechId.Hive), nil, "BUILD_CHAMBER")


local buildShell = "Select the advanced build menu [1:AdvancedMenu] and build a Shell [2:Shell] next to your Hive. This unlocks new upgrades for your team, build a maximum of three for increase upgrade strength."
local buildShellSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Shell), HighlightButton = kTechId.Shell, HighlightWorld = GetAnchorPoint },
}
AddCommanderTutorialEntry(kShellCost, kAlienTeamType, buildShell, buildShellSteps, GetPlaceForUnit(kTechId.Shell, GetCommandStructureOrigin, GetIsPointOnInfestation), GetHasUnit(kTechId.CragHive), "BUILD_CHAMBER")


local buildVeil = "Select the advanced build menu [1:AdvancedMenu] and build a Veil [2:Veil] next to your Hive. This unlocks new upgrades for your team, build a maximum of three for increase upgrade strength."
local buildVeilSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Veil), HighlightButton = kTechId.Veil, HighlightWorld = GetAnchorPoint },
}
AddCommanderTutorialEntry(kVeilCost, kAlienTeamType, buildVeil, buildVeilSteps, GetPlaceForUnit(kTechId.Veil, GetCommandStructureOrigin, GetIsPointOnInfestation), GetHasUnit(kTechId.ShadeHive), "BUILD_CHAMBER")


local buildSpur = "Select the advanced build menu [1:AdvancedMenu] and build a Spur [2:Spur] next to your Hive. This unlocks new upgrades for your team, build a maximum of three for increase upgrade strength."
local buildSpurSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Spur), HighlightButton = kTechId.Spur, HighlightWorld = GetAnchorPoint },
}
AddCommanderTutorialEntry(kSpurCost, kAlienTeamType, buildSpur, buildSpurSteps, GetPlaceForUnit(kTechId.Spur, GetCommandStructureOrigin, GetIsPointOnInfestation), GetHasUnit(kTechId.ShiftHive), "BUILD_CHAMBER")


local buildSecondShell = "Select a the advanced build menu [1:AdvancedMenu] and build a second shell [2:SecondShell] "
local buildSecondShellSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Shell), HighlightButton = kTechId.Shell, HighlightWorld = GetAnchorPoint }
}
AddCommanderTutorialEntry(kShellCost, kAlienTeamType, buildSecondShell, buildSecondShellSteps, GetPlaceForUnit(kTechId.Shell, GetCommandStructureOrigin, GetIsPointOnInfestation), TutorialAlienChamberBuildSecond(kTechId.CragHive, kTechId.TwoShells))


local buildSecondSpur = "Select a the advanced build menu [1:AdvancedMenu] and build a second spur [2:SecondSpur] "
local buildSecondSpurSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Spur), HighlightButton = kTechId.Spur, HighlightWorld = GetAnchorPoint }
}
AddCommanderTutorialEntry(kSpurCost, kAlienTeamType, buildSecondSpur, buildSecondSpurSteps, GetPlaceForUnit(kTechId.Spur, GetCommandStructureOrigin, GetIsPointOnInfestation), TutorialAlienChamberBuildSecond(kTechId.ShiftHive, kTechId.TwoSpurs))



local buildSecondVeil = "Select a the advanced build menu [1:AdvancedMenu] and build a second veil [2:SecondVeil] "
local buildSecondVeilSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AdvancedMenu), HighlightButton = kTechId.AdvancedMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Veil), HighlightButton = kTechId.Veil, HighlightWorld = GetAnchorPoint }
}
AddCommanderTutorialEntry(kVeilCost, kAlienTeamType, buildSecondVeil, buildSecondVeilSteps, GetPlaceForUnit(kTechId.Veil, GetCommandStructureOrigin, GetIsPointOnInfestation), TutorialAlienChamberBuildSecond(kTechId.ShadeHive, kTechId.TwoVeils))


local viewTechMap = "To see an overview of all technologies, click on the Tech Map icon [1:Research] next to the minimap on the bottom left of your screen."
local viewTechMapSteps =
{
    { CompletionFunc = PlayerUI_GetIsTechMapVisible }
}
AddCommanderTutorialEntry(0, kAlienTeamType, viewTechMap, viewTechMapSteps)


local selectDrifter = "You can use your drifter not only to speed up construction time. Select the assist menu [1:AssistMenu], click on select drifter [2:SelectDrifter]"
local selectDrifterSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.AssistMenu), HighlightButton = kTechId.AssistMenu },
    { CompletionFunc = GetHasUnitSelected(kTechId.Drifter), HighlightButton = kTechId.SelectDrifter },
}
AddCommanderTutorialEntry(0, kAlienTeamType, selectDrifter, selectDrifterSteps, nil, GetHasUnit(kTechId.Drifter))


local orderDrifter = "With right click you can give the Drifter a move order [1:Move] The drifter also has a set of abilities to support your team mates. Click on Enzyme [2:EnzymeCloud] and select a target position."
local orderDrifterSteps =
{
    { CompletionFunc = GetSelectionHasOrder(kTechId.Move), HighlightButton = kTechId.Move },
    { CompletionFunc = GetHasTechUsed(kTechId.EnzymeCloud), HighlightButton = kTechId.EnzymeCloud },
}
AddCommanderTutorialEntry(0, kAlienTeamType, orderDrifter, orderDrifterSteps, nil, GetHasUnitSelected(kTechId.Drifter))



local upgradeGorge = "Every alien class has its own set of abilities. Not all of them are unlocked from the start. To upgrade the Gorge [Gorge] select your Hive [1:Hive] and click upgrade gorge [2:UpgradeGorge] This will unlock Babblers [BabblerEgg]"
local upgradeGorgeSteps =
{
    { CompletionFunc = GetHasClassSelected("Hive"), HighlightWorld = GetCommandStructureOrigin },
    { CompletionFunc = GetHasTechUsed(kTechId.UpgradeGorge), HighlightButton = kTechId.UpgradeGorge },
}
AddCommanderTutorialEntry(kUpgradeGorgeResearchCost, kAlienTeamType, upgradeGorge, upgradeGorgeSteps)



local buildHive = "Stronger abilities require a higher bio mass level. The current level is displayed at the top left of your screen. To increase the bio mass level, select the build menu [1:BuildMenu] and build another Hive [2:Hive] at a free tech point [TechPoint]"
local buildHiveSteps =
{
    { CompletionFunc = GetHasMenuSelected(kTechId.BuildMenu), HighlightButton = kTechId.BuildMenu },
    { CompletionFunc = GetHasTechUsed(kTechId.Hive), HighlightButton = kTechId.Hive, HighlightWorld = GetClosestFreeTechPoint }
}
AddCommanderTutorialEntry(kHiveCost, kAlienTeamType, buildHive, buildHiveSteps)


local orderDrifterToBuildHive = "To increase the grow rate of your Hive, select a Drifter [1:Drifter] and right click on the unbuilt hive [2:Grow] "
local orderDrifterToBuildHiveSteps =
{
    { CompletionFunc = GetHasUnitSelected(kTechId.Drifter), HighlightButton = {kTechId.AssistMenu, kTechId.SelectDrifter} },
    { CompletionFunc = GetSelectionHasOrder(kTechId.Grow, kTechId.Hive), HighlightButton = kTechId.Grow, HighlightWorld = GetClosestUnbuiltStructurePosition(kTechId.Hive) },
}
AddCommanderTutorialEntry(0, kAlienTeamType, orderDrifterToBuildHive, orderDrifterToBuildHiveSteps, nil, GetHasUnbuiltStructure(kTechId.Hive), nil, nil, 7)



local upgradeBioMass = "Every hive can provide a maximum of 3 bio mass level. To upgrade a hives level, select it [1:Hive] and click on research bio mass [2:ResearchBioMassOne]"
local upgradeBioMassSteps =
{
    { CompletionFunc = GetHasClassSelected("Hive"), HighlightWorld = GetCommandStructureOrigin },
    { CompletionFunc = GetHasTechUsed({kTechId.ResearchBioMassOne, kTechId.ResearchBioMassTwo}), HighlightButton = {kTechId.ResearchBioMassOne, kTechId.ResearchBioMassTwo} }
}
AddCommanderTutorialEntry(kResearchBioMassTwoCost, kAlienTeamType, upgradeBioMass, upgradeBioMassSteps)

