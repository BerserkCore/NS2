// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIPlayerResource.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Displays team and personal resources. Everytime resources are being added, the numbers pulsate
// x times, where x is the amount of resource towers.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIPlayerResource'

GUIPlayerResource.kPersonalResourceIcon = { Width = 0, Height = 0, X = 0, Y = 0 }
GUIPlayerResource.kPersonalResourceIcon.Width = 32
GUIPlayerResource.kPersonalResourceIcon.Height = 64

GUIPlayerResource.kPersonalResourceIconSize = Vector(GUIPlayerResource.kPersonalResourceIcon.Width, GUIPlayerResource.kPersonalResourceIcon.Height, 0)
GUIPlayerResource.kPersonalResourceIconSizeBig = Vector(GUIPlayerResource.kPersonalResourceIcon.Width, GUIPlayerResource.kPersonalResourceIcon.Height, 0) * 1.1

GUIPlayerResource.kPersonalIconPos = Vector(30,-4,0)
GUIPlayerResource.kPersonalTextPos = Vector(100,4,0)
GUIPlayerResource.kPresDescriptionPos = Vector(110,4,0)
GUIPlayerResource.kResGainedTextPos = Vector(90,-6,0)

GUIPlayerResource.kRTCountSize = Vector(20, 40, 0)
GUIPlayerResource.kPixelWidth = 16
GUIPlayerResource.kPixelHeight = 32
local kRTCountTextures = { alien = PrecacheAsset("ui/alien_HUD_rtcount.dds"), marine = PrecacheAsset("ui/marine_HUD_rtcount.dds") }
GUIPlayerResource.kRTCountYOffset = -16

GUIPlayerResource.kTeamTextPos = Vector(20, 360, 0)

GUIPlayerResource.kIconTextXOffset = -20

GUIPlayerResource.kFontSizePersonal = 30
GUIPlayerResource.kFontSizePersonalBig = 30

GUIPlayerResource.kPulseTime = 0.5

GUIPlayerResource.kFontSizePresDescription = 18
GUIPlayerResource.kFontSizeResGained = 25
GUIPlayerResource.kFontSizeTeam = 18
GUIPlayerResource.kTextFontName = "fonts/AgencyFB_small.fnt"
GUIPlayerResource.kTresTextFontName = "fonts/AgencyFB_small.fnt"
GUIPlayerResource.kResGainedFontName = "fonts/AgencyFB_small.fnt"

local kBackgroundTextures = { alien = PrecacheAsset("ui/alien_HUD_presbg.dds"), marine = PrecacheAsset("ui/marine_HUD_presbg.dds") }

GUIPlayerResource.kRTCountTextOffset = Vector(460, 90, 0)

local kPresIcons = { alien = PrecacheAsset("ui/alien_HUD_presicon.dds"), marine = PrecacheAsset("ui/marine_HUD_presicon.dds") }

GUIPlayerResource.kBackgroundSize = Vector(280, 58, 0)
GUIPlayerResource.kBackgroundPos = Vector(-320, -100, 0)

local kNoResTexture = "ui/no_res.dds"
local kNoResSize = GUIScale(Vector(42, 42, 0))
local kNoResPos = Vector(0, -kNoResSize.y, 0)

local kNoResFontName = "fonts/AgencyFB_small.fnt"
local kNoResTimerPos = GUIScale(Vector(16, 0, 0))

function CreatePlayerResourceDisplay(scriptHandle, hudLayer, frame, style)

    local playerResource = GUIPlayerResource()
    playerResource.script = scriptHandle
    playerResource.hudLayer = hudLayer
    playerResource.frame = frame
    playerResource:Initialize(style)
    
    return playerResource
    
end

