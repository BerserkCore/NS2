// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIInsight_Statistics.lua
//
// Created by: Dghelneshi (nitro35@hotmail.de)
//             Jon 'Huze' Hughes (jon@jhuze.com)
//
// Spectator: Displays team resource statistics
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIInsight_Statistics' (GUIScript)

local kBackgroundTextureAlien = "ui/alien_commander_background.dds"
local kBackgroundTextureMarine = "ui/marine_commander_background.dds"
local kFrameTexture = "ui/statistics.dds"
local kBackgroundTexture = "ui/statsbackground.dds"

local kInfoSize = GUIScale(Vector(70, 20, 0))
local kIconSize = GUIScale(Vector(26, 26, 0))
local kTitleSize = Vector(GUIScale(70), kIconSize.y, 0)
local kInfoFontSize = GUIScale(20)
local kInfoIndentSize = GUIScale(5)
local kTitleFontSize = GUIScale(20)
local icons = 2
local infos = 3
local gapSize = GUIScale(15)
local backgroundPaddingSize = GUIScale(15)
local teamBackgroundSize = Vector(kInfoSize.x, kTitleSize.y * icons + kInfoSize.y * infos + gapSize, 0)
local backgroundSize = Vector(teamBackgroundSize.x * 2 + backgroundPaddingSize * 4, teamBackgroundSize.y + backgroundPaddingSize * 2, 0)

-- Layout

-- [Res Icon]   XXX
-- Lost         XXX
-- Total        XXX
--
-- [RTs Icon]    xx
-- Lost          XX

local kTeamResourceIcon = { Width = 0, Height = 0, X = 0, Y = 0, Coords = { X1 = 844, Y1 = 412, X2 = 882, Y2 = 450 } }
kTeamResourceIcon.Width = kTeamResourceIcon.Coords.X2 - kTeamResourceIcon.Coords.X1
kTeamResourceIcon.Height = kTeamResourceIcon.Coords.Y2 - kTeamResourceIcon.Coords.Y1
kTeamResourceIcon.X = -5
kTeamResourceIcon.Y = -4

local kResourceTowerIcon = { Width = 0, Height = 0, X = 0, Y = 0, Coords = { X1 = 918, Y1 = 418, X2 = 945, Y2 = 444 } }
kResourceTowerIcon.Width = kResourceTowerIcon.Coords.X2 - kResourceTowerIcon.Coords.X1
kResourceTowerIcon.Height = kResourceTowerIcon.Coords.Y2 - kResourceTowerIcon.Coords.Y1
kResourceTowerIcon.X = -kResourceTowerIcon.Width / 2
kResourceTowerIcon.Y = -4

local frameCoords = {0,0,256,230}
local topHeight = GUIScale(24)
local marineGradientCoords = {0,230,128,256}
local alienGradientCoords = {128,230,256,256}

