// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GUITeamSpectator.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUITeamSpectator' (GUIAnimatedScript)

local kFollowingTextOffset = Vector(0, -100, 0)
local kFont = "fonts/AgencyFB_small.fnt"
local kFollowingTextColor = Color(1, 1, 1, 1)

function GUITeamSpectator:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.followingText = GUIManager:CreateTextItem()
    self.followingText:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.followingText:SetFontName(kFont)
    self.followingText:SetTextAlignmentX(GUIItem.Align_Center)
    self.followingText:SetTextAlignmentY(GUIItem.Align_Center)
    self.followingText:SetPosition(kFollowingTextOffset)
    self.followingText:SetColor(kFollowingTextColor)
    
end

function GUITeamSpectator:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)
    
    GUI.DestroyItem(self.followingText)
    
end

function GUITeamSpectator:Update(deltaTime)

    GUIAnimatedScript.Update(self, deltaTime)
    
    PROFILE("GUITeamSpectator:Update")
    
    local player = Client.GetLocalPlayer()
    if player then
    
        local target = Shared.GetEntity(player:GetFollowTargetId())
        local followText = ""
        if target and target:isa("Player") then
            followText = StringReformat(Locale.ResolveString("FOLLOWING_NAME"), { name = target:GetName() })
        end
        self.followingText:SetText(followText)
        
    end
    
end