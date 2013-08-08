// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AlienCommander.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Handled Commander movement and actions.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Commander.lua")

class 'AlienCommander' (Commander)

AlienCommander.kMapName = "alien_commander"

local networkVars = 
{
    allowForesight = "boolean",
}

AlienCommander.kOrderClickedEffect = PrecacheAsset("cinematics/alien/order.cinematic")
AlienCommander.kSelectSound = PrecacheAsset("sound/NS2.fev/alien/commander/select")
AlienCommander.kChatSound = PrecacheAsset("sound/NS2.fev/alien/common/chat")
AlienCommander.kUpgradeCompleteSoundName = PrecacheAsset("sound/NS2.fev/alien/voiceovers/upgrade_complete")
AlienCommander.kResearchCompleteSoundName = PrecacheAsset("sound/NS2.fev/alien/voiceovers/research_complete")
AlienCommander.kManufactureCompleteSoundName = PrecacheAsset("sound/NS2.fev/alien/voiceovers/follow_me")
// TODO: replace with "objective completed" voiceover once it's available
AlienCommander.kObjectiveCompletedSoundName = PrecacheAsset("sound/NS2.fev/alien/skulk/taunt")
AlienCommander.kStructureUnderAttackSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/structure_under_attack")
AlienCommander.kSoldierNeedsMistSoundName = PrecacheAsset("sound/NS2.fev/alien/voiceovers/need_healing")
AlienCommander.kSoldierNeedsEnzymeSoundName = PrecacheAsset("sound/NS2.fev/alien/voiceovers/need_healing")
AlienCommander.kCragUnderAttackSound = PrecacheAsset("sound/NS2.fev/alien/structures/crag/wound")
AlienCommander.kHydraUnderAttackSound = PrecacheAsset("sound/NS2.fev/alien/structures/hydra/wound")
AlienCommander.kShadeUnderAttackSound = PrecacheAsset("sound/NS2.fev/alien/structures/shade/wound")
AlienCommander.kWhipUnderAttackSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/wound")
AlienCommander.kLifeformUnderAttackSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/lifeform_under_attack")
AlienCommander.kCommanderEjectedSoundName = PrecacheAsset("sound/NS2.fev/alien/voiceovers/commander_ejected")

AlienCommander.kMoveToWaypointSoundName = PrecacheAsset("sound/NS2.fev/alien/voiceovers/follow_me")
AlienCommander.kAttackOrderSoundName = PrecacheAsset("sound/NS2.fev/alien/voiceovers/game_start")
AlienCommander.kBuildStructureSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/follow_me")
AlienCommander.kHealTarget = PrecacheAsset("sound/NS2.fev/alien/voiceovers/need_healing")

AlienCommander.kSpendResourcesSoundName =  PrecacheAsset("sound/NS2.fev/alien/commander/spend_nanites")
AlienCommander.kSpendTeamResourcesSoundName =  PrecacheAsset("sound/NS2.fev/alien/commander/spend_metal")

AlienCommander.kForesightUpdateRate = 0.5

local kHoverSound = PrecacheAsset("sound/NS2.fev/alien/commander/hover")

function AlienCommander:GetSelectionSound()
    return AlienCommander.kSelectSound
end

function AlienCommander:GetHoverSound()
    return kHoverSound
end

function AlienCommander:GetTeamType()
    return kAlienTeamType
end

function AlienCommander:GetOrderConfirmedEffect()
    return AlienCommander.kOrderClickedEffect
end

function AlienCommander:GetSpendResourcesSoundName()
    return AlienCommander.kSpendResourcesSoundName
end

function AlienCommander:GetSpendTeamResourcesSoundName()
    return AlienCommander.kSpendTeamResourcesSoundName
end

if Server then
    
    function AlienCommander:OnCreate()
    
        Commander.OnCreate(self)
        
        self.allowForesight = false
        
    end
    
