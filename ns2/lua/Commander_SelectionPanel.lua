//=============================================================================
//
// lua/Commander_SelectionPanel.lua
// 
// Created by Henry Kropf and Charlie Cleveland
// Copyright 2011, Unknown Worlds Entertainment
//
//=============================================================================

/**
 * Return the number of entities currently selected by a commander
 */
function CommanderUI_GetSelectedEntitiesCount()

    return table.count(Client.GetLocalPlayer():GetSelection())

end

/**
 * Return a list of entities selected by a commander
 */
function CommanderUI_GetSelectedEntities()

    local player = Client.GetLocalPlayer()
    if player.GetSelection then
        return player:GetSelection()
    end
    
    return { }
        
end

/**
 * Player is selecting all active players. Sets local selection and sends command to server.
 */
function CommanderUI_ClickedSelectAllPlayers()
    
    local player = Client.GetLocalPlayer()
    if player and player.SelectAllPlayers then
    
        player:SelectAllPlayers()        
        Shared.ConsoleCommand("selectallplayers")
        
    end
        
end

/**
 * Get up to 2 <text>,[0-1] pairs in linear array for bargraphs on the commander selection
 */
function CommanderUI_GetCommandBargraphs()

    local selectedEnts = Client.GetLocalPlayer():GetSelection()
    
    if (table.count(selectedEnts) == 1) then
    
        local entId = selectedEnts[1]
        return CommanderUI_GetSelectedBargraphs(entityId)
        
    end

    return {}
    
end

/**
 * Get a string that describes the entity
 */
function CommanderUI_GetSelectedDescriptor(entityId)
    local player = Client.GetLocalPlayer()
    
    local descriptor = "Unknown"
    local ent = Shared.GetEntity(entityId)
    if(ent ~= nil) then
        descriptor = GetSelectionText(ent, player:GetTeamNumber())
    end
    
    return descriptor
    
end

/**
 * Get a string that describes the entity location
 */
function CommanderUI_GetSelectedLocation(entityId)

    local locationText = ""
    local ent = Shared.GetEntity(entityId)
    if (ent ~= nil) and ent.GetLocationName then
        locationText = locationText .. ent:GetLocationName()
    else
        Print("CommanderUI_GetSelectedLocation(): Entity %d is nil.", entityId)
    end
        
    return locationText

end

function CommanderUI_GetSelectedHealth(entityId)

    local ent = Shared.GetEntity(entityId)
    if ent and HasMixin(ent, "Live") and ent:GetMaxHealth() > 0 and not ent:GetIgnoreHealth() then
        return string.format("%d/%d", math.floor(ent:GetHealth()), math.ceil(ent:GetMaxHealth()))
    end
    
    return ""
    
end

function CommanderUI_GetSelectedArmor(entityId)

    local ent = Shared.GetEntity(entityId)
    if ent and HasMixin(ent, "Live") and ent:GetMaxArmor() > 0 then
        return string.format("%d/%d", math.floor(ent:GetArmor()), math.ceil(ent:GetMaxArmor()))
    end
    
    return ""
    
end

function CommanderUI_GetSelectedEnergy(entityId)

    local ent = Shared.GetEntity(entityId)
    if ent and ent.GetEnergy and ent.GetMaxEnergy then
        return string.format("%d/%d", math.floor(ent:GetEnergy()), math.ceil(ent:GetMaxEnergy()))
    end
    
    return ""

end

/**
 * Get up to 2 <text>,[0-1] pairs in linear array for bargraphs on the selected entity
 */
function CommanderUI_GetSelectedBargraphs(entityId)

    local t = {}
    
    local ent = Shared.GetEntity(entityId)
    
    if ent then
        
        if HasMixin(ent, "Recycle") and ent:GetRecycleActive() then
        
            table.insert(t, Locale.ResolveString("COMM_SEL_RECYCLING"))
            table.insert(t, ent:GetResearchProgress())
            table.insert(t, ent:GetResearchingId())
            
        elseif HasMixin(ent, "Construct") and not ent:GetIsBuilt() then
        
            table.insert(t, Locale.ResolveString("COMM_SEL_CONSTRUCTING"))
            table.insert(t, ent:GetBuiltFraction())
            table.insert(t, kTechId.Construct)
            
        elseif HasMixin(ent, "Research") and ent:GetIsManufacturing() then
        
            table.insert(t, Locale.ResolveString("COMM_SEL_BUILDING"))
            table.insert(t, ent:GetResearchProgress())
            table.insert(t, ent:GetResearchingId())
            
        elseif HasMixin(ent, "Research") and ent:GetIsUpgrading() then
        
            table.insert(t, Locale.ResolveString("COMM_SEL_UPGRADING"))
            table.insert(t, ent:GetResearchProgress())
            table.insert(t, ent:GetResearchingId())
            
        elseif HasMixin(ent, "Research") and ent:GetIsResearching() then
        
            table.insert(t, Locale.ResolveString("COMM_SEL_RESEARCHING"))
            table.insert(t, ent:GetResearchProgress())
            table.insert(t, ent:GetResearchingId())
            
        end
        
    end
    
    return t
    
end

function CommanderUI_GetSelectedHealthFraction(entityId)

    local ent = Shared.GetEntity(entityId)
    
    if ent and HasMixin(ent, "Live") and ent:GetIsAlive() then
        return ent:GetHealth() / ent:GetMaxHealth()
    end
    
    return 0

end

function CommanderUI_GetSelectedArmorFraction(entityId)

    local ent = Shared.GetEntity(entityId)
    
    if ent and HasMixin(ent, "Live") and ent:GetIsAlive() and ent:GetMaxArmor() ~= 0 then
        return ent:GetArmor() / ent:GetMaxArmor()
    end
    
    return 0

end

/**
 * Return pixel coordinates to the selected entity icon
 */
function CommanderUI_GetSelectedIconOffset(entityId)
    
    local isaMarine = Client.GetLocalPlayer():isa("MarineCommander")
    return GetPixelCoordsForIcon(entityId, isaMarine)
    
end

/**
 * Indicates the entity selected from a multiple-selection panel.
 */
function CommanderUI_ClickedSelectedEntity(entityId)
end


/**
 * Get custom rightside selection text for the commander selection pane
 */
function CommanderUI_GetCommanderSelectionCustomText()
    // Return description of what we have selected
    return "Energy 50/200"
end

function CommanderUI_GetCommandStationDescriptor()
end

function CommanderUI_GetCommandStationLocation()
end

function CommanderUI_GetCommandIconOffset()
end

/**
 * Get custom rightside selection text for a single selection
 */
function CommanderUI_GetSingleSelectionCustomText(entId)

    local customText = ""
    
    if entId ~= nil then
    
        local ent = Shared.GetEntity(entId)    
        if ent ~= nil and ent.GetCustomSelectionText then
            customText = ent:GetCustomSelectionText()
        end
        
    end
    
    return customText
    
end