// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========    
//    
// lua\SpawnBlockMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/SpawnBlocker.lua")

SpawnBlockMixin = CreateMixin( SpawnBlockMixin )
SpawnBlockMixin.type = "SpawnBlock"

SpawnBlockMixin.expectedMixins =
{
    Team = "For making friendly players visible"
}

SpawnBlockMixin.optionalCallbacks =
{
    GetSpawnBlockDuration = "Return custom duration for blocking structure creation."
}

function SpawnBlockMixin:__initmixin()

    self.spawnBlocked = false

end

if Server then

    local function CreateSpawnBlocker(self)
    
        if not self.spawnBlocked then
        
            local gameStarted = GetGamerules() and GetGamerules():GetGameStarted()
            if gameStarted then
            
                local spawnBlocker = CreateEntity(SpawnBlocker.kMapName, self:GetOrigin(), self:GetTeamNumber())

                if self.GetSpawnBlockDuration then
                    spawnBlocker:SetDuration(self:GetSpawnBlockDuration())
                end
         
                self.spawnBlocked = true
                
            end
            
        end
        
    end

    function SpawnBlockMixin:OnKill()
        CreateSpawnBlocker(self)
    end

    function SpawnBlockMixin:OnDestroy()
        CreateSpawnBlocker(self)
    end

end