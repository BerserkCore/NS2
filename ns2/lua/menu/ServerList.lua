// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. ======
//
// lua\menu\ServerList.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more inTableation, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/ServerEntry.lua")

local kDefaultWidth = 350
local kDefaultColumnHeight = 64
local kDefaultBackgroundColor = Color(0.5, 0.5, 0.5, 0.4)

kFilterMaxPing = 600

class 'ServerList' (MenuElement)

local gLastSortType = 0
local gSortReversed = false

function UpdateSortOrder(sortType)

    if gLastSortType == sortType then
        gSortReversed = not gSortReversed
    else
        gSortReversed = false
    end

    gLastSortType = sortType

end

function SortByTickrate(a, b)

    local tickrate1 = tonumber(a.tickrate) or 0
    local tickrate2 = tonumber(b.tickrate) or 0

    if not gSortReversed then
        return tickrate1 > tickrate2
    else
        return tickrate1 < tickrate2
    end
    
end

function SortByPing(a, b)

    if not gSortReversed then
        return tonumber(a.ping) < tonumber(b.ping)
    else
        return tonumber(a.ping) > tonumber(b.ping)
    end
    
end

function SortByPlayers(a, b)

    if not gSortReversed then
        return tonumber(a.numPlayers) > tonumber(b.numPlayers)
    else
        return tonumber(a.numPlayers) < tonumber(b.numPlayers)
    end
    
end

function SortByPrivate(a, b)

    local aValue = ConditionalValue(a.requiresPassword, 1, 0)
    local bValue = ConditionalValue(b.requiresPassword, 1, 0)

    if not gSortReversed then
        return aValue > bValue
    else
        return aValue < bValue
    end

end

function SortByFavorite(a, b)

    local aValue = ConditionalValue(a.favorite, 1, 0)
    local bValue = ConditionalValue(b.favorite, 1, 0)

    if not gSortReversed then
        return aValue > bValue
    else
        return aValue < bValue
    end

end

function SortByMap(a, b)

    if not gSortReversed then
        return a.map:upper() > b.map:upper()
    else
        return a.map:upper() < b.map:upper()
    end
    
end

function SortByName(a, b)

    if not gSortReversed then
        return a.name:upper() > b.name:upper()
    else
        return a.name:upper() < b.name:upper()
    end    
        
end

function SortByMode(a, b)

    if not gSortReversed then
        return a.mode:upper() > b.mode:upper()
    else
        return a.mode:upper() < b.mode:upper()
    end    
        
end

function FilterServerMode(mode)
    return function(entry) return string.find(entry.mode, mode) ~= nil end
end

function FilterMapName(map)
    return function(entry) return string.find(entry.map, map) ~= nil end
end

function FilterMinRate(minrate)
    return function(entry) return Clamp(entry.tickrate / 30, 0, 1) >= minrate - 0.01 end
end

function FilterMaxPing(maxping)
    return function(entry)
    
        // don't limit ping
        if maxping == kFilterMaxPing then
            return true
        else
            return entry.ping <= maxping
        end
        
    end
end

function FilterEmpty(active)
    return function(entry) return not active or entry.numPlayers ~= 0 end
end

function FilterFull(active)
    return function(entry) return not active or entry.numPlayers < entry.maxPlayers end
end

function FilterModded(active)
    return function(entry) return not active or entry.modded == false end
end

function FilterFavoriteOnly(active)
    return function(entry) return not active or entry.favorite == true end
end

function FilterPassworded(active)
    return function(entry) return active or entry.requiresPassword == false end
end

function FilterRookie(active)
    return function(entry) return not active or entry.rookieFriendly == false end
end

local function CheckShowTableEntry(self, entry)

    for _, filterFunc in pairs(self.filter) do
    
        if not filterFunc(entry) then
            return false
        end
    
    end
    
    return true
    
end

// called after the table has changed (style or data)
local function RenderServerList(self)

    local renderPosition = 0
    
    local serverListWidth = self:GetWidth()
    local serverListSize = #self.serverEntries
    local numServers = #self.tableData
    local lastSelectedServerId = MainMenu_GetSelectedServer()
    self.scriptHandle:ResetServerSelection()
    
    // add, remove entries, but reuse as many GUIItems as possible
    if serverListSize < numServers then
    
        for i = 1, numServers - serverListSize do
            table.insert(self.serverEntries, CreateMenuElement(self, 'ServerEntry', false))
        end
        
    elseif serverListSize > numServers then
    
        for i = 1, serverListSize - numServers do
        
            self.serverEntries[#self.serverEntries]:Uninitialize()
            table.remove(self.serverEntries, #self.serverEntries)
            
        end
        
    end
    
    for i = 1, #self.tableData do
    
        local serverEntry = self.serverEntries[i]
        
        if CheckShowTableEntry(self, self.tableData[i]) then
        
            serverEntry:SetIsVisible(true)
            serverEntry:SetWidth(serverListWidth)
            serverEntry:SetBackgroundPosition(Vector(0, renderPosition * kServerEntryHeight, 0))
            serverEntry:SetServerData(self.tableData[i])
            
            if self.tableData[i].serverId == lastSelectedServerId then
                SelectServerEntry(serverEntry)
            end
            
            renderPosition = renderPosition + 1
            
        else
            serverEntry:SetIsVisible(false)
        end
        
    end
    
    self:SetHeight(renderPosition * kServerEntryHeight)
    
end

function ServerList:Initialize()

    self:DisableBorders()
    MenuElement.Initialize(self)
    
    self:SetWidth(kDefaultWidth)
    self:SetBackgroundColor(kNoColor)
    
    self.tableData = {}
    self.serverEntries = {}
    self.filter = {}
    
    // default sorting is set in GUIMainMenu
    self.comparator = nil
    
end

function ServerList:Uninitialize()

    MenuElement.Uninitialize(self)

    self.tableData = {}
    self.serverEntries = {}

end

function ServerList:GetTagName()
    return "serverlist"
end

function ServerList:SetEntryCallbacks(callbacks)
    self.entryCallbacks = callbacks
end

function ServerList:SetComparator(comparator)

    self.comparator = comparator
    self:Sort(self.tableData)
    
end

function ServerList:Sort(tableData)

    if self.comparator then
        table.sort(tableData, self.comparator)
    end

    RenderServerList(self)

end

function ServerList:SetTableData(tableData)
    
    if tableData then
        self:Sort(tableData)
        self.tableData = tableData
    end
    
end

function ServerList:ClearChildren()

    MenuElement.ClearChildren(self)
    self.tableData = {}
    self.serverEntries = {}

end

function ServerList:AddEntry(serverEntry)

    table.insert(self.tableData, serverEntry)
    RenderServerList(self)
    
end

function ServerList:UpdateEntry(serverEntry)

    for s = 1, #self.tableData do
    
        if self.tableData[s].serverId == serverEntry.serverId then
        
            self.tableData[s] = serverEntry
            break
            
        end
        
    end
    
    RenderServerList(self)
    
end

function ServerList:SetFilter(index, func)

    self.filter[index] = func
    RenderServerList(self)

end