// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//    
// lua\BadgeMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    Updated by: Steven An (steve@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/VoiceOver.lua")

// TODO we should probably rename this to just DonationRewards or something. It maintains all that data.

kBadgesPathPrefix = "ui/badges/"

// These badges are not verified by DLC codes
local function CreateReinforceBadgeInfo( code, DDSPrefix, voiceOverMapping )
    return {
        code = code,
        unitStatusTexture = "ui/badges/"..DDSPrefix..".dds",
        scoreboardTexture = "ui/badges/"..DDSPrefix.."_20.dds",
        voiceOverMapping = voiceOverMapping,
    }
end

local kMarineTauntMapping = {
    [kVoiceId.MarineTaunt] = kVoiceId.MarineTauntExclusive,
}

kReinforcedTierData =
{
    CreateReinforceBadgeInfo( "supporter" , "game_tier1_blue"         , nil ) , 
    CreateReinforceBadgeInfo( "silver"    , "game_tier2_silver"       , nil ) , 
    CreateReinforceBadgeInfo( "gold"      , "game_tier3_gold"         , nil ) , 
    CreateReinforceBadgeInfo( "diamond"   , "game_tier4_diamond"      , nil ) , 
    CreateReinforceBadgeInfo( "shadow"    , "game_tier5_shadow"       , kMarineTauntMapping )  , 
    CreateReinforceBadgeInfo( "onos"      , "game_tier6_onos"         , kMarineTauntMapping )  , 
    CreateReinforceBadgeInfo( "insider"   , "game_tier7_Insider"      , kMarineTauntMapping )  , 
    CreateReinforceBadgeInfo( "director"  , "game_tier8_GameDirector" , kMarineTauntMapping )  , 
}

// Code given to players during PAX 2012 week.
local kPAXBadge = { productId = 4931, unitStatusTexture = "ui/badge_pax2012.dds", scoreboardTexture = "ui/badge_pax2012.dds"}

function BadgeMixin_GetMaxBadges()
    return 2    // PAX + one of the supporter badges
end

BadgeMixin = CreateMixin( BadgeMixin )
BadgeMixin.type = "Badge"

BadgeMixin.networkVars =
{
    hasPAXBadge = "boolean",
    reinforcedTierNum = "integer (0 to "..#kReinforcedTierData..")",
}

function BadgeMixin:__initmixin()

    hasPAXBadge = false
    reinforcedTierNum = 0

end

if Server then

    local function CreateBadgeQueryCallback( client )

        return function( rawJson )

            //DebugPrint("raw json response from server: "..rawJson)

            local obj, pos, err = json.decode( rawJson )

            if err then
                Print("ERROR: BadgeMixin:GetBadgeInfoCallback: Could not parse response of badge-info HTTP query. Error: "..ToString(err)
                        .. ". Raw JSON: "..rawJson )
            else

                obj.reinforcedTier = obj.reinforcedTier or ""

                local player = client:GetControllingPlayer()
                if player ~= nil then
                    
                    local badgeStruct, badgeNum = FindStructByFieldValue( kReinforcedTierData, "code", obj.reinforcedTier )

                    //DebugPrint("reinforced tier returned by hive server for player "..player:GetName()..": "..obj.reinforcedTier)

                    if badgeStruct ~= nil then

                        //DebugPrint("found matching badge struct, num = "..ToString(badgeNum) )
                        assert( badgeStruct.code == obj.reinforcedTier )
                        assert( badgeNum > 0 )
                        player.reinforcedTierNum = badgeNum

                    else
                        player.reinforcedTierNum = 0
                    end

                end
            end

        end

    end

    function BadgeMixin:OnClientUpdated(client)
        
        //DebugPrint("BadgeMixin:OnClientUpdated")
        self:RefreshBadgeInfo(client)

    end

    function BadgeMixin:RefreshBadgeInfo(client)

        self.hasPAXBadge = GetHasDLC( kPAXBadge.productId, client )

        // check reinforce level
        local steamId = client:GetUserId()
        self.reinforcedTierNum = 0
        local requestURL = "http://hive.naturalselection2.com/api/get/badges/"..steamId
        //DebugPrint("sending HTTP request: "..requestURL)
        Shared.SendHTTPRequest( requestURL, "GET", { }, CreateBadgeQueryCallback(client) )

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

if Client then

    function BadgeMixin_GetBadgeTextures(usecase, badgeInfo)

        local DDSPathKey = (usecase == "scoreboard" and "scoreboardTexture" or "unitStatusTexture")

        textures = {}

        if badgeInfo.hasPAXBadge then
            table.insert( textures, kPAXBadge[DDSPathKey] )
        end

        if badgeInfo.reinforcedTierNum > 0 then
            table.insert( textures, kReinforcedTierData[ badgeInfo.reinforcedTierNum ][ DDSPathKey ] )
        end

        assert( #textures <= BadgeMixin_GetMaxBadges() )
        return textures
        
    end

    function BadgeMixin:GetBadgeTextures(usecase)

        // Used by Embryo
        if usecase == "unitstatus" and self.GetShowBadgeOverride and not self:GetShowBadgeOverride() then
            return {}
        else
            return BadgeMixin_GetBadgeTextures( usecase, self )
        end
        
    end

end
