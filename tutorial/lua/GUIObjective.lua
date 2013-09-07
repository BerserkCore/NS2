// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// Created by: Steven An (steve@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local gDebugIgnoreGameState = false

local kBlankUrl = "temptemp"
local kTipViewURL = "file:///tutorial/resources/html5-webm-player.html"
local kTextureName = "*tip_video_webview_texture"
local kSlideInSecs = 0.5
local kFadeOutSecs = 0.5
local kAfterDeathDelay = 3.5
local kWidgetRightMargin = 20
local kTipTextHeight = 100
local kBackgroundAlpha = 0.5
local kVideoPad = 5
local kMaxPlaysPerVideo = 2

local kClickSound = "sound/NS2.fev/common/hovar"
Client.PrecacheLocalSound(kClickSound)

// This is how large the web-view should be, in "HTML space."
// Our videos will be 720p, so this should at least by 1280x720 pixels high, also allow 200 pixels for the margins
local webViewWidth = 720
local webViewHeight = 1 // for tutorials, we only use the WEBMs for sound, so no need to show the video

//----------------------------------------
//  
//----------------------------------------
class "GUIObjective" (GUIScript)

GUIObjective.main = nil

function GUIObjective:Initialize()

    GUIObjective.main = self
    GUIScript.Initialize(self)

    //----------------------------------------
    //  GUI design stuff
    //----------------------------------------
    
    // Compute size/pos
    local webAspect = webViewWidth / webViewHeight
    local wt = Client.GetScreenWidth() * 0.3
    local videoWt = wt - 2*kVideoPad
    local videoHt = videoWt / webAspect
    local ht = videoHt + kTipTextHeight + 2*kVideoPad
    local y = ht + kWidgetRightMargin
    
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
    self.widget:SetLayer(kGUILayerTipVideos)

    self.videoWebView:SetIsVisible(false)

    //----------------------------------------
    //  State init
    //----------------------------------------
    self.state = "hidden"
    self.sinceHide = 0

end

local function Destroy(self)

    self.widget:SetIsVisible(false)
    self.videoWebView:SetIsVisible(false)
    self.videoWebView:LoadUrl(kBlankUrl)

    if self.widget then
        GUI.DestroyItem( self.widget )
        self.widget = nil
    end

    if self.videoWebView then
        Client.DestroyWebView( self.videoWebView )
        self.videoWebView = nil
    end

end

function GUIObjective:Uninitialize()
    Destroy(self)
end


function GUIObjective:Hide()
    self.state = "hiding"
    self.sinceHide = 0.0
    StartSoundEffect(kClickSound)
end

function GUIObjective:GetMustHide()
    return false
end

function GUIObjective:Update(dt)

    GUIScript.Update(self, dt)

    if not self.videoWebView then
        // did not init successfully
        return
    end
    
    if self.state == "loadingHtml" then

        if self:GetMustHide() then
            self:Hide()
        elseif self.videoWebView:GetUrlLoaded() then

            self.sincePlay = 0.0
            self.state = "playing"

            local color = self.widget:GetColor()
            color.a = 1.0
            self.widget:SetColor( color )
            self.videoWebView:SetIsVisible(true)

        end

    elseif self.state == "playing" then
        // Video is sliding in or playing
   
        if self:GetMustHide() then
            self:Hide()
        else

            // Fancy tweened animation

            self.sincePlay = self.sincePlay + dt
            local pos = self.widget:GetPosition()

            local widgetWidth = self.background:GetSize().x
            local startX = Client.GetScreenWidth()
            local endX = Client.GetScreenWidth() - widgetWidth - kWidgetRightMargin

            if self.sincePlay < kSlideInSecs then
                local alpha = Easing.outBack( self.sincePlay, 0.0, 1.0, kSlideInSecs )
                pos.x = (1-alpha)*startX + alpha*endX
            else
                pos.x = endX
            end
            
            self.widget:SetPosition(pos)
            self.widget:SetIsVisible(true)  // set vis here rather than in loadingHtml, to avoid position-related flash

        end
        
    elseif self.state == "hiding" then
    
        self.sinceHide = self.sinceHide + dt

        local alpha = 1.0 - math.min( self.sinceHide / kFadeOutSecs, 1.0 )
        local color = self.widget:GetColor()
        color.a = alpha
        self.widget:SetColor( color )
        
        if alpha <= 0.0 then
            self.widget:SetIsVisible(false)
            self.videoWebView:SetIsVisible(false)
            self.videoWebView:LoadUrl(kBlankUrl)
            self.state = "hidden"
        end
        
    elseif self.state == "hidden" then

        // do nothing!
        
    end
    
end

// Interface for playing a ready video
function GUIObjective:Show( text, videoUrl )

    jsonData = {
        videoUrl = videoUrl,
        volume = Client.GetOptionInteger("soundVolume", 50) / 100.0,
        delaySecs = 0.0, // don't delay VO at all
    }

    self.videoWebView:LoadUrl(kTipViewURL.."?"..json.encode(jsonData))
    self.tipText:SetText( text )
    self.tipText:SetColor( Color(1,1,1,1) )
    self.state = "loadingHtml"
    self.widget:SetIsVisible(false)  // let the animation show this when ready
    StartSoundEffect(kClickSound)

end

function GUIObjective:GetIsPlaying()
    return self.state == "playing"
end

