// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// CommanderTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "CommanderTest", package.seeall, lunit.testcase )

local marineCommander = nil
local commandStation = nil
local alienCommander = nil
local hive = nil
local extractor = nil

// Transforms player into commander and returns commander
function StartCommanding(player)
    
    commandStation:OnUse(player, .1, true)
    
    // Become commander right away
    commandStation:UpdateCommanderLogin(true)
    
    local commander = commandStation:GetCommander()
    assert_not_nil(commander)
    
    // Test that we're in commander mode
    assert_equal(commandStation.occupied, true)   

    // Make sure tech tree availability is computed
    commander:GetTeam():Update(.5) 
    
    extractor = GetEntitiesIsa("Extractor")[1]
    assert_not_nil(extractor)
    
    return commander
    
end

function SelectExtractor(player)

    local extractors = GetEntitiesIsa("Extractor") 
    assert_not_nil(extractors)
    assert_equal(1, table.count(extractors))
    local extractor = extractors[1]
    assert_not_nil(extractor)
    player:SetSelection( extractor:GetId() )
    
end

function getNumVisibleWeapons(player, expectedNum, logVisible)

    local numVisibleWeapons = 0
    local logMessage = string.format("getNumVisibleWeapons %s failed: ", ToString(expectedNum))
    
    local weapons = GetChildEntities(player, "Weapon")
    
    for index, weapon in ipairs(weapons) do
    
        if (weapon:GetIsVisible()) then
        
            numVisibleWeapons = numVisibleWeapons + 1
            if logVisible then
            
                local delim = ConditionalValue(index ~= 1, ", ", "")
                logMessage = logMessage .. delim .. SafeClassName(weapon)
                
            end            
            
        end
        
    end
    
    if numVisibleWeapons ~= expectedNum and logVisible then
        Print(logMessage)
    end
    
    return numVisibleWeapons
    
end

function GetUnattached(className, teamNumber)

    local entities = GetEntitiesIsa(className, -1)
    
    for index, current in ipairs(entities) do
    
        if (current:GetAttached() == nil) then
        
            if (teamNumber == nil or (current:GetTeamNumber() == teamNumber)) then
        
                return current
                
            end
            
        end
        
    end 
    
    return nil
    
end

function setup()

    SetPrintEnabled(true, "CommanderTest")
    
    GetGamerules():ResetGame()

    // Initialize both players first so we can run the update and have game start right away, not invalidating players
    InitializeMarine()
    InitializeAlien()
    
    // Allow weapons to draw
    RunOneUpdate(1)
    
    // Find command station, move to it and use it
    local ents = GetEntitiesIsa("CommandStation", 1)
    assert_equal(table.maxn(ents), 1)
       
    commandStation = ents[1]
    assert_not_equal(commandStation, nil)
    
    local marine = GetEntitiesIsa("Marine")[1]
    assert_not_nil(marine)
    assert_not_equal(Entity.invalidId, marine:GetId())
    
    assert_equal(1, getNumVisibleWeapons(marine, 1, true))

    marineCommander = StartCommanding(marine)    
    
    // Find command station, move to it and use it
    local ents = GetEntitiesIsa("Hive", 2)
    assert_equal(table.maxn(ents), 1)
    
    RunOneUpdate()
    
    hive = ents[1]
    assert_not_equal(hive, nil)

    local alien = GetEntitiesIsa("Skulk")[1]
    assert_not_nil(alien)
    assert_not_equal(Entity.invalidId, alien:GetId())
    assert_equal(1, getNumVisibleWeapons(alien, 1, true))
    
    hive:OnUse(alien, .1, false)
    
    hive:UpdateCommanderLogin(true)
    
    alienCommander = hive.commander
    assert_not_equal(alienCommander, nil)
    
    // Test that we're in commander mode
    assert_equal(commandStation.occupied, true)   
    assert_equal(hive.occupied, true)   
    
    // Make sure tech tree availability is computed. Also make sure
    // clip weapons have finished drawing.
    RunOneUpdate(2)
        
end

function teardown()
    Cleanup()
    marineCommander = nil
    commandStation  = nil
    alienCommander  = nil
    hive            = nil
end

