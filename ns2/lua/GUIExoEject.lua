//======= Copyright (c) 2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIExoEject.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kButtonPos = GUIScale(Vector(180, - 120, 0))
local kTextOffset = GUIScale(Vector(0, 20, 0))

local kFontName = "fonts/AgencyFB_small.fnt"
local kFontScale = GUIScale(Vector(1, 1, 1))

class 'GUIExoEject' (GUIScript)

function GUIExoEject:Initialize()

    self.button = GUICreateButtonIcon("Drop")
    self.button:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    self.button:SetPosition(kButtonPos - self.button:GetSize() * 0.5)
    
    self.text = GetGUIManager():CreateTextItem()
    self.text:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.text:SetTextAlignmentX(GUIItem.Align_Center)
    self.text:SetTextAlignmentY(GUIItem.Align_Center)
    self.text:SetText(Locale.ResolveString("EJECT_FROM_EXO"))
    self.text:SetPosition(kTextOffset)
    self.text:SetScale(kFontScale)
    self.text:SetFontName(kFontName)
    self.text:SetColor(kMarineFontColor)

    self.button:AddChild(self.text)
    self.button:SetIsVisible(false)

end


function GUIExoEject:Uninitialize()

    if self.button then
        GUI.DestroyItem(self.button)
    end

end

function GUIExoEject:Update(deltaTime)

    local player = Client.GetLocalPlayer()
    local showEject = player ~= nil and Client.GetIsControllingPlayer() and player:GetCanEject()
    
    self.button:SetIsVisible(showEject)

end