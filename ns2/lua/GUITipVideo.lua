// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUITipVideo.lua
//
// Created by: Steven An (steve@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUITipVideo_Data.lua")

local kBlankUrl = "temptemp"
local kTipViewURL = "file:///ns2/web/client_game/tipvideo_widget.html"
local kTextureName = "*tip_video_webview_texture"
local kSlideInSecs = 1.0
local kFadeOutSecs = 0.5
local kPlayDelay = 1.0
local kWidgetLeftMargin = 20
local kTipTextHeight = 50
local kBackgroundAlpha = 0.5
local kVideoPad = 5

// This is how large the web-view should be, in "HTML space."
// Our videos will be 720p, so this should at least by 1280x720 pixels high, also allow 200 pixels for the margins
local webViewWidth = 1280
local webViewHeight = 720

local gEnabled = false

class "GUITipVideo" (GUIScript)

function GUITipVideo:Initialize()

    GUIScript.Initialize(self)
    
    // Compute size/pos
    local webAspect = webViewWidth / webViewHeight
    local wt = Client.GetScreenWidth() * 0.3
    local videoWt = wt - 2*kVideoPad
    local videoHt = videoWt / webAspect
    local ht = videoHt + kTipTextHeight + 2*kVideoPad
    local y = Client.GetScreenHeight()/2.0 - ht/2.0
    
    self.video = GUI.CreateItem()
    self.video:SetColor( Color(1.0,1.0,1.0,1.0) )
    self.video:SetInheritsParentAlpha( true )
    self.video:SetPosition(Vector(kVideoPad, kVideoPad, 0))
    self.video:SetSize( Vector(videoWt, videoHt, 0) )
    self.video:SetTexture( kTextureName )
    self.videoWebView = Client.CreateWebView( webViewWidth, webViewHeight )
    self.videoWebView:SetTargetTexture( kTextureName )

    self.tipText = GUI.CreateItem()
    self.tipText:SetOptionFlag(GUIItem.ManageRender)
    self.tipText:SetInheritsParentAlpha( true )
    self.tipText:SetPosition(Vector(kVideoPad*2, videoHt+3*kVideoPad+5, 0))
    self.tipText:SetTextAlignmentX(GUIItem.Align_Min)
    self.tipText:SetTextAlignmentY(GUIItem.Align_Center)
    self.tipText:SetAnchor( GUIItem.Left, GUIItem.Top )
    self.tipText:SetTextClipped( true, math.floor(wt)-2*kVideoPad, math.floor(kTipTextHeight) )
    self.tipText:SetFontName("fonts/AgencyFB_small.fnt")

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetColor( Color(0.0, 0.0, 0.0, kBackgroundAlpha) )
    self.background:SetPosition(Vector(0, 0, 0))
    self.background:SetSize( Vector(wt, ht, 0) )
    self.background:SetInheritsParentAlpha( true )

    self.widget = GUIManager:CreateGraphicItem()
    self.widget:SetColor( Color(1.0, 1.0, 1.0, 1.0) )
    self.widget:SetPosition(Vector(0, y, 0))
    self.widget:SetSize( Vector(0, 0, 0) )
    self.widget:AddChild(self.background)
    self.widget:AddChild(self.video)
    self.widget:AddChild(self.tipText)
    self.widget:SetIsVisible(false)

    self.state = "hidden"
    self.videoWebView:SetIsVisible(false)

end

local function Destroy(self)

    if self.videoWebView then
        Client.DestroyWebView( self.videoWebView )
        self.videoWebView = nil
    end

    if self.widget then
        GUI.DestroyItem( self.widget )
        self.widget = nil
    end

end

function GUITipVideo:Uninitialize()

    GUIScript.Uninitialize(self)
    Destroy(self)

end


local function Hide(self)

    self.state = "hiding"
    self.sinceHide = 0.0

end

function GUITipVideo:Update(dt)

    if not gEnabled then
        return
    end

    GUIScript.Update(self, dt)
    
    local player = Client.GetLocalPlayer()
    
    if not player then
        return
    end

    if not self.videoWebView then
        return
    end
    
    if self.state == "showing" then

        self.sinceShow = self.sinceShow + dt

        if player:GetIsAlive() then
            Hide(self)
        elseif self.sinceShow > kPlayDelay then

            local tip = ToNextTip(player)

            self.videoWebView:LoadUrl(kTipViewURL.."?"..json.encode(tip))

            // Setup tip text
            self.tipText:SetText( SubstituteBindStrings(Locale.ResolveString(tip.key)) )
            self.tipText:SetColor( kChatTextColor[player:GetTeamType()] )

            self.state = "loading"

        end

    elseif self.state == "loading" then

        if player:GetIsAlive() then
            Hide(self)
        elseif self.videoWebView:GetUrlLoaded() then

            self.sincePlay = 0.0
            self.state = "playing"

            local color = self.widget:GetColor()
            color.a = 1.0
            self.widget:SetColor( color )

        end

    elseif self.state == "playing" then
   
        self.sincePlay = self.sincePlay + dt

        local pos = self.widget:GetPosition()

        if self.sincePlay < kSlideInSecs then
            local alpha = Easing.outBounce( self.sincePlay, 0.0, 1.0, kSlideInSecs )
            pos.x = (1-alpha)*(-self.background:GetSize().x) + alpha*kWidgetLeftMargin
        else
            pos.x = kWidgetLeftMargin
        end
        
        self.widget:SetPosition(pos)
        self.widget:SetIsVisible(true)
        
        if player:GetIsAlive() then
            Hide(self)
        end

    elseif self.state == "hiding" then
    
        self.sinceHide = self.sinceHide + dt

        local alpha = 1.0 - math.min( self.sinceHide / kFadeOutSecs, 1.0 )
        local color = self.widget:GetColor()
        color.a = alpha
        self.widget:SetColor( color )
        
        if alpha <= 0.0 then
            self.widget:SetIsVisible(false)
            self.state = "hidden"
            self.videoWebView:SetIsVisible(false)
            self.videoWebView:LoadUrl(kBlankUrl)
        end
        
    elseif self.state == "hidden" then
    
        if not player:GetIsAlive() then
            self.sinceShow = 0.0
            self.state = "showing"
            self.videoWebView:SetIsVisible(true)
        end
        
    end
    
end

Event.Hook("Console_tipvids", function(enabled) gEnabled = enabled == "1" end)
