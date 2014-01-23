// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\SabotCoreClient.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================   

Script.Load("lua/Utility.lua")
Script.Load("lua/Sabot.lua")
 
local gLastUpdate = 0

local function UpdateGatherQueue()

    if Sabot.GetIsInGather() then
    
        if gLastUpdate + 1 < Shared.GetTime() then

            Sabot.UpdateRoom()
            gLastUpdate = Shared.GetTime()

        end
    
    end

end

Event.Hook("UpdateClient", UpdateGatherQueue)

