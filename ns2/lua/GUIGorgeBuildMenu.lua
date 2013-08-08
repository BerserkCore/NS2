// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIGorgeBuildMenu.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

local kMouseOverSound = "sound/NS2.fev/alien/common/alien_menu/hover"
local kSelectSound = "sound/NS2.fev/alien/common/alien_menu/evolve"
local kCloseSound = "sound/NS2.fev/alien/common/alien_menu/sell_upgrade"
local kFontName = "fonts/AgencyFB_small.fnt"
Client.PrecacheLocalSound(kMouseOverSound)
Client.PrecacheLocalSound(kSelectSound)
Client.PrecacheLocalSound(kCloseSound)

function GorgeBuild_OnClose()
    Shared.PlaySound(nil, kCloseSound)
end

function GorgeBuild_OnSelect()
    Shared.PlaySound(nil, kSelectSound)
end

function GorgeBuild_OnMouseOver()
    Shared.PlaySound(nil, kMouseOverSound)
end

function GorgeBuild_Close()
    local player = Client.GetLocalPlayer()
    
    local activeWeapon = player:GetActiveWeapon()
    
    if activeWeapon.DestroyBuildMenu then
        activeWeapon:DestroyBuildMenu()
    end    
end

function GorgeBuild_SendSelect(index)

    local player = Client.GetLocalPlayer()

    if player then
    
        local dropStructureAbility = player:GetWeapon(DropStructureAbility.kMapName)
        if dropStructureAbility then
            dropStructureAbility:SetActiveStructure(index)
        end
        
    end
    
end

function GorgeBuild_GetIsAbilityAvailable(index)

    return DropStructureAbility.kSupportedStructures[index] and DropStructureAbility.kSupportedStructures[index]:IsAllowed(Client.GetLocalPlayer())

end

function GorgeBuild_AllowConsumeDrop(techId)
    return LookupTechData(techId, kTechDataAllowConsumeDrop, false)
end

function GorgeBuild_GetCanAffordAbility(techId)

    local player = Client.GetLocalPlayer()
    local abilityCost = LookupTechData(techId, kTechDataCostKey, 0)
    local exceededLimit = not GorgeBuild_AllowConsumeDrop(techId) and GorgeBuild_GetNumStructureBuilt(techId) >= GorgeBuild_GetMaxNumStructure(techId)

    return player:GetResources() >= abilityCost and not exceededLimit

end

function GorgeBuild_GetStructureCost(techId)
    return LookupTechData(techId, kTechDataCostKey, 0)
end

local function GorgeBuild_GetKeybindForIndex(index)
    return "Weapon" .. ToString(index)
end

function GorgeBuild_GetNumStructureBuilt(techId)

    local player = Client.GetLocalPlayer()
    local ability = player:GetActiveWeapon()
    
    if ability and ability:isa("DropStructureAbility") then
        return ability:GetNumStructuresBuilt(techId)
    end
    
    return -1

end

function GorgeBuild_GetMaxNumStructure(techId)

    return LookupTechData(techId, kTechDataMaxAmount, -1)

end

class 'GUIGorgeBuildMenu' (GUIAnimatedScript)

GUIGorgeBuildMenu.kBaseYResolution = 1200

GUIGorgeBuildMenu.kButtonWidth = 180
GUIGorgeBuildMenu.kButtonHeight = 180

GUIGorgeBuildMenu.kBackgroundYOffset = GUIGorgeBuildMenu.kButtonHeight * 0.5

GUIGorgeBuildMenu.kButtonTexture = "ui/gorge_build_menu.dds"
GUIGorgeBuildMenu.kBuyMenuTexture = "ui/alien_buymenu.dds"
GUIGorgeBuildMenu.kSmokeSmallTextureCoordinates = { { 916, 4, 1020, 108 }, { 916, 15, 1020, 219 }, { 916, 227, 1020, 332 }, { 916, 332, 1020, 436 } }

GUIGorgeBuildMenu.kPixelSize = 128

GUIGorgeBuildMenu.kAvailableColor = kAlienTeamColorFloat
GUIGorgeBuildMenu.kTooExpensiveColor = Color(1, 0, 0, 1)
GUIGorgeBuildMenu.kUnavailableColor = Color(0.4, 0.4, 0.4, 0.7)