function test1()

    // Build a build bot and verify resources deducted properly
    assert_true(marineCommander:GetIsEntityNameSelected("CommandStation"))
    RunOneUpdate(1)

    CommAction(marineCommander, kTechId.RootMenu)
    CommAction(marineCommander, kTechId.MAC)

    // Give time for mac to move to starting position away from command station
    RunOneUpdate(1)
    
    // Find MAC
    local macs = GetEntitiesIsa("MAC", 1)
    assert_equal(kInitialMACs + 1, table.maxn(macs))

    local macOrigin = Vector(macs[1]:GetOrigin()) + Vector(2, 0, 0)
    macs[1]:SetOrigin(macOrigin)
    
    local toMac = Vector(macs[1]:GetOrigin())
    toMac = toMac - Vector(marineCommander:GetOrigin() + marineCommander:GetViewOffset())
    toMac:Normalize()

    local toCommandStation = Vector(commandStation:GetOrigin())
    toCommandStation = toCommandStation - marineCommander:GetOrigin()
    toCommandStation:Normalize()

    assert_equal(true, marineCommander:GetIsEntityNameSelected("CommandStation"))
    assert_equal(false, marineCommander:GetIsEntityNameSelected("ResourceTower"))
    
    // Send select order to it
    marineCommander:ClickSelectEntities(toMac)
    
    // Verify it is selected
    //assert_true(marineCommander:GetIsEntityNameSelected("MAC"))
    //assert_false(marineCommander:GetIsEntityNameSelected("ResourceTower"))
    
    // Send it an order
    
    // marineCommander:SendTargetedAction(techId, normalizedPickRay

end

// Don't let non-resource towers be built on resource nozzles
// Don't let non-CommandStructures be built on techpoints
function test2()

    // Find empty resource nozzle
    local nozzle = GetUnattached("ResourcePoint")
    assert_not_nil(nozzle)
   
    // Try to build an armory on top of it
    assert_nil(CreateEntityForCommander(kTechId.Armory, nozzle:GetOrigin(), marineCommander))
    
    // Try to build an extractor on it
    local extractor = CreateEntityForCommander(kTechId.Extractor, nozzle:GetOrigin(), marineCommander)
    assert_not_nil(extractor)
    DestroyEntity(extractor)
    
    // Find an empty tech point
    local techPoint = GetUnattached("TechPoint", 2)
    assert_not_nil(techPoint)
    
    // Try to build an armory on that
    local armory = CreateEntityForCommander(kTechId.Armory, techPoint:GetOrigin(), marineCommander)
    assert_nil(armory)
    
    // Try to build a hive on it
    local hive = CreateEntityForCommander(kTechId.Hive, techPoint:GetOrigin(), marineCommander)
    assert_not_nil(hive)
    DestroyEntity(hive)
    
    RunOneUpdate(1)

end

function test3()
    
    // Make sure players don't have active weapons or view models when commander
    assert_equal(0, getNumVisibleWeapons(marineCommander, 0, true))
    assert_equal(0, getNumVisibleWeapons(alienCommander, 0, true))
    
    // Make sure we don't see our view models
    assert_nil(marineCommander:GetViewModelEntity()) 
    assert_nil(alienCommander:GetViewModelEntity()) 

    // Have both players log out and make sure we don't have any errors or weird behavior
    local newMarine = commandStation:Logout()
    assert_not_nil(newMarine)
    assert_equal(Marine.kMapName, newMarine:GetMapName())
    
    local newAlien = hive:Logout()
    assert_not_nil(newAlien)
    assert_equal(Skulk.kMapName, newAlien:GetMapName())
    
    RunOneUpdate(1)
        
    // Make sure we have view models
    assert_not_nil(newMarine:GetViewModelEntity())
    assert_not_nil(newAlien:GetViewModelEntity())    
    
    assert_equal(1, getNumVisibleWeapons(newMarine, 1, true))
    assert_equal(1, getNumVisibleWeapons(newAlien, 1, true))

    // If the alien one passes and marine one doesn't, it might be due to 
    // clip weapons not finished drawing. Might want to add more time to
    // setup:RunUpdate() above.
    assert_not_equal(0, newAlien:GetViewModelEntity():GetModelIndex())
    assert_not_equal(0, newMarine:GetViewModelEntity():GetModelIndex())  
        
end

