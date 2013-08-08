// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIInsight_PlayerHealthbars.lua
//
// Created by: Jon 'Huze' Hughes (jon@jhuze.com)
//
// Spectator: Displays player name and healthbars
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIInsight_PlayerHealthbars' (GUIScript)

local playerList
local reusebackgrounds

local kPlayerHealthDrainRate = 0.75 --Percent per ???

local kPlayerHealthBarTexture = "ui/healthbarplayer.dds"
local kPlayerHealthBarTextureSize = Vector(100, 7, 0)

local kNameFontSize = GUIScale(16)
local kPlayerHealthBarSize = Vector( GUIScale(100),  GUIScale(7), 0)
local kHealthbarOffset = Vector(0, -kPlayerHealthBarSize.y - kNameFontSize - GUIScale(16), 0)

-- Color constants.
local kArmorColor = Color(1, 1, 1, 1)
local kParasiteColor = Color(1, 1, 0, 1)
local kPoisonColor = Color(0, 1, 0, 1)
local kHealthDrainColor = Color(1, 0, 0, 1)

function GUIInsight_PlayerHealthbars:Initialize()

    playerList = table.array(16)
    reusebackgrounds = table.array(16)

end

function GUIInsight_PlayerHealthbars:Uninitialize()

    -- Players
    for i, player in pairs(playerList) do
        GUI.DestroyItem(player.Background)
    end
    
    playerList = nil
    
    -- Reuse items
    for index, background in ipairs(reusebackgrounds) do
        GUI.DestroyItem(background["Background"])
    end
    reusebackgrounds = nil

end

function GUIInsight_PlayerHealthbars:OnResolutionChanged(oldX, oldY, newX, newY)

    self:Uninitialize()
    kPlayerHealthBarSize = Vector( GUIScale(100),  GUIScale(7), 0)
    self:Initialize()

end

function GUIInsight_PlayerHealthbars:Update(deltaTime)

    local player = Client.GetLocalPlayer()
    if not player then
        return
    end

    self:UpdatePlayers(deltaTime)
    
end

function GUIInsight_PlayerHealthbars:UpdatePlayers(deltaTime)

    local players = Shared.GetEntitiesWithClassname("Player")
    
    -- Remove old players
        
    for id, player in pairs(playerList) do
    
        local contains = false
        for key, newPlayer in ientitylist(players) do
            if id == newPlayer:GetId() then
                contains = true
            end
        end

        if not contains then
        
            -- Store unused elements for later
            player.Background:SetIsVisible(false)
            table.insert(reusebackgrounds, player)
            playerList[id] = nil
            
        end
    end
    
    -- Add new and Update all players
    
    for index, player in ientitylist(players) do

        local playerIndex = player:GetId()
        local relevant = player:GetIsVisible() and player:GetIsAlive() and not player:isa("Commander") and not player:isa("Spectator")
        
        if relevant then
        
            local health = player:GetHealth()
            local armor = player:GetArmor() * kHealthPointsPerArmor
            local maxHealth = player:GetMaxHealth()
            local maxArmor = player:GetMaxArmor() * kHealthPointsPerArmor            
            local healthFraction = (health + armor)/(maxHealth + maxArmor)
            
            -- Calculate Screen position
            local min, max = player:GetModelExtents()
            local nameTagWorldPosition = player:GetOrigin() + Vector(0, max.y, 0)
            local nameTagInScreenspace = Client.WorldToScreen(nameTagWorldPosition) + kHealthbarOffset
            
            
            local color = ConditionalValue(player:GetTeamType() == kAlienTeamType, kRedColor, kBlueColor)
            local isPoisoned = player.poisoned
            local isParasited = player.parasited
            
            -- Get/Create Player GUI Item
            local playerGUI
            if not playerList[playerIndex] then -- Add new GUI for new players
            
                playerGUI = self:CreatePlayerGUIItem()
                playerGUI.StoredValues.HealthFraction = healthFraction
                table.insert(playerList, playerIndex, playerGUI)

            else
            
                playerGUI = playerList[playerIndex]
                
            end
                    
            playerGUI.Background:SetIsVisible(true)
            
            -- Set player info --
            
            -- background
            local background = playerGUI.Background
            background:SetPosition(nameTagInScreenspace)
            
            -- name
            local nameItem = playerGUI.Name
            nameItem:SetText(ToString(player:GetName()))
            nameItem:SetColor(color)
            
            -- healthbar
            local healthBar = playerGUI.HealthBar
            local healthBarSize =  healthFraction * kPlayerHealthBarSize.x
            local healthBarTextureSize = healthFraction * kPlayerHealthBarTextureSize.x
            healthBar:SetTexturePixelCoordinates(unpack({0, 0, healthBarTextureSize, kPlayerHealthBarTextureSize.y}))
            healthBar:SetSize(Vector(healthBarSize, kPlayerHealthBarSize.y, 0))
            
            if isPoisoned then
                healthBar:SetColor(kPoisonColor)
            elseif isParasited then
                healthBar:SetColor(kParasiteColor)
            else
                healthBar:SetColor(color)
            end
            
            -- health change bar
            local healthChangeBar = playerGUI.HealthChangeBar
            local previousHealthFraction = playerGUI.StoredValues.HealthFraction
            if previousHealthFraction > healthFraction then
            
                healthChangeBar:SetIsVisible(true)
                local changeBarSize = (previousHealthFraction - healthFraction) * kPlayerHealthBarSize.x
                local changeBarTextureSize = (previousHealthFraction - healthFraction) * kPlayerHealthBarTextureSize.x
                healthChangeBar:SetTexturePixelCoordinates(unpack({healthBarTextureSize, 0, healthBarTextureSize + changeBarTextureSize, kPlayerHealthBarTextureSize.y}))
                healthChangeBar:SetSize(Vector(changeBarSize, kPlayerHealthBarSize.y, 0))
                healthChangeBar:SetPosition(Vector(healthBarSize, 0, 0))
                playerGUI.StoredValues.HealthFraction = math.max(healthFraction, previousHealthFraction - (deltaTime * kPlayerHealthDrainRate))
                
            else

                healthChangeBar:SetIsVisible(false)
                playerGUI.StoredValues.HealthFraction = healthFraction
                
            end
            
        else -- No longer relevant, remove if necessary
        
            if playerList[playerIndex] then
                GUI.DestroyItem(playerList[playerIndex].Background)
                playerList[playerIndex] = nil
            end
        
        end

    end

