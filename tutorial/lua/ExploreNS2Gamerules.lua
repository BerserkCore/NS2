// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreNS2Gamerules.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

if Server then

    // always start with 1 player in explore mode
    function NS2Gamerules:CheckGameStart()

        if self:GetGameState() == kGameState.NotStarted or self:GetGameState() == kGameState.PreGame then
        
            // Start pre-game when both teams have players or when once side does if cheats are enabled
            local team1Players = self.team1:GetNumPlayers()
            local team2Players = self.team2:GetNumPlayers()
            
            if team1Players > 0 or team2Players > 0 then
            
                if self:GetGameState() == kGameState.NotStarted then
                    self:SetGameState(kGameState.PreGame)                    
                end
                
            elseif self:GetGameState() == kGameState.PreGame then
                self:SetGameState(kGameState.NotStarted)
            end
            
        end
        
    end
    
    local chooseTechPoint = NS2Gamerules.ChooseTechPoint
    
    // TODO - we need to make sure to always use the same techpoint to start. Hopefully this code does it?
    function NS2Gamerules:ChooseTechPoint(techPoints, teamNumber)
    
        local choosenTechPoint = nil
        
        for _, currentTechPoint in ipairs(techPoints) do
        
            if currentTechPoint.exploreModeStart == teamNumber then
                choosenTechPoint = currentTechPoint
                break
            end    
        
        end
        
        if not choosenTechPoint then
            choosenTechPoint = chooseTechPoint(self, techPoints, teamNumber)
        end

        return choosenTechPoint
    
    end

    local __old_NS2Gamerules_JoinTeam = NS2Gamerules.JoinTeam
    function NS2Gamerules:JoinTeam( player, newTeamNumber, force )

        if GetTutorial() then
            GetTutorial():OnJoinTeam( player, newTeamNumber, force )
        end

        __old_NS2Gamerules_JoinTeam( self, player, newTeamNumber, force )

    end

    local __old_NS2Gamerules_GetCanJoinTeamNumber = NS2Gamerules.GetCanJoinTeamNumber
    function NS2Gamerules:GetCanJoinTeamNumber(teamNumber)
        if GetTutorial() then
            return GetTutorial():GetCanJoinTeamNumber( teamNumber )
        else
            return __old_NS2Gamerules_GetCanJoinTeamNumber( teamNumber )
        end
    end
    
    // game never ends in tutorial mode
    function NS2Gamerules:CheckGameEnd() 
    end
    
end
