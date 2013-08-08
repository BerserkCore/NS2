// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\FreeLookSpectatorMode.lua
//
// Created by: Marc Delorme (marc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/SpectatorMode.lua")

class 'FreeLookSpectatorMode' (SpectatorMode)

FreeLookSpectatorMode.name = "FreeLook"

function FreeLookSpectatorMode:Initialize(spectator)

    spectator:SetFreeLookMoveEnabled(true)
    
    if Server then
    
        // Start with a null velocity
        spectator:SetVelocity(Vector(0, 0, 0))
        
        local angles = Angles(spectator:GetViewAngles())
        local nearestTarget = nil
        local nearestTargetDistance = 25
        
        local targets = Shared.GetEntitiesWithClassname("Player")
        for index, target in ientitylist(targets) do
        
            if target:GetIsAlive() and target:GetIsVisible() and target:GetCanTakeDamage() and target ~= spectator then
            
                local dist = (target:GetOrigin() - spectator:GetOrigin()):GetLength()
                if dist < nearestTargetDistance then
                
                    nearestTarget = target
                    nearestTargetDistance = dist
                    
                end
                
            end
            
        end

        if nearestTarget then
        
            local min, max = nearestTarget:GetModelExtents()
            local diff = nearestTarget:GetOrigin() - spectator:GetOrigin()
            local direction = GetNormalizedVector(diff)
            
            angles.yaw   = GetYawFromVector(direction)
            angles.pitch = GetPitchFromVector(direction)
            
        else
            angles.pitch = 0.0
        end
        
        spectator:SetBaseViewAngles(Angles(0, 0, 0))
        spectator:SetViewAngles(angles)
        
    end
    
end

function FreeLookSpectatorMode:Uninitialize(spectator)
    spectator:SetFreeLookMoveEnabled(false)
end