elseif Client then

    function AlienCommander:OnInitLocalClient()
    
        Commander.OnInitLocalClient(self)
        
        if self.waypoints == nil then
        
            self.waypoints = GetGUIManager():CreateGUIScript("GUIWaypoints")
            self.waypoints:InitAlienTexture()
            
        end
        
        if self.eggInfo == nil then
            self.eggInfo = GetGUIManager():CreateGUIScript("GUIEggDisplay")
        end
        
        if self.pheromoneDisplay == nil then
            self.pheromoneDisplay = GetGUIManager():CreateGUIScript("GUICommanderPheromoneDisplay")
        end
        
        if not self.cursorLight then
        
            self.cursorLight = Client.CreateRenderLight()
            self.cursorLight:SetType(RenderLight.Type_Point)
            self.cursorLight:SetCastsShadows(true)
            self.cursorLight:SetRadius(8)
            self.cursorLight:SetIntensity(3) 
            self.cursorLight:SetColor(Color(1, 0.2, 0, 1))
            
        end
        
    end
    
    function AlienCommander:UpdateForesight()
    
        PROFILE("AlienCommander:UpdateForesight")
        
        // get mouse target and create a dark cloud effect in case it's an enemy
        local mouseX, mouseY = Client.GetCursorPosScreen()
        local pickVec = CreatePickRay(self, mouseX, mouseY)
        local trace = Shared.TraceRay(self:GetOrigin(), self:GetOrigin() + pickVec*1000, CollisionRep.Select, PhysicsMask.CommanderSelect, EntityFilterOne(self))
        
        self.cursorLight:SetCoords(Coords.GetTranslation(trace.endPoint + trace.normal * 0.5))
        
        local lightVisible = false
        
        local cursorLocation = GetLocationForPoint(trace.endPoint)
        if cursorLocation and cursorLocation:GetWasVisitedByTeam(self:GetTeamNumber()) then
            lightVisible = true
        end
        
        self.cursorLight:SetIsVisible(lightVisible)
        
        // update foresight twice per second
        if lightVisible and (not self.timeLastForesight or self.timeLastForesight + AlienCommander.kForesightUpdateRate < Shared.GetTime()) then
        
            for index, target in ipairs(GetEntitiesWithMixinForTeamWithinRange("Team", GetEnemyTeamNumber(self:GetTeamNumber()), trace.endPoint, 8)) do
            
                if GetIsUnitActive(target) and target.TriggerEffects then
                
                    target:TriggerEffects("foresight")
                    self.timeLastForesight = Shared.GetTime()
                    
                end
                
            end
            
        end
        
    end
    
end

function AlienCommander:OnDestroy()

    if Client then
    
        if self.waypoints then
        
            GetGUIManager():DestroyGUIScript(self.waypoints)
            self.waypoints = nil
            
        end
        
        if self.cursorLight then
        
            Client.DestroyRenderLight(self.cursorLight)
            self.cursorLight = nil
            
        end
        
        if self.eggInfo then
        
            GetGUIManager():DestroyGUIScript(self.eggInfo)
            self.eggInfo = nil
            
        end
        
        if self.pheromoneDisplay then
        
            GetGUIManager():DestroyGUIScript(self.pheromoneDisplay)
            self.pheromoneDisplay = nil
            
        end
        
    end
    
    Commander.OnDestroy(self)
    
end

function AlienCommander:SetSelectionCircleMaterial(entity)
 
    if HasMixin(entity, "Construct") and not entity:GetIsBuilt() then
    
        SetMaterialFrame("alienBuild", entity.buildFraction)

    else

        // Allow entities without health to be selected (infest nodes)
        local healthPercent = 1
        if(entity.health ~= nil and entity.maxHealth ~= nil) then
            healthPercent = entity.health / entity.maxHealth
        end
        
        SetMaterialFrame("alienHealth", healthPercent)
        
    end
   
end

function AlienCommander:GetChatSound()
    return AlienCommander.kChatSound
end

function AlienCommander:GetPlayerStatusDesc()
    return kPlayerStatus.Commander