// Test hotkeys, selection panel
function test4()

    local time = Shared.GetTime()
    local commandStationId = commandStation:GetId()

    // Select Command Station, try to make hotkey but it will fail
    // because this is default hotkey already made for us
    marineCommander:SetSelection( commandStationId )
    assert_true(marineCommander:GetIsSelected(commandStationId, true))
    
    assert_false(marineCommander:CreateHotkeyGroup(1))
    assert_equal(1, marineCommander:GetNumHotkeyGroups())

    assert_true(marineCommander:GetIsSelected(commandStationId))
    local selectedEnts = marineCommander:GetSelection()
    assert_not_nil(selectedEnts)
    assert_equal(1, table.count(selectedEnts))
        
    // Select extractor, create hotkey
    local extractors = GetEntitiesIsa("Extractor") 
    assert_not_nil(extractors)
    assert_equal(1, table.count(extractors))
    local extractor = extractors[1]
    assert_not_nil(extractor)
    local extractorId = extractor:GetId()
    
    marineCommander:SetSelection(extractorId)
    assert_true(marineCommander:CreateHotkeyGroup(2))
    assert_equal(2, marineCommander:GetNumHotkeyGroups())
    
    // Overwrite hotkey 1
    assert_true(marineCommander:CreateHotkeyGroup(1))
    assert_equal(2, marineCommander:GetNumHotkeyGroups())
    
    selectedEnts = marineCommander:GetSelection()
    assert_not_nil(selectedEnts)
    assert_equal(1, table.count(selectedEnts))
    assert_true(marineCommander:GetIsSelected(extractorId))

    // Try multiples
    marineCommander:SetSelection( {commandStationId, extractorId} )
    assert_true(marineCommander:CreateHotkeyGroup(1))
    assert_equal(2, marineCommander:GetNumHotkeyGroups())
    
    selectedEnts = marineCommander:GetSelection()
    assert_not_nil(selectedEnts)
    assert_equal(2, table.count(selectedEnts))
    
    // Verify console command
    assert_equal(string.format("hotgroup 1 %d_%d_", commandStationId, extractorId), marineCommander:SendHotkeyGroup(1))
    
    // Set no selection, then select hotkey
    marineCommander:ClearSelection()
    selectedEnts = marineCommander:GetSelection()
    assert_not_nil(selectedEnts)
    assert_equal(0, table.count(selectedEnts))
    
    // Move commander far away and check that it's still relevant
    marineCommander:SetOrigin( Vector(1000, 1000, 1000) )
    assert_true(marineCommander:GetIsEntityHotgrouped(extractor))
    assert_true(extractor:OnGetIsRelevant(marineCommander))
    
    assert_true(marineCommander:SelectHotkeyGroup(1))
    selectedEnts = marineCommander:GetSelection()
    assert_not_nil(selectedEnts)
    assert_equal(2, table.count(selectedEnts))    
    
    // Delete hotkeys
    assert_true(marineCommander:DeleteHotkeyGroup(1))
    assert_equal(1, marineCommander:GetNumHotkeyGroups())
    
    // Verify empty group
    assert_equal("hotgroup 1 ", marineCommander:SendHotkeyGroup(1))
    
    // Fake out - try deleting same one again
    assert_false(marineCommander:DeleteHotkeyGroup(1))
    assert_equal(1, marineCommander:GetNumHotkeyGroups())
    
    assert_true(marineCommander:DeleteHotkeyGroup(2))
    assert_equal(0, marineCommander:GetNumHotkeyGroups())
    
    // Shouldn't be relevant any more - once unselected
    assert_false(marineCommander:GetIsEntityHotgrouped(extractor))
    assert_true(extractor:OnGetIsRelevant(marineCommander))    
    marineCommander:ClearSelection()
    RunUpdate()
    assert_false(extractor:OnGetIsRelevant(marineCommander))
    
    // Make sure entities are preserved after replaced
    local marine = InitializeMarine()
    marineCommander:SetSelection( marine:GetId() )
    assert_true(marineCommander:CreateHotkeyGroup(1))
    
    local newMarine = marine:Replace(Marine.kMapName, 1, true)
    assert_not_nil(newMarine)
    assert_false(marineCommander:GetIsEntityHotgrouped(marine))
    assert_true(marineCommander:GetIsEntityHotgrouped(newMarine))
    
    DestroyEntity(marine)
    
end

// Test to make sure hotkeys are preserved over class change and death
function test5()

    // Select extractor, create hotkey
    SelectExtractor(marineCommander)
    assert_true(marineCommander:CreateHotkeyGroup(1))
    
    assert_equal(1, marineCommander:GetNumHotkeyGroups())
    
    // Logout and come back in
    local newMarine = commandStation:Logout()
    marineCommander = StartCommanding(newMarine)  
    assert_equal(1, marineCommander:GetNumHotkeyGroups())
    
