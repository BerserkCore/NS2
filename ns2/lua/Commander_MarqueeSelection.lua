// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Commander_MarqueeSelection.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

assert(Client)

local selectorCursorDown = false
local selectorStartX = 0
local selectorStartY = 0

function GetIsCommanderMarqueeSelectorDown()
    return selectorCursorDown
end

local selectorInfo = { }
function GetCommanderMarqueeSelectorInfo()

    selectorInfo.startX = selectorStartX
    selectorInfo.startY = selectorStartY
    local mousePos = MouseTracker_GetCursorPos()
    selectorInfo.endX = mousePos.x
    selectorInfo.endY = mousePos.y
    return selectorInfo
    
end

function SetCommanderMarqueeeSelectorDown(mouseX, mouseY)

    if selectorCursorDown == true then
        return
    end
    
	selectorCursorDown = true
	
	selectorStartX = mouseX
	selectorStartY = mouseY
    
end

function SetCommanderMarqueeeSelectorUp(mouseX, mouseY)

	if selectorCursorDown ~= true then
	    return
	end
	
	selectorCursorDown = false
	
	local player = Client.GetLocalPlayer()
	
	// Create normalized coords which can be used on client and server
    local pickStartVec = CreatePickRay(player, selectorStartX, selectorStartY)
    local pickEndVec = CreatePickRay(player, mouseX, mouseY)
    
    // Process selection locally.
    local didSelectEntities = player:MarqueeSelectEntities(pickStartVec, pickEndVec)
    
    // Don't bother sending the message to the server if nothing was selected on the client.
    if didSelectEntities then
    
        local message = BuildMarqueeSelectCommand(pickStartVec, pickEndVec)
        Client.SendNetworkMessage("MarqueeSelect", message, true)
        
    end
    
end