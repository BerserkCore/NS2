// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. ======
//
// lua\menu\ServerTabs.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more inTableation, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/WindowUtility.lua")
Script.Load("lua/menu/ServerList.lua")

class 'ServerTabs' (MenuElement)

local kDefaultButtons = {

    {
        name = "ALL",
        filters = { [1] = FilterServerMode(""), [8] = FilterFavoriteOnly(false), [11] = FilterHistoryOnly(false) },
    },
    
    {
        name = "NS2",
        filters = { [1] = FilterServerMode("ns2"), [8] = FilterFavoriteOnly(false), [11] = FilterHistoryOnly(false) },
    },
    
    {
        name = "FAVORITES",
        filters = { [1] = FilterServerMode(""), [8] = FilterFavoriteOnly(true), [11] = FilterHistoryOnly(false) },
    },
  
    {
        name = "HISTORY",
        filters = { [1] = FilterServerMode(""), [8] = FilterFavoriteOnly(false), [11] = FilterHistoryOnly(true) },
    },

}

local function UpdateTabHighlight(self)

    local pointX, pointY = Client.GetCursorPosScreen()
    local highlighted = false

    for _, tab in ipairs(self.tabs) do
    
        if not highlighted and GUIItemContainsPoint(tab.guiItem, pointX, pointY) then
        
            if self.highLightColor then
                tab:SetColor(self.highLightColor)
            end
            
            highlighted = true
            
        elseif tab:GetText() == self.selectedTab then    
            
            if self.highLightColor then
                tab:SetColor(self.highLightColor)
            end
            
        else
        
            if self.textColor then
                tab:SetColor(self.textColor)
            end
        
        end

    end

end

function ServerTabs:Initialize()

    self:DisableBorders()
    
    MenuElement.Initialize(self)

    local eventCallbacks =
    {
        
        OnMouseOver = function(self)
            
            UpdateTabHighlight(self)
            
        end,
        
        OnClick = function(self)
        
            for index, tab in ipairs(self.tabs) do
                
                local pointX, pointY = Client.GetCursorPosScreen()
                if GUIItemContainsPoint(tab.guiItem, pointX, pointY) then
                
                    self:EnableFilter(self.layout[index].filters)
                    self.selectedTab = tab.guiItem:GetText()
                    self:UpdateTabSelector()
                    MainMenu_OnMouseClick()
                    
                    break
                
                end
                
            end          
        
        end,

    }
    
    self:AddEventCallbacks(eventCallbacks)
    
    self.tabs = {}
    
    self.tabSelector = CreateGraphicItem(self)
    self.tabSelector:SetColor(Color(0.49, 0.9, 0.98, 0.2))
    self.tabSelector:SetPosition(Vector(-6, -1, 0))
    
    self.selectedTab = "ALL"
    
    self.tabSelector:SetIsVisible(false)

end

function ServerTabs:GetTagName()
    return "servertabs"
end

local function SortByPlayerCount(entry1, entry2)
    return entry1.count > entry2.count
end

function ServerTabs:SetServerList(serverList)
    self.serverList = serverList
end

function ServerTabs:EnableFilter(filters)

    if self.serverList then
    
        for index, filterFunc in pairs(filters) do        
            self.serverList:SetFilter(index, filterFunc)        
        end
    
    
    else
        Print("Warning: No server list set for ServerTabs item.")
    end

end

function ServerTabs:SetGameTypes(gameTypes)

    local types = {}
    for gameType, playerCount in pairs(gameTypes) do
        table.insert(types, {name = gameType, count = playerCount})
    end
    
    table.sort(types, SortByPlayerCount)

    self.layout = {}
    for _, type in ipairs(kDefaultButtons) do
        table.insert(self.layout, type)
    end

    for _, type in ipairs(types) do
    
        local gameType = type.name
        
        if gameType == "ns2" then
        
            self.layout[2].playerCount = type.count
        
        elseif gameType ~= "?" then

            local button = 
            {
                name = string.upper(gameType),
                filters = { [1] = FilterServerMode(gameType), [8] = FilterFavoriteOnly(false), [11] = FilterHistoryOnly(false) },
                playerCount = type.count,
            }
            
            table.insert(self.layout, button)
        
        end
    
    end
    
    self:Render()

end

function ServerTabs:SetFontName(fontName)
    self.fontName = fontName
end

function ServerTabs:SetTextColor(color)
    self.textColor = color
end

function ServerTabs:SetHoverTextColor(color)
    self.highLightColor = color
end

function ServerTabs:ClearTabs()

    for _, tab in ipairs(self.tabs) do    
        DestroyGUIItem(tab)    
    end
    
    self.tabs = {}

end

local function UpdateTabNum(self)

    local currentTabNum = #self.tabs
    local desiredTabNum = #self.layout

    if currentTabNum < desiredTabNum then
        
        for i = 1, desiredTabNum - currentTabNum do
            table.insert(self.tabs, CreateTextItem(self, true))
        end
    
    end

end

function ServerTabs:Reset()

    local tabSelectorParent = self.tabSelector.guiItem:GetParent()
    if tabSelectorParent then
        tabSelectorParent:RemoveChild(self.tabSelector.guiItem)
    end
    
    self:ClearTabs()
    self.layout = {}
    self.tabSelector:SetIsVisible(false)

end

function ServerTabs:UpdateTabSelector()

    local tabParent = self.tabSelector.guiItem:GetParent()
    if not tabParent or tabParent:GetText() ~= self.selectedTab then
    
        if tabParent then
            tabParent:RemoveChild(self.tabSelector.guiItem)
        end
        
        for _, tab in ipairs(self.tabs) do
        
            local tabText = tab:GetText()
            if tabText == self.selectedTab then
            
                tab.guiItem:AddChild(self.tabSelector.guiItem)
                self.tabSelector:SetIsVisible(true)
                self.tabSelector:SetSize(Vector(tab:GetTextWidth(tabText), tab:GetTextHeight(tabText), 0) + Vector(12, 2, 0))
            
            end
        
        end
    
    end

end

function ServerTabs:Render()

    local offset = 15
    local maxWidth = self.background.guiItem:GetSize().x
    
    local pointX, pointY = Client.GetCursorPosScreen()
    
    UpdateTabNum(self)

    for index, tabDefinition in ipairs(self.layout) do

        local tab = self.tabs[index]
        local additionalOffset = 0
        
        if index > #kDefaultButtons then
            additionalOffset = 80
        end

        local text = tabDefinition.name
        tab:SetText(text)
        tab:SetPosition(Vector(offset + additionalOffset, 4, 0))
        
        local useHighLightColor = text == self.selectedTab or GUIItemContainsPoint(tab.guiItem, pointX, pointY)
        
        if useHighLightColor then
        
            if self.highLightColor then
                tab:SetColor(self.highLightColor)
            end
            
        else
        
            if self.textColor then
                tab:SetColor(self.textColor)
            end
        
        end
        
        if self.fontName then
            tab:SetFontName(self.fontName)
        end
        
        tab:SetIsVisible(GUIScale(offset + additionalOffset) < maxWidth)
        
        offset = offset + 25 + tab:GetTextWidth(text)

    end
    
    self:UpdateTabSelector()

end