end

// Squad tests
function test6()

    assert_equal("Red squad", GetNameForSquad(1))
    assert_equal("Blue squad", GetNameForSquad(2))
    assert_equal("", GetNameForSquad(0))
    assert_equal("", GetNameForSquad(11))
    
    // Create some marines near each other to see if they become part of Red squad
    local baseX = 10
    local basePos = Vector(baseX, 20, 20)
    
    // Force spawning even though game started
    local marine1 = InitializeMarine(true)    
    marine1:SetOrigin(basePos)

    local marine2 = InitializeMarine(true)
    marine2:SetOrigin(basePos)

    // Sanity check to make sure commanders aren't about to be deleted    
    assert_equal(2, table.count(GetEntitiesIsa("Commander")))    
    RunOneUpdate(MarineTeam.kSquadUpdateInterval)
    
    local squads = marineCommander:GetSortedSquadList()
    assert_equal(1, table.count(squads))
    assert_equal(1, squads[1])
    
    // Now move one of the marines almost out of range
    local r = GetSquadRadius()
    marine2:SetOrigin(Vector(basePos.x + r - .01, basePos.y, basePos.z))
    RunOneUpdate(MarineTeam.kSquadUpdateInterval)
    assert_equal(1, table.count(squads))
    assert_equal(1, squads[1])

    // Now move out of range    
    marine2:SetOrigin(Vector(basePos.x + r + .01, basePos.y, basePos.z))
    RunOneUpdate(MarineTeam.kSquadUpdateInterval)
    squads = marineCommander:GetSortedSquadList()
    assert_equal(0, table.count(squads))
    
    // Add two more marines in between to make sure it bridges across to form a squad
    local marine3 = InitializeMarine(true)
    local marine4 = InitializeMarine(true)
    marine3:SetOrigin(Vector(basePos.x + r/2, basePos.y, basePos.z))
    marine4:SetOrigin(Vector(basePos.x + r/3, basePos.y, basePos.z))    
    RunOneUpdate(MarineTeam.kSquadUpdateInterval)    
    squads = marineCommander:GetSortedSquadList()
    assert_equal(1, table.count(squads))
    
    // Now move them away to make sure we have two squads
    marine1:SetOrigin(basePos)
    marine2:SetOrigin(basePos)    
    
    marine3:SetOrigin(Vector(basePos.x + 10, basePos.y, basePos.z))
    marine4:SetOrigin(Vector(basePos.x + 10, basePos.y, basePos.z))    
    
    RunOneUpdate(MarineTeam.kSquadUpdateInterval)
    squads = marineCommander:GetSortedSquadList()
    assert_equal(2, table.count(squads))
    
    // Now break up red squad marines and make sure we still have blue squad
    marine1:SetOrigin(Vector(basePos.x + 10, basePos.y, basePos.z))
    RunOneUpdate(MarineTeam.kSquadUpdateInterval)
    squads = marineCommander:GetSortedSquadList()
    assert_equal(1, table.count(squads), "Squads")
    
    // Make sure it's blue squad that was kept   
    assert_equal(2, squads[1])
    
end

// Test input
function test7()

    local kUpdateTime = .1
    local commandStationId = GetEntitiesIsa("CommandStation")[1]:GetId()
    local extractorId = GetEntitiesIsa("Extractor")[1]:GetId()
    
    local move = Move()
    move:Clear()
    move.timePassed = kUpdateTime
        
    move.commands = bit.bor(Move.Weapon1, Move.Crouch)
    RunUpdate(kUpdateTime, move)
    //assert_equal(1, marineCommander:GetNumHotkeyGroups())
    
    // Select extractor 
    SelectExtractor(marineCommander)
    
    // Create hotgroup #2
    move.commands = bit.bor(Move.Weapon2, Move.Crouch)
    RunUpdate(kUpdateTime, move)
    assert_equal(2, marineCommander:GetNumHotkeyGroups())
    
    // Select hotgroup #1
    move.commands = Move.Weapon1
    RunUpdate(kUpdateTime, move)
    
    local selectedEnts = marineCommander:GetSelection()
    assert_equal(selectedEnts[1], commandStationId)
    
    // Select hotgroup #2
    move.commands = Move.Weapon2
    RunUpdate(kUpdateTime, move)
    
    selectedEnts = marineCommander:GetSelection()
    assert_equal(selectedEnts[1], extractorId)

