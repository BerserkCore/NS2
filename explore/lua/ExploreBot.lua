// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreBot.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function AddBots(numBots, team)
    
    for index = 1, numBots do
    
        local bot = BotPlayer()
        bot:Initialize(tonumber(team), not passive)
        table.insert( server_bots, bot )
   
    end

end

function RemoveBots()

    local numBots = #bots

    for index = 1, numBots do

        local bot = table.remove(server_bots)
        
        if bot then        
            bot:Disconnect()            
        end
        
    end

end