// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Exosuit.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com.at)
//
//    Pickupable entity.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PickupableMixin.lua")
Script.Load("lua/SelectableMixin.lua")

class 'Exosuit' (ScriptActor)

Exosuit.kMapName = "exosuit"

Exosuit.kModelName = PrecacheAsset("models/marine/exosuit/exosuit_cm.model")
local kAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_spawn_only.animation_graph")

Exosuit.kThinkInterval = .5

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)

function Exosuit:OnCreate ()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, SelectableMixin)
    
    InitMixin(self, PickupableMixin, { kRecipientType = "Marine" })
    
    self:SetPhysicsGroup(PhysicsGroup.WeaponGroup)
    
end
/*
function Exosuit:GetCheckForRecipient()
    return false
end    
*/
function Exosuit:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Exosuit.kModelName, kAnimationGraph)
    
end

function Exosuit:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = self:GetIsValidRecipient(player)      
end

function Exosuit:_GetNearbyRecipient()
end

function Exosuit:OnTouch(recipient)    
end

if Server then

    function Exosuit:OnUse(player, elapsedTime, useSuccessTable)
    
        if self:GetIsValidRecipient(player) then
        
            DestroyEntity(self)
            player:GiveExo()
            
        end
        
    end
    
end

// only give Exosuits to standard marines
function Exosuit:GetIsValidRecipient(recipient)
    return not recipient:isa("Exo")
end

function Exosuit:GetIsPermanent()
    return true
end  

Shared.LinkClassToMap("Exosuit", Exosuit.kMapName, networkVars)