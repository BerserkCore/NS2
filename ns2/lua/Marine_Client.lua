// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Marine_Client.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Marine.k2DHUDFlash = "ui/marine_hud_2d.swf"
Marine.kBuyMenuTexture = "ui/marine_buymenu.dds"
Marine.kBuyMenuUpgradesTexture = "ui/marine_buymenu_upgrades.dds"
Marine.kBuyMenuiconsTexture = "ui/marine_buy_icons.dds"

Marine.kInfestationFootstepCinematic = PrecacheAsset("cinematics/marine/infestation_footstep.cinematic")
Marine.kSpitHitCinematic = PrecacheAsset("cinematics/marine/spit_hit_1p.cinematic")

Shared.PrecacheSurfaceShader("cinematics/vfx_materials/rupture.surface_shader")

Marine.kSpitHitEffectDuration = 1

local kSensorBlipSize = 25

local kMarineHealthbarOffset = Vector(0, 1.2, 0)
function Marine:GetHealthbarOffset()
    return kMarineHealthbarOffset
end

function MarineUI_GetHasArmsLab()

    local player = Client.GetLocalPlayer()
    
    if player then
        return GetHasTech(player, kTechId.ArmsLab)
    end
    
    return false
    
end

function PlayerUI_GetSensorBlipInfo()

    PROFILE("PlayerUI_GetSensorBlipInfo")
    
    local player = Client.GetLocalPlayer()
    local blips = {}
    
    if player then
    
        local eyePos = player:GetEyePos()
        for index, blip in ientitylist(Shared.GetEntitiesWithClassname("SensorBlip")) do
        
            local blipOrigin = blip:GetOrigin()
            local blipEntId = blip.entId
            local blipName = ""
            
            // Lookup more recent position of blip
            local blipEntity = Shared.GetEntity(blipEntId)
            
            // Do not display a blip for the local player.
            if blipEntity ~= player then

                if blipEntity then
                
                    if blipEntity:isa("Player") then
                        blipName = Scoreboard_GetPlayerData(blipEntity:GetClientIndex(), kScoreboardDataIndexName)
                    elseif blipEntity.GetTechId then
                        blipName = GetDisplayNameForTechId(blipEntity:GetTechId())
                    end
                    
                end
                
                if not blipName then
                    blipName = ""
                end
                
                // Get direction to blip. If off-screen, don't render. Bad values are generated if 
                // Client.WorldToScreen is called on a point behind the camera.
                local normToEntityVec = GetNormalizedVector(blipOrigin - eyePos)
                local normViewVec = player:GetViewAngles():GetCoords().zAxis
               
                local dotProduct = normToEntityVec:DotProduct(normViewVec)
                if dotProduct > 0 then
                
                    // Get distance to blip and determine radius
                    local distance = (eyePos - blipOrigin):GetLength()
                    local drawRadius = kSensorBlipSize/distance
                    
                    // Compute screen xy to draw blip
                    local screenPos = Client.WorldToScreen(blipOrigin)

                    /*
                    local trace = Shared.TraceRay(eyePos, blipOrigin, CollisionRep.LOS, PhysicsMask.Bullets, EntityFilterTwo(player, entity))                               
                    local obstructed = ((trace.fraction ~= 1) and ((trace.entity == nil) or trace.entity:isa("Door"))) 
                    
                    if not obstructed and entity and not entity:GetIsVisible() then
                        obstructed = true
                    end
                    */
                    
                    // Add to array (update numElementsPerBlip in GUISensorBlips:UpdateBlipList)
                    table.insert(blips, screenPos.x)
                    table.insert(blips, screenPos.y)
                    table.insert(blips, drawRadius)
                    table.insert(blips, true)
                    table.insert(blips, blipName)

                end
                
            end
            
        end
    
    end
    
    return blips
    
end

