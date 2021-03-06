// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========    
//    
// lua\HiveVision.lua    
//    
//    Created by:   Max McGuire (max@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

HiveVisionMixin = CreateMixin( HiveVisionMixin )
HiveVisionMixin.type = "HiveVision"

HiveVisionMixin.expectedMixins =
{
    Team = "For making friendly players visible",
    Model = "For copying bonecoords and drawing model in view model render zone.",
}

function HiveVisionMixin:__initmixin()

    if Client then
        self.hiveSightVisible = false
    end

end

if Client then

    function HiveVisionMixin:OnDestroy()

        if self.hiveSightVisible then
            local model = self:GetRenderModel()
            if model ~= nil then
                HiveVision_RemoveModel( model )
                //DebugPrint("%s remove model", self:GetClassName())
            end
        end
        
    end
    
    local function GetMaxDistanceFor(player)
    
        if player:isa("AlienCommander") then
            return 63
        end

        return 33
    
    end
    
    local function GetIsObscurred(viewer, target)
    
        local targetOrigin = HasMixin(target, "Target") and target:GetEngagementPoint() or target:GetOrigin()
        local eyePos = GetEntityEyePos(viewer)
    
        local trace = Shared.TraceRay(eyePos, targetOrigin, CollisionRep.LOS, PhysicsMask.All, EntityFilterAll())
        
        if trace.fraction == 1 then
            return false
        end
            
        return true    
    
    end

    function HiveVisionMixin:OnUpdate(deltaTime)   

        // Determine if the entity should be visible on hive sight
        local visible = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
        local player = Client.GetLocalPlayer()
        
        if Client.GetLocalClientTeamNumber() == kSpectatorIndex and self:isa("Alien") and Client.GetOutlinePlayers() and not self.hiveSightVisible then

            local model = self:GetRenderModel()
            if model ~= nil then
            
                HiveVision_AddModel( model )
                   
                self.hiveSightVisible = true    
                self.timeHiveVisionChanged = Shared.GetTime()
                
            end
        
        end
        
        // check the distance here as well. seems that the render mask is not correct for newly created models or models which get destroyed in the same frame
        local playerCanSeeHiveVision = player ~= nil and (player:GetOrigin() - self:GetOrigin()):GetLength() <= GetMaxDistanceFor(player) and (player:isa("Alien") or player:isa("AlienCommander") or player:isa("AlienSpectator"))

        if not visible and self:isa("Player") then
        
            // Make friendly players always show up.            
            if player ~= self and GetAreFriends(self, player) and GetIsObscurred(player, self) then
                visible = true
            end
            
        end
        
        if visible and not playerCanSeeHiveVision then
            visible = false
        end
        
        // Update the visibility status.
        if visible ~= self.hiveSightVisible and (not self.timeHiveVisionChanged or self.timeHiveVisionChanged + 1 < Shared.GetTime()) then
        
            local model = self:GetRenderModel()
            if model ~= nil then
            
                if visible then
                    HiveVision_AddModel( model )
                    //DebugPrint("%s add model", self:GetClassName())
                else
                    HiveVision_RemoveModel( model )
                    //DebugPrint("%s remove model", self:GetClassName())
                end 
                   
                self.hiveSightVisible = visible    
                self.timeHiveVisionChanged = Shared.GetTime()
                
            end
            
        end
            
    end

end