function GUIPlayerResource:Initialize(style)

    self.style = style
    
    self.scale = 1
    
    self.lastPersonalResources = 0
    
    // Background.
    self.background = self.script:CreateAnimatedGraphicItem()
    self.background:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.background:SetTexture(kBackgroundTextures[style.textureSet])
    self.background:AddAsChildTo(self.frame)
    
    self.rtCount = GetGUIManager():CreateGraphicItem()
    self.rtCount:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.rtCount:SetLayer(self.hudLayer + 2)
    self.rtCount:SetTexture(kRTCountTextures[style.textureSet])
    self.background:AddChild(self.rtCount)
    
    // Personal display.
    self.personalIcon = self.script:CreateAnimatedGraphicItem()
    self.personalIcon:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.personalIcon:SetTexture(kPresIcons[style.textureSet])
    self.background:AddChild(self.personalIcon)
    
    self.personalText = self.script:CreateAnimatedTextItem()
    self.personalText:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.personalText:SetTextAlignmentX(GUIItem.Align_Max)
    self.personalText:SetTextAlignmentY(GUIItem.Align_Center)
    self.personalText:SetColor(style.textColor)
    self.personalText:SetFontIsBold(true)
    self.personalText:SetFontName(GUIPlayerResource.kTextFontName)
    self.background:AddChild(self.personalText)
    
    self.pResDescription = self.script:CreateAnimatedTextItem()
    self.pResDescription:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.pResDescription:SetTextAlignmentX(GUIItem.Align_Min)
    self.pResDescription:SetTextAlignmentY(GUIItem.Align_Center)
    self.pResDescription:SetColor(style.textColor)
    self.pResDescription:SetFontIsBold(true)
    self.pResDescription:SetFontName(GUIPlayerResource.kTextFontName)
    self.pResDescription:SetText(Locale.ResolveString("RESOURCES"))
    self.background:AddChild(self.pResDescription)
    
    self.ResGainedText = self.script:CreateAnimatedTextItem()
    self.ResGainedText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.ResGainedText:SetTextAlignmentX(GUIItem.Align_Max)
    self.ResGainedText:SetTextAlignmentY(GUIItem.Align_Max)
    self.ResGainedText:SetColor(style.textColor)
    self.ResGainedText:SetFontIsBold(false)
    self.ResGainedText:SetBlendTechnique(GUIItem.Add)
    self.ResGainedText:SetFontName(GUIPlayerResource.kResGainedFontName)
    self.ResGainedText:SetText("+")
    self.background:AddChild(self.ResGainedText)
    
    // Team display.
    self.teamText = self.script:CreateAnimatedTextItem()
    self.teamText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.teamText:SetTextAlignmentX(GUIItem.Align_Min)
    self.teamText:SetTextAlignmentY(GUIItem.Align_Min)
    self.teamText:SetColor(style.textColor)
    self.teamText:SetBlendTechnique(GUIItem.Add)
    self.teamText:SetFontIsBold(true)
    self.teamText:SetFontName(GUIPlayerResource.kTresTextFontName)
    self.teamText:SetIsVisible(style.displayTeamRes)
    self.frame:AddChild(self.teamText)
    
    self.noResIcon = GetGUIManager():CreateGraphicItem()
    self.noResIcon:SetTexture(kNoResTexture)
    self.noResIcon:SetSize(kNoResSize)
    self.noResIcon:SetPosition(kNoResPos)
    self.noResIcon:SetIsVisible(true)
    
    self.noResTimer = GetGUIManager():CreateTextItem()
    self.noResTimer:SetFontName(kNoResFontName)
    self.noResTimer:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.noResTimer:SetScale(GUIScale(Vector(1,1,1)))
    self.noResTimer:SetTextAlignmentX(GUIItem.Align_Min)
    self.noResTimer:SetTextAlignmentY(GUIItem.Align_Center)
    self.noResTimer:SetColor(Color(1, 0, 0, 1))
    self.noResTimer:SetPosition(kNoResTimerPos)
    
    self.noResIcon:AddChild(self.noResTimer)   
    self.background:AddChild(self.noResIcon)
    
end

function GUIPlayerResource:Reset(scale)

    self.scale = scale

    self.background:SetUniformScale(self.scale)
    self.background:SetPosition(GUIPlayerResource.kBackgroundPos)
    self.background:SetSize(GUIPlayerResource.kBackgroundSize)
    
    self.personalIcon:SetUniformScale(self.scale)
    self.personalIcon:SetSize(Vector(GUIPlayerResource.kPersonalResourceIcon.Width, GUIPlayerResource.kPersonalResourceIcon.Height, 0))
    self.personalIcon:SetPosition(GUIPlayerResource.kPersonalIconPos)
    
    self.personalText:SetScale(Vector(1,1,1) * self.scale * 1.2)
    self.personalText:SetFontSize(GUIPlayerResource.kFontSizePersonal)
    self.personalText:SetPosition(GUIPlayerResource.kPersonalTextPos)
   
    self.pResDescription:SetScale(Vector(1,1,1) * self.scale * 1.2)
    self.pResDescription:SetFontSize(GUIPlayerResource.kFontSizePresDescription)
    self.pResDescription:SetPosition(GUIPlayerResource.kPresDescriptionPos)
   
    self.teamText:SetScale(Vector(1,1,1) * self.scale * 1.2)
    self.teamText:SetScale(GetScaledVector())
    self.teamText:SetPosition(GUIPlayerResource.kTeamTextPos)
    
    self.ResGainedText:SetUniformScale(self.scale)
    self.ResGainedText:SetPosition(GUIPlayerResource.kResGainedTextPos)

