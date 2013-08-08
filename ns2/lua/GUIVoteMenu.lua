// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GUIVoteMenu.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIVoteMenu' (GUIScript)

local kBackgroundColor = Color(0.0, 0.0, 0.0, 0.7)
local kTitleColor = Color(0.7, 0.7, 0.7, 1)
local kTitleTextColor = Color(1, 1, 1, 1)
local kYesBackgroundColor = Color(0, 0.3, 0, 0.4)
local kVotedYesColor = Color(0, 0.6, 0, 0.7)
local kNoBackgroundColor = Color(0.3, 0, 0, 0.4)
local kVotedNoColor = Color(0.6, 0, 0, 0.7)
local kChoiceTextColor = Color(1, 1, 1, 1)
local kFonts = { tiny = "fonts/AgencyFB_tiny.fnt", small = "fonts/AgencyFB_small.fnt", large = "fonts/AgencyFB_large.fnt" }

local function GetFontHeight(screenHeight)
    return screenHeight < 720 and 20 or 30
end

local function UpdateSizeOfUI(self, screenWidth, screenHeight)

    local titleFontName = kFonts.small
    if screenHeight < 720 then
        titleFontName = kFonts.tiny
    end
    self.titleText:SetFontName(titleFontName)
    self.timeText:SetFontName(titleFontName)
    
    self.titleText:SetPosition(Vector(0, -GetFontHeight(screenHeight) / 2, 0))
    self.timeText:SetPosition(Vector(0, GetFontHeight(screenHeight) / 2, 0))
    
    local minWidth = self.titleText:GetTextWidth(self.titleText:GetText()) + 8
    local size = Vector(math.max(screenWidth * 0.2, minWidth), screenHeight * 0.18, 0)
    self.background:SetSize(size)
    self.background:SetPosition(Vector(2, -size.y, 0))
    
    local titleSize = Vector(size.x - 4, size.y * 0.5 - 4, 0)
    self.titleBackground:SetSize(titleSize)
    self.titleBackground:SetPosition(Vector(2, 2, 0))
    
    local choiceSize = Vector(size.x - 4, size.y * 0.25 - 2, 0)
    self.yesBackground:SetSize(choiceSize)
    local yesPos = Vector(2, titleSize.y + 4, 0)
    self.yesBackground:SetPosition(yesPos)
    self.yesText:SetFontName(titleFontName)
    self.yesCount:SetFontName(titleFontName)
    
    self.noBackground:SetSize(choiceSize)
    self.noBackground:SetPosition(Vector(2, yesPos.y + choiceSize.y + 2, 0))
    self.noText:SetFontName(titleFontName)
    self.noCount:SetFontName(titleFontName)
    
end

function GUIVoteMenu:Initialize()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetIsVisible(false)
    self.background:SetColor(kBackgroundColor)
    self.background:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.background:SetLayer(kGUILayerMainMenu)
    
    self.titleBackground = GUIManager:CreateGraphicItem()
    self.titleBackground:SetColor(kTitleColor)
    self.background:AddChild(self.titleBackground)
    
    self.titleText = GUIManager:CreateTextItem()
    self.titleText:SetColor(kTitleTextColor)
    self.titleText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.titleText:SetTextAlignmentX(GUIItem.Align_Center)
    self.titleText:SetTextAlignmentY(GUIItem.Align_Center)
    self.titleBackground:AddChild(self.titleText)
    
    self.timeText = GUIManager:CreateTextItem()
    self.timeText:SetColor(kTitleTextColor)
    self.timeText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.timeText:SetTextAlignmentX(GUIItem.Align_Center)
    self.timeText:SetTextAlignmentY(GUIItem.Align_Center)
    self.titleBackground:AddChild(self.timeText)
    
    self.yesBackground = GUIManager:CreateGraphicItem()
    self.yesBackground:SetColor(kYesBackgroundColor)
    self.background:AddChild(self.yesBackground)
    
    self.yesText = GUIManager:CreateTextItem()
    self.yesText:SetColor(kChoiceTextColor)
    self.yesText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.yesText:SetTextAlignmentX(GUIItem.Align_Min)
    self.yesText:SetTextAlignmentY(GUIItem.Align_Center)
    self.yesText:SetText(StringReformat(Locale.ResolveString("VOTE_YES"), { key = GetPrettyInputName("VoteYes") }))
    self.yesText:SetPosition(Vector(2, 0, 0))
    self.yesBackground:AddChild(self.yesText)
    
    self.yesCount = GUIManager:CreateTextItem()
    self.yesCount:SetColor(kChoiceTextColor)
    self.yesCount:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.yesCount:SetTextAlignmentX(GUIItem.Align_Max)
    self.yesCount:SetTextAlignmentY(GUIItem.Align_Center)
    self.yesCount:SetText("0")
    self.yesCount:SetPosition(Vector(-2, 0, 0))
    self.yesBackground:AddChild(self.yesCount)
    
    self.noBackground = GUIManager:CreateGraphicItem()
    self.noBackground:SetColor(kNoBackgroundColor)
    self.background:AddChild(self.noBackground)
    
    self.noText = GUIManager:CreateTextItem()
    self.noText:SetColor(kChoiceTextColor)
    self.noText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.noText:SetTextAlignmentX(GUIItem.Align_Min)
    self.noText:SetTextAlignmentY(GUIItem.Align_Center)
    self.noText:SetText(StringReformat(Locale.ResolveString("VOTE_NO"), { key = GetPrettyInputName("VoteNo") }))
    self.noText:SetPosition(Vector(2, 0, 0))
    self.noBackground:AddChild(self.noText)
    
    self.noCount = GUIManager:CreateTextItem()
    self.noCount:SetColor(kChoiceTextColor)
    self.noCount:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.noCount:SetTextAlignmentX(GUIItem.Align_Max)
    self.noCount:SetTextAlignmentY(GUIItem.Align_Center)
    self.noCount:SetText("0")
    self.noCount:SetPosition(Vector(-2, 0, 0))
    self.noBackground:AddChild(self.noCount)
    
    self.votedYes = nil
    
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
end

