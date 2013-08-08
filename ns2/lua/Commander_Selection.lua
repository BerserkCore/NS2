// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Commander_Selection.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Shared code that handles selection.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function Commander:GetEntitiesBetweenVecs(potentialEntities, pickStartVec, pickEndVec, entityList)

    local minX = math.min(pickStartVec.x, pickEndVec.x)
    local minZ = math.min(pickStartVec.z, pickEndVec.z)
    
    local maxX = math.max(pickStartVec.x, pickEndVec.x)
    local maxZ = math.max(pickStartVec.z, pickEndVec.z)

    for index, entity in pairs(potentialEntities) do

        // Get normalized vector to entity
        local toEntity = entity:GetOrigin() - self:GetOrigin()
        toEntity:Normalize()
                   
        // It should be selected if this vector lies between the pick vectors
        if( ( minX < toEntity.x and minZ < toEntity.z ) and
            ( maxX > toEntity.x and maxZ > toEntity.z ) ) then
    
            // Insert entity along with current time for fading
            table.insertunique(entityList, entity )            
        end
    
    end
    
end

/**
 * If selected entities include structures and non-structures, get rid of the structures (ala modern RTS').
 * In addition, always filter out Commander players.
 */
local function FilterOutMarqueeSelection(selection)

    local foundStructure = false
    local foundNonStructure = false
    local toRemove = { }
    
    for index, entity in ipairs(selection) do
        
        if entity:isa("Commander") then
            table.insertunique(toRemove, entityPair)
        else
        
            if entity.GetIsMoveable and entity:GetIsMoveable() then
                foundNonStructure = true
            else
                foundStructure = true
            end
            
        end
        
    end
    
    if foundStructure and foundNonStructure then
    
        for index, entity in ipairs(selection) do

            // filter out non moveables
            if not entity.GetIsMoveable or not entity:GetIsMoveable() then
                table.insertunique(toRemove, entity)
            end
            
        end
        
    end
    
    for index, entity in ipairs(toRemove) do
    
        if not table.removevalue(selection, entity) then
            Print("FilterOutMarqueeSelection(): Unable to remove entityPair (%s)", entity:GetClassName())
        end
        
    end
    
end

// Input vectors are normalized world vectors emanating from player, representing a selection region where the marquee 
// existed (or they were created around the vector where the mouse was clicked for a single selection). 
function Commander:MarqueeSelectEntities(selectorStartX, selectorStartY, mouseX, mouseY, shiftSelect)

    local startPos = Vector(
        selectorStartX < mouseX and selectorStartX or mouseX,
        selectorStartY < mouseY and selectorStartY or mouseY,
        0
    )
    
    local endPos = Vector(
        selectorStartX >= mouseX and selectorStartX or mouseX,
        selectorStartY >= mouseY and selectorStartY or mouseY,
        0
    )

    local newSelection = GetSelectablesOnScreen(self, nil, startPos, endPos)
    FilterOutMarqueeSelection(newSelection)
    
    if not shiftSelect then
        DeselectAllUnits(self:GetTeamNumber())
    end
    
    for _, entity in ipairs(newSelection) do
    
        local setSelected = true
        if shiftSelect then
            setSelected = not entity:GetIsSelected(self:GetTeamNumber())
        end
    
        entity:SetSelected(self:GetTeamNumber(), setSelected)    
        
    end

end

function Commander:GetUnitUnderCursor(pickVec)

    local origin = self:GetOrigin()
    local trace = Shared.TraceRay(origin, origin + pickVec*1000, CollisionRep.Select, PhysicsMask.CommanderSelect, EntityFilterOne(self))
    local recastCount = 0
    while trace.entity == nil and trace.fraction < 1 and trace.normal:DotProduct(Vector(0, 1, 0)) < 0 and recastCount < 3 do
        // We've hit static geometry with the normal pointing down (ceiling). Re-cast from the point of impact.
        local recastFrom = 1000 * trace.fraction + 0.1
        trace = Shared.TraceRay(origin + pickVec*recastFrom, origin + pickVec*1000, CollisionRep.Select, PhysicsMask.CommanderSelect, EntityFilterOne(self))
        recastCount = recastCount + 1
    end
    
    return trace.entity
    
