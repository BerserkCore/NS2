// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\BabblerEgg.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    X babblers will hatch out of it when construction is completed.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Babbler.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/MobileTargetMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/OwnerMixin.lua")
Script.Load("lua/ConstructMixin.lua")

class 'BabblerEgg' (ScriptActor)

BabblerEgg.kMapName = "babbleregg"

BabblerEgg.kModelName = PrecacheAsset("models/alien/babbler/babbler_egg.model")
local kAnimationGraph = PrecacheAsset("models/alien/babbler/babbler_egg.animation_graph")

local networkVars =
{
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)

function BabblerEgg:OnCreate()

    ScriptActor.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, ConstructMixin)
    
    if Server then
        
        InitMixin(self, EntityChangeMixin)
        InitMixin(self, OwnerMixin)
    
        self.trackingBabblerId = {}
        self.silenced = false
    
    end

end

function BabblerEgg:OnInitialized()

    self:SetModel(BabblerEgg.kModelName, kAnimationGraph)
    
    if Server then    
        InitMixin(self, MobileTargetMixin)        
    end
    
end

if Server then

    local kVerticalOffset = 0.3
    local kBabblerSpawnPoints =
    {
        Vector(0.3, kVerticalOffset, 0.3),
        Vector(-0.3, kVerticalOffset, -0.3),
        Vector(0, kVerticalOffset, 0.3),
        Vector(0, kVerticalOffset, -0.3),
        Vector(0.3, kVerticalOffset, 0),
        Vector(-0.3, kVerticalOffset, 0),    
    }

    function BabblerEgg:OnConstructionComplete()

        // disables also collision
        self:SetModel(nil)       
        self:TriggerEffects("babbler_hatch")
    
        for i = 1, kNumBabblersPerEgg do
        
            local babbler = CreateEntity(Babbler.kMapName, self:GetOrigin() + kBabblerSpawnPoints[i], self:GetTeamNumber())
            babbler:SetOwner(self:GetOwner())
            babbler:SetSilenced(self.silenced)
            table.insert(self.trackingBabblerId, babbler:GetId() )
        
        end
    
    end
    
    function BabblerEgg:GetCanTakeDamage()
        return not self:GetIsBuilt()
    end
    
    function BabblerEgg:GetCanDie()
        return not self:GetIsBuilt()
    end
    
    function BabblerEgg:OnKill()
    
        self:TriggerEffects("death")
        DestroyEntity(self)
        
    end
    
    function BabblerEgg:SetOwner(owner)
    
        if GetHasSilenceUpgrade(owner) then
            self.silenced = true
        end
    
    end
    
    function BabblerEgg:OnEntityChange(oldId)
    
        if table.removevalue(self.trackingBabblerId, oldId) then
        
            if #self.trackingBabblerId == 0 then
                DestroyEntity(self)
            end
        
        end
    
    end
    
end   

function BabblerEgg:GetEffectParams(tableParams)

    ScriptActor.GetEffectParams(self, tableParams)

    tableParams[kEffectFilterSilenceUpgrade] = self.silenced
    
end 

 Shared.LinkClassToMap("BabblerEgg", BabblerEgg.kMapName, networkVars)
    