
Script.Load("lua/Badges_Shared.lua")

local ClientId2Badges = {}

Client.HookNetworkMessage("ClientBadges",
        function(msg) 
            //Print("received ClientBadges msg for client id = "..msg.clientId.." msg = "..ToString(msg) )
            ClientId2Badges[ msg.clientId ] = msg 
        end)

function Badges_GetBadgeTextures( clientId, usecase )

    local badges = ClientId2Badges[ clientId ]

    if badges then

        local textures = {}
        local textureKey = (usecase == "scoreboard" and "scoreboardTexture" or "unitStatusTexture")

        for _,info in ipairs(gBadgesData) do
            if badges[ Badge2NetworkVarName(info.name) ] == true then
                table.insert( textures, info[textureKey] )
            end
        end

        return textures

    else
        return {}
    end

end
