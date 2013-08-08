
Script.Load("lua/bots/CommanderBrain.lua")
Script.Load("lua/bots/MarineCommanderBrain_Data.lua")

gMarineCommanderBrains = {}

//----------------------------------------
//  
//----------------------------------------
class 'MarineCommanderBrain' (CommanderBrain)

function MarineCommanderBrain:Initialize()

    CommanderBrain.Initialize(self)
    self.senses = CreateMarineComSenses()
    table.insert( gMarineCommanderBrains, self )

end

function MarineCommanderBrain:GetExpectedPlayerClass()
    return "MarineCommander"
end

function MarineCommanderBrain:GetExpectedTeamNumber()
    return kMarineTeamType
end

function MarineCommanderBrain:GetActions()
    return kMarineComBrainActions
end

function MarineCommanderBrain:GetSenses()
    return self.senses
end
