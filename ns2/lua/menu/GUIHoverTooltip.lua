// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIHoverTooltip.lua
//
//    Created by:   Brian Arneson (samusdroid@gmail.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local fadeColor = Color(1,1,1,0)
local lastUpdatedtime = 0
local playAnimation = ""
local flipPosition = false
local kCoordinates = { 265, 0, 1023, 98 }
local kCrosshairCoordinates = { 0, 0, 64, 512 }
local gbackgroundCoordinates = 0

class 'GUIHoverTooltip' (GUIScript)

function GUIHoverTooltip:Initialize()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(300, 55, 0))
    self.background:SetTexture("ui/insight_resources.dds")
    self.background:SetTexturePixelCoordinates(unpack(kCoordinates))
    self.background:SetColor(fadeColor)
    self.background:SetLayer(kGUILayerOptionsTooltips)
    
    self.tooltip = GUIManager:CreateTextItem()
    self.tooltip:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.tooltip:SetPosition(Vector(15, 0, 0))
    self.tooltip:SetFontName("fonts/AgencyFB_tiny.fnt")
    self.tooltip:SetTextAlignmentX(GUIItem.Align_Min)
    self.tooltip:SetTextAlignmentY(GUIItem.Align_Center)
    self.tooltip:SetColor(fadeColor)
    self.tooltip:SetText("")
    self.background:AddChild(self.tooltip)
    
    self.isVisible = false

end

function GUIHoverTooltip:Uninitialize()
    GUI.DestroyItem(self.background)
    self.background = nil
    
    GUI.DestroyItem(self.tooltip)
    self.tooltip = nil
    
end

function GUIHoverTooltip:Update(deltaTime)

	if fadeColor.a <= 0 then
		self:SetIsVisible(false)
	elseif fadeColor.a > 0 then
		self:SetIsVisible(true)
	end
	
    self:PlayFadeAnimation()
    
    if self.tooltip:GetText() ~= "" then
	    playAnimation = "show"
	else
	    playAnimation = "hide"
	end
    
    if flipPosition == true then
        local mouseX, mouseY = Client.GetCursorPosScreen()
	    self.background:SetPosition(Vector(mouseX - 280, mouseY + gbackgroundCoordinates, 0))
	else
	    local mouseX, mouseY = Client.GetCursorPosScreen()
        self.background:SetPosition(Vector(mouseX + 20, mouseY + gbackgroundCoordinates, 0))
	end
	
end

function GUIHoverTooltip:SendKeyEvent(key, down)

	if key == InputKey.Escape then
        playAnimation = "hide"
		self.tooltip:SetText("")
	end
    
end

function GUIHoverTooltip:SetIsVisible(visible)
    self.background:SetIsVisible(visible)
    self.tooltip:SetIsVisible(visible)
    self.isVisible = visible
end

function GUIHoverTooltip:ShowAnimation()

	if fadeColor.a <= 1 and Shared.GetTime() - lastUpdatedtime > 0.0025 then
		fadeColor.a = fadeColor.a + 0.075
		self.background:SetColor(fadeColor)
		self.tooltip:SetColor(fadeColor)
		lastUpdatedtime = Shared.GetTime()
	end

end

function GUIHoverTooltip:HideAnimation()

	if fadeColor.a >= 0 and Shared.GetTime() - lastUpdatedtime > 0.0025 then
		fadeColor.a = fadeColor.a - 0.075
		self.background:SetColor(fadeColor)
		self.tooltip:SetColor(fadeColor)
		lastUpdatedtime = Shared.GetTime()
	end
   
end
function GUIHoverTooltip:PlayFadeAnimation()

	if playAnimation == "show" then
		self:ShowAnimation()
	elseif playAnimation == "hide" then
		self:HideAnimation()
	end
   
end

function GUIHoverTooltip:SetPlayAnimation(animType)
    playAnimation = animType
end

function GUIHoverTooltip:FlipPosition(value)
    flipPosition = value
end

function GUIHoverTooltip:SetCrosshair(value)
	if value ~= "" then
		self.background:SetSize(Vector(64, 512, 0))
		self.background:SetTexture(value)
		self.background:SetTexturePixelCoordinates(unpack(kCrosshairCoordinates))
		gbackgroundCoordinates = -512
	elseif value == "" then
		self.background:SetSize(Vector(275, 55, 0))
		self.background:SetTexture("ui/insight_resources.dds")
		self.background:SetTexturePixelCoordinates(unpack(kCoordinates))
		gbackgroundCoordinates = 0
	end
end