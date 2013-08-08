//----------------------------------------
//  
//----------------------------------------

Script.Load("lua/bots/CommanderBrain.lua")
Script.Load("lua/bots/AlienCommanderBrain_Data.lua")

gAlienCommanderBrains = {}

//----------------------------------------
//  
//----------------------------------------
class 'AlienCommanderBrain' (CommanderBrain)

function AlienCommanderBrain:Initialize()

    CommanderBrain.Initialize(self)
    self.senses = CreateAlienComSenses()
    table.insert( gAlienCommanderBrains, self )

end

function AlienCommanderBrain:GetExpectedPlayerClass()
    return "AlienCommander"
end

function AlienCommanderBrain:GetExpectedTeamNumber()
    return kAlienTeamType
end

function AlienCommanderBrain:GetActions()
    return kAlienComBrainActions
end

function AlienCommanderBrain:GetSenses()
    return self.senses
end

