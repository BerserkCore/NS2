// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\GorgeTunnelAbility.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// Gorge builds hydra.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'GorgeTunnelAbility' (StructureAbility)

function GorgeTunnelAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end

function GorgeTunnelAbility:GetGhostModelName(ability)
    return TunnelEntrance.kModelName
end

function GorgeTunnelAbility:GetDropStructureId()
    return kTechId.GorgeTunnel
end

function GorgeTunnelAbility:GetDropClassName()
    return "TunnelEntrance"
end

function GorgeTunnelAbility:GetDropMapName()
    return TunnelEntrance.kMapName
end

local kUpVector = Vector(0, 1, 0)
local kTolerance = 0.9
local kCheckDistance = 1.5
local kVerticalOffset = 0.3

local kCheckDirections = 
{
    Vector(kCheckDistance, 0, -kCheckDistance),
    Vector(kCheckDistance, 0, kCheckDistance),
    Vector(-kCheckDistance, 0, kCheckDistance),
    Vector(-kCheckDistance, 0, -kCheckDistance),
}

function GorgeTunnelAbility:GetDropRange()
    return 1.5
end

function GorgeTunnelAbility:GetIsPositionValid(position, player, surfaceNormal)

    local valid = false

    /// allow only on even surfaces
    if surfaceNormal then
    
        if surfaceNormal:DotProduct(kUpVector) > 0.9 then
        
            valid = true
        
            local startPos = position + Vector(0, kVerticalOffset, 0)
        
            for i = 1, #kCheckDirections do
            
                local traceStart = startPos + kCheckDirections[i]
            
                local trace = Shared.TraceRay(traceStart, traceStart - Vector(0, kVerticalOffset * 1.09, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOne(player))
            
                if trace.fraction < 0.9 or trace.fraction >= 1.0 then
                    valid = false
                    break
                end
            
            end
        
        
        end

    end
    
    return valid

end