end

function testMovement()

    local move = Move()
    move:Clear()
   
    local kUpdateInterval = 1 
    RunUpdate(kUpdateInterval, move)

    local startOrigin = Vector( marineCommander:GetOrigin() )   
    move.x = 1
    RunUpdate(kUpdateInterval, move)
    
    local newOrigin = Vector( marineCommander:GetOrigin() )   
    //assert_float_equal(newOrigin.x, startOrigin.x * Commander.kScrollVelocity * kUpdateInterval)
    
end

function testHeightMap()

    local kDefaultCameraHeight = 10
    
    local map = marineCommander:GetHeightmap()
    assert_not_nil(map)
    
    local offset = map:GetOffset()
    local extents = map:GetExtents()
    
    local aspectRatio = extents.x / extents.z
    assert_float_equal(aspectRatio, map:GetAspectRatio())
    
    // Map taller than wide
    assert(aspectRatio > 1)

    // Because it's taller, vertical extents go to edge of image
    assert_float_equal(0, map:GetMapY(offset.x + extents.x))
    assert_float_equal(1, map:GetMapY(offset.x - extents.x))    
    assert_float_equal(.5, map:GetMapY(offset.x))    
    assert_float_equal(.25, map:GetMapY(offset.x + extents.x/2))    
    
    //...and horizontal shouldn't go all the way
    assert_float_equal(.5 - (1/aspectRatio)/2, map:GetMapX(offset.z - extents.z))
    assert_float_equal(.5 + (1/aspectRatio)/2, map:GetMapX(offset.z + extents.z))
    assert_float_equal(.5, map:GetMapX(offset.z))    
    
    // Test playable width/height
    local playableWidth = GetMinimapPlayableWidth(map)
    assert_float_equal(1/aspectRatio, playableWidth)
    
    local playableHeight = GetMinimapPlayableHeight(map)
    assert_float_equal(1, playableHeight)
    
    // Test minimap conversions
    local worldUpperLeft = MinimapToWorld(marineCommander, .5 - playableWidth/2, .5 - playableHeight/2)
    assert_float_equal(offset.x + extents.x, worldUpperLeft.x)
    assert_float_equal(offset.z - extents.z, worldUpperLeft.z)

    local worldLowerRight = MinimapToWorld(marineCommander, .5 + playableWidth/2, .5 + playableHeight/2)
    assert_float_equal(offset.x - extents.x, worldLowerRight.x)
    assert_float_equal(offset.z + extents.z, worldLowerRight.z)    
    
    // Test minimap scale
    assert_float_equal(1, GetMinimapVerticalScale(map))
    assert_float_equal(1/aspectRatio, GetMinimapHorizontalScale(map))
    
    // Move commander and test proper scroll position
    local commanderCenterPos = Vector(offset.x - Commander.kViewOffsetXHeight, offset.y, offset.z)
    marineCommander:SetOrigin(commanderCenterPos)
    assert_float_equal(.5, marineCommander:GetScrollPositionX())
    assert_float_equal(.5, marineCommander:GetScrollPositionY())
    
    // Test clamp and elevations functions
    assert_float_equal(commanderCenterPos.x, map:ClampXToMapBounds(commanderCenterPos.x))
    assert_float_equal(commanderCenterPos.z, map:ClampZToMapBounds(commanderCenterPos.z))
    
    // Now make sure elevation is smooth as we move. Move camera from bottom middel towards camera in middle left.
    // Middle left of playable region of map, near vents. There's a camera there, so camera should
    // be smoothly increasing in elevation towards it.
    /*
    local kMaxIters = 40
    local startPos =  MinimapToWorld(marineCommander, .5, 1)  // Bottom middle
    local targetPos = MinimapToWorld(marineCommander, 0, .5)  // Middle left
    local diff = Vector(targetPos - startPos)
    diff:Scale(1 / kMaxIters)
    
    local lastY = map:GetElevation(startPos.x, startPos.z)
    
    for i = 1, kMaxIters do
    
        local newPosition = startPos + diff * i
        local newY = map:GetElevation(newPosition.x, newPosition.z)
        
        assert_true(newY >= lastY, "iteration " .. i)
        
        lastY = newY
        
    end*/
    
