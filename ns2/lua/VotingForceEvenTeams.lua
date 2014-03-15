// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//    
// lua\VotingForceEvenTeams.lua
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kExecuteVoteDelay = 2

RegisterVoteType("VotingForceEvenTeams", { })

if Client then

    local function SetupForceEvenTeamsVote(voteMenu)
    
        local function StartForceEvenTeamsVote(data)
            AttemptToStartVote("VotingForceEvenTeams", { })
        end
        
        voteMenu:AddMainMenuOption(Locale.ResolveString("VOTE_FORCE_EVEN_TEAMS"), nil, StartForceEvenTeamsVote)
        
        -- This function translates the networked data into a question to display to the player for voting.
        local function GetVoteForceEvenTeamsQuery(data)
            return Locale.ResolveString("VOTE_FORCE_EVEN_TEAMS_QUERY")
        end
        AddVoteStartListener("VotingForceEvenTeams", GetVoteForceEvenTeamsQuery)
        
    end
    AddVoteSetupCallback(SetupForceEvenTeamsVote)
    
end

if Server then

    local function OnForceEvenTeamsVoteSuccessful(data)

        local players = GetEntities("Player")
        local teamOneCommander = nil
        local teamTwoCommander = nil
        local playersToAssign = {}
        
        local teamOneSkill = 0
        local teamTwoSkill = 0
        
        for _, player in ipairs(players) do
        
            if player:GetClientIndex() ~= 0 then
        
                if player:isa("Commander") then
                    
                    if player:GetTeamNumber() == 1 then
                    
                        teamOneCommander = player
                        teamOneSkill = player:GetPlayerSkill()
                        
                    elseif player:GetTeamNumber() == 2 then
                    
                        teamTwoCommander = player
                        teamTwoSkill = player:GetPlayerSkill()
                        
                    end
                    
                else
                    table.insert(playersToAssign, player)
                end
                
            end    
        
        end
        
        // consider last round stats
        local highestKills = 0
        // first figure out highest kills value
        for i = 1, #playersToAssign do
        
            local player = playersToAssign[i]
            local clientIndex = player:GetClientIndex()

            if clientIndex and clientIndex > 0 then
            
                local kills = GetSessionKills(clientIndex)
                if kills > highestKills then
                    highestKills = kills
                end
            
            end
        
        end
        
        // uses highest kills and assign a skill rating based on kills
        for i = 1, #playersToAssign do
            
            local player = playersToAssign[i]
            local clientIndex = player:GetClientIndex()
            
            if clientIndex and clientIndex > 0 then
            
                local kills = GetSessionKills(clientIndex)

                if kills > 0 then        
                    player.lastRoundSkill = (kills / highestKills) * kMaxPlayerSkill
                end
            
            end
            
        end

        local function GetPlayerSkill(player)
        
            local skill = player:GetPlayerSkill()
            // consider last round skill based off K/D if found
            if player.lastRoundSkill then
                skill = (skill + player.lastRoundSkill) * 0.5
            end
            
            return skill
        
        end

        local function SortByPlayerSkill(playerOne, playerTwo)
            return GetPlayerSkill(playerOne) > GetPlayerSkill(playerTwo)
        end
        
        table.sort(playersToAssign, SortByPlayerSkill)
        
        local useTeamNumber = math.random(1, 2)

        if not teamOneCommander and teamTwoCommander then
            useTeamNumber = 1
        elseif not teamTwoCommander and teamOneCommander then
            useTeamNumber = 2
        end    

        for i = 1, #playersToAssign do
        
            local player = playersToAssign[i]

            if useTeamNumber == 1 then
                teamOneSkill = teamOneSkill + player:GetPlayerSkill()
            elseif useTeamNumber == 2 then
                teamTwoSkill = teamTwoSkill + player:GetPlayerSkill()
            end
            
            player:SetCameraDistance(0)
            GetGamerules():JoinTeam(player, useTeamNumber, true)             
            useTeamNumber = Math.Wrap(useTeamNumber + 1, 1, 3)

        end    

        Print("forced even teams, team one skill: %s  team two skill %s", ToString(teamOneSkill), ToString(teamTwoSkill))    
        
    end
    
    SetVoteSuccessfulCallback("VotingForceEvenTeams", kExecuteVoteDelay, OnForceEvenTeamsVoteSuccessful)
    
end