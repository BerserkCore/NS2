// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. ======
//
// lua\menu\GatherChat.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more inTableation, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/WindowUtility.lua")

local kChatInputHeight = 40
local kSliderWidth = 32
local kLineHeight = 38

local kMaxSymbols = 35
local kTransparent = Color(0,0,0,0)

class 'GatherChat' (MenuElement)

function GatherChat:Initialize()

    MenuElement.Initialize(self)

    self.chatInput = CreateMenuElement(self, "TextInput", false)    
    self.chatInput:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.chatInput:SetHeight(kChatInputHeight)
    self.chatInput:SetTopOffset(-kChatInputHeight)
    
    local eventCallbacks =
    {
        OnEscape = function (self)        
            self:SetValue("")            
        end,
        
        OnHide = function (self)
            self:SetValue("")            
        end,
        
        OnEnter = function (self)
        
            local message = self:GetValue()
            Sabot.SendChatMessage(message)
        
            self:SetValue("")  
          
        end,
        
    }
    
    self.chatInput:AddEventCallbacks(eventCallbacks)
    self.chatInput:SetBackgroundColor(Color(0,0,0,1))
    self.chatInput:SetMaxLength(kMaxSymbols)

    self.slideBar = CreateMenuElement(self, "SlideBar", false)
    self.slideBar:SetBackgroundSize(Vector(kSliderWidth, 100, 0), true)
    self.slideBar:SetVertical()
    self.slideBar:SetBackgroundPosition(Vector(-kSliderWidth, 0, 0))
    self.slideBar:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.slideBar:ScrollMax()
    
    self.chatContentBox = CreateMenuElement(self, "ContentBox", false)
    self.chatContentBox:SetOpacity(0)
    self.chatContentBox:SetBorderWidth(0)

    self.slideBar:Register(self.chatContentBox, SLIDE_VERTICAL)
    
    self.chatEntries = {}
    
    self.fontName = "fonts/AgencyFB_small.fnt"
    self.fontColor = Color(1,1,1,1)
    
end

function GatherChat:SetFontName(fontName)

    self.chatInput:SetFontName(fontName)
    self.fontName = fontName

end

function GatherChat:SetTextColor(color)
    
    self.chatInput:SetTextColor(color)
    self.fontColor = color

end

function GatherChat:SetChatData(chatData)

    PROFILE("GatherChat:SetChatData")
    
    local slideBarPos = self.slideBar:GetValue()
    
    local wasOnMax = slideBarPos == 1 or slideBarPos == 0

    local numEntries = #self.chatEntries
    local numCurrentEntries = #chatData
    
    // do nothing when same amount of messages, users cannot edit messages
    if numEntries == numCurrentEntries then
        return
    end    
     
    if numEntries > numCurrentEntries then
     
        for i = 1,  numEntries - numCurrentEntries do
        
            self.chatEntries[#self.chatEntries]:Uninitialize()
            self.chatEntries[#self.chatEntries] = nil
        
        end
     
    elseif numCurrentEntries > numEntries then
     
        for i = 1, numCurrentEntries - numEntries do
        
            local entry = CreateMenuElement(self.chatContentBox, "Font")
            entry:SetFontName(self.fontName)
            entry:SetBackgroundColor(kTransparent)
            entry:SetTextColor(self.fontColor)
            table.insert(self.chatEntries, entry)                    
       
        end
     
    end
     
    // update data and positions
    for i = 1, numCurrentEntries do
     
        local data = string.gsub(chatData[i], 0, kMaxSymbols)
        local entry = self.chatEntries[i]
        
        entry:SetTopOffset( (i-1) * kLineHeight )
        entry:SetText(data)
     
    end
    
    if wasOnMax then
        self.slideBar:ScrollBottom()        
    end

end

function GatherChat:GetTagName()
    return "gatherchat"
end

function GatherChat:SetBackgroundSize(sizeVector, absolute, time, animateFunc, animName, callBack)

    MenuElement.SetBackgroundSize(self, sizeVector, absolute, time, animateFunc, animName, callBack)
    
    self.chatInput:SetWidth(sizeVector.x - 2 * kSliderWidth)
    self.chatContentBox:SetBackgroundSize(Vector(sizeVector.x - 2 * kSliderWidth, sizeVector.y - kChatInputHeight, 0))
    self.slideBar:SetBackgroundSize(Vector(kSliderWidth, sizeVector.y, 0))

end