function GUIVoteMenu:Uninitialize()

    GUI.DestroyItem(self.noCount)
    self.noCount = nil
    
    GUI.DestroyItem(self.noText)
    self.noText = nil
    
    GUI.DestroyItem(self.noBackground)
    self.noBackground = nil
    
    GUI.DestroyItem(self.yesCount)
    self.yesCount = nil
    
    GUI.DestroyItem(self.yesText)
    self.yesText = nil
    
    GUI.DestroyItem(self.yesBackground)
    self.yesBackground = nil
    
    GUI.DestroyItem(self.timeText)
    self.timeText = nil
    
    GUI.DestroyItem(self.titleText)
    self.titleText = nil
    
    GUI.DestroyItem(self.titleBackground)
    self.titleBackground = nil
    
    GUI.DestroyItem(self.background)
    self.background = nil
    
end

function GUIVoteMenu:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
end

function GUIVoteMenu:Update(deltaTime)

    PROFILE("GUIVoteMenu:Update")
    
    local currentVoteQuery = GetCurrentVoteQuery()
    local visible = currentVoteQuery ~= nil
    self.background:SetIsVisible(visible)
    
    local changed = self.lastCurrentVoteQuery ~= currentVoteQuery
    
    if changed and visible then
    
        self.lastCurrentVoteQuery = currentVoteQuery
        self.votedYes = nil
        self.titleText:SetText(currentVoteQuery)
        self.titleText:SetColor(kTitleTextColor)
        
    end
    
    if visible then
    
        if self.votedYes ~= nil then
        
            if self.votedYes then
            
                self.yesBackground:SetColor(kVotedYesColor)
                self.noBackground:SetColor(kNoBackgroundColor)
                
            else
            
                self.noBackground:SetColor(kVotedNoColor)
                self.yesBackground:SetColor(kYesBackgroundColor)
                
            end
            
        else
        
            self.yesBackground:SetColor(kYesBackgroundColor)
            self.noBackground:SetColor(kNoBackgroundColor)
            
        end
        
        local yes, no = GetVoteResults()
        self.yesCount:SetText(ToString(yes))
        self.noCount:SetText(ToString(no))
        
        local lastVoteResults = GetLastVoteResults()
        if lastVoteResults ~= nil then
        
            self.titleText:SetText(((lastVoteResults and Locale.ResolveString("VOTE_PASSED")) or Locale.ResolveString("VOTE_FAILED")))
            self.titleText:SetColor(lastVoteResults and kVotedYesColor or kVotedNoColor)
            
            UpdateSizeOfUI(self, Client.GetScreenWidth(), Client.GetScreenHeight())
            
        end
        
    else
        self.lastCurrentVoteQuery = nil
    end
    
    local voteTimeLeft = GetCurrentVoteTimeLeft()
    self.timeText:SetText(ToString(math.ceil(voteTimeLeft)))
    
end

function GUIVoteMenu:SendKeyEvent(key, down)

    local voteId = GetCurrentVoteId()
    if down and self.votedYes == nil and voteId ~= self.lastVotedId then
    
        if GetIsBinding(key, "VoteYes") then
        
            self.votedYes = true
            self.timeLastVoted = Shared.GetTime()
            SendVoteChoice(true)
            self.lastVotedId = voteId
            
        elseif GetIsBinding(key, "VoteNo") then
        
            self.votedYes = false
            self.timeLastVoted = Shared.GetTime()
            SendVoteChoice(false)
            self.lastVotedId = voteId
            
        end
        
    end
    
    return false
    
end