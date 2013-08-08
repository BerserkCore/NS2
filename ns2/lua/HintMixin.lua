// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\HintMixin.lua
//
// Pickups can have up to one hint on the screen, which shows a more important message
// either in the middle of your HUD with an arrow pointing at the location, or as
// an in-world icon when you're looking at it.
//
// Hints go away after a time. They reset their time and are replaced by higher priority
// hints. If we're displaying a hint currently and add a hint of equal or lesser priority,
// ignore it.
//
// Assumes host of mixin is a player (needed for sending/receiving network messages).
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/FunctionContracts.lua")

HintMixin = CreateMixin( HintMixin )
HintMixin.type = "Hint"

HintMixin.kSentExpireTime = 10

if Client then
HintMixin.expectedCallbacks = {
    AddHint = "Adds a hint to display - location (origin), localizableText (string), priority(integer)",
    AddGlobalHint = "Adds a text hint at bottom of display - localizableText (string), priority(integer)",
}
end

////////////
// Shared //
////////////
local kHintMessage =
{
    message = string.format("string (%d)", 64),
    location = "vector",
    priority = "integer (0 to 10)",    
}
Shared.RegisterNetworkMessage( "AddHint", kHintMessage )

local kGlobalHintMessage = 
{
    message = string.format("string (%d)", 64),
    priority = "integer (0 to 10)",
}
Shared.RegisterNetworkMessage( "AddGlobalHint", kGlobalHintMessage )

function HintMixin:__initmixin()

    assert(self:isa("Player"))
    
    self.displayedHints = {}
    self.timeSinceUpdate = 0
    
end

local function GetCanDisplayHint(self, hintText, timeInterval, onlyOnce)

    ASSERT(type(hintText) == "string")
    
    if Shared.GetIsRunningPrediction() then
        return false
    end
    
    local currentTime = Shared.GetTime()
    
    // Return false if we've recently added any tooltip
    if onlyOnce and self.timeOfLastTooltip ~= nil and currentTime < (self.timeOfLastTooltip + self:GetMixinConstants().kHintInterval) then
        return false
    end
    
    // Return false if we've too recently shown this particular tooltip
    for index, entity in ipairs(self.displayedTooltips) do
    
        //self.displayedHints, {location, localizableText, Shared.GetTime(), priority}
        if hintText == entity[2] then
        
            if onlyOnce or timeInterval == nil or (currentTime < entity[3] + timeInterval) then
                return false
            end
            
        end
        
    end
    
    return true
    
end
AddFunctionContract(GetCanDisplayHint, { Arguments = { "Entity", "string", { "number", "nil" } }, Returns = { "boolean" } })

////////////
// Server //
////////////
if Server then

// If we have a recent hint with the same text and near location, don't sent
/*function HintMixin:GetRecentlySentHint(location, localizableText)

    for index, triple in ipairs(self.sentHints) do
    
        assert(type(triple[2]) == "string")
        
        if triple[2] == localizableText then
        
            assert(type(location) == "userdata")
            assert(location:isa("Vector"))
            
            assert(type(triple[1]) == "userdata")
            assert(triple[1]:isa("Vector"))
            
            // Check distance to see if hint is the same hint
            local distance = (location - triple[1]):GetLength()
            if distance < .5 then
            
                return true
                
            end
            
        end
        
    end
    
    return false
    
end*/

// Pass either vector or an entity for the location. Can be called either on client or server.
function HintMixin:SendHint(location, localizableText, priority, timeInterval, onlyOnce)

    // TODO: Don't send hint if lower priority than recently sent hint    
    if GetCanDisplayHint(self, localizableText, timeInterval, onlyOnce) then
    
        local message = BuildHintMessage(location, localizableText, priority)
        
        Server.SendNetworkMessage(self, "AddHint", message, true)
        
        // Save hint and time sent
        table.insert(self.displayedHints, {location, localizableText, Shared.GetTime(), priority})
        
    end
        
end
AddFunctionContract(HintMixin.SendHint, { Arguments = { "userdata", "userdata", "string", "number" }, Returns = { "boolean" } })

function HintMixin:SendGlobalHint(localizableText, priority)

    local message = BuildGlobalHintMessage(localizableText, priority)
    
    Server.SendNetworkMessage(self, "AddGlobalHint", message, true)
    
end
AddFunctionContract(HintMixin.SendGlobalHint, { Arguments = { "userdata", "string", "number" }, Returns = { "boolean" } })


/*function HintMixin:ExpireSentHints()

    PROFILE("HintMixin:ExpireSentHints")
    
    local time = Shared.GetTime()
    
    function expireOldHint(triple)
        return time > (triple[3] + HintMixin.kSentExpireTime)
    end
        
    table.removeConditional(self.displayedHints, expireOldHint)

end*/

/*
function HintMixin:OnUpdate(deltaTime)

    // Expire recently sent hints
    self.timeSinceUpdate = self.timeSinceUpdate + deltaTime
    
    if self.timeSinceUpdate > .5 then
    
        self:ExpireSentHints()
        self.timeSinceUpdate = self.timeSinceUpdate - .5
        
    end
    
end
*/

function BuildHintMessage(location, message, priority)

    local t = {}
    
    assert(type(message) == "string")
    assert(type(location) == "userdata")
    assert(type(priority) == "number")
    
    t.message = message
    t.location = location
    t.priority = priority
    
    return t
    
end

function BuildGlobalHintMessage(message, priority)

    local t = {}
    
    assert(type(message) == "string")
    assert(type(priority) == "number")
    
    t.message = message
    t.priority = priority
    
    return t
    
end

end

////////////
// Client //
////////////
if Client then
function HintMixin:ReceiveHint(location, localizeableText, priority)
    self:AddHint(location, localizeableText, priority)
end
AddFunctionContract(HintMixin.ReceiveHint, { Arguments = { "userdata", "string", "number" }, Returns = { "boolean" } })

function ParseHintMessage(hint)

    assert(hint ~= nil)
    assert(type(hint) == "table")
    
    return hint.location, hint.message, hint.priority
    
end

function HintMixin:ReceiveGlobalHint(localizedText, priority)
    self:AddGlobalHint(localizedText, priority)
end
AddFunctionContract(HintMixin.ReceiveGlobalHint, { Arguments = { "string", "number" }, Returns = { "boolean" } })

function ParseGlobalHintMessage(hint)

    assert(hint ~= nil)
    assert(type(hint) == "table")
    
    return hint.message, hint.priority
    
end

function OnCommandAddHint(hintTable)

    // Parse out message, location and priority      
    local location, localizeableMessage, priority = ParseHintMessage(hintTable)
    
    local player = Client.GetLocalPlayer()
    if player then
    
        assert(HasMixin(player, "Hint"))
        
        player:ReceiveHint(location, localizeableMessage, priority)
        
    end
    
end

function OnCommandAddGlobalHint(hintTable)

    // Parse out message, location and priority      
    local localizeableMessage, priority = ParseGlobalHintMessage(hintTable)
    
    local player = Client.GetLocalPlayer()
    if player then
    
        assert(HasMixin(player, "Hint"))

        player:ReceiveGlobalHint(localizeableMessage, priority)
        
    end
    
end

Client.HookNetworkMessage("AddHint",            OnCommandAddHint)
Client.HookNetworkMessage("AddGlobalHint",      OnCommandAddGlobalHint)
end