end

function GUIInsight_PlayerHealthbars:CreatePlayerGUIItem()

    -- Reuse an existing healthbar item if there is one.
    if table.count(reusebackgrounds) > 0 then
        local returnbackground = reusebackgrounds[1]
        table.remove(reusebackgrounds, 1)
        return returnbackground
    end

    local playerBackground = GUIManager:CreateGraphicItem()
    playerBackground:SetLayer(kGUILayerPlayerNameTags)
    playerBackground:SetColor(Color(0,0,0,0))
    
    local playerNameItem = GUIManager:CreateTextItem()
    --playerNameItem:SetFontName(kInsightFont)
    playerNameItem:SetFontSize(kNameFontSize)
    playerNameItem:SetFontIsBold(true)
    playerNameItem:SetTextAlignmentX(GUIItem.Align_Center)
    playerNameItem:SetTextAlignmentY(GUIItem.Align_Min)
    playerBackground:AddChild(playerNameItem)

    local playerHealthBackground = GUIManager:CreateGraphicItem()
    playerHealthBackground:SetSize(Vector(kPlayerHealthBarSize.x, kPlayerHealthBarSize.y, 0))
    playerHealthBackground:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerHealthBackground:SetColor(Color(0,0,0,0.75))
    playerHealthBackground:SetPosition(Vector(-kPlayerHealthBarSize.x/2, kNameFontSize, 0))
    playerBackground:AddChild(playerHealthBackground)

    local playerHealthBar = GUIManager:CreateGraphicItem()
    playerHealthBar:SetSize(kPlayerHealthBarSize)
    playerHealthBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerHealthBar:SetTexture(kPlayerHealthBarTexture)
    playerHealthBackground:AddChild(playerHealthBar)
    
    local playerHealthChangeBar = GUIManager:CreateGraphicItem()
    playerHealthChangeBar:SetSize(kPlayerHealthBarSize)
    playerHealthChangeBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerHealthChangeBar:SetTexture(kPlayerHealthBarTexture)
    playerHealthChangeBar:SetColor(kHealthDrainColor)
    playerHealthChangeBar:SetIsVisible(false)
    playerHealthBackground:AddChild(playerHealthChangeBar)
    
    return { Background = playerBackground, Name = playerNameItem, HealthBar = playerHealthBar, HealthChangeBar = playerHealthChangeBar, StoredValues = {HealthFraction = -1} }
end