// selection circle animation:
GUIGorgeBuildMenu.kPulseInAnimationDuration = 0.6
GUIGorgeBuildMenu.kPulseOutAnimationDuration = 0.3
GUIGorgeBuildMenu.kLowColor = Color(1, 0.4, 0.4, 0.5)
GUIGorgeBuildMenu.kHighColor = Color(1, 1, 1, 1)

GUIGorgeBuildMenu.kPersonalResourceIcon = { Width = 0, Height = 0, X = 0, Y = 0, Coords = { X1 = 144, Y1 = 363, X2 = 192, Y2 = 411} }
GUIGorgeBuildMenu.kPersonalResourceIcon.Width = 32
GUIGorgeBuildMenu.kPersonalResourceIcon.Height = 32
GUIGorgeBuildMenu.kResourceTexture = "ui/alien_commander_textures.dds"
GUIGorgeBuildMenu.kIconTextXOffset = 5

local kBackgroundNoiseTexture = "ui/alien_commander_bg_smoke.dds"
local kSmokeyBackgroundSize = GUIScale(Vector(220, 400, 0))

local kDefaultStructureCountPos = Vector(-48, -24, 0)
local kCenteredStructureCountPos = Vector(0, -24, 0)

//selection circle animation callbacks
function PulseOutAnimation(script, item)
    item:SetColor(GUIGorgeBuildMenu.kHighColor, GUIGorgeBuildMenu.kPulseInAnimationDuration, "PULSE", AnimateLinear, PulseInAnimation)
end

function PulseInAnimation(script, item)
    item:SetColor(GUIGorgeBuildMenu.kLowColor, GUIGorgeBuildMenu.kPulseOutAnimationDuration, "PULSE", AnimateLinear, PulseOutAnimation)
end

local rowTable = nil
local function GetRowForTechId(techId)

    if not rowTable then
    
        rowTable = {}
        rowTable[kTechId.Hydra] = 1
        rowTable[kTechId.Clog] = 3
    
    end
    
    return rowTable[techId]

end

function GUIGorgeBuildMenu:Initialize()

    GUIAnimatedScript.Initialize(self)

    self.scale = Client.GetScreenHeight() / GUIGorgeBuildMenu.kBaseYResolution
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    self.buttons = {}
    
    self:Reset()

end

function GUIGorgeBuildMenu:Uninitialize()
    
    GUIAnimatedScript.Uninitialize(self)

end

function GUIGorgeBuildMenu:_HandleMouseOver(onItem)
    
    if onItem ~= self.lastActiveItem then
        GorgeBuild_OnMouseOver()
        self.lastActiveItem = onItem
    end
    
end

local function UpdateButton(button, index)

    local col = 1
    local color = GUIGorgeBuildMenu.kAvailableColor

    if not GorgeBuild_GetCanAffordAbility(button.techId) then
        col = 2
        color = GUIGorgeBuildMenu.kTooExpensiveColor
    end
    
    if not GorgeBuild_GetIsAbilityAvailable(index) then
        col = 3
        color = GUIGorgeBuildMenu.kUnavailableColor
    end
    
    local row = GetRowForTechId(button.techId)
   
    button.graphicItem:SetTexturePixelCoordinates(GUIGetSprite(col, row, GUIGorgeBuildMenu.kPixelSize, GUIGorgeBuildMenu.kPixelSize))
    button.description:SetColor(color)
    button.costIcon:SetColor(color)
    button.costText:SetColor(color)

    local numLeft = GorgeBuild_GetNumStructureBuilt(button.techId)
    if numLeft == -1 then
        button.structuresLeft:SetIsVisible(false)
    else
        button.structuresLeft:SetIsVisible(true)
        local amountString = ToString(numLeft)
        local maxNum = GorgeBuild_GetMaxNumStructure(button.techId)
        
        if maxNum > 0 then
            amountString = amountString .. "/" .. ToString(maxNum)
        end
        
        if numLeft >= maxNum then
            color = GUIGorgeBuildMenu.kTooExpensiveColor
        end
        
        button.structuresLeft:SetColor(color)
        button.structuresLeft:SetText(amountString)
        
    end    
    
    local cost = GorgeBuild_GetStructureCost(button.techId)
    if cost == 0 then        
    
        button.costIcon:SetIsVisible(false)
        button.structuresLeft:SetPosition(kCenteredStructureCountPos)
        
    else
    
        button.costIcon:SetIsVisible(true)
        button.costText:SetText(ToString(cost))
        button.structuresLeft:SetPosition(kDefaultStructureCountPos)
        
        
    end
    
    
end



