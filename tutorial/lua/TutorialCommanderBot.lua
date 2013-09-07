
Script.Load("lua/bots/CommanderBot.lua")

class 'TutorialCommanderBrain' (CommanderBrain)

function TutorialCommanderBrain:Initialize()

    self.senses = BrainSenses()
    self.senses:Initialize()

    CommanderBrain.Initialize(self)

end

function TutorialCommanderBrain:GetExpectedPlayerClass()
    if self.forceTeam == kMarineTeamType then
        return "MarineCommander"
    else
        return "AlienCommander"
    end
end

function TutorialCommanderBrain:GetExpectedTeamNumber()
    return self.forceTeam
end

local BrainActions =
{
    function(bot, brain)
        return { name = "idle", weight = 1e-5,
            perform = function(move)
            end}
    end
}

function TutorialCommanderBrain:GetActions()
    return BrainActions
end

function TutorialCommanderBrain:GetSenses()
    return self.senses
end

class 'TutorialCommanderBot' (CommanderBot)

//----------------------------------------
//  Override
//----------------------------------------
function TutorialCommanderBot:_LazilyInitBrain()

    if self.brain == nil then
        self.brain = TutorialCommanderBrain()
        self.brain:Initialize()
    end

end

// origin should be near a res point
function TutorialCommanderBot:DropStructure( origin, techId, className )

    self:_LazilyInitBrain()
    self.brain:ExecuteTechId( self:GetPlayer(), techId, origin, self:GetPlayer() )
    local ents = GetEntitiesForTeamWithinRange( className, self.forceTeam, origin, 10.0 )
    assert( #ents > 0 )
    return ents[1]

end
