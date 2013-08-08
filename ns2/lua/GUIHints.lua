// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIHints.lua
//
// Created by: Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kHintDuration = .25
local kHintAnimDuration = .3
local kHintFontSize = 22

local kGlobalHintDuration = 6
local kGlobalHintFontSize = GUIScale(26)

local kArrowTextureName = "ui/arrows.dds"
local kArrowIconHeight = 64
local kArrowIconWidth = 64

class 'GUIHints' (GUIAnimatedScript)

function GUIHints:Initialize()

    GUIAnimatedScript.Initialize(self)

    // directional hint
    self.hintMessage = ""
    self.timeOfHint = 0
    self.hintPriority = 0
    self.hintEntId = Entity.invalidId
    self.hintPosition = Vector(0, 0, 0)
    
    // global hint (text message at bottom of screen)
    self.globalHintPriority = 0
    
    self:CreateInfoHintText()

end

function GUIHints:Update(deltaTime)

    PROFILE("GUIHints:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)
    
    self:UpdateHint(deltaTime)
    
end

function GUIHints:GetIsDisplayingHint()
    return (self.hintTextItem ~= nil) and self.hintTextItem:GetIsVisible()
end

// Pickups can have up to one hint on the screen, which shows a more important message
// either in the middle of your HUD with an arrow pointing at the location, or as
// an in-world icon when you're looking at it.
//
// Hints go away after a time. They reset their time and are replaced by higher priority
// hints. If we're displaying a hint currently and add a hint of equal or lesser priority,
// ignore it.
//
// Pass either vector or an entity for the location. Can be called either on client or server.
// Hints expire immediately so are meant to be added every frame.
function GUIHints:AddHint(entId, localizedText, priority)

    local success = false

    // Don't create a new hint on an entity we're already displaying a hint for
    // (as we create new hints every frame, this would cause the hint to never
    // animate and reach target position)
    local ent = Shared.GetEntity(entId)
    if ent then

        local time = Shared.GetTime()
        if self.hintEntId == entId then
        
            // Update time of hint every frame so it doesn't expire
            self.timeOfHint = time
            
            self.hintTextItem:SetIsVisible(true)
            self.arrowGraphicItem:SetIsVisible(true)    
            
        elseif priority > self.hintPriority then    
        
            local position = ent:GetOrigin()
            if ent.GetModelOrigin then
                position = ent:GetModelOrigin()
            end
            
            self:CreateArrowGraphicItem(position)
            self:CreateHintTextItem(localizedText)            

            self.hintMessage = localizedText
            self.timeOfHint = time
            self.hintPriority = priority
            self.hintEntId = entId
            self.hintPosition = position
            
            // Play hint local sound
            local localPlayer = Client.GetLocalPlayer()
            Shared.PlaySound(localPlayer, Player.kTooltipSound)
            
            success = true
        end
            
    else
        Print("GUIHints:AddHint(%s, \"%s\", %s) - Couldn't find entity for message", ToString(entId), localizedText, ToString(priority))
    end            
        
    return success    
    
end
AddFunctionContract(GUIHints.AddHint, { Arguments = { "number", "string", "number" }, Returns = { "boolean" } })

// Adds a small "i" marker in the world which can optionally be investigated
function GUIHints:AddInfoHint(entId, localizedText)

    local success = false

    // Don't create a new hint on an entity we're already displaying a hint for
    // (as we create new hints every frame, this would cause the hint to never
    // animate and reach target position)
    local ent = Shared.GetEntity(entId)
    local player = Client.GetLocalPlayer()
    
    if ent then
    
        // Add info hint if we don't have one or if closer
        local entPosition = ent:GetOrigin()    
        
        // Position hint above entity so it works for stuff on the ground
        entPosition.y = entPosition.y + .5
        
        if player then

            if entId == self.infoHintId then
            
                self.originOfInfoHint = entPosition
                self.infoHintTextItem:SetText(localizedText)
                
            else

                local distToNewHint = (player:GetModelOrigin() - entPosition):GetLength()        
                if self.originOfInfoHint == nil or (distToNewHint < self.distToInfoHint) then
                
                    self.originOfInfoHint = entPosition
                    self.distToInfoHint = distToNewHint
                    self.infoHintId = entId
                    self.infoHintTextItem:SetText(localizedText)
                    
                    success = true
                    
                end
                
            end
            
        end
        
    else
        Print("GUIHints:AddInfoHint(%s, \"%s\") - Couldn't find entity for message", ToString(entId), localizedText)
    end
    
    return success
    
end
AddFunctionContract(GUIHints.AddInfoHint, { Arguments = { "number", "string"}, Returns = { "boolean" } })

// Add a hint that shows up in middle of screen, not at a position in world
// Can exist along-side positional hints. Should be relatively high-priority.
// Global hints are only added occasionally and go away after a few seconds.
// They are overriden by higher priority global hints. They time out after
// a few seconds.
function GUIHints:AddGlobalHint(localizedText, priority)

    local success = false
    
    if priority > self.globalHintPriority then
    
        self.globalHintPriority = priority

        if self.globalHintTextItem then
        
            self.globalHintTextItem:Destroy()
            self.globalHintTextItem = nil
            
        end

        self.globalHintTextItem = self:CreateAnimatedTextItem()
        self.globalHintTextItem:SetIsScaling(false)
        self.globalHintTextItem:SetFontSize(kGlobalHintFontSize)
        self.globalHintTextItem:SetAnchor(GUIItem.Left, GUIItem.Top)
        self.globalHintTextItem:SetTextAlignmentX(GUIItem.Align_Center)
        self.globalHintTextItem:SetTextAlignmentY(GUIItem.Align_Center)

        self.globalHintTextItem:SetPosition(Vector(Client.GetScreenWidth() / 2, Client.GetScreenHeight()*.9, 0))
        
        self.globalHintTextItem:SetFontIsBold(true)
        self.globalHintTextItem:SetText(localizedText)
        self.globalHintTextItem:SetIsVisible(true)
        
        // Fade in
        self.globalHintTextItem:SetColor(Color(0, 0, 0, 0))
        self.globalHintTextItem:SetColor(Color(1, 1, 1, 1), .5, nil, AnimateSin)
        
        self.timeOfGlobalHint = Shared.GetTime()

        success = true
        
    end
    
    return success
    
end
AddFunctionContract(GUIHints.AddGlobalHint, { Arguments = { "string", "number" }, Returns = { "boolean" } })

function GUIHints:CreateArrowGraphicItem(position)

    // delete current hint and save new one
    if self.arrowGraphicItem then
    
        self.arrowGraphicItem:Destroy()
        self.arrowGraphicItem = nil
        
    end

    self.arrowGraphicItem = self:CreateAnimatedGraphicItem()
    self.arrowGraphicItem:SetIsScaling(false)
    self.arrowGraphicItem:SetTexture(kArrowTextureName)
    self.arrowGraphicItem:SetIsVisible(true)    
    
end

function GUIHints:CreateHintTextItem(text)

    if self.hintTextItem then
    
        self.hintTextItem:Destroy()
        self.hintTextItem = nil
        
    end

    self.hintTextItem = self:CreateAnimatedTextItem()
    self.hintTextItem:SetIsScaling(false)
    self.hintTextItem:SetFontSize(kHintFontSize)
    self.hintTextItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.hintTextItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.hintTextItem:SetTextAlignmentY(GUIItem.Align_Center)
    self.hintTextItem:SetColor(Color(1, 1, 1, 1))
    self.hintTextItem:SetFontIsBold(true)
    self.hintTextItem:SetText(text)
    self.hintTextItem:SetIsVisible(true)
    
    // So it doesn't animate from 0,0
    self.hintTextItem:SetPosition(Vector(Client.GetScreenWidth()/2, Client.GetScreenHeight()/2, 0))
    
end

function GUIHints:CreateInfoHintText()

    if self.infoHintTextItem then
    
        self.infoHintTextItem:Destroy()
        self.infoHintTextItem = nil
        
    end
    
    self.infoHintTextItem = self:CreateAnimatedTextItem()
    self.infoHintTextItem:SetIsScaling(false)
    self.infoHintTextItem:SetFontSize(kHintFontSize)
    self.infoHintTextItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.infoHintTextItem:SetTextAlignmentY(GUIItem.Align_Center)
    self.infoHintTextItem:SetColor(Color(0, 0, 0, 0))
    self.infoHintTextItem:SetIsVisible(true)  
    
end

// Return screen position, as well as a bool indicating if position is near middle of screen, and bool indicating left
function ClassifyWorldPosition(worldPosition)

    local screenSpacePosition = Client.WorldToScreen(worldPosition)
    local nearCenterOfScreen = false
    
    // In each direction
    local kXExtents = .4
    local kYExtents = .5
    
    local screenWidth = Client.GetScreenWidth()
    local screenHeight = Client.GetScreenHeight()

    // Check to see if it's in front of us (because WorldToScreen doesn't distinguish behind us)
    local player = Client.GetLocalPlayer()
    local inFront = player:GetViewCoords().zAxis:DotProduct(GetNormalizedVector(worldPosition - player:GetEyePos())) > 0
    local left = player:GetViewCoords().xAxis:DotProduct(GetNormalizedVector(worldPosition - player:GetEyePos())) > 0
    
    // Is position outside of extents of center of screen?
    if  (inFront and 
        (screenSpacePosition.x > (screenWidth/2 - screenWidth*kXExtents)) and (screenSpacePosition.x < (screenWidth/2 + screenWidth*kXExtents)) and
        (screenSpacePosition.y > (screenHeight/2 - screenHeight*kYExtents)) and (screenSpacePosition.y < (screenHeight/2 + screenHeight*kYExtents)) ) then

        nearCenterOfScreen = true

    else
    
        screenSpacePosition.x = screenWidth/2
        // Adjust down a little so it doesn't overlap the reticle
        screenSpacePosition.y = screenHeight/2 + screenHeight * .25
        
    end
    
    return screenSpacePosition, nearCenterOfScreen, left
    
end

function GUIHints:UpdateHint(deltaTime)

    if self.hintTextItem and self.hintTextItem:GetIsVisible() then
    
        // If screen pos isn't near center of screen, draw text in center of screen
        local screenPos, nearCenter, left = ClassifyWorldPosition(self.hintPosition)

        if self.hintTextItem:GetText() ~= self.hintMessage then        
        
            self.hintTextItem:SetText(self.hintMessage)
            
            // So it doesn't animate from 0,0
            //self.hintTextItem:SetPosition(Vector(Client.GetScreenWidth()/2, Client.GetScreenHeight()/2, 0))

        end
        
        self.hintTextItem:DestroyAnimations()        
        self.hintTextItem:SetPosition(screenPos, .15, nil, AnimateSin)
        
        if not nearCenter then
        
            // In this case, draw an arrow pointing the direction that it is (using "left")            
            local textureIndex = ConditionalValue(left, 0, 1)
            self.arrowGraphicItem:SetTexturePixelCoordinates(0, textureIndex * kArrowIconHeight, kArrowIconWidth, (textureIndex + 1) * kArrowIconHeight)            
            
            // Put arrow text to hint text if visible
            local arrowScreenSize = self.hintTextItem:GetTextHeight(self.hintMessage)
            self.arrowGraphicItem:SetSize( Vector(arrowScreenSize, arrowScreenSize, 0) )
            
            local halfTextWidth = self.hintTextItem:GetTextWidth(self.hintMessage) / 2
            local hintTextPos = self.hintTextItem:GetPosition()
            
            if left then 
                hintTextPos.x = hintTextPos.x - halfTextWidth - arrowScreenSize
            else
                hintTextPos.x = hintTextPos.x + halfTextWidth
            end            
            hintTextPos.y = hintTextPos.y - arrowScreenSize/2
            
            self.arrowGraphicItem:SetPosition( hintTextPos )
            self.arrowGraphicItem:SetIsVisible(true)
            
        else
            self.arrowGraphicItem:SetIsVisible(false)
        end
        
        // Set both invisible if very close, so they don't overlap with GUIActionIcon
        local player = Client.GetLocalPlayer()
        if player and (player:GetEyePos() - self.hintPosition):GetLength() < kPlayerUseRange * 1.5 then
        
            if self.arrowGraphicItem then
                self.arrowGraphicItem:SetIsVisible(false)
            end
            
            if self.hintTextItem then
                self.hintTextItem:SetIsVisible(false)
            end
            
        end

    end
    
    if self.hintTextItem then

        local animate = (Shared.GetTime() > (self.timeOfHint + kHintDuration))
        if animate then

            self.arrowGraphicItem:DestroyAnimations()        
            self.arrowGraphicItem:SetColor(Color(0, 0, 0, 0), kHintAnimDuration, nil, AnimateSin)
            
            self.hintTextItem:DestroyAnimations()        
            self.hintTextItem:SetColor(Color(0, 0, 0, 0), kHintAnimDuration, nil, AnimateSin)            
            
        end

        // Delete hint after it expires
        local expired = (Shared.GetTime() > (self.timeOfHint + kHintDuration + kHintAnimDuration))
        if expired then

            self.arrowGraphicItem:Destroy()
            self.hintTextItem:Destroy()                
            
            self.arrowGraphicItem = nil
            self.hintTextItem = nil            
            
            self.hintMessage = ""
            self.hintEntId = Entity.invalidId
            self.hintPriority = 0
            
        end        
        
    end
    
    if self.globalHintTextItem then
    
        local animate = Shared.GetTime() > (self.timeOfGlobalHint + kGlobalHintDuration)
        if animate then
            self.globalHintTextItem:DestroyAnimations()
            self.globalHintTextItem:SetColor(Color(0, 0, 0, 0), kHintAnimDuration, nil, AnimateSin)
        end
        local expire = (Shared.GetTime() > (self.timeOfGlobalHint + kGlobalHintDuration + kHintAnimDuration))
        if expire then
        
            self.globalHintTextItem:Destroy()
            self.globalHintTextItem = nil
            self.globalHintPriority = 0
            
        end        
        
    end
    
    // Update position and visibility of info hint
    local player = Client.GetLocalPlayer()
    if self.originOfInfoHint and player then
    
        local toInfoHint = self.originOfInfoHint - player:GetEyePos()
        local inFront = player:GetViewCoords().zAxis:DotProduct(GetNormalizedVector(toInfoHint)) > 0
        
        // Set size
        self.distToInfoHint = toInfoHint:GetLength()
        
        // Now update info text
        local hintTextVisible = false
        if self.distToInfoHint < 10 then
        
            // If mouse cursor is over info hint, fade in hint text item
            //local x, y = Client.GetCursorPosScreen()
            hintTextVisible = inFront and (player:GetEyePos() - self.originOfInfoHint):GetLength() < 4
            
        end
        
        // If we're looking at it and nearby, fade in the extra text description otherwise fade it out
        self.infoHintTextItem:SetPosition(Client.WorldToScreen(self.originOfInfoHint))
        //Print("x/y: %.2f/%.2f", x, y)
                    
        if hintTextVisible then
            self.infoHintTextItem:DestroyAnimations()
            self.infoHintTextItem:SetColor(Color(1, 1, 1, 1), .2, nil, AnimateSin)
        else
            self.infoHintTextItem:DestroyAnimations()
            self.infoHintTextItem:SetColor(Color(0, 0, 0, 0), .4, nil, AnimateSin)
        end
        
    end
    
end