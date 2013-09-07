
Script.Load("lua/bots/PlayerBot.lua")
Script.Load("lua/bots/PlayerBrain.lua")
Script.Load("lua/bots/BotUtils.lua")

class "EasyBrain" (PlayerBrain)

function EasyBrain:Initialize()
    PlayerBrain.Initialize(self)
    self.dieTime = nil
end

function EasyBrain:Update( bot, move )

    local target = Shared.GetEntity( bot.targetId )
    local botPlayer = bot:GetPlayer()

    if self.dieTime ~= nil then
        
        // wait 5 seconds before disconnecting
        if (Shared.GetTime()-self.dieTime) > 5 then
            bot:Disconnect()
        end

    else

        if not botPlayer:GetIsAlive() then

            self.dieTime = Shared.GetTime()

        elseif target then

            local toStudent = target:GetOrigin() - botPlayer:GetOrigin()
            local dist = toStudent:GetLength()
            toStudent:Normalize()
            local forward = botPlayer:GetViewCoords().zAxis

            //----------------------------------------
            //  Engage or not?
            //----------------------------------------

            local doEngage = false

            if botPlayer:GetHealthFraction() < 0.99 then
                doEngage = true
            elseif dist < 10
                    and forward:DotProduct(toStudent) > 0.5
                    and GetBotCanSeeTarget( botPlayer, target ) then
                doEngage = true
            end

            if bot.telepathic then
                // engage player even if we cannot see them or were attacked
                doEngage = true
            end

            if doEngage then

                // move towards player with some jitter
                if not bot.pinned then
                    bot:GetMotion():SetDesiredMoveTarget( target:GetOrigin() )
                end

                // terrible aim
                local jitter = Vector( math.random(), math.random(), math.random() ) * 0.5
                bot:GetMotion():SetDesiredViewTarget( target:GetOrigin() + jitter )

                // attack with small prob
                if math.random() < 0.5 then
                    move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
                end

            end

        end

    end

end

class "EasyBot" (PlayerBot)

function EasyBot:SetTargetId(id)
    self.targetId = id
end

function EasyBot:_LazilyInitBrain()

    local player = self:GetPlayer()

    if self.brain == nil and not player:isa("ReadyRoomPlayer") then

        self.brain = EasyBrain()
        self.brain:Initialize()
        self:GetPlayer().botBrain = self.brain

    else

        // destroy brain if we are ready room
        if self:GetPlayer():isa("ReadyRoomPlayer") then
            self.brain = nil
            self:GetPlayer().botBrain = nil
        end

    end

end

function EasyBot:SetPinned(value)
    self.pinned = value
end

function EasyBot:SetTelepathic(value)
    self.telepathic = value
end
