// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIInsight_Graphs.lua
//
// Created by: Jon Hughes (jon@jhuze.com)
//
// Displays graphs and statistic information
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/graphs/LineGraph.lua")
Script.Load("lua/graphs/ComparisonBarGraph.lua")

local kGraphs = enum( {'RT', 'Resource', 'Kill' } )

class 'GUIInsight_Graphs' (GUIScript)

local graphPadding = GUIScale(50)
local isVisible
local maxRTs = 0
local maxRes = 0
local rtLineGraph
local rtKilledGraph
local graphBackground

local graphState = kGraphs.RT

function GUIInsight_Graphs:Initialize()
    
    isVisible = false
    
    teams = {}
    teams[kTeam1Index] = {RTs = 0, TotalTeamRes = 0}
    teams[kTeam2Index] = {RTs = 0, TotalTeamRes = 0}
    
    local width = Client.GetScreenWidth()
    local height = Client.GetScreenHeight()
    
    local miniGraphSize = Vector(width/2, height/4, 0)
    local comparisonSize = GUIScale(Vector(400,40,0))
    
    local graphSize = Vector(miniGraphSize.x, miniGraphSize.y*2, 0) + Vector(2*graphPadding,5*graphPadding,0) + Vector(0,comparisonSize.y,0)
    
    graphBackground = GUIManager:CreateGraphicItem()
    graphBackground:SetAnchor(GUIItem.Middle, GUIItem.Center)
    graphBackground:SetSize(graphSize)
    graphBackground:SetPosition(-graphSize/2)
    graphBackground:SetColor(Color(0,0,0,0.9))
    graphBackground:SetLayer(kGUILayerInsight)
    graphBackground:SetIsVisible(isVisible)
    
    rtLineGraph = _G["LineGraph"]()
    rtLineGraph:Initialize()
    rtLineGraph:SetAnchor(GUIItem.Left, GUIItem.Top)
    rtLineGraph:SetTitle("Resource Towers")
    rtLineGraph:SetSize(miniGraphSize)
    rtLineGraph:SetYGridSpacing(1)
    rtLineGraph:SetXAxisIsTime(true)
    rtLineGraph:ExtendXAxisToBounds(true)
    rtLineGraph:StartLine(kTeam1Index, kBlueColor)
    rtLineGraph:StartLine(kTeam2Index, kRedColor)
    rtLineGraph:SetPosition(Vector(graphPadding,graphPadding,0))
    rtLineGraph:GiveParent(graphBackground)
    
    rtKilledGraph = _G["ComparisonBarGraph"]()
    rtKilledGraph:Initialize()
    rtKilledGraph:SetAnchor(GUIItem.Middle, GUIItem.Top)
    rtKilledGraph:SetTitle("RTs Destroyed")
    rtKilledGraph:SetValues(0,0)
    rtKilledGraph:SetPosition(-comparisonSize/2 + Vector(0, miniGraphSize.y + 3*graphPadding, 0))
    rtKilledGraph:GiveParent(graphBackground)
    
    resourceLineGraph = _G["LineGraph"]()
    resourceLineGraph:Initialize()
    resourceLineGraph:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    resourceLineGraph:SetTitle("Total Team Resources")
    resourceLineGraph:SetSize(miniGraphSize)
    resourceLineGraph:SetPosition(Vector(graphPadding, -miniGraphSize.y - graphPadding,0))
    resourceLineGraph:SetYGridSpacing(1)
    resourceLineGraph:SetXAxisIsTime(true)
    resourceLineGraph:StartLine(kTeam1Index, kBlueColor)
    resourceLineGraph:StartLine(kTeam2Index, kRedColor)
    resourceLineGraph:GiveParent(graphBackground)
    
end

function GUIInsight_Graphs:Uninitialize()
    
    GUI.DestroyItem(graphBackground)

end

function GUIInsight_Graphs:SetIsVisible(bool)
    isVisible = bool
    graphBackground:SetIsVisible(isVisible)
end

function GUIInsight_Graphs:SendKeyEvent(key, down)

    if down and GetIsBinding(key, "RequestHealth") then
        GUIInsight_Graphs:SetIsVisible(not isVisible)
        return true
    end
    return false

end

function GUIInsight_Graphs:UpdateTeam(time, teamIndex)

    local teamInfo = GetEntitiesForTeam("TeamInfo", teamIndex)
    local team = teams[teamIndex]
    
    local currentRTs = teamInfo[1]:GetNumResourceTowers()
    local previousRTs = team.RTs
    if currentRTs ~= previousRTs then
    
        maxRTs = math.max(maxRTs, currentRTs)
        rtLineGraph:AddPoint(teamIndex, Vector(time, previousRTs, 0), true, true)
        rtLineGraph:AddPoint(teamIndex, Vector(time, currentRTs, 0), true, true)
        team.RTs = currentRTs
    
    end
    
    local currentTotalTeamRes = teamInfo[1]:GetTotalTeamResources()
    local previousTotalTeamRes = team.TotalTeamRes
    if currentTotalTeamRes ~= previousTotalTeamRes then
    
        maxRes = math.max(maxRes, currentTotalTeamRes)
        resourceLineGraph:AddPoint(teamIndex, Vector(time, currentTotalTeamRes, 0), true, true)
        team.TotalTeamRes = currentTotalTeamRes
    
    end
    
end

local function getXSpacing(time)

    local elapsedTime = time - PlayerUI_GetGameStartTime()
    if elapsedTime < 60 then
        return 10
    elseif elapsedTime < 5*60 then
        return 30
    elseif elapsedTime < 15*60 then
        return 60
    elseif elapsedTime < 60*60 then
        return 300
    else
        return 600
    end    

end

local function getResSpacing(res)

    if res < 100 then
        return 10
    elseif res < 500 then
        return 50
    elseif res < 1000 then
        return 100
    else
        return 200    
    end
    
end

function GUIInsight_Graphs:Update(deltaTime)

    local time = Shared.GetTime()
    if PlayerUI_GetHasGameStarted() then
    
        GUIInsight_Graphs:UpdateTeam(time, kTeam1Index)
        GUIInsight_Graphs:UpdateTeam(time, kTeam2Index)
        
        local newX = getXSpacing(time)
        rtLineGraph:SetXGridSpacing(newX)
        resourceLineGraph:SetXGridSpacing(newX)
        
        local newRes = getResSpacing(maxRes)
        resourceLineGraph:SetYGridSpacing(newRes)
        
        if isVisible then
            local startTime = PlayerUI_GetGameStartTime()
            rtLineGraph:SetYBounds(0, maxRTs+1, true)
            rtLineGraph:SetXBounds(startTime, time)
            
            resourceLineGraph:SetYBounds(0, maxRes, true)
            resourceLineGraph:SetXBounds(startTime, time)
            
            rtKilledGraph:SetValues(DeathMsgUI_GetRtsLost(kTeam2Index), DeathMsgUI_GetRtsLost(kTeam1Index))
        end
        
    else

        rtLineGraph:StartLine(kTeam1Index, kBlueColor)
        rtLineGraph:StartLine(kTeam2Index, kRedColor)
        resourceLineGraph:StartLine(kTeam1Index, kBlueColor)
        resourceLineGraph:StartLine(kTeam2Index, kRedColor)
    
    end
    
end