end
function testAlerts()

    local team = marineCommander:GetTeam()
    
    //assert_false(team:TriggerAlert(kTechId.MarineAlertCommandStationUnderAttack, nil))
    
    assert_true(team:TriggerAlert(kTechId.MarineAlertCommandStationUnderAttack, commandStation))
    assert_false(team:TriggerAlert(kTechId.MarineAlertCommandStationUnderAttack, commandStation))
    
    RunOneUpdate(PlayingTeam.kBaseAlertInterval + .01)
    assert_true(team:TriggerAlert(kTechId.MarineAlertStructureUnderAttack, commandStation))
    assert_false(team:TriggerAlert(kTechId.MarineAlertStructureUnderAttack, commandStation))
    
    RunOneUpdate(PlayingTeam.kRepeatAlertInterval - .1)
    assert_false(team:TriggerAlert(kTechId.MarineAlertStructureUnderAttack, commandStation))
    RunOneUpdate(.11)
    assert_true(team:TriggerAlert(kTechId.MarineAlertStructureUnderAttack, commandStation))
    
    // Make sure we sent enough minimap pings
    assert_not_nil(table.count(marineCommander:GetSentAlerts()))
    assert_equal(3, table.count(marineCommander:GetSentAlerts()))
    
    // Make sure we don't send too many "pings" to commanders
    assert_false(marineCommander:SendAlert(kTechId.MarineAlertStructureUnderAttack, commandStation))
    assert_true(marineCommander:SendAlert(kTechId.MarineAlertStructureUnderAttack, hive))
    
    assert_equal(4, table.count(marineCommander:GetSentAlerts()))
    assert_false(marineCommander:SendAlert(kTechId.MarineAlertStructureUnderAttack, hive))    
    assert_equal(4, table.count(marineCommander:GetSentAlerts()))
    
end

function CheckBuildLegal(techId, origin, snapDist)

    local pickVec = GetNormalizedVector(origin - marineCommander:GetEyePos())
    local valid, position, attachEntity = GetIsBuildPickVecLegal(techId, marineCommander, pickVec, snapDist)
    return valid, position, attachEntity

end

// Don't allow structures to build too close to others, so players can move through base easily
// and to give nice appearance. Also test to make sure packs CAN be dropped on top of stuff.
// Don't allow build tech too close to ResourcePoints, TechPoints or Structures.
function testBuildBuyTech()

    local commStationOrigin = Vector(commandStation:GetOrigin())
    local techPoint = GetUnattached("TechPoint", 2)
    assert_not_nil(techPoint)
    local techPointOrigin = Vector(techPoint:GetOrigin())
    
    // Destroy all MACs and IPs to make sure they don't interfere with our build tests
    for index, mac in ipairs(GetEntitiesIsa("MAC", 1)) do
        DestroyEntity(mac)
    end
    for index, ip in ipairs(GetEntitiesIsa("InfantryPortal", 1)) do
        DestroyEntity(ip)
    end
    RunOneUpdate()
    
    local structuresToTest = {kTechId.Sentry, kTechId.Armory, kTechId.MedPack, kTechId.AmmoPack}
    
    local numBuildNodes = 0
    local numBuyNodes = 0
    
    for index, techId in ipairs(structuresToTest) do
    
        local errorString = EnumToString(kTechId, techId)
        local techNode = marineCommander:GetTechTree():GetTechNode(techId)
        
        assert_not_nil(techNode)
        
        local buildNode = techNode:GetIsBuild()
        local buyNode = techNode:GetIsBuy()
        
        if buildNode then
        
            assert_false(CheckBuildLegal(techId, Vector(commStationOrigin.x, commStationOrigin.y, commStationOrigin.z + 1)), errorString)
            assert_false(CheckBuildLegal(techId, Vector(commStationOrigin.x, commStationOrigin.y, commStationOrigin.z + kBlockAttachStructuresRadius - .1)), errorString)    
            assert_true(CheckBuildLegal(techId, Vector(commStationOrigin.x, commStationOrigin.y, commStationOrigin.z + kBlockAttachStructuresRadius + 1)), errorString)

            // Make we aren't able to build structures that don't attach on top of attach points (ie, can't build armory on or near a tech_point)
            assert_false(CheckBuildLegal(techId, Vector(techPointOrigin.x, techPointOrigin.y, techPointOrigin.z + 1)), errorString)
            assert_false(CheckBuildLegal(techId, Vector(techPointOrigin.x, techPointOrigin.y, techPointOrigin.z + kBlockAttachStructuresRadius - .1)), errorString)    
            assert_true(CheckBuildLegal(techId, Vector(techPointOrigin.x, techPointOrigin.y, techPointOrigin.z + kBlockAttachStructuresRadius + .1)), errorString)
            
            numBuildNodes = numBuildNodes + 1
            
        elseif buyNode then
        
            // Make sure buy tech isn't blocked by proximity to other things (need to be able to drop medpacks anywhere)
            assert_true(CheckBuildLegal(techId, Vector(commStationOrigin.x, commStationOrigin.y, commStationOrigin.z + 1)), errorString)
            assert_true(CheckBuildLegal(techId, Vector(commStationOrigin.x, commStationOrigin.y, commStationOrigin.z + kBlockAttachStructuresRadius - .1)), errorString)    
            assert_true(CheckBuildLegal(techId, Vector(commStationOrigin.x, commStationOrigin.y, commStationOrigin.z + kBlockAttachStructuresRadius + .1)), errorString)

            assert_true(CheckBuildLegal(techId, Vector(techPointOrigin.x, techPointOrigin.y, techPointOrigin.z + 1)), errorString)
            assert_true(CheckBuildLegal(techId, Vector(techPointOrigin.x, techPointOrigin.y, techPointOrigin.z + kBlockAttachStructuresRadius - .1)), errorString)    
            assert_true(CheckBuildLegal(techId, Vector(techPointOrigin.x, techPointOrigin.y, techPointOrigin.z + kBlockAttachStructuresRadius + .1)), errorString)
            
            numBuyNodes = numBuyNodes + 1

        end        
        
    end
    
    assert_equal(numBuildNodes, 2)
    assert_equal(numBuyNodes, 2)
    