end

function AlienCommander:OnProcessMove(input)

    Commander.OnProcessMove(self, input)

    if Client then    
        self:UpdateForesight()    
    end

end

if Server then

    local function GetIsPheromone(techId)    
        return techId == kTechId.ThreatMarker or techId == kTechId.LargeThreatMarker or techId ==  kTechId.NeedHealingMarker or techId == kTechId.WeakMarker or techId == kTechId.ExpandingMarker    
    end
    
    function AlienCommander:CreateCyst(position, normal, orientation, pickVec)

        if not self.cystAllowed then
            return false
        end

        // check for energy
        local hive = self:GetClassHasEnergy("Hive", LookupTechData(kTechId.Cyst, kTechDataCostKey) )
        local success = false

        if hive then
        
            success = self:AttemptToBuild(kTechId.Cyst, position, normal, orientation, pickVec, false, hive)
            
            if success then
            
                Shared.PlayPrivateSound(self, self:GetSpendTeamResourcesSoundName(), nil, 1.0, self:GetOrigin())            
                hive:SetEnergy(hive:GetEnergy() - LookupTechData(kTechId.Cyst, kTechDataCostKey))
                
            end
            
        end

        return success
    
    end
    
    // check if a notification should be send for successful actions
    function AlienCommander:ProcessTechTreeActionForEntity(techNode, position, normal, pickVec, orientation, entity, trace)
    
        local techId = techNode:GetTechId()
        local success = false
        local keepProcessing = false
        
        if GetIsPheromone(techId) then
        
            success = CreatePheromone(techId, position, self:GetTeamNumber()) ~= nil
            keepProcessing = false
        
        else
            success, keepProcessing = Commander.ProcessTechTreeActionForEntity(self, techNode, position, normal, pickVec, orientation, entity, trace)
        end
        
        if success then
        
            local location = GetLocationForPoint(position)
            local locationName = location and location:GetName() or ""
            self:TriggerNotification(Shared.GetStringIndex(locationName), techId)
            
        end
        
        return success, keepProcessing
        
    end
    
end

function AlienCommander:GetIsInQuickMenu(techId)
    return Commander.GetIsInQuickMenu(self, techId) or techId == kTechId.MarkersMenu
end

local gAlienMenuButtons =
{
    [kTechId.BuildMenu] = { kTechId.Cyst, kTechId.Harvester, kTechId.Whip, kTechId.Hive,
                            kTechId.None, kTechId.None, kTechId.None, kTechId.None },
                            
    [kTechId.AdvancedMenu] = { kTechId.Crag, kTechId.Shade, kTechId.Shift, kTechId.None,
                               kTechId.Shell, kTechId.Veil, kTechId.Spur, kTechId.None },

    [kTechId.AssistMenu] = { kTechId.ThreatMarker, kTechId.NeedHealingMarker, kTechId.ExpandingMarker, kTechId.None,
                             kTechId.NutrientMist, kTechId.BoneWall, kTechId.None, kTechId.None } 
}

function AlienCommander:GetButtonTable()
    return gAlienMenuButtons
end

// Top row always the same. Alien commander can override to replace. 
function AlienCommander:GetQuickMenuTechButtons(techId)

    // Top row always for quick access.
    local alienTechButtons = { kTechId.BuildMenu, kTechId.AdvancedMenu, kTechId.AssistMenu, kTechId.RootMenu }
    local menuButtons = gAlienMenuButtons[techId]

    if not menuButtons then
    
        // Make sure all slots are initialized so entities can override simply.
        menuButtons = { kTechId.None, kTechId.None, kTechId.None, kTechId.None, kTechId.None, kTechId.None, kTechId.None, kTechId.None }
        
    end
    
    table.copy(menuButtons, alienTechButtons, true)
    
    // Return buttons and true/false if we are in a quick-access menu.
    return alienTechButtons
    
end

Shared.LinkClassToMap("AlienCommander", AlienCommander.kMapName, networkVars)