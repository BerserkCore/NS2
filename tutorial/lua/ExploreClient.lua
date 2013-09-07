// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreClient.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ExploreShared.lua")
Script.Load("lua/GUIObjective.lua")

// always hide tip videos
Script.Load("lua/GUITipVideo.lua")
function GUITipVideo:GetMustHide()
    return true
end

Script.Load("lua/GUIReadyVideoList.lua")
function GUIReadyVideoList:GetMustHide()
    return true
end

AddClientUIScriptForTeam( "all", "GUIObjective" )