local function GetIsCloseToMenuStructure(self)
    
    local ptlabs = GetEntitiesForTeamWithinRange("PrototypeLab", self:GetTeamNumber(), self:GetOrigin(), PrototypeLab.kResupplyUseRange)
    local armories = GetEntitiesForTeamWithinRange("Armory", self:GetTeamNumber(), self:GetOrigin(), Armory.kResupplyUseRange)
    
    return (ptlabs and #ptlabs > 0) or (armories and #armories > 0)

end

function Marine:OnInitLocalClient()

    Player.OnInitLocalClient(self)
    
    self.notifications = {}
    self.timeLastSpitHitEffect = 0
    
    if self:GetTeamNumber() ~= kTeamReadyRoom then

        if self.marineHUD == nil then
            self.marineHUD = GetGUIManager():CreateGUIScript("Hud/Marine/GUIMarineHUD")
        end
        
        if self.poisonedGUI == nil then
            self.poisonedGUI = GetGUIManager():CreateGUIScript("GUIPoisonedFeedback")
        end
        
        self:TriggerHudInitEffects()
        
        if self.waypoints == nil then
            self.waypoints = GetGUIManager():CreateGUIScript("GUIWaypoints")
            self.waypoints:InitMarineTexture()
        end
        
        if self.pickups == nil then
            self.pickups = GetGUIManager():CreateGUIScript("GUIPickups")
        end

        if self.hints == nil then
            //self.hints = GetGUIManager():CreateGUIScript("GUIHints")
        end
        
        if self.guiOrders == nil then
            self.guiOrders = GetGUIManager():CreateGUIScript("GUIOrders")
        end
        
        if self.sensorBlips == nil then
            self.sensorBlips = GetGUIManager():CreateGUIScript("GUISensorBlips")
        end
        
        if self.objectiveDisplay == nil then
            self.objectiveDisplay = GetGUIManager():CreateGUIScript("GUIObjectiveDisplay")
        end 
        
        if self.progressDisplay == nil then
            self.progressDisplay = GetGUIManager():CreateGUIScript("GUIProgressBar")
        end
        
        if self.requestMenu == nil then
            self.requestMenu = GetGUIManager():CreateGUIScript("GUIRequestMenu")
        end
        
    end
    
end

function Marine:TriggerHudInitEffects()
    self.marineHUD:TriggerInitAnimations()
end

function Marine:UnitStatusPercentage()
    return self.unitStatusPercentage
end

function Marine:ShowMap(showMap, showBig, forceReset)

    Player.ShowMap(self, showMap, showBig, forceReset)
    
    if showMap ~= self.mapState then
    
        self.mapState = showMap
        
        if not self.timeLastMapStateChange then
            self.timeLastMapStateChange = 0
        end
    
        if self.mapState and self.timeLastMapStateChange + 3 < Shared.GetTime() then
            
            self.timeLastMapStateChange = Shared.GetTime()
        
            local hudParams = self:GetHudParams()
            hudParams.initProjectingCinematic = true    
            self:SetHudParams(hudParams)
        end
    
    end

end

function Marine:GetHudParams()

    if self.hudParams == nil then
    
        self.hudParams = {}
        self.hudParams.timeDamageTaken = nil
        // scalar 0-1        
        self.hudParams.damageIntensity = 0
        // boolean to check if a hud cinematic should be played,  init with true so respawning / ejecting from CS / joining team will trigger it
        self.hudParams.initProjectingCinematic = true
    
    end
    
    return self.hudParams

end

function Marine:SetHudParams(hudParams)
    self.hudParams = hudParams
end

local function TriggerSpitHitEffect(coords)

    local spitCinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
    spitCinematic:SetCinematic(Marine.kSpitHitCinematic)
    spitCinematic:SetRepeatStyle(Cinematic.Repeat_None)
    spitCinematic:SetCoords(coords)
    
end

function Marine:OnKillClient()

    Player.OnKillClient(self)
    
    if self.requestMenu then
        
        GetGUIManager():DestroyGUIScript(self.requestMenu)
        self.requestMenu = nil
            
    end
    
    if self.marineHUD then
    
        GetGUIManager():DestroyGUIScript(self.marineHUD)
        self.marineHUD = nil
        
    end

end

function Marine:UpdatePoisonedEffect()

    if self.poisoned and self:GetIsAlive() and not self.poisonedGUI:GetIsAnimating() then    
        self.poisonedGUI:TriggerPoisonEffect()        
    end
    
end

function Marine:UpdateClientEffects(deltaTime, isLocal)
    
    Player.UpdateClientEffects(self, deltaTime, isLocal)
    
    if isLocal then
    
        Client.SetMouseSensitivityScalar(ConditionalValue(self:GetIsStunned(), 0, 1))
        
        self:UpdateGhostModel()
        
        self:UpdatePoisonedEffect()
        
        if self.marineHUD then
            self.marineHUD:SetIsVisible(self:GetIsAlive())
        end
        
        if self.buyMenu then
            if not self:GetIsAlive() or not GetIsCloseToMenuStructure(self) then
                self:CloseMenu()
            end
        end    
        
        if Player.screenEffects.disorient then
            Player.screenEffects.disorient:SetParameter("time", Client.GetTime())
        end
        
        local stunned = HasMixin(self, "Stun") and self:GetIsStunned()
        local blurEnabled = self.buyMenu ~= nil or stunned or self.minimapVisible
        self:SetBlurEnabled(blurEnabled)
        
        // update spit hit effect
        if not Shared.GetIsRunningPrediction() then
        
            if self.timeLastSpitHit ~= self.timeLastSpitHitEffect then
            
                local viewAngle = self:GetViewAngles()
                local angleDirection = Angles(GetPitchFromVector(self.lastSpitDirection), GetYawFromVector(self.lastSpitDirection), 0)
                angleDirection.yaw = GetAnglesDifference(viewAngle.yaw, angleDirection.yaw)
                angleDirection.pitch = GetAnglesDifference(viewAngle.pitch, angleDirection.pitch)
                
                TriggerSpitHitEffect(angleDirection:GetCoords())
                
                local intensity = self.lastSpitDirection:DotProduct(self:GetViewCoords().zAxis)
                self.spitEffectIntensity = intensity
                self.timeLastSpitHitEffect = self.timeLastSpitHit
                
            end
            
        end
        
        local spitHitDuration = Shared.GetTime() - self.timeLastSpitHitEffect
        
        if Player.screenEffects.disorient and self.timeLastSpitHitEffect ~= 0 and spitHitDuration <= Marine.kSpitHitEffectDuration then
        
            Player.screenEffects.disorient:SetActive(true)
            local amount = (1 - ( spitHitDuration/Marine.kSpitHitEffectDuration) ) * 3.5 * self.spitEffectIntensity
            Player.screenEffects.disorient:SetParameter("amount", amount)
            
        end
        
    end
    
    if self._renderModel then
    
        if self.ruptured and not self.ruptureMaterial then

            local material = Client.CreateRenderMaterial()
            material:SetMaterial("cinematics/vfx_materials/rupture.material")

            local viewMaterial = Client.CreateRenderMaterial()
            viewMaterial:SetMaterial("cinematics/vfx_materials/rupture.material")
            
            self.ruptureEntities = {}
            self.ruptureMaterial = material
            self.ruptureMaterialViewMaterial = viewMaterial
            AddMaterialEffect(self, material, viewMaterial, self.ruptureEntities)
        
        elseif not self.ruptured and self.ruptureMaterial then

            RemoveMaterialEffect(self.ruptureEntities, self.ruptureMaterial, self.ruptureMaterialViewMaterial)
            Client.DestroyRenderMaterial(self.ruptureMaterial)
            Client.DestroyRenderMaterial(self.ruptureMaterialViewMaterial)
            self.ruptureMaterial = nil
            self.ruptureMaterialViewMaterial = nil
            self.ruptureEntities = nil
            
        end
        
    end
    
    
end

function Marine:OnUpdateRender()

    PROFILE("Marine:OnUpdateRender")
    
    Player.OnUpdateRender(self)
    
    local isLocal = self:GetIsLocalPlayer()
    
    // Synchronize the state of the light representing the flash light.
    self.flashlight:SetIsVisible(self.flashlightOn and (isLocal or self:GetIsVisible()) )
    
    if self.flashlightOn then
    
        local coords = Coords(self:GetViewCoords())
        coords.origin = coords.origin + coords.zAxis * 0.75
        
        self.flashlight:SetCoords(coords)
        
        // Only display atmospherics for third person players.
        local density = 0.2
        if isLocal and not self:GetIsThirdPerson() then
            density = 0
        end
        self.flashlight:SetAtmosphericDensity(density)
        
    end
    
    // Don't draw waypoint if we have hints displaying (to avoid the screen telling the player
    // about too many things to do)
    local waypointVisible = true
    if self.hints and self.hints:GetIsDisplayingHint() then
        waypointVisible = false
    end
    
    if self.waypoints then
        self.waypoints:SetWaypointVisible(waypointVisible)
    end
    
end

function Marine:CloseMenu()

    if self.buyMenu then
    
        GetGUIManager():DestroyGUIScript(self.buyMenu)
        self.buyMenu = nil
        MouseTracker_SetIsVisible(false)
        return true
        
    end
   
    return false
    
end

function Marine:AddNotification(locationId, techId)

    local locationName = ""

    if locationId ~= 0 then
        locationName = Shared.GetString(locationId)
    end

    table.insert(self.notifications, { LocationName = locationName, TechId = techId })

end

// this function returns the oldest notification and clears it from the list
function Marine:GetAndClearNotification()

    local notification = nil

    if table.count(self.notifications) > 0 then
    
        notification = { LocationName = self.notifications[1].LocationName, TechId = self.notifications[1].TechId }
        table.remove(self.notifications, 1)
    
    end
    
    return notification

end

function Marine:UpdateClientHelp()

    local kDefaultScanRange = 10
    local teamNumber = self:GetTeamNumber()
    
    // Look for structure that needs to be built
    function isBuildStructure(ent)
        return ent:GetCanConstruct(self)
    end
    
    local origin = self:GetModelOrigin()

    local structures = Shared.GetEntitiesWithTagInRange("class:Structure", origin, kDefaultScanRange, isBuildStructure)
    Shared.SortEntitiesByDistance(origin, structures)
    
    for index = 1, #structures do
        local structure = structures[index]
        local localizedStructureName = Locale.ResolveString(LookupTechData(structure:GetTechId(), kTechDataDisplayName))
        local buildStructureText = Locale.ResolveString("BUILD_STRUCTURE") .. localizedStructureName
        self:AddBindingHint("Use", structure:GetId(), buildStructureText, 3)
    end
    
    // Look for unattached resource nozzles
    /*
    function isFreeResourcePoint(ent)
        return (ent:GetAttached() == nil)
    end
    for index, nozzle in ipairs( GetSortedByFunctor("ResourcePoint", self:GetModelOrigin(), kDefaultScanRange, isFreeResourcePoint) ) do
        self:AddInfoHint(nozzle:GetId(), "UNATTACHED_NOZZLE", 1)
    end

    // Look for unbuilt resource nozzles
    function isFreeTechPoint(ent)
        return (ent:GetAttached() == nil)
    end
    for index, nozzle in ipairs( GetSortedByFunctor("TechPoint", self:GetModelOrigin(), kDefaultScanRange, isFreeTechPoint) ) do
        self:AddInfoHint(nozzle:GetId(), "UNATTACHED_TECH_POINT", 1)
    end
    */
    
    // Look for power nodes
    function isPowerPoint(ent)
        return true
    end
    
    local powerNodes = Shared.GetEntitiesWithTagInRange("class:PowerPoint", origin, kDefaultScanRange, isPowerPoint)
    Shared.SortEntitiesByDistance(origin, powerNodes)
    
    for index = 1, #powerNodes do
        local powerNode = powerNodes[index]
        local state = powerNode:GetPowerState()
        if powerNode:GetIsSocketed() and not powerNode:GetIsBuilt() then
            // Override BUILD_STRUCTURE above
            self:AddBindingHint("Use", powerNode:GetId(), "UNBUILT_POWER_NODE", 4)
        elseif state == powerNode:GetIsDisabled() then
            // If being repaired, tell marine to guard it
            if powerNode:GetRecentlyRepaired() then
                self:AddHint(powerNode:GetId(), "GUARD_POWER_NODE", 2)
            else
                // If we have a welder, show us a hint
                // otherwise a info hint
//                player:AddInfoHint(powerNode:GetId(), "DESTROYED_POWER_NODE", 2)
            end
        end
    end
       
end

function Marine:TriggerFootstep()

    Player.TriggerFootstep(self)
    
    if self:GetGameEffectMask(kGameEffect.OnInfestation) and self:GetIsSprinting() and self == Client.GetLocalPlayer() and not self:GetIsThirdPerson() then
    
        local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
        cinematic:SetRepeatStyle(Cinematic.Repeat_None)
        cinematic:SetCinematic(Marine.kInfestationFootstepCinematic)
    
    end

end

gCurrentHostStructureId = Entity.invalidId

function MarineUI_SetHostStructure(structure)

    if structure then
        gCurrentHostStructureId = structure:GetId()
    end    

end

function MarineUI_GetCurrentHostStructure()

    if gCurrentHostStructureId and gCurrentHostStructureId ~= Entity.invalidId then
        return Shared.GetEntity(gCurrentHostStructureId)
    end

    return nil    

end

// Bring up buy menu
function Marine:BuyMenu(structure)
    
    // Don't allow display in the ready room
    if self:GetTeamNumber() ~= 0 and Client.GetLocalPlayer() == self then
    
        if not self.buyMenu then
        
            self.buyMenu = GetGUIManager():CreateGUIScript("GUIMarineBuyMenu")
            
            MarineUI_SetHostStructure(structure)
            
            if structure then
                self.buyMenu:SetHostStructure(structure)
            end
            
            TEST_EVENT("Marine buy menu displayed")
            
        end
        
    end
    
end

function Marine:UpdateMisc(input)

    Player.UpdateMisc(self, input)
    
    if not Shared.GetIsRunningPrediction() then

        if input.move.x ~= 0 or input.move.z ~= 0 then

            self:CloseMenu()
            
        end
        
    end
    
end

// Give dynamic camera motion to the player
/*
function Marine:PlayerCameraCoordsAdjustment(cameraCoords) 

    if self:GetIsFirstPerson() then
        
        if self:GetIsStunned() then
            local attachPointOffset = self:GetAttachPointOrigin("Head") - cameraCoords.origin
            attachPointOffset.x = attachPointOffset.x * .5
            attachPointOffset.z = attachPointOffset.z * .5
            cameraCoords.origin = cameraCoords.origin + attachPointOffset
        end
    
    end
    
    return cameraCoords

end*/

function Marine:OnCountDown()

    Player.OnCountDown(self)
    
    if self.marineHUD then
        self.marineHUD:SetIsVisible(false)
    end

end

function Marine:OnCountDownEnd()

    Player.OnCountDownEnd(self)
    
    if self.marineHUD then
        self.marineHUD:SetIsVisible(true)
        self:TriggerHudInitEffects()
    end

end

function Marine:OnOrderSelfComplete(orderType)

    self:TriggerEffects("complete_order")

end

function Marine:GetSpeedDebugSpecial()
    return self:GetSprintTime() / SprintMixin.kMaxSprintTime
end

function Marine:OnUpdateSprint()

    /*if self.loopingSprintSoundEntId ~= Entity.invalidId then
    
        local soundEnt = Shared.GetEntity(self.loopingSprintSoundEntId)
        if soundEnt then
        
            // Note: This line is resulting in console spam:
            // SoundEventInstance::SetParameter(marine/common/sprint_loop, tired = 0.998213, 1): getValue():
            // Do not check in unless this is resolved. This method is not ideal in any case.
            soundEnt:SetParameter("tired", self:GetTiredScalar(), 1)
            
        end 
        
    end*/
    
end

function Marine:UpdateGhostModel()

    self.currentTechId = nil
    self.ghostStructureCoords = nil
    self.ghostStructureValid = false
    self.showGhostModel = false
    
    local weapon = self:GetActiveWeapon()

    if weapon and weapon:isa("LayMines") then
    
        self.currentTechId = kTechId.Mine
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
    
    end

end

function Marine:GetShowGhostModel()
    return self.showGhostModel
end    

function Marine:GetGhostModelTechId()
    return self.currentTechId
end

function Marine:GetGhostModelCoords()
    return self.ghostStructureCoords
end

function Marine:GetIsPlacementValid()
    return self.ghostStructureValid
end
