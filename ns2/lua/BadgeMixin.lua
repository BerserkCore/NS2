// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//    
// lua\BadgeMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    Updated by: Steven An (steve@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

// TODO we should probably rename this to just DonationRewards or something. It maintains that data and not much else.

Script.Load("lua/VoiceOver.lua")

// NOTE: Badges stuff is handled via Badges_*.lua, and things like shoulder pads is handled via DLC codes
local kMarineTauntMapping = {
    [kVoiceId.MarineTaunt] = kVoiceId.MarineTauntExclusive,
}

kReinforcedTierData =
{
    { code = "shadow", voiceOverMapping = kMarineTauntMapping },
    { code = "onos", voiceOverMapping = kMarineTauntMapping },
    { code = "insider", voiceOverMapping = kMarineTauntMapping },
    { code = "director", voiceOverMapping = kMarineTauntMapping },
}

BadgeMixin = CreateMixin( BadgeMixin )
BadgeMixin.type = "Badge"

BadgeMixin.networkVars =
{
    reinforcedTierNum = "integer (0 to "..#kReinforcedTierData..")",
}

function BadgeMixin:__initmixin()

    reinforcedTierNum = 0

end

if Server then
    
    function BadgeMixin:SetReinforcedTier(reinforcedTier)
    
        if reinforcedTier ~= self.reinforcedTier then
        
            self.reinforcedTier = reinforcedTier
    
            reinforcedTier = reinforcedTier or ""
            local badgeStruct, badgeNum = FindStructByFieldValue( kReinforcedTierData, "code", reinforcedTier )
            if badgeStruct ~= nil then
            
                assert( badgeStruct.code == reinforcedTier )
                assert( badgeNum > 0 )
                self.reinforcedTierNum = badgeNum

            else
                self.reinforcedTierNum = 0
            end
        
        end
    
    end

    function BadgeMixin:CopyPlayerDataFrom(player)
    
        self.reinforcedTierNum = player.reinforcedTierNum or 0
        self.reinforcedTier = player.reinforcedTier
        
    end

    Event.Hook("Console_retier", function(client, arg)
                if Shared.GetCheatsEnabled() then
                    local tierNum = tonumber(arg)
                    local player = client:GetControllingPlayer()
                    DebugPrint("Switching player "..player:GetName().." to tier "..tierNum)
                    player.reinforcedTierNum = tierNum
                end

            end)
    
end

