
Script.Load("lua/Badges_Shared.lua")

assert(Server)

local allowBadgeRequest = true
local function OnToggleBadgeRequest()

    allowBadgeRequest = not allowBadgeRequest
    Shared.Message("Badge request " .. (allowBadgeRequest and "enabled" or "disabled"))
    
end
Event.Hook("Console_togglebadgerequest", OnToggleBadgeRequest)

local ClientId2Badges = {}

local function OnClientConnect(client)

    if allowBadgeRequest and client and not client:GetIsVirtual() then
    
        local steamId = client:GetUserId()
        local requestUrl = "http://hive.naturalselection2.com/api/get/badges/" .. steamId
        local clientId = client:GetId()
        
        Shared.SendHTTPRequest(requestUrl, "GET", { },
            function(response)
            
                local responseClient = Server.GetClientById(clientId)
                if responseClient then
                
                    local obj, pos, err = json.decode(response, 1, nil)
                    
                    if err ~= nil then
                    
                        Print("Error from hive get-badges response: " .. ToString(err))
                        return
                        
                    end
                    
                    // Build reverse table.
                    local badge2has = { }
                    if obj.badges ~= nil then
                    
                        for i,name in ipairs(obj.badges) do
                            badge2has[name] = true
                        end
                        
                    end
                    
                    local msg = { clientId = responseClient:GetId() }
                    
                    // Go through each badge to see if the client has it
                    for i,info in ipairs(gBadgesData) do
                    
                        local hasBadge = false
                        if info.productId ~= nil then
                            hasBadge = GetHasDLC(info.productId, responseClient)
                        else
                            hasBadge = (badge2has[info.name] == true)
                        end
                        
                        msg[Badge2NetworkVarName(info.name)] = hasBadge
                        
                    end
                    
                    // Send badge info update to all players (including the one who just connected)
                    Server.SendNetworkMessage("ClientBadges", msg, true)

                    // Store it ourselves as well for future clients
                    ClientId2Badges[ msg.clientId ] = msg
                    
                end
                
            end)

        // Send this client info for all existing clients
        for clientId, msg in pairs(ClientId2Badges) do
            Server.SendNetworkMessage( client, "ClientBadges", msg, true )
        end
            
    end
    
end

local function OnClientDisconnect(client)

    if client:GetId() ~= nil then
        ClientId2Badges[ client:GetId() ] = nil
    end

end

Event.Hook("ClientConnect", OnClientConnect)
Event.Hook("ClientDisconnect", OnClientDisconnect)