function GUIGorgeBuildMenu:Update(deltaTime)

    GUIAnimatedScript.Update(self, deltaTime)
    
    for index, button in ipairs(self.buttons) do
        
        UpdateButton(button, index)
        
        if self:_GetIsMouseOver(button.graphicItem) then
            self:_HandleMouseOver(button.graphicItem)
        end
       
    end

end

function GUIGorgeBuildMenu:Reset()
    
    self.background:SetUniformScale(self.scale)

    for index, structureAbility in ipairs(DropStructureAbility.kSupportedStructures) do
    
        // TODO: pass keybind from options instead of index
        table.insert( self.buttons, self:CreateButton(structureAbility.GetDropStructureId(), self.scale, self.background, GorgeBuild_GetKeybindForIndex(index), index - 1) )
    
    end
    
    local backgroundXOffset = (#self.buttons * GUIGorgeBuildMenu.kButtonWidth) * -.5
    self.background:SetPosition(Vector(backgroundXOffset, GUIGorgeBuildMenu.kBackgroundYOffset, 0))
    
end

function GUIGorgeBuildMenu:OnResolutionChanged(oldX, oldY, newX, newY)

    self.scale = newY / GUIGorgeBuildMenu.kBaseYResolution
    self:Reset()

end

function GUIGorgeBuildMenu:CreateButton(techId, scale, frame, keybind, position)

    local button =
    {
        frame = self:CreateAnimatedGraphicItem(),
        background = self:CreateAnimatedGraphicItem(),
        graphicItem = self:CreateAnimatedGraphicItem(),
        description = self:CreateAnimatedTextItem(),
        keyIcon = GUICreateButtonIcon(keybind, true),
        keybind = keybind,
        techId = techId,
        structuresLeft = self:CreateAnimatedTextItem(),
        costIcon = self:CreateAnimatedGraphicItem(),
        costText = self:CreateAnimatedTextItem(),
    }
    
    local smokeyBackground = GetGUIManager():CreateGraphicItem()
    smokeyBackground:SetAnchor(GUIItem.Middle, GUIItem.Center)
    smokeyBackground:SetSize(kSmokeyBackgroundSize)    
    smokeyBackground:SetPosition(kSmokeyBackgroundSize * -.5)
    smokeyBackground:SetShader("shaders/GUISmokeHUD.surface_shader")
    smokeyBackground:SetTexture("ui/alien_logout_smkmask.dds")
    smokeyBackground:SetAdditionalTexture("noise", kBackgroundNoiseTexture)
    smokeyBackground:SetFloatParameter("correctionX", 0.6)
    smokeyBackground:SetFloatParameter("correctionY", 1)
    
    button.frame:SetUniformScale(scale)
    button.frame:SetSize(Vector(GUIGorgeBuildMenu.kButtonWidth, GUIGorgeBuildMenu.kButtonHeight, 0))
    button.frame:SetColor(Color(1,1,1,0))
    button.frame:SetPosition(Vector(position * GUIGorgeBuildMenu.kButtonWidth, 0, 0))
    frame:AddChild(button.frame)
    
    button.background:SetUniformScale(scale)
    button.graphicItem:SetUniformScale(scale)    
    button.frame:AddChild(button.background)
    
    button.description:SetUniformScale(scale) 
    
    button.background:SetSize(Vector(GUIGorgeBuildMenu.kButtonWidth, GUIGorgeBuildMenu.kButtonHeight * 1.5, 0))
    button.background:SetColor(Color(0,0,0,0))
    
    button.graphicItem:SetSize(Vector(GUIGorgeBuildMenu.kButtonWidth, GUIGorgeBuildMenu.kButtonHeight, 0))
    button.graphicItem:SetTexture(GUIGorgeBuildMenu.kButtonTexture)
    button.graphicItem:SetShader("shaders/GUIWavyNoMask.surface_shader")
     
    //button.description:SetText(LookupTechData(techId, kTechDataDisplayName, "") .. " (".. keybind ..")")
    button.description:SetText(Locale.ResolveString(LookupTechData(techId, kTechDataDisplayName, "")))
    button.description:SetAnchor(GUIItem.Middle, GUIItem.Top)
    button.description:SetTextAlignmentX(GUIItem.Align_Center)
    button.description:SetTextAlignmentY(GUIItem.Align_Center)
    button.description:SetFontSize(22)
    button.description:SetFontName(kFontName)
    button.description:SetPosition(Vector(0, 0, 0))
    button.description:SetFontIsBold(true)
    
    button.keyIcon:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    button.keyIcon:SetFontName(kFontName)
    local pos = Vector(-button.keyIcon:GetSize().x/2, 0.5*button.keyIcon:GetSize().y, 0)
    button.keyIcon:SetPosition(pos)
    
    button.structuresLeft:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    button.structuresLeft:SetTextAlignmentX(GUIItem.Align_Center)
    button.structuresLeft:SetTextAlignmentY(GUIItem.Align_Center)
    button.structuresLeft:SetFontSize(28)
    button.structuresLeft:SetFontName(kFontName)
    button.structuresLeft:SetPosition(kDefaultStructureCountPos)
    button.structuresLeft:SetFontIsBold(true)
    button.structuresLeft:SetColor(GUIGorgeBuildMenu.kAvailableColor)
    
    // Personal display.
    button.costIcon:SetSize(Vector(GUIGorgeBuildMenu.kPersonalResourceIcon.Width, GUIGorgeBuildMenu.kPersonalResourceIcon.Height, 0))
    button.costIcon:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    button.costIcon:SetTexture(GUIGorgeBuildMenu.kResourceTexture)
    button.costIcon:SetPosition(Vector(0, -GUIGorgeBuildMenu.kPersonalResourceIcon.Height * .5 - 24, 0))
    button.costIcon:SetUniformScale(scale)
    GUISetTextureCoordinatesTable(button.costIcon, GUIGorgeBuildMenu.kPersonalResourceIcon.Coords)

    button.costText:SetUniformScale(scale)
    button.costText:SetAnchor(GUIItem.Right, GUIItem.Center)
    button.costText:SetTextAlignmentX(GUIItem.Align_Min)
    button.costText:SetTextAlignmentY(GUIItem.Align_Center)
    button.costText:SetPosition(Vector(GUIGorgeBuildMenu.kIconTextXOffset, 0, 0))
    button.costText:SetColor(Color(1, 1, 1, 1))
    button.costText:SetFontIsBold(true)    
    button.costText:SetFontSize(28)
    button.costText:SetFontName(kFontName)
    button.costText:SetColor(GUIGorgeBuildMenu.kAvailableColor)
    button.costIcon:AddChild(button.costText)
    
    button.background:AddChild(smokeyBackground)
    button.background:AddChild(button.graphicItem)    
    button.graphicItem:AddChild(button.description)
    button.graphicItem:AddChild(button.structuresLeft)
    button.graphicItem:AddChild(button.keyIcon)   
    button.graphicItem:AddChild(button.costIcon)

    return button

end

function GUIGorgeBuildMenu:OverrideInput(input)

    local closeMenu = false

    local weaponSwitchCommands = { Move.Weapon1, Move.Weapon2, Move.Weapon3, Move.Weapon4, Move.Weapon5 }
    for index, weaponSwitchCommand in ipairs(weaponSwitchCommands) do
    
        if bit.band(input.commands, weaponSwitchCommand) ~= 0 then

            if GorgeBuild_GetIsAbilityAvailable(index) and GorgeBuild_GetCanAffordAbility(self.buttons[index].techId)  then
                GorgeBuild_SendSelect(index)
                local removeWeaponMask = bit.bxor(0xFFFFFFFF, weaponSwitchCommand)
                input.commands = bit.band(input.commands, removeWeaponMask)
            end
            
            closeMenu = true
            
            break
            
        end
        
    end  
    
    if closeMenu then
        self:OnClose()
        GorgeBuild_Close()
    end

    // small hack: secondary attack causes switch to previous weapon. since we dont know here which was the previous weapon, we treat primary attack in this frame
    // as a secondary to trigger the weapon switch
    
    if bit.band(input.commands, Move.PrimaryAttack) ~= 0 then
        input.commands = bit.bor(input.commands, Move.SecondaryAttack)
    end
    
    local removePrimaryAttackMask = bit.bxor(0xFFFFFFFF, Move.PrimaryAttack)
    input.commands = bit.band(input.commands, removePrimaryAttackMask)

    return input

end

function GUIGorgeBuildMenu:_GetIsMouseOver(overItem)

    return GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    
end

function GUIGorgeBuildMenu:OnClose()

    GorgeBuild_OnClose()

end

function GUIGorgeBuildMenu:OnAnimationCompleted(animatedItem, animationName, itemHandle)
end

// called when the last animation remaining has completed this frame
function GUIGorgeBuildMenu:OnAnimationsEnd(item)
end