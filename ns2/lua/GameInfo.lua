// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua/GameInfo.lua
//
// GameInfo is used to sync information about the game state to clients.
//
// Created by Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GameInfo' (Entity)

GameInfo.kMapName = "gameinfo"

local networkVars =
{
    state = "enum kGameState",
    startTime = "time",
    averagePlayerSkill = "integer",
    isGatherReady = "boolean"
}

function GameInfo:OnCreate()

    Entity.OnCreate(self)
    
    if Server then
    
        self:SetPropagate(Entity.Propagate_Always)
        self:SetUpdates(false)
        
        self.state = kGameState.NotStarted
        self.startTime = 0
        self.averagePlayerSkill = 0
        
    end
    
end

function GameInfo:GetStartTime()
    return self.startTime
end

function GameInfo:GetGameStarted()
    return self.state == kGameState.Started
end

function GameInfo:GetState()
    return self.state
end

function GameInfo:GetAveragePlayerSkill()
    return self.averagePlayerSkill
end

function GameInfo:SetIsGatherReady(isGatherReady)
    self.isGatherReady = isGatherReady
end

function GameInfo:GetIsGatherReady()
    return self.isGatherReady
end

if Server then

    function GameInfo:SetStartTime(startTime)
        self.startTime = startTime
    end
    
    function GameInfo:SetState(state)
        self.state = state
    end
    
    function GameInfo:SetAveragePlayerSkill(skill)
        self.averagePlayerSkill = skill
    end
    
end

Shared.LinkClassToMap("GameInfo", GameInfo.kMapName, networkVars)