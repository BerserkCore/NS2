// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MarineCommander_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// TODO: return true only when attempting to drop a structure which requires power
function MarineCommander:GetShowPowerIndicator()
    /*
    local showPowerIndicator = self.currentTechId and self.currentTechId ~= kTechId.None and LookupTechData(self.currentTechId, kTechDataRequiresPower, false)
    return showPowerIndicator
    */
    // Always show the power for the commander
    return true
end    

function MarineCommander:TechCausesDelay(techId)
    return techId == kTechId.MedPack or techId == kTechId.AmmoPack or techId == kTechId.NanoShield or techId == kTechId.Scan
end

function MarineCommander:OnInitLocalClient()

    Commander.OnInitLocalClient(self)
    
    if self.guiDistressBeacon == nil then
        self.guiDistressBeacon = GetGUIManager():CreateGUIScript("GUIDistressBeacon")
    end
    
    if self.sensorBlips == nil then
        self.sensorBlips = GetGUIManager():CreateGUIScript("GUISensorBlips")
    end 
    
    if self.waypoints == nil then
        self.waypoints = GetGUIManager():CreateGUIScript("GUIWaypoints")
        self.waypoints:InitMarineTexture()
    end
    
end

function MarineCommander:SetSelectionCircleMaterial(entity)
 
    if HasMixin(entity, "Construct") and not entity:GetIsBuilt() then
    
        SetMaterialFrame("marineBuild", entity.buildFraction)

    else

        // Allow entities without health to be selected (infest nodes)
        local healthPercent = 1
        if(entity.health ~= nil and entity.maxHealth ~= nil) then
            healthPercent = entity.health / entity.maxHealth
        end
        
        SetMaterialFrame("marineHealth", healthPercent)

    end
   
end