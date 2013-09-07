//=============================================================================
//
// lua\bots\Bot.lua
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

if (not Server) then
    error("Bot.lua should only be included on the Server")
end

Script.Load("lua/bots/BotDebug.lua")

// Stores all of the bots
gServerBots = { }

class 'Bot'

Script.Load("lua/TechMixin.lua")
Script.Load("lua/ExtentsMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/OrdersMixin.lua")


function Bot:Initialize(forceTeam, active)

    InitMixin(self, TechMixin)
    InitMixin(self, ExtentsMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })

    // Create a virtual client for the bot
    self.client = Server.AddVirtualClient()
    self.forceTeam = forceTeam
    self.active = active
    
end

function Bot:GetMapName()
    return "bot"
end

function Bot:GetIsFlying()
    return false
end

function Bot:UpdateTeam(joinTeam)

    local player = self:GetPlayer()

    // Join random team (could force join if needed but will enter respawn queue if game already started)
    if player and player:GetTeamNumber() == 0 and (math.random() < .03) then
    
        player:SetPlayerSkill(math.random() * kMaxPlayerSkill)
    
        if joinTeam == nil then
            joinTeam = ConditionalValue(math.random() < .5, 1, 2)
        end
        
        if GetGamerules():GetCanJoinTeamNumber(joinTeam) or Shared.GetCheatsEnabled() then
            GetGamerules():JoinTeam(player, joinTeam)            
        end
        
    end
    
end


function Bot:Disconnect()
    Server.DisconnectClient(self.client)    
    self.client = nil
end

function Bot:GetPlayer()
    if self.client then
        return self.client:GetControllingPlayer()
    else
        return nil
    end
end

//----------------------------------------
//  NOTE: There is no real reason why this is different from GenerateMove - the C++ just calls one after another.
//  For now, just put higher-level book-keeping here I guess.
//----------------------------------------
function Bot:OnThink()

    self:UpdateTeam(self.forceTeam)
    
end

//----------------------------------------
//  Console commands for managing bots
//----------------------------------------

local function GetIsClientAllowedToManage(client)

    return client == nil    // console command from server
    or Shared.GetCheatsEnabled()
    or Shared.GetDevMode()
    or client:GetIsLocalClient()    // the client that started the listen server

end

function OnConsoleAddPassiveBots(client, numBotsParam, forceTeam, className)
    OnConsoleAddBots(client, numBotsParam, forceTeam, className, true)  
end

function OnConsoleAddBots(client, numBotsParam, forceTeam, botType, passive)

    if GetIsClientAllowedToManage(client) then

        local kType2Class =
        {
            test = TestBot,
            com = CommanderBot
        }
        local class = kType2Class[ botType ]
    
        if class == nil then
            class = PlayerBot   // Default
        end

        local numBots = 1
        if numBotsParam then
            numBots = math.max(tonumber(numBotsParam), 1)
        end
        
        for index = 1, numBots do
        
            local bot = class()
            bot:Initialize(tonumber(forceTeam), not passive)
            table.insert( gServerBots, bot )
       
        end
        
    end
    
end

function OnConsoleRemoveBots(client, numBotsParam, teamNum)

    if GetIsClientAllowedToManage(client) then
    
        local numBots = 1
        if numBotsParam then
            numBots = math.max(tonumber(numBotsParam), 1)
        end
        
        teamNum = teamNum and tonumber(teamNum) or nil
        
        local numRemoved = 0
        for index = #gServerBots, 1, -1 do
        
            local bot = gServerBots[index]
            if bot then
            
                local disconnect = true
                if teamNum and bot:GetPlayer():GetTeamNumber() ~= teamNum then
                    disconnect = false
                end
                
                if disconnect then
                
                    bot:Disconnect()
                    numRemoved = numRemoved + 1
                    table.remove(gServerBots, index)
                    
                end
                
                if numRemoved == numBots then
                    break
                end
                
            end
            
        end
        
    end
    
end

function OnVirtualClientMove(client)

    // If the client corresponds to one of our bots, generate a move from it.
    for i,bot in ipairs(gServerBots) do
    
        if bot.client == client then
        
            local player = bot:GetPlayer()
            if player then
                return bot:GenerateMove()
            end
            
        end
        
    end

end

function OnVirtualClientThink(client, deltaTime)

    // If the client corresponds to one of our bots, allow it to think.
    for i, bot in ipairs(gServerBots) do
    
        if bot.client == client then
            local player = bot:GetPlayer()
            bot:OnThink()
        end
        
    end

    return true
    
end

// Make sure to load these after Bot is defined
Script.Load("lua/bots/TestBot.lua")
Script.Load("lua/bots/PlayerBot.lua")
Script.Load("lua/bots/CommanderBot.lua")

// Register the bot console commands
Event.Hook("Console_addpassivebot",  OnConsoleAddPassiveBots)
Event.Hook("Console_addbot",         OnConsoleAddBots)
Event.Hook("Console_removebot",      OnConsoleRemoveBots)
Event.Hook("Console_addbots",        OnConsoleAddBots)
Event.Hook("Console_removebots",     OnConsoleRemoveBots)

// Register to handle when the server wants this bot to
// process orders
Event.Hook("VirtualClientThink",    OnVirtualClientThink)

// Register to handle when the server wants to generate a move
// for one of the virtual clients
Event.Hook("VirtualClientMove",     OnVirtualClientMove)
