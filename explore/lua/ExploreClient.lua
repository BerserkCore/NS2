// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreClient.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Client.lua")
Script.Load("lua/ExploreShared.lua")

// Print simple help
Print(Locale.ResolveString("EXPLORE_MODE_INITIALIZED"), "reset_help")

local gExploreHintScript = nil
local gLastWeaponTechId = nil

function Explore_OnClientDisconnected(reason)
    GetGUIManager():DestroyGUIScriptSingle("GUIExploreHint")
end

function Explore_OnLoadComplete()
    gExploreHintScript = GetGUIManager():CreateGUIScript("GUIExploreHint")
end

function Explore_OnUpdateRender()

    local player = Client.GetLocalPlayer()
    if player and gExploreHintScript then
    
        // Hide in ready room
        if player:GetIsPlaying() then
    
            local target = player:GetCrossHairTarget()
            local techId = nil
            local displayingViewModel = false
            
            if target and HasMixin(target, "Tech") then
                techId = target:GetTechId()
            else
                local activeWeapon = player:GetActiveWeapon()
                if activeWeapon and gLastWeaponTechId ~= activeWeapon:GetTechId() then
                
                    techId = activeWeapon:GetTechId()
                    gLastWeaponTechId = activeWeapon:GetTechId()
                    displayingViewModel = true
                    
                    local viewModelEnt = player:GetViewModelEntity()
                    if viewModelEnt then
                        if viewModelEnt:Highlight() then
                            gExploreHintScript:Highlight()
                        end
                    end
                    
                end
            end
            
            if techId then
            
                local techTree = GetTechTree()

                if techTree then

                    local text = GetDisplayNameForTechId(techId, "TIP")
                    local info = SubstituteBindStrings(GetTooltipInfoText(techId))
                    if target and target.GetTooltipText then
                        info = target:GetTooltipText()
                    end
                    
                    // Don't display resource costs for view model hints
                    local costNumber = 0
                    if not displayingViewModel then
                        costNumber = LookupTechData(techId, kTechDataCostKey, 0)                
                    end
                    
                    local requiresText = techTree:GetRequiresText(techId)
                    local enablesText = techTree:GetEnablesText(techId)
                    local resourceType = 0                
                    local techNode = techTree:GetTechNode(techId)
                    if techNode then
                        resourceType = techNode:GetResourceType()
                    end
                
                    gExploreHintScript:UpdateData(text, "", costNumber, requiresText, enablesText, info, resourceType)
                    
                    if HasMixin(target, "Hightlight") then
                        if target:Highlight() then
                            gExploreHintScript:Highlight()
                        end
                    end
                
                end
        
            end
            
        else
            // Don't show tooltip in ready room
            gExploreHintScript:FadeOut()
        end
    
    end

end

// Override and set GUI inventory as always visible
local alienInitLocalClient = nil
assert(Alien.OnInitLocalClient)
alienInitLocalClient = Alien.OnInitLocalClient

function Alien:OnInitLocalClient()
    alienInitLocalClient(self)
    if self.alienHUD and self.alienHUD.inventoryDisplay then
        self.alienHUD.inventoryDisplay:SetForceAnimationReset(true)
    end
end

// Override and set GUI inventory as always visible (skip Exo because no extra weapons yet)
local marineInitLocalClient = nil
assert(Marine.OnInitLocalClient)
marineInitLocalClient = Marine.OnInitLocalClient

function Marine:OnInitLocalClient()
    marineInitLocalClient(self)
    if self.marineHUD and self.marineHUD.inventoryDisplay then
        self.marineHUD.inventoryDisplay:SetForceAnimationReset(true)
    end
end

Event.Hook("UpdateRender", Explore_OnUpdateRender)
Event.Hook("ClientDisconnected", Explore_OnClientDisconnected)
Event.Hook("LoadComplete", Explore_OnLoadComplete)