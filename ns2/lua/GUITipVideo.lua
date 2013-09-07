// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
//
// lua\GUITipVideo.lua
//
// Created by: Steven An (steve@unknownworlds.com)
//
//  There are two types of tip videos: Spawn videos (play when you die and are waiting to spawn), 
//  and ready videos
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// TEMP TEMP
gSpawnVideoUrlPrefix = "file:///ns2/tipvideos/"
//gSpawnVideoUrlPrefix = "file://C:/ns2_p4/ns2_p4/assets/tipvideos/"
Script.Load("lua/GUITipVideo_SpawnVideos.lua")
Script.Load("lua/tweener/Tweener.lua")

local gDebugIgnoreGameState = false

local kBlankUrl = "temptemp"
local kTipViewURL = "file:///ns2/web/client_game/tipvideo_widget_html5.html"
local kTextureName = "*tip_video_webview_texture"
local kSlideInSecs = 0.5
local kFadeOutSecs = 0.25
local kAfterDeathDelay = 3.5    // wait after fade to black, etc.
local kWidgetRightMargin = 20
local kTipTextHeight = 50
local kBackgroundAlpha = 0.5
local kVideoPad = 5
local kMaxPlaysPerVideo = 2

local kStopSound = "sound/NS2.fev/common/hovar"
Client.PrecacheLocalSound(kStopSound)

// This is how large the web-view should be, in "HTML space."
// Our videos will be 720p, so this should at least by 1280x720 pixels high, also allow 200 pixels for the margins
local webViewWidth = 720
local webViewHeight = 480

//----------------------------------------
//  External API for other stuff, like ready video list
//----------------------------------------
function GetNumTipVideoPlays(subKey)
    local nplays = Client.GetOptionInteger("tipvids/"..subKey, 0)
    return nplays
end

function IncNumTipVideoPlays(subKey)
    local nplays = GetNumTipVideoPlays(subKey)
    Client.SetOptionInteger("tipvids/"..subKey, nplays+1)
end

//----------------------------------------
//  Picks a video that has been played the least, and increments its play count
//----------------------------------------
local function GetNextTipVideo( player, evolveClass )

    // Try to play the least-played video

    local leastPlays = 0
    local leastPlayedRelevance = 0
    local leastPlayedIndex = -1

    for itip = 1, #gSpawnTipVideos do

        local tip = gSpawnTipVideos[itip]
        local nplays = Client.GetOptionInteger("tipvids/"..tip.subKey, 0)

        if evolveClass ~= nil
        and (tip.context ~= "evolve" or tip.evolveClass == nil or tip.evolveClass:lower() ~= evolveClass:lower())
        then
            // no good

        elseif tip.teamNumber ~= player:GetTeamNumber() or nplays >= kMaxPlaysPerVideo then

            // never play vids for the other team, and don't play a vid too many times

        else

            // Use relevancy to break ties
            local relevance = 
                ConditionalValue( player:isa(tip.playerClass), 1, 0 )

            //DebugPrint("tip %d nplays %d rel %d", itip, nplays, relevance)

            if (nplays < leastPlays) or (nplays == leastPlays and relevance > leastPlayedRelevance) or leastPlayedIndex == -1 then
                leastPlays = nplays
                leastPlayedIndex = itip
                leastPlayedRelevance = relevance
            end

        end

    end

    if leastPlayedIndex >= 0 then

        local tip = gSpawnTipVideos[ leastPlayedIndex ]
        Client.SetOptionInteger("tipvids/"..tip.subKey, leastPlays+1)
        tip.videoType = "spawn"
        return tip

    else
        return nil
    end
end

//----------------------------------------
//  
//----------------------------------------
class "GUITipVideo" (GUIScript)

GUITipVideo.singleton = nil

function GUITipVideo:Initialize()

    GUITipVideo.singleton = self

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
    self.widget:SetLayer(kGUILayerTipVideos)

    self.state = "hidden"
    self.videoWebView:SetIsVisible(false)

    // init vars just in case
    self.sinceDeath = 0
    self.sinceHide = 0
    self.tip = nil
    self.wasEvolveVideo = false

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

function GUITipVideo:Uninitialize()
    Destroy(self)
end


function GUITipVideo:Hide()
    self.state = "hiding"
    self.sinceHide = 0.0
    self.tip = nil

    // reset layer, in case it was changed
    self.widget:SetLayer(kGUILayerTipVideos)
end

local function GetMustHideSpawnVideo( self )

    local player = Client.GetLocalPlayer()

    return player == nil
    // only hide the vid if the player is CONTROLLING a live player - cuz if they're just spectating a live player, we should NOT be playing!
    or (Client.GetIsControllingPlayer() and player:GetIsAlive())
    or (gDebugIgnoreGameState or GetGameInfoEntity():GetState() ~= kGameState.Started)

end

// Returns true if we must hide the video asap - ie. the player disabled hints, or player is playing the game
function GUITipVideo:GetMustHide()

    if not self.tip then
        return true
    end

    if self.tip.videoType ~= "adhoc" and not Client.GetOptionBoolean("showHints", true) then
        return true
    end

    if self.mustHideFunction ~= nil then
        local val = self:mustHideFunction()
        return val
    end

    return false

end

function GUITipVideo:GetMaxPlaySecs()

    if self.tip.videoType == "spawn" then
        return 7.0
    elseif self.tip.videoType == "ready" then
        return 40.0
    else
        return 99999.0
    end

end

