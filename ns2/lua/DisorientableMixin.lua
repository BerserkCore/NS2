// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\DisorientableMixin.lua    
//    
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Andreas Urwalek (andi@unknownworlds.com)
//
//    Client side mixin.  Calculates disoriented amount and provides result with GetDisorientedAmount()
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/CommAbilities/Alien/ShadeInk.lua")

DisorientableMixin = CreateMixin( DisorientableMixin )
DisorientableMixin.type = "Disorientable"

DisorientableMixin.expectedCallbacks = {}

// don't update too often
DisorientableMixin.kUpdateIntervall = 0.5
DisorientableMixin.kDisorientIntensity = 4

DisorientableMixin.expectedMixins =
{
    Team = "For defining enemy shades."
}    

DisorientableMixin.networkVars =
{
}

function DisorientableMixin:__initmixin()
    self.disorientedAmount = 0
    self.timeLastDisorientUpdate = 0
end

local function SharedUpdate(self)

    if self.timeLastDisorientUpdate + DisorientableMixin.kUpdateIntervall < Shared.GetTime() then
    
        local fromPoint = self:GetOrigin()
        local nearbyEnemyShades = GetEntitiesForTeamWithinRange("ShadeInk", GetEnemyTeamNumber(self:GetTeamNumber()), fromPoint, ShadeInk.kShadeInkDisorientRadius )
        Shared.SortEntitiesByDistance(fromPoint, nearbyEnemyShades)
        
        local adjustedDisorient = false
        
        for _, shade in ipairs(nearbyEnemyShades) do
        
            local distanceToShade = (shade:GetOrigin() - fromPoint):GetLength()
            self.disorientedAmount = DisorientableMixin.kDisorientIntensity - Clamp( (distanceToShade / ShadeInk.kShadeInkDisorientRadius) * DisorientableMixin.kDisorientIntensity, 0, DisorientableMixin.kDisorientIntensity)
            adjustedDisorient = true
            break
        
        end
        
        if not adjustedDisorient then
            self.disorientedAmount = 0
        end
    
        self.timeLastDisorientUpdate = Shared.GetTime()
        
    end

end

function DisorientableMixin:OnProcessMove(input)
    SharedUpdate(self)
end

function DisorientableMixin:OnUpdate(deltaTime)
    SharedUpdate(self)
end

function DisorientableMixin:GetDisorientedAmount()
    return self.disorientedAmount
end