end

function testSpecialBuildings()

    local commStationOrigin = Vector(commandStation:GetOrigin())
    local techPoint = GetUnattached("TechPoint", 2)
    assert_not_nil(techPoint)
    local techPointOrigin = Vector(techPoint:GetOrigin())
    
    // Destroy all MACs to make sure they don't interfere with our build tests
    for index, mac in ipairs(GetEntitiesIsa("MAC", 1)) do
        DestroyEntity(mac)
    end
    RunOneUpdate()

    // Make sure IP can only be built near command station
    local attachRange = LookupTechData(kTechId.InfantryPortal, kStructureAttachRange, 0)
    assert_true(attachRange > 0)
    
    assert_false(CheckBuildLegal(kTechId.InfantryPortal, Vector(commStationOrigin.x, commStationOrigin.y, commStationOrigin.z + attachRange + .1), Commander.kStructureSnapRadius), errorString)
    assert_true(CheckBuildLegal(kTechId.InfantryPortal, Vector(commStationOrigin.x, commStationOrigin.y, commStationOrigin.z + attachRange - .1), Commander.kStructureSnapRadius), errorString)
    
    // Make sure command station "snaps" to tech point
    local valid, position, attachEntity = CheckBuildLegal(kTechId.CommandStation, Vector(techPointOrigin.x, techPointOrigin.y, techPointOrigin.z + Commander.kStructureSnapRadius - .1), Commander.kStructureSnapRadius)
    assert_true(valid, errorString)
    assert_float_equal(0, (position - techPointOrigin):GetLength(), errorString)

    local buildOrigin = Vector(techPointOrigin.x, techPointOrigin.y, techPointOrigin.z + Commander.kStructureSnapRadius + .1)
    valid, position, attachEntity = CheckBuildLegal(kTechId.CommandStation, buildOrigin, Commander.kStructureSnapRadius)
    assert_false(valid, errorString)
    
    // Don't snap unless valid
    assert_float_equal(0, (position - buildOrigin):GetLength(), errorString)

end

function verifyReplicate(sourceEntity, attachClassName)

    // Find free node and put it there
    local attachEnt = nil
    
    local ents = GetEntitiesIsa(attachClassName)
    for index, ent in ipairs(ents) do
    
        if ent:GetAttached() == nil then
        
            attachEnt = ent
            break
            
        end
        
    end
    
    assert_not_nil(attachEnt)
    
    // Make sure replicate follows regular build rules
    assert_nil(ReplicateStructure(sourceEntity:GetTechId(), Vector(0, 0, 0), marineCommander))
    assert_nil(ReplicateStructure(sourceEntity:GetTechId(), attachEnt:GetOrigin() + Vector(1, 0, 0), marineCommander))
    assert_nil(ReplicateStructure(sourceEntity:GetTechId(), attachEnt:GetOrigin() + Vector(0, 1, 0), marineCommander))
    assert_nil(ReplicateStructure(sourceEntity:GetTechId(), attachEnt:GetOrigin() + Vector(0, 0, 1), marineCommander))
    
    local newEntity = ReplicateStructure(sourceEntity:GetTechId(), attachEnt:GetOrigin(), marineCommander)
    assert_not_nil(newEntity)
    
    // Make sure it's attached
    assert_not_nil(newEntity:GetAttached())
    assert_equal(newEntity:GetAttached():GetId(), attachEnt:GetId())
    
