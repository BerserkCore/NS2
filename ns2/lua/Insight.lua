// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Insight.lua
//
// Created by: Jon 'Huze' Hughes (jon@jhuze.com)
//
// Handles Tech Point network packets and team names
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kGUILayerInsight = 10
kBlueColor = ColorIntToColor(kMarineTeamColor)
kRedColor = Color(1, .61, 0, 1)
kPenToolColor = Color(1, 1, 1, 1)

local techPointData = { }
local team1Name= "Frontiersmen"
local team2Name = "Kharaa"

function Insight_Clear()

    techPointData = { }
    
end

function Insight_SetTechPoint(entityIndex, teamNumber, techId, builtFraction, location, health, maxHealth, armor, maxArmor)

    for i = 1, table.maxn(techPointData) do
    
        local structureRecord = techPointData[i]
        if structureRecord.EntityIndex == entityIndex then
            structureRecord.TeamNumber = teamNumber
            structureRecord.TechId = techId
            structureRecord.BuiltFraction = builtFraction
            structureRecord.Location = location
            structureRecord.Health = health
            structureRecord.MaxHealth = maxHealth
            structureRecord.Armor = armor
            structureRecord.MaxArmor = maxArmor
           
            return
        end
        
    end
    
    // Otherwise insert a new record
    local structureRecord = {}
    structureRecord.EntityIndex = entityIndex
    structureRecord.TeamNumber = teamNumber
    structureRecord.TechId = techId
    structureRecord.BuiltFraction = builtFraction
    structureRecord.Location = location
    structureRecord.Health = health
    structureRecord.MaxHealth = maxHealth
    structureRecord.Armor = armor
    structureRecord.MaxArmor = maxArmor
    table.insert(techPointData, structureRecord )

end

local function sortById(tp1, tp2)
    --if tp1.TeamNumber == tp2.TeamNumber then
        return tp1.EntityIndex > tp2.EntityIndex
    --end
    --return tp1.TeamNumber > tp2.TeamNumber
end

function InsightUI_GetTechPointData()

    table.sort(techPointData, sortById)
    return techPointData
    
end

local function SetTeamNames(newTeam1Name, newTeam2Name)

    team1Name = newTeam1Name
    team2Name = newTeam2Name
    --GUIInsight_TopBar:SetText(team1Name, team2Name)
     local GUITeamNames = GetGUIManager():GetGUIScriptSingle("GUIInsight_TeamNames")
    if GUITeamNames then 
        GUITeamNames:SetText(team1Name, team2Name)
    end
    
end

local function HandleTeamsMessage(params)

    if params[1] == "teams" then
    
            if params[2] ~= nil and params[3] ~= nil then
                SetTeamNames(params[2], params[3])
            elseif params[2] == "swap" or params[2] == "switch" then
                SetTeamNames(team2Name, team1Name)
            elseif params[2] == "reset" or params[2] == "clear" then
                --SetTeamNames(nil, nil)
                SetTeamNames("", "")
            end
            
    elseif params[1] == "team1" then
        SetTeamNames(params[2], nil)
    elseif params[1] == "team2" then
        SetTeamNames(nil, params[2])
    end

end

local function OnConsoleTeams(param1, param2)
    HandleTeamsMessage({"teams", param1, param2})
end

local function OnConsoleTeam1(param1)
    HandleTeamsMessage({"team1", param1, nil})
end

local function OnConsoleTeam2(param1)
    HandleTeamsMessage({"team2", param1, nil})
end

/*function OnMessageChat(chat)

    if chat.message:sub(0,1) == "/" then
        params = {}
        for param in chat.message:gmatch("%w+") do 
            table.insert(params, string.lower(param))
        end

        HandleTeamsMessage(params)

    end
    
end*/

local function IntFromString(str)

    local num = tonumber(str)
    if num and num >1 then
        num = num/255
    end
    return num

end

local function OnConsolePenColor(r_or_ColorInt, g, b, a)
    
    if r_or_ColorInt ~= nil and g == nil then
    
        local ColorInt = tonumber(r_or_ColorInt)
        local color = ColorIntToColor(ColorInt)
        if color then
            kPenToolColor = color
        end
        
    else
    
        local rInt = IntFromString(r_or_ColorInt) or 1
        local gInt = IntFromString(g) or 1
        local bInt = IntFromString(b) or 1
        local aInt = IntFromString(a) or 1
        kPenToolColor = Color(rInt, gInt, bInt, aInt)
        
    end

end
//Client.HookNetworkMessage("Chat", OnMessageChat)
Event.Hook( "Console_teams", OnConsoleTeams )
Event.Hook( "Console_team1", OnConsoleTeam1 )
Event.Hook( "Console_team2", OnConsoleTeam2 )
Event.Hook( "Console_johnmadden", OnConsolePenColor )
Event.Hook( "Console_jm", OnConsolePenColor )
Event.Hook( "Console_pen", OnConsolePenColor )