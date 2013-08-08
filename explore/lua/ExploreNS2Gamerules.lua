// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreNS2Gamerules.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

if Server then

    // Preserve original SetGameState function
    local setGameStateFunction = nil
    if setGameStateFunction == nil then
        setGameStateFunction = NS2Gamerules.SetGameState
    end
    
    function NS2Gamerules:SetGameState(state)
    
        if state == kGameState.Countdown then
            state = kGameState.Started
        end
        
        // Now call original
        setGameStateFunction(self, state)
        
    end
    
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
    
    local function AutoAttach(entity, toClassName)
    
        entity:ClearAttached()

        // attach to techPoint
        local attachEnts = GetEntitiesWithinRange(toClassName, entity:GetOrigin(), 200)
        Shared.SortEntitiesByDistance(entity:GetOrigin(), attachEnts)
        
        if attachEnts[1] then            
            attachEnts[1]:SetAttached(entity)
        end
    
    end
    
    local resetGame = NS2Gamerules.ResetGame
    
    function NS2Gamerules:ResetGame()
    
        resetGame(self)
        
        for index, commandStructure in ientitylist(Shared.GetEntitiesWithClassname("CommandStructure")) do
            AutoAttach(commandStructure, "TechPoint")   
        end
        
        for index, resourceTower in ientitylist(Shared.GetEntitiesWithClassname("ResourceTower")) do
            AutoAttach(resourceTower, "ResourcePoint")
        end
        
    end
    
    // No pre-game time for explore mode, it's strange
    function NS2Gamerules:GetPregameLength()
        return 0
    end

    //function NS2Gamerules:GetGameStarted()
    //    return true
    //end
    
    // game never ends in explore mode
    function NS2Gamerules:CheckGameEnd() 
    end
    
    // Set all tech researched
    function NS2Gamerules:GetAllTech()
        return true
    end

    function NS2Gamerules:GetCanSpawnImmediately()
        return true
    end    
    
end