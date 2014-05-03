// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TeamJoin.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Trigger.lua")

class 'TeamJoin' (Trigger)

TeamJoin.kMapName = "team_join"

local networkVars =
{
    teamNumber = string.format("integer (-1 to %d)", kSpectatorIndex),
    teamIsFull = "boolean",
    playerCount = "integer (0 to " .. kMaxPlayers - 1 .. ")"
}

function TeamJoin:OnCreate()

    Trigger.OnCreate(self)
    
    self.teamIsFull = false
    self.playerCount = 0
    
    if Server then
        self:SetUpdates(true)
    end
    
end

function TeamJoin:OnInitialized()

    Trigger.OnInitialized(self)
    
    // self:SetPropagate(Actor.Propagate_Never)
    self:SetPropagate(Entity.Propagate_Always)
    
    self:SetIsVisible(false)
    
    self:SetTriggerCollisionEnabled(true)
    
end

if Server then

    function TeamJoin:OnUpdate()
    
        local team1PlayerCount = GetGamerules():GetTeam(kTeam1Index):GetNumPlayers()
        local team2PlayerCount = GetGamerules():GetTeam(kTeam2Index):GetNumPlayers()
        if self.teamNumber == kTeam1Index then
        
            self.teamIsFull = team1PlayerCount > team2PlayerCount
            self.playerCount = team1PlayerCount
            
        elseif self.teamNumber == kTeam2Index then
        
            self.teamIsFull = team2PlayerCount > team1PlayerCount
            self.playerCount = team2PlayerCount
            
        end
        
    end
    
    function JoinRandomTeam(player)

        // Join team with less players or random.
        local team1Players = GetGamerules():GetTeam(kTeam1Index):GetNumPlayers()
        local team2Players = GetGamerules():GetTeam(kTeam2Index):GetNumPlayers()
        
        // Join team with least.
        if team1Players < team2Players then
            Server.ClientCommand(player, "jointeamone")
        elseif team2Players < team1Players then
            Server.ClientCommand(player, "jointeamtwo")
        else
        
            // Join random otherwise.
            if math.random() < 0.5 then
                Server.ClientCommand(player, "jointeamone")
            else
                Server.ClientCommand(player, "jointeamtwo")
            end
            
        end
        
    end
	
	function ForceEvenTeams()
		
		local players = GetEntities("Player")
        local teamOneCommander = nil
        local teamTwoCommander = nil
        local playersToAssign = {}
        
        local teamOneSkill = 0
        local teamTwoSkill = 0
		if GetGamerules():GetGameStarted() then
			return
		end
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
  
    end

    function TeamJoin:OnTriggerEntered(enterEnt, triggerEnt)

        if enterEnt:isa("Player") then
        
            if self.teamNumber == kTeamReadyRoom then
                Server.ClientCommand(enterEnt, "spectate")
            elseif self.teamNumber == kTeam1Index then
                Server.ClientCommand(enterEnt, "jointeamone")
            elseif self.teamNumber == kTeam2Index then
                Server.ClientCommand(enterEnt, "jointeamtwo")
            elseif self.teamNumber == kRandomTeamType then
                JoinRandomTeam(enterEnt)
            end
            
        end
            
    end

end

Shared.LinkClassToMap("TeamJoin", TeamJoin.kMapName, networkVars)