// ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========    
//    
// lua\MarineOutlineMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

MarineOutlineMixin = CreateMixin( MarineOutlineMixin )
MarineOutlineMixin.type = "MarineOutline"

MarineOutlineMixin.expectedMixins =
{
    Model = "For copying bonecoords and drawing model in view model render zone.",
}

function MarineOutlineMixin:__initmixin()

    if Client then
        self.marineOutlineVisible = false
    end

end

if Client then

    function MarineOutlineMixin:OnDestroy()

        if self.marineOutlineVisible then
            local model = self:GetRenderModel()
            if model ~= nil then
                EquipmentOutline_RemoveModel( model )
            end
        end
        
    end

    function MarineOutlineMixin:OnUpdate(deltaTime)   

        local player = Client.GetLocalPlayer()
        
        local model = self:GetRenderModel()
        if model ~= nil then 
        
            local outlineModel = player:isa("Spectator") and player:GetOutlinePlayers() and self:isa("Player")
        
            if  outlineModel and not self.marineOutlineVisible then
                
                EquipmentOutline_AddModel( model )                   
                self.marineOutlineVisible = true 
            
            elseif self.marineOutlineVisible and not outlineModel then
            
                EquipmentOutline_RemoveModel( model )
                self.marineOutlineVisible = false
            
            end
        
        end
            
    end

end