end

function testReplicate()

    verifyReplicate(extractor, "ResourcePoint")
    verifyReplicate(commandStation, "TechPoint")
        
end

function testResearch()

    // Destroy all team extractors
    local extractors = GetEntitiesIsa("Extractor", marineCommander:GetTeamNumber())
    for index, extractor in ipairs(extractors) do
        extractor:OnKill(1, nil, nil, extractor:GetOrigin(), nil)
    end    
    
    // Create armory
    local armory = CreateEntityForCommander(kTechId.Armory, Vector(0, 0, 0), marineCommander)
    
    local techNode = marineCommander:GetTechTree():GetTechNode(kTechId.Weapons1)
    assert_not_nil(techNode)

    local teamResources = marineCommander:GetTeamResources()
    local researchCost = LookupTechData(techNode:GetTechId(), kTechDataCostKey, nil)
    assert_not_nil(researchCost)
    
    CommAction(marineCommander, kTechId.ArmoryUpgradesMenu)
    
    assert_true(marineCommander:ProcessTechTreeActionForEntity(techNode, Vector(0, 0, 0), Vector(0, 0, 0), armory, true))

    // Make sure research costs are deducted properly    
    assert_equal(teamResources - researchCost, marineCommander:GetTeamResources())
    
    local researchTime = LookupTechData(techNode:GetTechId(), kTechDataResearchTimeKey, nil)
    assert_not_nil(researchTime)
    
    RunUpdate(researchTime - .1)
    assert_false(techNode.researched)
    
    RunUpdate(.2)
    assert_true(techNode.researched)
    
    assert_equal(teamResources - researchCost, marineCommander:GetTeamResources())
    
end

function verifyMetabolizeEvolution(unit)

    // Get initial time
    local time = unit:GetEvolutionTime()
    
    // Pass time at regular rate
    assert_float_equal(0, unit:GetEvolutionTime())
    RunUpdate(1)
    time = time + 1
    assert_float_equal(time, unit:GetEvolutionTime())
    
    // Pass time at 1xMetabolize rate
    unit:AddStackableGameEffect(kMetabolizeGameEffect, kMetabolizeTime)
    RunUpdate(2)
    time = time + 2 + 1 * kMetabolizeResearchScalar
    assert_float_equal(time, unit:GetEvolutionTime())
    
    // Pass time at 2xMetabolize rate
    unit:AddStackableGameEffect(kMetabolizeGameEffect, kMetabolizeTime)
    RunUpdate(1)
    time = time + 1 + 2 * kMetabolizeResearchScalar
    assert_float_equal(time, unit:GetEvolutionTime())
    
end

function testMetabolize()

    local skulk = InitializeAlien(true)
    assert_not_nil(skulk)
    assert_not_equal(skulk:GetId(), Entity.invalidId)
    assert_equal("Skulk", skulk:GetClassName())
    
    local success, embryo = skulk:Evolve(kTechId.Gorge)
    assert_true(success)

    //verifyMetabolizeEvolution(embryo)

end

function testUpgradeBeforeComplete()

    local oldExtractor = GetEntitiesIsa("Extractor")[1]
    assert_not_nil(oldExtractor)
    local extractorPos = Vector(oldExtractor:GetOrigin())
    
    oldExtractor:Kill(marineCommander)
    RunUpdate(2)
    
    // Create new extractor here
    local extractor = CreateEntity(Extractor.kMapName, extractorPos, 1)
    
    assert_true(marineCommander:SetSelection( extractor:GetId() ))
    
    local techNode = marineCommander:GetTeam():GetTechTree():GetTechNode(kTechId.ExtractorUpgrade)    
    assert_not_nil(techNode)
    assert_false(marineCommander:AttemptToResearchOrUpgrade(techNode))
    
    extractor:SetConstructionComplete()
    assert_true(marineCommander:AttemptToResearchOrUpgrade(techNode))

end