end

function Commander:GetUnitIdUnderCursor(pickVec)

    local entity = self:GetUnitUnderCursor(pickVec)
    
    if entity then
        return entity:GetId()
    end
    
    return Entity.invalidId

end

function Commander:SelectAllPlayers()

    DeselectAllUnits(self:GetTeamNumber(), true)    
    for _, unit in ipairs(GetEntitiesWithMixinForTeam("Selectable", self:GetTeamNumber())) do
        unit:SetSelected(self:GetTeamNumber(), unit:isa("Player"))
    end
    
end

local function PlaySelectionChangedSound(self)

    if Client and self:GetIsLocalPlayer() then
        Shared.PlayPrivateSound(self, self:GetSelectionSound(), nil, 1.0, self:GetOrigin())
    end
    
end

function LeaveSelectionMenu(self)

    // Only execute for the local Commander player.
    if Client and self == Client.GetLocalPlayer() and self:GetSelectedTabIndex() == 4 then
    
        self:SetCurrentTech(kTechId.BuildMenu)
        
    elseif Server then
        // don't switch the menu if in a tap. client pressed the tap button instead of clearing selection / seleciton became invalid
        if self.currentMenu ~= kTechId.BuildMenu and self.currentMenu ~= kTechId.AdvancedMenu and self.currentMenu ~= kTechId.AssistMenu then
            self:ProcessTechTreeAction(kTechId.BuildMenu, nil, nil)
        end    
    end

end

local function GoToRootMenu(self)

    // Only execute for the local Commander player.
    if Client and self == Client.GetLocalPlayer() then
    
        self:TriggerButtonIndex(4)
        
    elseif Server then
        self:ProcessTechTreeAction(kTechId.RootMenu, nil, nil)
    end
    
end

// Returns table of sorted selected entities 
function Commander:GetSelection()

    local selected = {}
    
    for _, entity in ipairs(GetEntitiesWithMixin("Selectable")) do
        if entity:GetIsSelected(self:GetTeamNumber()) then
            table.insert(selected, entity)    
        end
    end
    
    return selected
    
end

// Returns true if hotkey exists and was selected
function Commander:SelectHotkeyGroup(number)

    if Client then    
        self:SendSelectHotkeyGroupMessage(number)        
    end
    
    local selection = false

    // select entities which match hotgroup, unselect all others
    for _, entity in ipairs(GetEntitiesWithMixinForTeam("Selectable", self:GetTeamNumber())) do
        
        if entity:GetHotGroupNumber() == number then
            entity:SetSelected(self:GetTeamNumber(), true, true, false)
            selection = true
        else
            entity:SetSelected(self:GetTeamNumber(), false, true, false)
        end
        
    end
    
    UpdateMenuTechId(self:GetTeamNumber(), selection)
    
end

function Commander:GetHotGroup(number)

    local hotgroupEntities = {}

    for _, entity in ipairs(GetEntitiesWithMixinForTeam("Selectable", self:GetTeamNumber())) do
        
        if entity:GetHotGroupNumber() == number then
            table.insert(hotgroupEntities, entity)
        end
        
    end
    
    return hotgroupEntities

end

function Commander:GetHotGroupSelected(number)

    local hotgroupEntities = self:GetHotGroup(number)
    local hotGroupSize = #hotgroupEntities
    local numSelected = 0
    local teamNum = self:GetTeamNumber()
    
    for _, entity in ipairs(hotgroupEntities) do

        if entity:GetIsSelected(teamNum) then
            numSelected = numSelected + 1
        end
    
    end
    
    // return true when the hotgroup exists and every entity is selected
    return numSelected ~= 0 and numSelected == hotGroupSize, hotgroupEntities

end
