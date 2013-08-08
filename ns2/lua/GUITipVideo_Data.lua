// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUITipVideo.lua - Contains the actual tips data, and has logic to decide which ones to play next.
//
// Created by: Steven An (steve@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// NOTE: The relevance logic would be more general. Right now, we just look at the player and weapon class,
// but in the future we could make these fields just functions that take the player as an argument and returns
// a boolean if it is relevent.
local gTips =
{
    {key = "TIPVIDEO_GORGE_CLOGGING" , youtubeCode = "_Sbi-9loqvA", teamNumber = 2, playerClass = "Gorge"} ,
    {key = "TIPVIDEO_WELDING"        , youtubeCode = "_Sbi-9loqvA", teamNumber = 1, playerClass = "Marine"} ,
    {key = "TIPVIDEO_EXO"        , youtubeCode     = "_Sbi-9loqvA", teamNumber = 1, playerClass = "Exo"} ,
    {key = "TIPVIDEO_SKULKFLOOR"  , youtubeCode     = "6I-nSJi8KQk", teamNumber = 2, playerClass = "Skulk"} ,
}

function ToNextTip(player)

    playerClass = player:GetClassName()

    local leastPlays = 0
    local leastPlayedRelevance = 0
    local leastPlayed = -1

    for itip = 1, #gTips do

        local tip = gTips[itip]
        local nplays = Client.GetOptionInteger("tipvids/"..tip.key, 0)

        // Use relevancy to break ties
        local relevance = 
            ConditionalValue( tip.teamNumber == player:GetTeamNumber(), 1, 0 ) +
            ConditionalValue( tip.playerClass == player:GetClassName(), 1, 0 )

        DebugPrint("tip %d nplays %d rel %d", itip, nplays, relevance)

        if (nplays < leastPlays) or (nplays == leastPlays and relevance > leastPlayedRelevance) or leastPlayed == -1 then
            leastPlays = nplays
            leastPlayed = itip
            leastPlayedRelevance = relevance
        end

    end

    local tip = gTips[ leastPlayed ]

    Client.SetOptionInteger("tipvids/"..tip.key, leastPlays+1)

    return tip
end

Event.Hook("Console_resettipvids",
        function(enabled)
            for itip = 1, #gTips do

                local tip = gTips[itip]
                Client.SetOptionInteger("tipvids/"..tip.key, 0)

            end
        end)
