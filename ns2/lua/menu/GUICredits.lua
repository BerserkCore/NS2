// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUICredits.lua
//
//    Created by:   Steven An (steve@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Event.lua")

local kTextureName = "*credits_webpage_render"
local kURL = "http://unknownworlds.com/ns2/ingamecredits/"

class 'GUICredits' (GUIScript)

function GUICredits:Initialize()

    local width = 0.8 * Client.GetScreenWidth()
    local height = width * 9.0/16.0
    self.webView = Client.CreateWebView(width, height)
    self.webView:SetTargetTexture(kTextureName)
    self.webView:LoadUrl(kURL)
    
    self.webContainer = GUIManager:CreateGraphicItem()
    self.webContainer:SetSize(Vector(width, height, 0))
    self.webContainer:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.webContainer:SetPosition(Vector(-width/2, -height/2, 0))
    self.webContainer:SetTexture(kTextureName)
    self.webContainer:SetIsVisible(false)
    
    self.closeEvent = Event()
    self.closeEvent:Initialize()

    self.buttonDown = { [InputKey.MouseButton0] = false, [InputKey.MouseButton1] = false, [InputKey.MouseButton2] = false }
    
end

function GUICredits:SendKeyEvent(key, down, amount)

    local isScrollingKey = false
    
    if type(self.buttonDown[key]) == "boolean" then
        isScrollingKey = true
    end

    local mouseX, mouseY = Client.GetCursorPosScreen()
    if isScrollingKey then
    
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.webContainer, mouseX, mouseY)
        
        // If we pressed the button inside the window, always send it the button up
        // even if the cursor was outside the window.
        if containsPoint or (not down and self.buttonDown[key]) then
        
            local buttonCode = key - InputKey.MouseButton0
            if down then
                self.webView:OnMouseDown(buttonCode)
            else
                self.webView:OnMouseUp(buttonCode)
            end
            
            self.buttonDown[key] = down
            
            return true
            
        end

    elseif key == InputKey.Escape then

        GetGUIManager():DestroyGUIScript(self)
        self.closeEvent:Trigger()

        return true
            
    end
    
    return false
end

function GUICredits:Uninitialize()

    GUI.DestroyItem(self.webContainer)
    self.webContainer = nil
    
    Client.DestroyWebView(self.webView)
    self.webView = nil
    
end

function GUICredits:Update()

    // don't show until the URL is loaded
    if not self.webContainer:GetIsVisible() then
        if self.webView:GetUrlLoaded() then
            self.webContainer:SetIsVisible(true)
        end
    end

    local mouseX, mouseY = Client.GetCursorPosScreen()
    local containsPoint, withinX, withinY = GUIItemContainsPoint(self.webContainer, mouseX, mouseY)
    if containsPoint or self.buttonDown[InputKey.MouseButton0] or self.buttonDown[InputKey.MouseButton1] or self.buttonDown[InputKey.MouseButton2] then
        self.webView:OnMouseMove(withinX, withinY)
    end

end