function GUIInsight_Statistics:Initialize()
 
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(backgroundSize)
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.background:SetPosition(-Vector(backgroundSize.x/2, backgroundSize.y, 0))
    self.background:SetTexture(kBackgroundTexture)
    self.background:SetTexturePixelCoordinates(unpack({0,0,412,364}))
    self.background:SetLayer(kGUILayerInsight)

    local frame = GUIManager:CreateGraphicItem()
    frame:SetSize(Vector(backgroundSize.x, backgroundSize.y + topHeight, 0))
    frame:SetPosition(Vector(0, -topHeight, 0))
    frame:SetAnchor(GUIItem.Left, GUIItem.Top)
    frame:SetTexture(kFrameTexture)
    frame:SetTexturePixelCoordinates(unpack(frameCoords))
    frame:SetLayer(kGUILayerInsight+1)
    self.background:AddChild(frame)
    
    local marineGradient = GUIManager:CreateGraphicItem()
    marineGradient:SetSize(Vector(backgroundSize.x/2, backgroundSize.y, 0))
    marineGradient:SetAnchor(GUIItem.Left, GUIItem.Top)
    marineGradient:SetTexture(kFrameTexture)
    marineGradient:SetTexturePixelCoordinates(unpack(marineGradientCoords))
    marineGradient:SetColor(kBlueColor)
    marineGradient:SetIsVisible(false)
    self.background:AddChild(marineGradient)
    
    local alienGradient = GUIManager:CreateGraphicItem()
    alienGradient:SetSize(Vector(backgroundSize.x/2, backgroundSize.y, 0))
    alienGradient:SetAnchor(GUIItem.Middle, GUIItem.Top)
    alienGradient:SetTexture(kFrameTexture)
    alienGradient:SetTexturePixelCoordinates(unpack(alienGradientCoords))
    alienGradient:SetColor(kRedColor)
    alienGradient:SetIsVisible(false)
    self.background:AddChild(alienGradient)
    
    local padding = Vector(backgroundPaddingSize, backgroundPaddingSize,0)
    
    -- MARINES --
    
    -- Background
    local marineResBackground = GUIManager:CreateGraphicItem()
    marineResBackground:SetSize(teamBackgroundSize)
    marineResBackground:SetPosition(padding)
    marineResBackground:SetAnchor(GUIItem.Left, GUIItem.Top)
    marineResBackground:SetColor(Color(0, 0, 0, 0))
    self.background:AddChild(marineResBackground)

    -- Resources and Extractors
    self.marineTeamText = self:CreateTextIconItem(  0, marineResBackground, kBackgroundTextureMarine, kTeamResourceIcon.Coords)
    _, self.marineResLostText = self:CreateTextItem(   kTitleSize.y, marineResBackground, "Lost", kBlueColor)
    self.marineTotalResName, self.marineTotalResText = self:CreateTextItem(  kTitleSize.y +   kInfoSize.y, marineResBackground, "Total", kBlueColor)
    self.marineTowerText = self:CreateTextIconItem( kTitleSize.y + 2*kInfoSize.y + gapSize, marineResBackground, kBackgroundTextureMarine, kResourceTowerIcon.Coords)
    _, self.marineRtLostText = self:CreateTextItem(  2*kTitleSize.y + 2*kInfoSize.y + gapSize, marineResBackground, "Lost", kBlueColor)

    -- ALIENS --
    
    -- Background
    local alienResBackground = GUIManager:CreateGraphicItem()
    alienResBackground:SetSize(teamBackgroundSize)
    alienResBackground:SetPosition(padding)
    alienResBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
    alienResBackground:SetColor(Color(0, 0, 0, 0))
    self.background:AddChild(alienResBackground)

    -- Resources and Harvesters
    self.alienTeamText = self:CreateTextIconItem(  0, alienResBackground, kBackgroundTextureAlien, kTeamResourceIcon.Coords)
    _, self.alienResLostText = self:CreateTextItem(   kTitleSize.y, alienResBackground, "Lost", kRedColor)
    self.alienTotalResName, self.alienTotalResText = self:CreateTextItem(  kTitleSize.y +   kInfoSize.y, alienResBackground, "Total", kRedColor)
    self.alienTowerText = self:CreateTextIconItem( kTitleSize.y + 2*kInfoSize.y + gapSize, alienResBackground, kBackgroundTextureAlien, kResourceTowerIcon.Coords)
    _, self.alienRtLostText = self:CreateTextItem(  2*kTitleSize.y + 2*kInfoSize.y + gapSize, alienResBackground, "Lost", kRedColor)

end

function GUIInsight_Statistics:Uninitialize()

    // Resource display
    GUI.DestroyItem(self.background)
    self.background = nil
    
end

function GUIInsight_Statistics:OnResolutionChanged(oldX, oldY, newX, newY)

    self:Uninitialize()

    kInfoSize = GUIScale(Vector(70, 20, 0))
    kIconSize = GUIScale(Vector(26, 26, 0))
    kTitleSize = Vector(GUIScale(70), kIconSize.y, 0)
    kInfoFontSize = GUIScale(20)
    kInfoIndentSize = GUIScale(5)
    kTitleFontSize = GUIScale(20)
    gapSize = GUIScale(15)
    backgroundPaddingSize = GUIScale(15)
    teamBackgroundSize = Vector(kInfoSize.x, kTitleSize.y * icons + kInfoSize.y * infos + gapSize, 0)
    backgroundSize = Vector(teamBackgroundSize.x * 2 + backgroundPaddingSize * 4, teamBackgroundSize.y + backgroundPaddingSize * 2, 0)

    topHeight = GUIScale(24)
    
    self:Initialize()

end

function GUIInsight_Statistics:SetIsVisible(bool)

    self.background:SetIsVisible(bool)

end

