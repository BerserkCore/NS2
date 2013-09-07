// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreServer.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ExploreShared.lua")
Script.Load("lua/ExploreNS2Gamerules.lua")

function Embryo:GetGestationTime(gestationTypeTechId)
    return 3
end

assert(SendTeamMessage)
local savedSendTeamMessage = SendTeamMessage
function SendTeamMessage(team, messageType, optionalData)

    // Don't send "You need a commander" alert
    if messageType ~= kTeamMessageTypes.NoCommander then
        savedSendTeamMessage(team, messageType, optionalData)
    end
    
end

//----------------------------------------
//  
//----------------------------------------

local tutorial = nil

function GetTutorial()

    assert(Server)
    if not tutorial then
        tutorial = CreateEntity("tutorial")
        assert( tutorial ~= nil )
    end

    return tutorial

end

//----------------------------------------
//  Override stuff
//  Not sure why these need to be here, but whatever!
//----------------------------------------

local __ConstructMixin_OnConstructionComplete = ConstructMixin.OnConstructionComplete
function ConstructMixin:OnConstructionComplete(builder)
    GetTutorial():OnBuiltEvent( self, builder )
    return __ConstructMixin_OnConstructionComplete(self)
end

local __LiveMixin_OnKill = LiveMixin.OnKill
function LiveMixin:OnKill()
    GetTutorial():OnKillEvent( self )
    if __LiveMixin_OnKill ~= nil then
        return __LiveMixin_OnKill(self)
    end
end

local __Clog_OnCreate = Clog.OnCreate
function Clog:OnCreate()
    GetTutorial():OnClogCreated(self)
    return __Clog_OnCreate(self)
end

local __Hydra_OnCreate = Hydra.OnCreate
function Hydra:OnCreate()
    GetTutorial():OnHydraCreated(self)
    return __Hydra_OnCreate(self)
end

local __DamageMixin_DoDamage = DamageMixin.DoDamage
function DamageMixin:DoDamage( damage, target, point, direction, surface, altMode, showTracer )

    local student = GetTutorial():GetPlayer()

    if target ~= nil
        and (student == target or GetTutorial().comStation == target)
        and (target:GetHealth()-damage <= 10)
    then
        return false
    else
        return __DamageMixin_DoDamage( self, damage, target, point, direction, surface, altMode, showTracer )
    end

end

// Avoid our tutorial bots getting afk kicked..
local __AFKMixin_GetAFKTime = AFKMixin.GetAFKTime
function AFKMixin:GetAFKTime()
    return 0
end

//----------------------------------------
//  Make sure we don't track player rankings in tut mode
//----------------------------------------
function PlayerRanking:GetTrackServer()
    return false
end

// override so commander may build on top of players
Script.Load("lua/PhysicsGroups.lua")
PhysicsMask.CommanderStack = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup, PhysicsGroup.PlayerGroup, PhysicsGroup.WeaponGroup, PhysicsGroup.BigPlayerControllersGroup, PhysicsGroup.PathingGroup)
               
Event.Hook("ClientConnect", function(client)
        GetTutorial():OnClientConnect(client)
        end)

