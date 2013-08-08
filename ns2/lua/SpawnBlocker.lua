// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========    
//    
// lua\SpawnBlocker.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/TeamMixin.lua")

class 'SpawnBlocker' (Entity)

SpawnBlocker.kMapName = "spawnblocker"

local kDefaultBlockDuration = 5

local networkVars =
{
}

function SpawnBlocker:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    
    self:SetUpdates(true)
    self.endTime = kDefaultBlockDuration + Shared.GetTime()
    
end

function SpawnBlocker:SetDuration(duration)
    self.endTime = duration + Shared.GetTime()
end

if Server then

    function SpawnBlocker:OnUpdate(deltaTime)
    
        if self.endTime and self.endTime <= Shared.GetTime() then
            DestroyEntity(self)
        end
    
    end

end

Shared.LinkClassToMap("SpawnBlocker", SpawnBlocker.kMapName, networkVars)