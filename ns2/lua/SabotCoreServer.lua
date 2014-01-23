// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\SabotCoreServer.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================   

Script.Load("lua/Utility.lua")
Script.Load("lua/Sabot.lua")
 
local gLastUpdate = 0

local function UpdateGatherServer()

    if Server.GetConfigSetting("gather_server") then
    
        if gLastUpdate + 5 < Shared.GetTime() then  
          
            Sabot.RequestServerConfig()
            
            local settings = Sabot.GetServerSettings()            
            Server.SetPassword(settings.password or "")
            
            if Shared.GetMapName() ~= settings.mapName then
                MapCycle_ChangeMap(settings.mapName)
            end
            
            gLastUpdate = Shared.GetTime()   
            
        end

    end

end

Event.Hook("UpdateServer", UpdateGatherServer)