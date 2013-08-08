// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\SupplyUserMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

SupplyUserMixin = CreateMixin( SupplyUserMixin )
SupplyUserMixin.type = "Supply"

function SupplyUserMixin:__initmixin()
    
    assert(Server)    
    
    local team = self:GetTeam()
    if team and team.AddSupplyUsed then
    
        team:AddSupplyUsed(LookupTechData(self:GetTechId(), kTechDataSupply, 0))
        self.supplyAdded = true   
 
    end
    
end

local function RemoveSupply(self)

    if self.supplyAdded then
        
        local team = self:GetTeam()
        if team and team.RemoveSupplyUsed then
            
            team:RemoveSupplyUsed(LookupTechData(self:GetTechId(), kTechDataSupply, 0))
            self.supplyAdded = false
            
        end
        
    end
    
end

function SupplyUserMixin:OnKill()
    RemoveSupply(self)
end

function SupplyUserMixin:OnDestroy()
    RemoveSupply(self)
end
