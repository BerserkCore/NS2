// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\GUIMinimapFrame.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages displaying the minimap and the minimap background.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIMinimap.lua")

class 'GUIMinimapFrame' (GUIMinimap)

GUIMinimapFrame.kModeMini = 0
GUIMinimapFrame.kModeBig = 1
GUIMinimapFrame.kModeZoom = 2

local kMapBackgroundXOffset = 28
local kMapBackgroundYOffset = 28

local kBigSizeScale = 3
local kZoomedBlipSizeScale = 1 // 0.8
local kMiniBlipSizeScale = 0.5

local kMarineZoomedIconColor = Color(191 / 255, 226 / 255, 1, 1)

local kFrameTextureSize = GUIScale(Vector(473, 354, 0))
local kMarineFrameTexture = PrecacheAsset("ui/marine_commander_textures.dds")
local kFramePixelCoords = { 466, 250 , 466 + 473, 250 + 354 }

local kBackgroundNoiseTexture = PrecacheAsset("ui/alien_commander_bg_smoke.dds")
local kSmokeyBackgroundSize = GUIScale(Vector(480, 640, 0))

local kMarineIconsFileName = PrecacheAsset("ui/marine_minimap_blip.dds")

function GUIMinimapFrame:Initialize()

    GUIMinimap.Initialize(self)
    
    self.zoom = 1
    self.desiredZoom = 1
    
    self:InitSmokeyBackground()
    self:InitFrame()
    
end

function GUIMinimapFrame:InitFrame()

    self.minimapFrame = GUIManager:CreateGraphicItem()
    self.minimapFrame:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.minimapFrame:SetSize(kFrameTextureSize)
    self.minimapFrame:SetPosition(Vector(-kMapBackgroundXOffset, -kFrameTextureSize.y + kMapBackgroundYOffset, 0))
    self.minimapFrame:SetTexture(kMarineFrameTexture)
    self.minimapFrame:SetTexturePixelCoordinates(unpack(kFramePixelCoords))
    self.minimapFrame:SetIsVisible(false)
    self.minimapFrame:SetLayer(-1)
    self.background:AddChild(self.minimapFrame)

end

function GUIMinimapFrame:InitSmokeyBackground()

    self.smokeyBackground = GUIManager:CreateGraphicItem()
    self.smokeyBackground:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.smokeyBackground:SetSize(kSmokeyBackgroundSize)
    self.smokeyBackground:SetPosition(-kSmokeyBackgroundSize * .5)
    self.smokeyBackground:SetTexture("ui/alien_minimap_smkmask.dds")
    self.smokeyBackground:SetShader("shaders/GUISmoke.surface_shader")
    self.smokeyBackground:SetAdditionalTexture("noise", kBackgroundNoiseTexture)
    self.smokeyBackground:SetFloatParameter("correctionX", 1)
    self.smokeyBackground:SetFloatParameter("correctionY", 1.2)
    self.smokeyBackground:SetIsVisible(false)
    self.smokeyBackground:SetLayer(-1)
    
    self.background:AddChild(self.smokeyBackground)

end

function GUIMinimapFrame:Update(deltaTime)

    PROFILE("GUIMinimapFrame:Update")
    
    self.minimapFrame:SetIsVisible(PlayerUI_GetTeamType() == kMarineTeamType and self.comMode == GUIMinimapFrame.kModeMini)
    self.smokeyBackground:SetIsVisible(PlayerUI_GetTeamType() == kAlienTeamType and self.comMode == GUIMinimapFrame.kModeMini)
    
    if self.comMode == GUIMinimapFrame.kModeBig then
        //self.background:SetTexture(nil)
        
    elseif PlayerUI_IsOverhead() then
        
        if PlayerUI_IsACommander() then
        
            // Commander always sees the minimap.
            if not PlayerUI_IsCameraAnimated() then
                self.background:SetIsVisible(true)
            else
                self.background:SetIsVisible(false)
            end
            
            //GUISetTextureCoordinatesTable(self.background, GUIMinimapFrame.kBackgroundTextureCoords)
            
        else

            self.background:SetIsVisible(true)
            //self.background:SetTexture(GUIMinimapFrame.kBackgroundTextureSpec)
            //self.background:SetTexturePixelCoordinates(unpack({0,0,572,548}))
            
        end

    end
    
    if self.comMode == GUIMinimapFrame.kModeZoom then
        if self.desiredZoom ~= self.zoom then
            local currSqrt = math.sqrt(self.zoom)
            local zoomSpeed = 0.8
            if self.zoom < self.desiredZoom then
                currSqrt = currSqrt + deltaTime*zoomSpeed
                self:SetZoom(Clamp(currSqrt*currSqrt, 0, self.desiredZoom))
            else
                currSqrt = currSqrt - deltaTime*zoomSpeed
                self:SetZoom(Clamp(currSqrt*currSqrt, self.desiredZoom, 1))
            end
        end
    end
    
    GUIMinimap.Update(self, deltaTime)

