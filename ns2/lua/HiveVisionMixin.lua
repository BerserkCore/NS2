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
            end
        end
        
    end

    function HiveVisionMixin:OnUpdate(deltaTime)   

        // Determine if the entity should be visible on hive sight
        local visible = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
        local player = Client.GetLocalPlayer()

        if self:isa("Player") then
        
            // Make friendly players always show up.            
            if player ~= self then
            
                if GetAreFriends(self, player) then
                    visible = true
                end
            
            end
            
        end
        
        // Update the visibility status.
        if visible ~= self.hiveSightVisible then
            local model = self:GetRenderModel()
            if model ~= nil then
                if visible then
                    HiveVision_AddModel( model )
                else
                    HiveVision_RemoveModel( model )
                end                    
                self.hiveSightVisible = visible    
            end
        end
            
    end

end