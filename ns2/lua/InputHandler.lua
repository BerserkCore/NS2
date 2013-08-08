// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\InputHandler.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// The ConsoleBindings.lua ConsoleBindingsKeyPressed function is used below.
// It is possible for the OnSendKeyEvent function below to be called
// before ConsoleBindings.lua is loaded so make sure to load it here.
Script.Load("lua/ConsoleBindings.lua")
Script.Load("lua/menu/MouseTracker.lua")

local keyEventBlocker = nil

function SetKeyEventBlocker(setKeyEventBlocker)
    keyEventBlocker = setKeyEventBlocker
end

// Return true if the event should be stopped here.
local function OnSendKeyEvent(key, down)

    local stop = MouseTracker_SendKeyEvent(key, down, keyEventBlocker ~= nil)
    
    if keyEventBlocker then
        return keyEventBlocker:SendKeyEvent(key, down)
    end
    
    if not stop then
    
        local player = Client.GetLocalPlayer()
        if player then
            stop = player:SendKeyEvent(key, down)
        end
        
    end
    
    if not stop then
        stop = GetGUIManager():SendKeyEvent(key, down)
    end

    if not stop then
    
        local winMan = GetWindowManager()
        if winMan then
            stop = winMan:SendKeyEvent(key, down)
        end
        
    end
    
    if not stop and down then
        ConsoleBindingsKeyPressed(key)
    end
    
    return stop
    
end

// Return true if the event should be stopped here.
local function OnSendCharacterEvent(character)

    local stop = false
    
    local winMan = GetWindowManager()
    if winMan then
        stop = winMan:SendCharacterEvent(character)
    end
    
    if not stop then
        stop = GetGUIManager():SendCharacterEvent(character)
    end
    
    return stop
    
end

Event.Hook("SendKeyEvent", OnSendKeyEvent)
Event.Hook("SendCharacterEvent", OnSendCharacterEvent)