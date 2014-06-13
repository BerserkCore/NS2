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
		local tempTextures = {}
        local textureKey = (usecase == "scoreboard" and "scoreboardTexture" or "unitStatusTexture")
		
        for _, info in ipairs(gBadgesData) do
            local badgePosition = badges[ Badge2NetworkVarName(info.name) ]
            if badgePosition > 0 then
                tempTextures[badgePosition] = info[textureKey]
            end
        end
		
		for _, texture in pairs(tempTextures) do
			table.insert(textures, texture)
		end
		
        return textures
        
    else
        return {}
    end

end