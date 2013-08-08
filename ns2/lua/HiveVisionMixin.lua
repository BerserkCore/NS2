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

    function HiveVisionMixin:OnUpdate(deltaTime)   

        // Determine if the entity should be visible on hive sight
        local visible = HasMixin(self, "ParasiteAble") and self:GetIsParasited()
        local player = Client.GetLocalPlayer()
        
        // check the distance here as well. seems that the render mask is not correct for newly created models or models which get destroyed in the same frame
        local playerCanSeeHiveVision = player ~= nil and (player:GetOrigin() - self:GetOrigin()):GetLength() <= GetMaxDistanceFor(player) and (player:isa("Alien") or player:isa("AlienCommander") or player:isa("AlienSpectator"))

        if not visible and self:isa("Player") then
        
            // Make friendly players always show up.            
            if player ~= self then
            
                if GetAreFriends(self, player) then
                    visible = true
                end
            
            end
            
        end
        
        if visible and not playerCanSeeHiveVision then
            visible = false
        end
        
        // Update the visibility status.
        if visible ~= self.hiveSightVisible then
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
            end
        end
            
    end

end