end

function GUIPlayerResource:Update(deltaTime, parameters)

    PROFILE("GUIPlayerResource:Update")
    
    local tRes, pRes, numRTs = unpack(parameters)
    
    self.rtCount:SetIsVisible(numRTs > 0)
    
    local resGainAllowed = PlayerUI_GetCanEarnResources()
    
    // adjust rt count display
    local x1 = 0
    local x2 = numRTs * GUIPlayerResource.kPixelWidth
    local y1 = 0
    local y2 = GUIPlayerResource.kPixelHeight
    
    local width = GUIPlayerResource.kRTCountSize.x * self.scale * numRTs
    
    self.rtCount:SetTexturePixelCoordinates(x1, y1, x2, y2)
    self.rtCount:SetSize(Vector(width, GUIPlayerResource.kRTCountSize.y * self.scale, 0))
    self.rtCount:SetPosition(Vector(-width/2, GUIPlayerResource.kRTCountYOffset * self.scale, 0))
    
    self.personalText:SetText(ToString(math.floor(pRes * 10) / 10))
    self.teamText:SetText(string.format(Locale.ResolveString("TEAM_RES"), math.floor(tRes)))
    
    if pRes > self.lastPersonalResources then

        self.ResGainedText:DestroyAnimations()
        self.ResGainedText:SetColor(self.style.textColor)
        self.ResGainedText:FadeOut(2)
        
        self.lastPersonalResources = pRes
        self.pulseLeft = 1
        
        self.personalText:SetFontSize(GUIPlayerResource.kFontSizePersonalBig)
        self.personalText:SetFontSize(GUIPlayerResource.kFontSizePersonal, GUIPlayerResource.kPulseTime, "RES_PULSATE")
        self.personalText:SetColor(Color(1,1,1,1))
        self.personalText:SetColor(self.style.textColor, GUIPlayerResource.kPulseTime)
        
        self.personalIcon:DestroyAnimations()
        self.personalIcon:SetSize(GUIPlayerResource.kPersonalResourceIconSizeBig)
        self.personalIcon:SetSize(GUIPlayerResource.kPersonalResourceIconSize, GUIPlayerResource.kPulseTime,  nil, AnimateQuadratic)
        
    end

    if not resGainAllowed then
    
        local timeNoRes = PlayerUI_GetNoResourceGainTimer()
        
        self.noResTimer:SetText(ToString(math.ceil(timeNoRes)))
        self.noResIcon:SetIsVisible(true)
        self.ResGainedText:SetIsVisible(false)
    
    else
        self.noResIcon:SetIsVisible(false)
        self.ResGainedText:SetIsVisible(true)
    end

end

function GUIPlayerResource:OnAnimationCompleted(animatedItem, animationName, itemHandle)

    if animationName == "RES_PULSATE" then
    
        if self.pulseLeft > 0 then
        
            self.personalText:SetFontSize(GUIPlayerResource.kFontSizePersonalBig)
            self.personalText:SetFontSize(GUIPlayerResource.kFontSizePersonal, GUIPlayerResource.kPulseTime, "RES_PULSATE", AnimateQuadratic)
            self.personalText:SetColor(Color(1, 1, 1, 1))
            self.personalText:SetColor(self.style.textColor, GUIPlayerResource.kPulseTime)
            
            self.personalIcon:DestroyAnimations()
            self.personalIcon:SetSize(GUIPlayerResource.kPersonalResourceIconSizeBig)
            self.personalIcon:SetSize(GUIPlayerResource.kPersonalResourceIconSize, GUIPlayerResource.kPulseTime,  nil, AnimateQuadratic)
            
            self.pulseLeft = self.pulseLeft - 1
            
        end
        
    end
    
end

function GUIPlayerResource:Destroy()
end