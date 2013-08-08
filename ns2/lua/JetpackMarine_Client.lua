// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\JetpackMarine_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

JetpackMarine.kJetEffectIntervall = .00001
JetpackMarine.kJetPackTakeOffEffectDuration = 1
JetpackMarine.kTakeOffEffectIntervall = 0.05
JetpackMarine.kTakeOffEffectDuration = 1

function JetpackMarine:OnInitLocalClient()

    Marine.OnInitLocalClient(self)
    
    if(self:GetTeamNumber() ~= kTeamReadyRoom) then

        if self.guiFuelDisplay == nil then
            self.guiFuelDisplay = GetGUIManager():CreateGUIScript("GUIJetpackFuel")
        end
        
    end
    
end

// only display jetpack in thirdperson or for other players
function JetpackMarine:UpdateClientEffects(deltaTime, isLocal)

    Marine.UpdateClientEffects(self, deltaTime, isLocal)
    
    local drawWorld = ((not isLocal) or self:GetIsThirdPerson())
    
    local jetpackOnBack = self:GetJetpack()
    
    if jetpackOnBack then
        jetpackOnBack:SetIsVisible( drawWorld )
        jetpackOnBack:UpdateJetpackTrails(deltaTime)
    end

end