function GUIInsight_Statistics:Update(deltaTime)

    PROFILE("GUIInsight_Statistics:Update")
    
    if self.background:GetIsVisible() then

        local player = Client.GetLocalPlayer()
        if player == nil then
            return
        end

        // Resources

        if self.lastUpdateTime == nil or Shared.GetTime() > (self.lastUpdateTime + 1) then

            local marineTeamInfo = GetEntitiesForTeam("TeamInfo", kTeam1Index)
            if table.count(marineTeamInfo) > 0 then

                local totalTeamRes = marineTeamInfo[1]:GetTotalTeamResources()
                local extractorsLost = DeathMsgUI_GetRtsLost(kTeam1Index)
                local numExtractors = marineTeamInfo[1]:GetNumResourceTowers()
                local totalResLost = math.round(DeathMsgUI_GetResLost(kTeam1Index))

                if totalTeamRes >= 1000 then
                    self.marineTotalResName:SetText("Tot.")
                else
                    self.marineTotalResName:SetText("Total")
                end
                
                self.marineTeamText:SetText(ToString(marineTeamInfo[1]:GetTeamResources()))
                self.marineRtLostText:SetText(ToString(extractorsLost))                
                self.marineTotalResText:SetText(ToString(totalTeamRes))
                self.marineTowerText:SetText(ToString(numExtractors))
                self.marineResLostText:SetText(ToString(totalResLost))

            end

            local alienTeamInfo = GetEntitiesForTeam("TeamInfo", kTeam2Index)
            if table.count(alienTeamInfo) > 0 then
                
                local totalTeamRes = alienTeamInfo[1]:GetTotalTeamResources()
                local harvestersLost = DeathMsgUI_GetRtsLost(kTeam2Index)
                local numHarvesters = alienTeamInfo[1]:GetNumResourceTowers()
                local totalResLost = math.round(DeathMsgUI_GetResLost(kTeam2Index))
                
                if totalTeamRes >= 1000 then
                    self.alienTotalResName:SetText("Tot.")
                else
                    self.alienTotalResName:SetText("Total")
                end
                
                self.alienTeamText:SetText(ToString(alienTeamInfo[1]:GetTeamResources()))
                self.alienRtLostText:SetText(ToString(harvestersLost))                
                self.alienTotalResText:SetText(ToString(totalTeamRes))
                self.alienTowerText:SetText(ToString(numHarvesters))
                self.alienResLostText:SetText(ToString(totalResLost))

            end

            self.lastUpdateTime = Shared.GetTime()

        end
    
    end
    
end

function GUIInsight_Statistics:GetBackgroundSize()
    return backgroundSize
end

function GUIInsight_Statistics:CreateTextItem(yPosition, parent, text, color)

    local name = GUIManager:CreateTextItem()
    name:SetFontSize(kTitleFontSize)
    name:SetAnchor(GUIItem.Left, GUIItem.Top)
    name:SetText(text)
    name:SetTextAlignmentX(GUIItem.Align_Min)
    name:SetTextAlignmentY(GUIItem.Align_Min)
    name:SetColor(color)
    name:SetPosition(Vector(0, yPosition, 0))
    name:SetFontIsBold(true)
    parent:AddChild(name)
    
    local value = GUIManager:CreateTextItem()
    value:SetFontSize(kInfoFontSize)
    value:SetAnchor(GUIItem.Left, GUIItem.Top)
    value:SetTextAlignmentX(GUIItem.Align_Max)
    value:SetTextAlignmentY(GUIItem.Align_Min)
    value:SetColor(Color(1, 1, 1, 1))
    value:SetPosition(Vector(kInfoSize.x, yPosition, 0))
    value:SetFontIsBold(true)
    parent:AddChild(value)
    
    return name, value
end

function GUIInsight_Statistics:CreateTextIconItem(yPosition, parent, texture, coords)

    local icon = GUIManager:CreateGraphicItem()
    icon:SetSize(kIconSize)
    icon:SetAnchor(GUIItem.Left, GUIItem.Top)
    icon:SetPosition(Vector(kInfoIndentSize, yPosition, 0))
    icon:SetTexture(texture)
    GUISetTextureCoordinatesTable(icon, coords)
    parent:AddChild(icon)
    
    local value = GUIManager:CreateTextItem()
    value:SetFontSize(kInfoFontSize)
    value:SetAnchor(GUIItem.Left, GUIItem.Top)
    value:SetTextAlignmentX(GUIItem.Align_Max)
    value:SetTextAlignmentY(GUIItem.Align_Center)
    value:SetColor(Color(1, 1, 1, 1))
    value:SetPosition(Vector(kInfoSize.x, yPosition + kIconSize.y/2, 0))
    value:SetFontIsBold(true)
    parent:AddChild(value)
    
    return value
end