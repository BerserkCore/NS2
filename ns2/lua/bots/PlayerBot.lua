//=============================================================================
//
// lua\bots\PlayerBot.lua
//
// AI "bot" functions for goal setting and moving (used by Bot.lua).
//
// Created by Charlie Cleveland (charlie@unknownworlds.com)
// Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
//
// Updated by Dushan, Steve, 2013. The "brain" controls the higher level logic. A lot of this code is no longer used..
//
//=============================================================================

Script.Load("lua/bots/Bot.lua")
Script.Load("lua/bots/BotMotion.lua")
Script.Load("lua/bots/MarineBrain.lua")
Script.Load("lua/bots/SkulkBrain.lua")

local kBotNames = {
    "Flayra",
    "m4x0r",
    "Ooghi",
    "Breadman",
    "Squeal Like a Pig",
    "Chops",
    "Numerik",
    "SteveRock",
    "Comprox",
    "MonsieurEvil",
    "Joev",
    "puzl",
    "Crispix",
    "Kouji_San",
    "TychoCelchuuu",
    "Insane",
    "CoolCookieCooks",
    "devildog",
    "tommyd",
    "Relic25"
}

class 'PlayerBot' (Bot)

function PlayerBot:GetPlayerOrder()
    local order = nil
    local player = self:GetPlayer()
    if player and player.GetCurrentOrder then
        order = player:GetCurrentOrder()
    end
    return order
end

function PlayerBot:GivePlayerOrder(orderType, targetId, targetOrigin, orientation, clearExisting, insertFirst, giver)
    local player = self:GetPlayer()
    if player and player.GiveOrder then
        player:GiveOrder(orderType, targetId, targetOrigin, orientation, clearExisting, insertFirst, giver)
    end
end

function PlayerBot:GetPlayerHasOrder()
    local player = self:GetPlayer()
    if player and player.GetHasOrder then
        return player:GetHasOrder()
    end
    return false
end

function PlayerBot:GetNamePrefix()
    return "[BOT] "
end

function PlayerBot:UpdateName()

    // Set name after a bit of time to simulate real players
    if self.botSetName == nil and math.random() < .01 then

        local player = self:GetPlayer()
        local name = player:GetName()
        if name and string.find(string.lower(name), string.lower("Bot")) ~= nil then
    
            local numNames = table.maxn(kBotNames)
            local index = Clamp(math.ceil(math.random() * numNames), 1, numNames)
            self.botSetName = true
            
            name = self:GetNamePrefix() .. TrimName(kBotNames[index]) .. " T"..ToString(self.forceTeam)
            
            // Treat "NsPlayer" as special.
            if name ~= player:GetName() and name ~= kDefaultPlayerName and string.len(name) > 0 then
            
                local prevName = player:GetName()
                player:SetName(name)
                
                if prevName ~= player:GetName() then
                    Server.Broadcast(nil, string.format("%s is now known as %s.", prevName, player:GetName()))
                end
                
            end
            
        end
        
    end
    
end

function PlayerBot:_LazilyInitBrain()

    if self.brain == nil then

        if self:GetPlayer():isa("Marine") then
            self.brain = MarineBrain()
        elseif self:GetPlayer():isa("Skulk") then
            self.brain = SkulkBrain()
        else
            // must be spectator - wait until we have joined a team
        end

        if self.brain ~= nil then
            self.brain:Initialize()
            self:GetPlayer().botBrain = self.brain
        end

    else

        // destroy brain if we are ready room
        if self:GetPlayer():isa("ReadyRoomPlayer") then
            self.brain = nil
            self:GetPlayer().botBrain = nil
        end

    end

end

/**
 * Responsible for generating the "input" for the bot. This is equivalent to
 * what a client sends across the network.
 */
function PlayerBot:GenerateMove()

    self:_LazilyInitBrain()

    local player = self:GetPlayer()
    local move = Move()

    // Brain will modify move.commands and send desired motion to self.motion
    if self.brain ~= nil then

        // always clear view each frame
        self:GetMotion():SetDesiredViewTarget(nil)

        self.brain:Update(self,  move)

    end

    // Now do look/wasd

    local viewDir, moveDir, doJump = self:GetMotion():OnGenerateMove(self:GetPlayer())

    move.yaw = GetYawFromVector(viewDir) - player:GetBaseViewAngles().yaw
    move.pitch = GetPitchFromVector(viewDir)

    moveDir.y = 0
    moveDir = moveDir:GetUnit()
    local zAxis = Vector(viewDir.x, 0, viewDir.z):GetUnit()
    local xAxis = zAxis:CrossProduct(Vector(0, -1, 0))
    local moveZ = moveDir:DotProduct(zAxis)
    local moveX = moveDir:DotProduct(xAxis)
    move.move = GetNormalizedVector(Vector(moveX, 0, moveZ))

    if doJump then
        move.commands = AddMoveCommand(move.commands, Move.Jump)
    end
    
    return move

end

function PlayerBot:TriggerAlerts()

    local player = self:GetPlayer()
    
    local team = player:GetTeam()
    if player:isa("Marine") and team and team.TriggerAlert then
    
        local primaryWeapon = nil
        local weapons = player:GetHUDOrderedWeaponList()        
        if table.count(weapons) > 0 then
            primaryWeapon = weapons[1]
        end
        
        // Don't ask for stuff too often
        if not self.timeOfLastRequest or (Shared.GetTime() > self.timeOfLastRequest + 9) then
        
            // Ask for health if we need it
            if player:GetHealthScalar() < .4 and (math.random() < .3) then
            
                team:TriggerAlert(kTechId.MarineAlertNeedMedpack, player)
                self.timeOfLastRequest = Shared.GetTime()
                
            // Ask for ammo if we need it            
            elseif primaryWeapon and primaryWeapon:isa("ClipWeapon") and (primaryWeapon:GetAmmo() < primaryWeapon:GetMaxAmmo()*.4) and (math.random() < .25) then
            
                team:TriggerAlert(kTechId.MarineAlertNeedAmmo, player)
                self.timeOfLastRequest = Shared.GetTime()
                
            elseif (not self:GetPlayerHasOrder()) and (math.random() < .2) then
            
                team:TriggerAlert(kTechId.MarineAlertNeedOrder, player)
                self.timeOfLastRequest = Shared.GetTime()
                
            end
            
        end
        
    end
    
end

function PlayerBot:GetEngagementPointOverride()
    return self:GetModelOrigin()
end

function PlayerBot:GetMotion()

    if self.motion == nil then
        self.motion = BotMotion()
        self.motion:Initialize(self:GetPlayer())
    end

    return self.motion

end

function PlayerBot:OnThink()

    Bot.OnThink(self)

    local player = self:GetPlayer()

    if not self.initializedBot then
        self.prefersAxe = (math.random() < .5)
        self.inAttackRange = false
        self.initializedBot = true
    end
        
    self:UpdateName()
    

    
end
