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
    
    self.prevMouseDown = false
    self.closeEvent = Event()
    self.closeEvent:Initialize()
    
end

function GUICredits:SendKeyEvent(key, down, amount)

    if key == InputKey.MouseButton0 and down ~= self.prevMouseDown then

        self.prevMouseDown = down
    
        local mouseX, mouseY = Client.GetCursorPosScreen()
        local containsPoint = GUIItemContainsPoint(self.webContainer, mouseX, mouseY)
        
        if containsPoint then
        
            if down then
            Print("down")
                self.webView:OnMouseDown(0)
            else
            Print("up")
                self.webView:OnMouseUp(0)
            end
            
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

