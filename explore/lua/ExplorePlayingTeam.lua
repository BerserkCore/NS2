// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\PlayingTeam.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

function PlayingTeam:ResetTeam()

    local initialTechPoint = self:GetInitialTechPoint()

    for i, player in ipairs( GetEntitiesForTeam("Player", self:GetTeamNumber()) ) do
        player:OnInitialSpawn(initialTechPoint:GetOrigin())
    end 
    
    self.rebuildTechTree = true
    
end