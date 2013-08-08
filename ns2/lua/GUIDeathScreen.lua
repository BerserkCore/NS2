// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIDeathScreen.lua
//
// Created by: Andreas Urwalek (andi@unkownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")
Script.Load("lua/DeathMessage_Client.lua")

class 'GUIDeathScreen' (GUIAnimatedScript)

local kWeaponIconSize = Vector(256, 128, 0)
local kFontName = "fonts/AgencyFB_medium.fnt"

function GUIDeathScreen:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetColor(Color(0,0,0,0))
    self.background:SetIsScaling(false)
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(),0))
    self.background:SetLayer(kGUILayerDeathScreen)
    
    self.weaponIcon = self:CreateAnimatedGraphicItem()
    self.weaponIcon:SetColor(Color(1,1,1,0))
    self.weaponIcon:SetIsScaling(true)
    self.weaponIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.weaponIcon:SetSize(kWeaponIconSize)    
    self.weaponIcon:SetPosition(Vector(-kWeaponIconSize.x / 2, -kWeaponIconSize.y / 2, 0))
    self.weaponIcon:SetTexture(kInventoryIconsTexture)
    
    self.killerName = GetGUIManager():CreateTextItem()
    self.killerName:SetText("")
    self.killerName:SetFontName(kFontName)
    self.killerName:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.killerName:SetTextAlignmentX(GUIItem.Align_Max)
    self.killerName:SetTextAlignmentY(GUIItem.Align_Center)
    self.killerName:SetInheritsParentAlpha(true)
    self.weaponIcon:AddChild(self.killerName)
    
    self.playerName = GetGUIManager():CreateTextItem()
    self.playerName:SetText("")
    self.playerName:SetFontName(kFontName)
    self.playerName:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.playerName:SetTextAlignmentX(GUIItem.Align_Min)
    self.playerName:SetTextAlignmentY(GUIItem.Align_Center)
    self.playerName:SetInheritsParentAlpha(true)
    self.weaponIcon:AddChild(self.playerName)    

    self.feintText = self:CreateAnimatedTextItem()
    self.feintText:SetText(Locale.ResolveString("FEINTING_DEATH"))
    self.feintText:SetFontName(kFontName)
    self.feintText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.feintText:SetTextAlignmentX(GUIItem.Align_Center)
    self.feintText:SetTextAlignmentY(GUIItem.Align_Center)
    self.feintText:SetColor(Color(1, 1, 1, 0))
    self.feintText:SetInheritsParentAlpha(false)
    
    self.lastIsDead = PlayerUI_GetIsDead()
    
end

function GUIDeathScreen:Reset()

    GUIAnimatedScript.Reset(self)
    
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(),0))
    
end

function GUIDeathScreen:Update(deltaTime)

    PROFILE("GUIDeathScreen:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)
    
    local isDead = (PlayerUI_GetIsDead() or PlayerUI_GetIsFeinting() ) and not PlayerUI_GetIsSpecating()    
            
    if isDead ~= self.lastIsDead then
    
        self.lastIsDead = isDead
        
        if self.lastIsDead == true then

            local killerName, weaponIconIndex = GetKillerNameAndWeaponIcon()
            local playerName = PlayerUI_GetPlayerName()
            local xOffset = DeathMsgUI_GetTechOffsetX(0)
            local yOffset = DeathMsgUI_GetTechOffsetY(weaponIconIndex)
            local iconWidth = DeathMsgUI_GetTechWidth(0)
            local iconHeight = DeathMsgUI_GetTechHeight(0)
    
            self.killerName:SetText(killerName)
            self.playerName:SetText(playerName)
            
            self.weaponIcon:SetTexturePixelCoordinates(xOffset, yOffset, xOffset + iconWidth, yOffset + iconHeight)
            self.weaponIcon:FadeIn(0.5, "FADE_DEATH_ICON")
            
            if PlayerUI_GetIsFeinting() then

                self.feintText:FadeIn(0.2, "FADE_DEATH_FEINT")
                self.background:SetColor(Color(0, 0, 0, 0.6), 0.5, "FADE_DEATH_SCREEN")
                self.weaponIcon:SetIsVisible(false)

            else

                self.weaponIcon:SetIsVisible(true)        
                self.background:FadeIn(2, "FADE_DEATH_SCREEN")        

            end
            
        else
        
            self.background:FadeOut(0.5, "FADE_DEATH_SCREEN")
            self.weaponIcon:FadeOut(1.5, "FADE_DEATH_ICON")
            self.feintText:FadeOut(1.5, "FADE_DEATH_FEINT")
            
        end
        
    end
    
end