end

function GUIMinimapFrame:SetZoom(zoom)
    self.zoom = zoom
    self:SetScale(kBigSizeScale * zoom)
    self:SetBlipScale(zoom)
end

function GUIMinimapFrame:SetDesiredZoom(desiredZoom)
    self.desiredZoom = Clamp(desiredZoom, 0, 1)
end

function GUIMinimapFrame:GetDesiredZoom()
    return self.desiredZoom
end

function GUIMinimapFrame:SetBackgroundMode(setMode, forceReset)

    if self.comMode ~= setMode or forceReset then
        
        self.comMode = setMode
        local modeIsMini = self.comMode == GUIMinimapFrame.kModeMini
        local modeIsZoom = self.comMode == GUIMinimapFrame.kModeZoom
        
        // Special settings for zoom mode
        self:SetMoveBackgroundEnabled(modeIsZoom)
        if modeIsZoom then
            
            self:SetStencilFunc(GUIItem.NotEqual)
            self:SetPlayerIconColor(kMarineZoomedIconColor)
            self:SetIconFileName(kMarineIconsFileName)
        else
            self:SetStencilFunc(GUIItem.Always)
            self:SetPlayerIconColor(nil)
            self:SetIconFileName(nil)
        end
        
        // 
        self:SetLocationNamesEnabled(not modeIsMini and not modeIsZoom)

        // We want the background to sit "inside" the border so move it up and to the right a bit.
        //local borderExtraWidth = ConditionalValue(self.background, GUIMinimapFrame.kBackgroundWidth - self:GetMinimapSize().x, 0)
        //local borderExtraHeight = ConditionalValue(self.background, GUIMinimapFrame.kBackgroundHeight - self:GetMinimapSize().y, 0)
        //local defaultPosition = Vector(borderExtraWidth / 2, borderExtraHeight / 2, 0)
        //local modePosition = ConditionalValue(modeIsMini, defaultPosition, Vector(0, 0, 0))
        //self.minimap:SetPosition(modePosition * self.zoom)
        
        if modeIsMini then
            self:SetScale(1)
            self:SetBlipScale(kMiniBlipSizeScale)
            self.background:SetAnchor(GUIItem.Left, GUIItem.Bottom)
            self.background:SetPosition(Vector(kMapBackgroundXOffset, -GUIMinimap.kBackgroundHeight - kMapBackgroundYOffset, 0))
            self.background:SetSize(Vector(GUIMinimap.kBackgroundWidth, GUIMinimap.kBackgroundHeight, 0))
            self.minimap:SetAnchor(GUIItem.Left, GUIItem.Top)
            self.minimap:SetPosition(Vector(0, 0, 0))
        elseif modeIsZoom then
            self:SetScale(kBigSizeScale * self.zoom)
            self:SetBlipScale(kZoomedBlipSizeScale)
            self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
            local scale = Client.GetScreenHeight() / kBaseScreenHeight
            self.background:SetSize(Vector(190 * (scale * 2), 180 * (scale * 2), 0)) // don't ask.. the minimap placement in GUIMarineHud.lua needs some clean up
            self.minimap:SetAnchor(GUIItem.Middle, GUIItem.Center)
            self.minimap:SetPosition(Vector(0, 0, 0))
            
        else
            self:InitializeLocationNames()
            self:SetScale(kBigSizeScale)
            self:SetBlipScale(1)
            
            self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
            self.background:SetSize( Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0) )
            self.background:SetPosition(Vector(0, 0, 0))
            
            self.minimap:SetAnchor(GUIItem.Middle, GUIItem.Center)
            local modeSize = self:GetMinimapSize()
            self.minimap:SetPosition(modeSize * -0.5)

        end
        
        // Make sure everything is in sync in case this function is called after GUIMinimapFrame:Update() is called.
        self:Update(0)
    
    end
    
end

function GUIMinimapFrame:OnResolutionChanged(oldX, oldY, newX, newY)

    GUIMinimap.OnResolutionChanged(self, oldX, oldY, newX, newY)

    if self.comMode == GUIMinimapFrame.kModeZoom then
        local scale = newY / kBaseScreenHeight
        self.background:SetSize(Vector(190 * (scale * 2), 180 * (scale * 2), 0)) // don't ask.. the minimap placement in GUIMarineHud.lua needs some clean up
    elseif self.comMode == GUIMinimapFrame.kModeBig then
        self.background:SetSize(Vector(newX, newY, 0) )
    end
    
end
