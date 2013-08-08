// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenu_Mods.lua
//
//    Created by:   Marc Delorme (marc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// Translates from names returned by Client.GetModState to what we display
local kModStateNames =
    {
        getting_info    = "GETTING INFO",
        downloading     = "DOWNLOADING",
        unavailable     = "UNAVAILABLE",
        available       = "AVAILABLE",
    }

function GUIMainMenu:RefreshModsList()
    Client.RefreshModList()
end

local kGetModsURL = "http://steamcommunity.com/workshop/browse?appid=4920"

function GUIMainMenu:CreateModsWindow()

    self.modsWindow = self:CreateWindow()
    self.modsWindow:DisableCloseButton()
    self:SetupWindow(self.modsWindow, "MODS")
    self.modsWindow:GetContentBox():SetCSSClass("mod_list")
    
    local back = CreateMenuElement(self.modsWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText("BACK")
    back:AddEventCallbacks({ OnClick = function() self.modsWindow:SetIsVisible(false) end })
    
    local getMods = CreateMenuElement(self.modsWindow, "MenuButton")
    getMods:SetCSSClass("getmods")
    getMods:SetText("GET MODS")
    getMods:AddEventCallbacks({ OnClick = function() Client.ShowWebpage(kGetModsURL) end })
    //getMods:AddEventCallbacks({ OnClick = function() SetMenuWebView(kGetModsURL, Vector(Client.GetScreenWidth() * 0.8, Client.GetScreenHeight() * 0.8, 0)) end })
    
    local restart = CreateMenuElement(self.modsWindow, "MenuButton")
    restart:SetCSSClass("apply")
    restart:SetText("RESTART")
    restart:AddEventCallbacks({ OnClick = function() Client.RestartMain() end })
    
    self.highlightMod = CreateMenuElement(self.modsWindow:GetContentBox(), "Image")
    self.highlightMod:SetCSSClass("highlight_server")
    self.highlightMod:SetIgnoreEvents(true)
    self.highlightMod:SetIsVisible(false)
    
    self.blinkingArrow = CreateMenuElement(self.highlightMod, "Image")
    self.blinkingArrow:SetCSSClass("blinking_arrow")
    self.blinkingArrow:GetBackground():SetInheritsParentStencilSettings(false)
    self.blinkingArrow:GetBackground():SetStencilFunc(GUIItem.Always)
    
    self.selectMod = CreateMenuElement(self.modsWindow:GetContentBox(), "Image")
    self.selectMod:SetCSSClass("select_server")
    self.selectMod:SetIsVisible(false)
    self.selectMod:SetIgnoreEvents(true)
    
    self.modsRowNames = CreateMenuElement(self.modsWindow, "Table")
    self.modsTable = CreateMenuElement(self.modsWindow:GetContentBox(), "Table")

    local columnClassNames =
    {
        "modname",
        "state",
        "subscribed",
        "active"
    }
    
    local rowNames = { { "NAME", "STATE", "SUBSCRIBED", "ACTIVE" } }
    
    self.modsRowNames:SetCSSClass("server_list_row_names")
    self.modsRowNames:SetColumnClassNames(columnClassNames)
    self.modsRowNames:SetRowPattern( {RenderServerNameEntry} )
    self.modsRowNames:SetTableData(rowNames)

    local rowPattern =
    {
        RenderModName,
        RenderTextEntry,
        RenderTextEntry,
        RenderTextEntry,
    }
    
    self.modsTable:SetRowPattern(rowPattern)
    self.modsTable:SetCSSClass("mod_list")
    self.modsTable:SetColumnClassNames(columnClassNames)
    
    local OnRowCreate = function(row)
    
        local eventCallbacks =
        {
            OnMouseIn = function(self, buttonPressed)
                MainMenu_OnMouseIn()
            end,
            
            OnMouseOver = function(self)
            
                local height = self:GetHeight()
                local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
                self.scriptHandle.highlightMod:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
                self.scriptHandle.highlightMod:SetIsVisible(true)
                
            end,
            
            OnMouseOut = function(self)
                self.scriptHandle.highlightMod:SetIsVisible(false)
            end,
            
            OnMouseDown = function(self)
            
                local height = self:GetHeight()
                local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
                self.scriptHandle.selectMod:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
                self.scriptHandle.selectMod:SetIsVisible(true)
                
                // Toggle whether or not the mod is active
                local id = self:GetId()
                Client.SetModActive( id, not Client.GetIsModActive(id) )
                
            end
        }
        
        row:AddEventCallbacks(eventCallbacks)
        row:SetChildrenIgnoreEvents(true)
        
    end
    
    self.modsTable:SetRowCreateCallback(OnRowCreate)
    self.modsTable:SetColumnClassNames(columnClassNames)
    
    self.modsWindow:AddEventCallbacks({ 
        OnShow = function() 
            self.displayedMods = { }
            self.modsTable:ClearChildren()
            self.selectMod:SetIsVisible(false)
        end 
    })
    
end

function GUIMainMenu:UpdateModsWindow(self)
    
    local reload = false

    for s = 1, Client.GetNumMods() do

        local state = Client.GetModState(s)
        local stateString = kModStateNames[state]
        if stateString == nil then
            stateString = "??"
        end
        local name = Client.GetModTitle(s)
        local active = Client.GetIsModActive(s) and "YES" or "NO"
        local subscribed = Client.GetIsSubscribedToMod(s) and "YES" or "NO"
        local percent = "100%"
        
        local downloading, bytesDownloaded, totalBytes = Client.GetModDownloadProgress(s)
        
        if downloading then
        
            percent = "0%"
            if totalBytes > 0 then
                percent = string.format("%d%%", math.floor((bytesDownloaded / totalBytes) * 100))
            end
            
            stateString = stateString .. " (" .. percent .. ")"
            
        end
        
        local currentStatus = state .. name .. subscribed .. active .. percent
        
        if state ~= "getting_info" and (s > #self.displayedMods or self.displayedMods[s].currentStatus ~= currentStatus) then
        
            reload = true
            
            if s > #self.displayedMods then
            
                table.insert(self.displayedMods, { index = s, currentStatus = currentStatus })
                self.modsTable:AddRow({ name, stateString, subscribed, active }, s)
                
            else
                
                self.modsTable:UpdateRowData(s, { name, stateString, subscribed, active })
                self.displayedMods[s].currentStatus = currentStatus
                
            end
            
        end
        
    end

    if reload then
        self.modsTable:Sort()
    end
   
end