// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreBot_Player.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function BotPlayer:ChooseOrder()

    local player = self:GetPlayer()
    local order = player:GetCurrentOrder()

    // Update order values for client
    self:UpdateOrderVariables()
    
end

/**
 * Responsible for generating the "input" for the bot. This is equivalent to
 * what a client sends across the network.
 */
function BotPlayer:GenerateMove()

    local player = self:GetPlayer()
    local move = Move()
    
    // keep the current yaw/pitch as default
    move.yaw = player:GetAngles().yaw
    move.pitch = player:GetAngles().pitch

    local order = player:GetCurrentOrder()

    // Look at order and generate move for it
    if order then
    
        self:UpdateWeaponMove(move)
    
        local orderLocation = order:GetLocation()
        local target = Shared.GetEntity(order:GetParam())
        
        if target and HasMixin(target, "Target") then
            orderLocation = target:GetEngagementPoint()
        end
        
        local closeToTarget = (player:GetOrigin () - orderLocation):GetLength() < kPlayerUseRange

        if order:GetType() == kTechId.Construct and target and closeToTarget then 
           
            move.commands = bit.bor(move.commands, Move.Use)
            
            move.yaw = GetYawFromVector( GetNormalizedVector(orderLocation - player:GetEyePos()) )
            move.pitch = GetPitchFromVector( GetNormalizedVector(orderLocation - player:GetEyePos()) )

        else    
            self:MoveToPoint(orderLocation, move)
        end
        
    end
    
    // Trigger request when marine need them (health, ammo, orders)
    self:TriggerAlerts()
    
    return move

end
