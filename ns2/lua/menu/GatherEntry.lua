// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. ======
//
// lua\menu\GatherEntry.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more inTableation, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/WindowUtility.lua")

kGatherEntryHeight = 256
kGatherEntryWidth = 196

local kYellow = Color(1, 1, 0)
local kGreen = Color(0, 1, 0)
local kRed = Color(1, 0 ,0)

local kGatherTexture = "ui/menu/sabot/ns2icon.dds"

local kTopOffset = 32

local kPrivateIconSize = Vector(26, 26, 0)
local kPrivateIconPos = Vector(32, 74 + kTopOffset, 0)
local kPrivateIconTexture = "ui/lock.dds"

local kPlayerSkillSize = Vector(64, 20, 0)
local kPlayerSkillOffset = Vector(64, 110 + kTopOffset, 0)

local kGatherNameOffset = Vector(0, 150 + kTopOffset, 0)

local kGatherIconSize = Vector(74, 74, 0)
local kGatherIconOffset = Vector(-kGatherIconSize.x * 0.5, 32 + kTopOffset, 0)

local kPlayerCountOffset = Vector(0, 180 + kTopOffset, 0)
local kFontScale = 0.7

local kMapOffset = Vector(0, kTopOffset, 0)

class 'GatherEntry' (MenuElement)

function GatherEntry:Initialize()

    self:DisableBorders()
    
    MenuElement.Initialize(self)
    
    // Has no children, but just to keep sure, we do that.
    self:SetChildrenIgnoreEvents(true)
    
    local eventCallbacks =
    {
        OnMouseIn = function(self, buttonPressed)
            MainMenu_OnMouseIn()
        end,
        
        OnMouseOver = function(self)        
            // TODO         
        end,
        
        OnMouseDown = function(self, key, doubleClick)
            self.scriptHandle:ProcessJoinGather(self.gatherId)            
        end
    }
    
    self:AddEventCallbacks(eventCallbacks)
    
    self.gatherId = -1
    
    self.icon = CreateGraphicItem(self, true)
    self.icon:SetTexture(kGatherTexture)
    self.icon:SetSize(kGatherIconSize)
    self.icon:SetPosition(kGatherIconOffset)
    self.icon:SetAnchor(GUIItem.Middle, GUIItem.Top)
    
    self.gatherName = CreateTextItem(self, true)
    self.gatherName:SetPosition(kGatherNameOffset)
    self.gatherName:SetTextAlignmentX(GUIItem.Align_Center)
    self.gatherName:SetTextAlignmentY(GUIItem.Align_Center)
    self.gatherName:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.gatherName:SetScale(GUIScale(Vector(1,1,1)) * kFontScale)
        
    self.mapName = CreateTextItem(self, true)
    self.mapName:SetTextAlignmentX(GUIItem.Align_Center)
    self.mapName:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.mapName:SetScale(GUIScale(Vector(1,1,1)) * kFontScale)
    self.mapName:SetPosition(kMapOffset)
    
    self.playerCount = CreateTextItem(self, true)
    self.playerCount:SetPosition(kPlayerCountOffset)
    self.playerCount:SetTextAlignmentX(GUIItem.Align_Center)
    self.playerCount:SetTextAlignmentY(GUIItem.Align_Center)
    self.playerCount:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.playerCount:SetScale(GUIScale(Vector(1,1,1)) * kFontScale)

    self.private = CreateGraphicItem(self, true)
    self.private:SetSize(kPrivateIconSize)
    self.private:SetPosition(kPrivateIconPos)
    self.private:SetTexture(kPrivateIconTexture)
    
    self.playerSkill = CreateGraphicItem(self, true)
    self.playerSkill:SetPosition(kPlayerSkillOffset)
    
    self:SetFontName("fonts/AgencyFB_medium.fnt")
    
    self:SetTextColor(kWhite)
    self:SetHeight(kGatherEntryHeight)
    self:SetWidth(kGatherEntryWidth)
    self:SetBackgroundColor(kNoColor)

end

function GatherEntry:SetFontName(fontName)

    self.gatherName:SetFontName(fontName)
    self.mapName:SetFontName(fontName)
    self.playerCount:SetFontName(fontName)

end

function GatherEntry:SetTextColor(color)

    self.gatherName:SetColor(color)
    self.mapName:SetColor(color)
    self.playerCount:SetColor(color)
    
end

function GatherEntry:SetGatherData(gatherData)

    PROFILE("GatherEntry:SetGatherData")

    if self.gatherData ~= gatherData then
    
        gatherData.playerNumber = gatherData.playerNumber or 0
        gatherData.requiresPassword = gatherData.requiresPassword == true or false

        self.playerCount:SetText(string.format("%d/%d", gatherData.playerNumber, gatherData.playerSlots))
        if gatherData.playerNumber >= gatherData.playerSlots then
            self.playerCount:SetColor(kRed)
        else
            self.playerCount:SetColor(kWhite)
        end 
     
        self.gatherName:SetText(gatherData.name)
        
        self.mapName:SetText(gatherData.map)

        self.private:SetIsVisible(gatherData.requiresPassword)

        local skillFraction = Clamp( (gatherData.playerSkill or 0) / kMaxPlayerSkill, 0, 1)
        local skillColor
        if skillFraction >= 0.5 then
            skillColor = LerpColor(kYellow, kRed, (skillFraction - 0.5) * 2)
        elseif skillFraction < 0.5 then
            skillColor = LerpColor(kGreen, kYellow, skillFraction * 2)
        end

        self.playerSkill:SetColor(skillColor)
        self.playerSkill:SetSize(Vector(kPlayerSkillSize.x * skillFraction, kPlayerSkillSize.y, 0))

        self:SetId(gatherData.gatherId)
        self.gatherData = { }
        for name, value in pairs(gatherData) do
            self.gatherData[name] = value
        end
        
    end
    
end

function GatherEntry:GetTagName()
    return "gatherentry"
end

function GatherEntry:SetId(id)

    assert(type(id) == "number")
    self.gatherId = id
    
end

function GatherEntry:GetId()
    return self.gatherId
end