function GUITipVideo:Update(dt)

    GUIScript.Update(self, dt)

    if not self.videoWebView then
        // did not init successfully
        return
    end
    
    if self.state == "playerIsDead" then

        self.sinceDeath = self.sinceDeath + dt

        if self:GetMustHide() then
            self:Hide()
        elseif self.sinceDeath > kAfterDeathDelay then

            if self.tip then

                // load the widget page
                self.tip.volume = Client.GetOptionInteger("soundVolume", 50) / 100.0
                self.tip.delaySecs = kSlideInSecs    // do not have the video play until we are done sliding in
                //DebugPrint("json sent to tip vid HTML: "..json.encode(self.tip))
                self.videoWebView:LoadUrl(kTipViewURL.."?"..json.encode(self.tip))

                // Setup tip text
                local player = Client.GetLocalPlayer()
                local tipStr = SubstituteBindStrings(Locale.ResolveString(self.tip.subKey))
                self.tipText:SetText( tipStr )
                self.tipText:SetColor( kChatTextColor[player:GetTeamType()] )

                self.state = "loadingHtml"

            else
                self:Hide()
            end

        end

    elseif self.state == "loadingHtml" then

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

            // Hide after some time

            if self.sincePlay > (self:GetMaxPlaySecs()+kSlideInSecs) then
                self:Hide()
            end

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

        local player = Client.GetLocalPlayer()

        if self.wasEvolveVideo then

            // wait for the player to finish evolving before ever playing another video
            //if player and not player:isa("Embryo") then
                self.state = "waiting"
            //end


        else

            // and the player may still be dead
            // do not even consider showing again until player respawns

            if player and player:GetIsOnPlayingTeam()
                and player:GetIsAlive()
                and Client.GetIsControllingPlayer()
            then
                // player is back in the game
                self.state = "waiting"
            end

        end

    elseif self.state == "waiting" then

        //----------------------------------------
        //  Waiting on certain events to trigger videos
        //----------------------------------------
    
        local player = Client.GetLocalPlayer()
        local isEnabled = Client.GetOptionBoolean("showHints", true)
        local justDied = not player:GetIsAlive() and Client.GetIsControllingPlayer()
        local isEvolving = player:isa("Embryo")

        if isEnabled and justDied then

            // player just died
            self.sinceDeath = 0.0
            self.state = "playerIsDead"

            // Decide which tip to play right here, since the player ent will be gone soon
            self.tip = GetNextTipVideo(player)
            self.mustHideFunction = GetMustHideSpawnVideo

        elseif isEnabled and isEvolving then

            // immediately play evolve video
            local evolveClass = LookupTechData(player.gestationTypeTechId, kTechDataGestateName)
            local evolveTime = LookupTechData(player.gestationTypeTechId, kTechDataGestateTime)
            local tip = GetNextTipVideo(player, evolveClass)

            if tip ~= nil then
                self:TriggerVideo( tip )
                self.tipText:SetColor( kChatTextColor[player:GetTeamType()] )
                self.wasEvolveVideo = true

                // override this function
                self.mustHideFunction = function(self)
                    if not Client.GetLocalPlayer():isa("Embryo") then
                        return true
                    end
                    return self.sincePlay ~= nil and (self.sincePlay-kSlideInSecs) > 8.0
                end
            end

        end
        
    end
    
end

// Interface for playing a ready video
function GUITipVideo:TriggerReadyVideo(tip)


    if self.state == "hiding"
    or self.state == "hidden"
    or self.state == "waiting"
    then
        
        self.tip = tip
        self.tip.volume = Client.GetOptionInteger("soundVolume", 50) / 100.0
        self.tip.delaySecs = kSlideInSecs
        self.videoWebView:LoadUrl(kTipViewURL.."?"..json.encode(self.tip))
        local tipStr = SubstituteBindStrings(Locale.ResolveString(self.tip.subKey))
        tipStr = tipStr .. "  (Press 0 to stop)"
        self.tipText:SetText( tipStr )
        self.tipText:SetColor( Color(1,1,1,1) )
        self.state = "loadingHtml"
        self.tip.videoType = "ready"

    end

end

// Interface for playing a video from training menu
function GUITipVideo:TriggerVideo( tip, seconds, guiLayer )

    if self.state ~= "hidden" then
        self:Hide()
    end

    self.tip =
    {
        videoUrl = tip.videoUrl,
        subKey = tip.subKey,
        volume = Client.GetOptionInteger("soundVolume", 50) / 100.0,
        delaySecs = kSlideInSecs,
        videoType = "adhoc",
        lengthSeconds = seconds,
    }
    self.videoWebView:LoadUrl(kTipViewURL.."?"..json.encode(self.tip))
    local tipStr = SubstituteBindStrings(Locale.ResolveString(self.tip.subKey))
    self.tipText:SetText( tipStr )
    self.tipText:SetColor( Color(1,1,1,1) )
    self.state = "loadingHtml"
    self.sincePlay = 0
    // stop playing after given time
    self.mustHideFunction = function(self)
        return self.sincePlay ~= nil and (self.sincePlay-kSlideInSecs) > self.tip.lengthSeconds
    end

    // TODO this does not work - our stuff does not show above the training video list WTF
    if guiLayer ~= nil then
        self.widget:SetLayer(guiLayer)
    end

end

function GUITipVideo:GetIsPlaying()
    return self.state == "playing"
end

function GUITipVideo:SendKeyEvent(key, down)

    if self.state == "playing" then

        if key == InputKey.Num0 and down then
            self:Hide()
            StartSoundEffect(kStopSound)
            return true
        end

    end

    return false

end

//Event.Hook("Console_tipvids", function(enabled) gEnabled = enabled == "1" end)
Event.Hook("Console_resettipvids",
        function(enabled)
            for itip = 1, #gSpawnTipVideos do
                local tip = gSpawnTipVideos[itip]
                Client.SetOptionInteger("tipvids/"..tip.subKey, 0)
            end
            Print("OK cleared tip vid history")
        end)

