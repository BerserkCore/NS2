// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GUIEventTester.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Displays a list of events that need to be tested.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")

class 'GUIEventTester' (GUIScript)

local kBackgroundSize = Vector(250, 400, 0)

local kMaxEventsDisplayedOnPage = 24

function GUIEventTester:Initialize()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(kBackgroundSize)
    self.background:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.background:SetPosition(Vector(-kBackgroundSize.x - 10, -kBackgroundSize.y / 2, 0))
    self.background:SetColor(Color(0.8, 0.8, 0.8, 0.8))
    self.background:SetIsVisible(false)
    
    self.percentComplete = GUIManager:CreateTextItem()
    self.percentComplete:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.percentComplete:SetTextAlignmentX(GUIItem.Align_Center)
    self.percentComplete:SetTextAlignmentY(GUIItem.Align_Min)
    self.percentComplete:SetText("")
    self.percentComplete:SetFontName("fonts/Arial_15.fnt")
    self.background:AddChild(self.percentComplete)
    
    self.events = table.array(128)
    
    self.currentPage = 0
    self.currentEvents = { }
    
end

function GUIEventTester:Uninitialize()
    GUI.DestroyItem(self.background)
end

local function GetNumPages(self)
    return math.ceil(table.countkeys(self.currentEvents) / kMaxEventsDisplayedOnPage)
end

function GUIEventTester:SendKeyEvent(key, down)

    if self.background:GetIsVisible() and down then
    
        if key == InputKey.PageUp then
        
            self.currentPage = math.max(0, self.currentPage - 1)
            self:SetTestEvents(self.currentEvents)
            
        elseif key == InputKey.PageDown then
        
            local numPages = GetNumPages(self)
            self.currentPage = math.min(numPages - 1, self.currentPage + 1)
            self:SetTestEvents(self.currentEvents)
            
        end
        
    end
    
end

local function ClearCurrentEvents(self)

    for e = 1, #self.events do
        self.events[e]:SetIsVisible(false)
    end
    
    self.currentEvents = { }
    
end

local function GetFreeTestEvent(self)

    for e = 1, #self.events do
    
        if not self.events[e]:GetIsVisible() then
        
            self.events[e]:SetIsVisible(true)
            return self.events[e]
            
        end
        
    end
    
    local newEvent = GUIManager:CreateTextItem()
    newEvent:SetAnchor(GUIItem.Left, GUIItem.Top)
    newEvent:SetTextAlignmentX(GUIItem.Align_Min)
    newEvent:SetTextAlignmentY(GUIItem.Align_Center)
    newEvent:SetText("")
    newEvent:SetFontName("fonts/Arial_15.fnt")
    self.background:AddChild(newEvent)
    table.insert(self.events, newEvent)
    return newEvent
    
end

function GUIEventTester:SetTestEvents(testEvents)

    ClearCurrentEvents(self)
    
    self.currentEvents = testEvents
    
    local sortedEvents = table.array(table.countkeys(self.currentEvents))
    for name, tested in pairs(self.currentEvents) do
        table.insert(sortedEvents, { name = name, tested = tested })
    end
    table.sort(sortedEvents, function(a, b) return (a.name < b.name) end)
    
    local eventNum = 0
    local numTested = 0
    for e = 1, #sortedEvents do
    
        local name = sortedEvents[e].name
        local tested = sortedEvents[e].tested
        local currentEventNum = e - 1
        
        // Only display the events on the current page.
        if currentEventNum >= self.currentPage * kMaxEventsDisplayedOnPage and
           currentEventNum < (self.currentPage + 1) * kMaxEventsDisplayedOnPage then
        
            local eventUI = GetFreeTestEvent(self)
            eventUI:SetColor(Color(0, tested and 0.5 or 0, 0, 1))
            local testedName = tested and ("- " .. name) or name
            eventUI:SetText(testedName)
            eventUI:SetPosition(Vector(2, eventNum * 16 + 24, 0))
            
            eventNum = eventNum + 1
            
        end
        
        if tested then
            numTested = numTested + 1
        end
        
    end
    
    local percent = math.ceil((numTested / #sortedEvents) * 100)
    self.percentComplete:SetText(percent .. "% Complete Pg Up/Down (" .. (self.currentPage + 1) .. " / " .. GetNumPages(self) .. ")")
    
end

function GUIEventTester:SetIsVisible(visible)
    self.background:SetIsVisible(visible)
end