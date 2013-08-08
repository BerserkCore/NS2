// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\MAC.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// AI controllable flying robot marine commander can control. Used to build structures
// and has other special abilities. 
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/Marine/EMPBlast.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/DoorMixin.lua")
Script.Load("lua/BuildingMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/UpgradableMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/MobileTargetMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/AttackOrderMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/VortexAbleMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/CombatMixin.lua")

class 'MAC' (ScriptActor)

MAC.kMapName = "mac"

MAC.kModelName = PrecacheAsset("models/marine/mac/mac.model")
MAC.kAnimationGraph = PrecacheAsset("models/marine/mac/mac.animation_graph")

MAC.kConfirmSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/confirm")
MAC.kConfirm2DSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/confirm_2d")
MAC.kStartConstructionSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/constructing")
MAC.kStartConstruction2DSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/constructing_2d")
MAC.kStartWeldSound = PrecacheAsset("sound/NS2.fev/marine/structures/mac/weld_start")
MAC.kHelpingSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/help_build")
MAC.kPassbyMACSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/passby_mac")
MAC.kPassbyDrifterSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/passby_driffter")

MAC.kUsedSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/use")

// Animations
MAC.kAnimAttack = "attack"

local kJetsCinematic = PrecacheAsset("cinematics/marine/mac/jet.cinematic")
local kJetsSound = PrecacheAsset("sound/NS2.fev/marine/structures/mac/thrusters")

local kRightJetNode = "fxnode_jet1"
local kLeftJetNode = "fxnode_jet2"
MAC.kLightNode = "fxnode_light"
MAC.kWelderNode = "fxnode_welder"

// Balance
local kConstructRate = 0.4
local kWeldRate = 0.5
local kOrderScanRadius = 10
MAC.kRepairHealthPerSecond = 50
MAC.kHealth = kMACHealth
MAC.kArmor = kMACArmor
MAC.kMoveSpeed = 4.5
MAC.kHoverHeight = .5
MAC.kStartDistance = 3
MAC.kWeldDistance = 2
MAC.kBuildDistance = 2     // Distance at which bot can start building a structure. 
MAC.kSpeedUpgradePercent = (1 + kMACSpeedAmount)

MAC.kCapsuleHeight = .2
MAC.kCapsuleRadius = .5

// Greetings
MAC.kGreetingUpdateInterval = 1
MAC.kGreetingInterval = 10
MAC.kGreetingDistance = 5
MAC.kUseTime = 2.0

MAC.kTurnSpeed = 3 * math.pi // a mac is nimble
local networkVars =
{
    welding = "boolean",
    constructing = "boolean",
    moving = "boolean",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(AttackOrderMixin, networkVars)
AddMixinNetworkVars(VortexAbleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)

function MAC:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, DoorMixin)
    InitMixin(self, BuildingMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, PathingMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, AttackOrderMixin)
    InitMixin(self, VortexAbleMixin)
    InitMixin(self, CombatMixin)
    
    if Server then
    
        InitMixin(self, RepositioningMixin)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end

    elseif Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetUpdates(true)
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
end

function MAC:OnInitialized()
    
    ScriptActor.OnInitialized(self)

    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)

    if Server then
    
        self:UpdateIncludeRelevancyMask()
        
        InitMixin(self, SleeperMixin)
        InitMixin(self, MobileTargetMixin)
        
        self.jetsSound = Server.CreateEntity(SoundEffect.kMapName)
        self.jetsSound:SetAsset(kJetsSound)
        self.jetsSound:SetParent(self)

    elseif Client then
        InitMixin(self, UnitStatusMixin)      

        // Setup movement effects
        self.jetsCinematics = {}
        for index,attachPoint in ipairs({ kLeftJetNode, kRightJetNode }) do
            self.jetsCinematics[index] = Client.CreateCinematic(RenderScene.Zone_Default)
            self.jetsCinematics[index]:SetCinematic(kJetsCinematic)
            self.jetsCinematics[index]:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.jetsCinematics[index]:SetParent(self)
            self.jetsCinematics[index]:SetCoords(Coords.GetIdentity())
            self.jetsCinematics[index]:SetAttachPoint(self:GetAttachPointIndex(attachPoint))
            self.jetsCinematics[index]:SetIsActive(false)
        end

    end
    
    self.timeOfLastGreeting = 0
    self.timeOfLastGreetingCheck = 0
    self.timeOfLastChatterSound = 0
    self.timeOfLastWeld = 0
    self.timeOfLastConstruct = 0
    self.moving = false
    
    self:SetModel(MAC.kModelName, MAC.kAnimationGraph)
    
end

function MAC:GetTurnSpeedOverride()
    return MAC.kTurnSpeed
end

function MAC:GetCanSleep()
    return self:GetCurrentOrder() == nil
end

function MAC:GetMinimumAwakeTime()
    return 5
end

function MAC:GetExtentsOverride()
    return Vector(MAC.kCapsuleRadius, MAC.kCapsuleHeight / 2, MAC.kCapsuleRadius)
end

function MAC:GetFov()
    return 120
end

function MAC:GetIsFlying()
    return true
end

function MAC:GetReceivesStructuralDamage()
    return true
end

function MAC:OnUse(player, elapsedTime, useSuccessTable)

    // Play flavor sounds when using MAC.
    if Server then
    
        local time = Shared.GetTime()
        
        if self.timeOfLastUse == nil or (time > (self.timeOfLastUse + MAC.kUseTime)) then
        
            Server.PlayPrivateSound(player, MAC.kUsedSoundName, self, 1.0, Vector(0, 0, 0))
            self.timeOfLastUse = time
            
        end
        
    end
    
end

function MAC:GetHoverHeight()
    return MAC.kHoverHeight
end

function MAC:OnOverrideOrder(order)

    local orderTarget = nil
    if (order:GetParam() ~= nil) then
        orderTarget = Shared.GetEntity(order:GetParam())
    end
    
    // Default orders to unbuilt friendly structures should be construct orders
    if(order:GetType() == kTechId.Default and GetOrderTargetIsConstructTarget(order, self:GetTeamNumber())) then
    
        order:SetType(kTechId.Construct)

    elseif(order:GetType() == kTechId.Default and GetOrderTargetIsWeldTarget(order, self:GetTeamNumber())) then
    
        order:SetType(kTechId.Weld)
        
    elseif(order:GetType() == kTechId.Weld and not GetOrderTargetIsWeldTarget(order, self:GetTeamNumber())) then

        // Not valid, cancel order
        order:SetType(kTechId.None)
        
    // If target is enemy, attack it
    elseif (order:GetType() == kTechId.Default) and orderTarget ~= nil and HasMixin(orderTarget, "Live") and GetEnemyTeamNumber(self:GetTeamNumber()) == orderTarget:GetTeamNumber() and orderTarget:GetIsAlive() and (not HasMixin(orderTarget, "LOS") or orderTarget:GetIsSighted()) then
    
        order:SetType(kTechId.Attack)

    elseif((order:GetType() == kTechId.Default or order:GetType() == kTechId.Move) and (order:GetParam() ~= nil)) then
        
        // Convert default order (right-click) to move order
        order:SetType(kTechId.Move)
        
    end
    
end

function MAC:GetIsOrderHelpingOtherMAC(order)

    if order:GetType() == kTechId.Construct then
    
        // Look for friendly nearby MACs
        local macs = GetEntitiesForTeamWithinRange("MAC", self:GetTeamNumber(), self:GetOrigin(), 3)
        for index, mac in ipairs(macs) do
        
            if mac ~= self then
            
                local otherMacOrder = mac:GetCurrentOrder()
                if otherMacOrder ~= nil and otherMacOrder:GetType() == order:GetType() and otherMacOrder:GetParam() == order:GetParam() then
                    return true
                end
                
            end
            
        end
        
    end
    
    return false
end

function MAC:OnOrderChanged()
    local order = self:GetCurrentOrder()    
    if order then
    
        local owner = self:GetOwner()
        
        if not owner then
            local commanders = GetEntitiesForTeam("Commander", self:GetTeamNumber())
            if commanders and commanders[1] then
                owner = commanders[1]
            end    
        end

        // Look for nearby MAC doing the same thing
        if self:GetIsOrderHelpingOtherMAC(order) then
            self:PlayChatSound(MAC.kHelpingSoundName)            
        elseif order:GetType() == kTechId.Construct then
        
            self:PlayChatSound(MAC.kStartConstructionSoundName)
            
            if owner then
                Server.PlayPrivateSound(owner, MAC.kStartConstruction2DSoundName, owner, 1.0, Vector(0, 0, 0))
            end
            
        elseif order:GetType() == kTechId.Weld then 
       
            self:PlayChatSound(MAC.kStartWeldSound) 

            if owner then
                Server.PlayPrivateSound(owner, MAC.kStartWeldSound, owner, 1.0, Vector(0, 0, 0))
            end
           
        else
        
            self:PlayChatSound(MAC.kConfirmSoundName)
            
            if owner then
                Server.PlayPrivateSound(owner, MAC.kConfirm2DSoundName, owner, 1.0, Vector(0, 0, 0))
            end
            
        end

    end

end

function MAC:OnDestroyCurrentOrder(currentOrder)
    
    local orderTarget = nil
    if currentOrder:GetParam() ~= nil then
        orderTarget = Shared.GetEntity(currentOrder:GetParam())
    end
    
    if currentOrder:GetType() == kTechId.Weld and GetOrderTargetIsWeldTarget(currentOrder, self:GetTeamNumber()) and orderTarget.OnWeldCanceled then
        orderTarget:OnWeldCanceled(self)
    end

end

function MAC:OverrideTechTreeAction(techNode, position, orientation, commander)

    local success = false
    local keepProcessing = true
    
    // Convert build tech actions into build orders for selected MACs
    if techNode:GetIsBuild() then
    
        self:GiveOrder(kTechId.Build, techNode:GetTechId(), position, orientation, not commander.queuingOrders, false, commander)
        
        // If MAC was orphaned by commander that has left chair or server, take control
        if self:GetOwner() == nil then
            self:SetOwner(commander)
        end
        
        success = true
        keepProcessing = false
        
    end
    
    return success, keepProcessing
    
end

function MAC:GetMoveSpeed()

    local moveSpeed = GetDevScalar(MAC.kMoveSpeed, 8)
    local techNode = self:GetTeam():GetTechTree():GetTechNode(kTechId.MACSpeedTech)

    if techNode and techNode:GetResearched() then
        moveSpeed = moveSpeed * MAC.kSpeedUpgradePercent
    end

    return moveSpeed
    
end

function MAC:ProcessWeldOrder(deltaTime)

    local time = Shared.GetTime()
    
    local order = self:GetCurrentOrder()
    local targetId = order:GetParam()
    local target = Shared.GetEntity(targetId)
    local canBeWeldedNow = false

    // Not allowed to weld after taking damage recently.
    if Shared.GetTime() - self:GetTimeLastDamageTaken() <= 1.0 then
    
        TEST_EVENT("MAC cannot weld after taking damage")
        return
        
    end
    
    if self.timeOfLastWeld == 0 or time > self.timeOfLastWeld + kWeldRate then
    
        // It is possible for the target to not be weldable at this point.
        // This can happen if a damaged Marine becomes Commander for example.
        // The Commander is not Weldable but the Order correctly updated to the
        // new entity Id of the Commander. In this case, the order will simply be completed.
        if target ~= nil and HasMixin(target, "Weldable") then
        
            local targetPosition = Vector(target:GetOrigin())
            local toTarget = (targetPosition - Vector(self:GetOrigin()))
            local distanceToTarget = toTarget:GetLength()
            canBeWeldedNow = target:GetCanBeWelded(self)
            
            local obstacleSize = 0
            if HasMixin(target, "Extents") then
                obstacleSize = target:GetExtents():GetLengthXZ()
            end
            
            // If we're close enough to weld, weld
            if distanceToTarget - obstacleSize < MAC.kWeldDistance and not GetIsVortexed(self) then
            
                if canBeWeldedNow then
                
                    target:OnWeld(self, kWeldRate)
                    self.timeOfLastWeld = time
                                        
                elseif not canBeWeldedNow then
                    self:CompletedCurrentOrder()
                end
                
            else
            
                // otherwise move towards it
                local hoverAdjustedLocation = GetHoverAt(self, target:GetEngagementPoint())
                local doneMoving = self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime)
                self.moving = not doneMoving
                
            end
            
        end
        
        // If door or structure is welded, complete order
        if target == nil or not canBeWeldedNow then
            self:CompletedCurrentOrder()
        end
        
    end
    
    // Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if not self.moving then
        local toOrder = (order:GetLocation() - Vector(self:GetOrigin()))
        self:SmoothTurn(deltaTime, GetNormalizedVector(toOrder), 0)
    end
    
end

function MAC:ProcessMove(deltaTime)

    local currentOrder = self:GetCurrentOrder()
    local hoverAdjustedLocation = GetHoverAt(self, currentOrder:GetLocation())

    if self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime) then

        self:CompletedCurrentOrder()
        self.moving = false

    else
        self.moving = true
    end
    
end

function MAC:PlayChatSound(soundName)

    if self.timeOfLastChatterSound == 0 or (Shared.GetTime() > self.timeOfLastChatterSound + 2) then
        self:PlaySound(soundName)
        self.timeOfLastChatterSound = Shared.GetTime()
    end
    
end

// Look for other MACs and Drifters to greet as we fly by 
function MAC:UpdateGreetings()

    local time = Shared.GetTime()
    if self.timeOfLastGreetingCheck == 0 or (time > (self.timeOfLastGreetingCheck + MAC.kGreetingUpdateInterval)) then
    
        if self.timeOfLastGreeting == 0 or (time > (self.timeOfLastGreeting + MAC.kGreetingInterval)) then
        
            local ents = GetEntitiesMatchAnyTypes({"MAC", "Drifter"})
            for index, ent in ipairs(ents) do
            
                if (ent ~= self) and (self:GetOrigin() - ent:GetOrigin()):GetLength() < MAC.kGreetingDistance then
                
                    if GetCanSeeEntity(self, ent) then
                        if ent:isa("MAC") then
                            self:PlayChatSound(MAC.kPassbyMACSoundName)
                        elseif ent:isa("Drifter") then
                            self:PlayChatSound(MAC.kPassbyDrifterSoundName)
                        end
                        
                        self.timeOfLastGreeting = time
                        break
                        
                    end
                    
                end                    
                    
            end                
                            
        end
        
        self.timeOfLastGreetingCheck = time
        
    end

end

function MAC:GetCanBeWeldedOverride()
    return self.lastTakenDamageTime + 1 < Shared.GetTime()
end

function MAC:GetEngagementPointOverride()
    return self:GetOrigin()
end

function MAC:ProcessBuildConstruct(deltaTime)

    local time = Shared.GetTime()
    
    local currentOrder = self:GetCurrentOrder()
    local toTarget = (currentOrder:GetLocation() - self:GetOrigin());
    local distToTarget = toTarget:GetLengthXZ()
    
    if self.timeOfLastConstruct == 0 or (time > (self.timeOfLastConstruct + kConstructRate)) then
    
        local engagementDist = ConditionalValue(currentOrder:GetType() == kTechId.Build, GetEngagementDistance(currentOrder:GetParam(), true), GetEngagementDistance(currentOrder:GetParam()))
        if distToTarget < engagementDist then
        
            // Create structure here
            if currentOrder:GetType() == kTechId.Build then
            
                local commander = self:GetOwner()
                if commander then
                
                    local techId = currentOrder:GetParam()
                    assert(techId ~= 0)
                    
                    local techNode = commander:GetTechTree():GetTechNode(techId)
                    local cost = (techNode and techNode:GetCost()) or nil
                    assert(cost ~= nil)
                    local team = commander:GetTeam()
                    
                    if team:GetTeamResources() >= cost then
                    
                        local success, createdStructureId = self:AttemptToBuild(techId, currentOrder:GetLocation(), Vector(0, 1, 0), currentOrder:GetOrientation(), nil, nil, self, currentOrder:GetOwner())
                        
                        // Now construct it
                        if success then
                        
                            self:CompletedCurrentOrder()
                            team:AddTeamResources(-cost)
                            self:GiveOrder(kTechId.Construct, createdStructureId, nil, nil, false, true)
                            
                        else
                        
                            // Issue alert to commander that way was blocked?
                            self:GetTeam():TriggerAlert(kTechId.MarineAlertMACBlocked, self)
                            
                        end
                        
                    else
                    
                        self:GetTeam():TriggerAlert(kTechId.MarineAlertNotEnoughResources, self)
                        
                        // Cancel build bots orders so he doesn't move away
                        self:ClearOrders()
                        
                    end
                    
                else
                    self:ClearOrders()
                end
                
            else
            
                // Construct structure
                local constructTarget = GetOrderTargetIsConstructTarget(self:GetCurrentOrder(), self:GetTeamNumber())
                if constructTarget then
                
                    // Otherwise, add build time to structure
                    if not self:GetIsVortexed() and not GetIsVortexed(constructTarget) then
                        constructTarget:Construct(kConstructRate * kMACConstructEfficacy, self)
                        self.timeOfLastConstruct = time
                    end
                    
                else
                    self:CompletedCurrentOrder()
                end
                
            end
            
        else
        
            local hoverAdjustedLocation = GetHoverAt(self, currentOrder:GetLocation())
            local doneMoving = self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime)
            self.moving = not doneMoving
            
        end
        
    end
    
    // Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if not self.moving then
        self:SmoothTurn(deltaTime, GetNormalizedVector(toTarget), 0)
    end
    
end

local function FindSomethingToDo(self)

    if self.timeOfLastFindSomethingTime == nil or Shared.GetTime() > self.timeOfLastFindSomethingTime + 1 then
    
        self.timeOfLastFindSomethingTime = Shared.GetTime()
        
        // If there's a friendly entity nearby that needs constructing, constuct it.
        local constructables = GetEntitiesWithMixinForTeamWithinRange("Construct", self:GetTeamNumber(), self:GetOrigin(), kOrderScanRadius)
        for c = 1, #constructables do
        
            local constructable = constructables[c]
            if constructable:GetCanConstruct(self) then
            
                local acceptedOrder = self:GiveOrder(kTechId.Construct, constructable:GetId(), constructable:GetOrigin(), nil, false, false) ~= kTechId.None
                return acceptedOrder
                
            end
            
        end
        
        // Look for entities to heal with weld.
        local weldables = GetEntitiesWithMixinForTeamWithinRange("Weldable", self:GetTeamNumber(), self:GetOrigin(), kOrderScanRadius)
        for w = 1, #weldables do
        
            local weldable = weldables[w]
            // There are cases where the weldable's weld percentage is very close to
            // 100% but not exactly 100%. This second check prevents the MAC from being so pedantic.
            if weldable:GetCanBeWelded(self) and weldable:GetWeldPercentage() < 0.95 then
                return self:GiveOrder(kTechId.Weld, weldable:GetId(), weldable:GetOrigin(), nil, false, false) ~= kTechId.None
            end
            
        end
        
    end
    
    return false
    
end

local function UpdateOrders(self, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
    
        if currentOrder:GetType() == kTechId.Move then
        
            self:ProcessMove(deltaTime)
            self:UpdateGreetings()
            
        elseif currentOrder:GetType() == kTechId.Attack then
            self:ProcessAttackOrder(1, GetDevScalar(MAC.kMoveSpeed, 8), deltaTime)
        elseif currentOrder:GetType() == kTechId.Weld then
            self:ProcessWeldOrder(deltaTime)
        elseif currentOrder:GetType() == kTechId.Build or currentOrder:GetType() == kTechId.Construct then
            self:ProcessBuildConstruct(deltaTime)
        end
        
    end
    
end

function MAC:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
    if Server and self:GetIsAlive() then

        // assume we're not moving initially
        self.moving = false
    
        if not self:GetHasOrder() then
            FindSomethingToDo(self)
        else
            UpdateOrders(self, deltaTime)
        end
        
        self.constructing = Shared.GetTime() - self.timeOfLastConstruct < 0.5
        self.welding = Shared.GetTime() - self.timeOfLastWeld < 0.5

        if self.moving and not self.jetsSound:GetIsPlaying() then
            self.jetsSound:Start()
        elseif not self.moving and self.jetsSound:GetIsPlaying() then
            self.jetsSound:Stop()
        end
        
    // client side build / weld effects
    elseif Client and self:GetIsAlive() then
    
        if self.constructing then
        
            if not self.timeLastConstructEffect or self.timeLastConstructEffect + kConstructRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_construct")
                self.timeLastConstructEffect = Shared.GetTime()
                
            end
            
        end
        
        if self.welding then
        
            if not self.timeLastWeldEffect or self.timeLastWeldEffect + kWeldRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_weld")
                self.timeLastWeldEffect = Shared.GetTime()
                
            end
            
        end
        
        if self:GetHasOrder() ~= self.clientHasOrder then
        
            self.clientHasOrder = self:GetHasOrder()
            
            if self.clientHasOrder then
                self:TriggerEffects("mac_set_order")
            end
            
        end

        if self.jetsCinematics then

            for id,cinematic in ipairs(self.jetsCinematics) do
                self.jetsCinematics[id]:SetIsActive(self.moving and self:GetIsVisible())
            end

        end

    end
    
end

function MAC:PerformActivation(techId, position, normal, commander)

    if techId == kTechId.MACEMP then
    
        local empBlast = CreateEntity(EMPBlast.kMapName, self:GetOrigin(), self:GetTeamNumber())
        return empBlast ~= nil, false
    
    end
    
    return ScriptActor.PerformActivation(self, techId, position, normal, commander)
    
end

function MAC:GetMeleeAttackOrigin()
    return self:GetAttachPointOrigin("fxnode_welder")
end

function MAC:GetMeleeAttackDamage()
    return kMACAttackDamage
end

function MAC:GetMeleeAttackInterval()
    return kMACAttackFireDelay 
end

function MAC:GetTechButtons(techId)

    if(techId == kTechId.RootMenu) then return 
            {   kTechId.Attack, kTechId.Stop, kTechId.Welding, kTechId.None,
                kTechId.MACEMP, kTechId.None, kTechId.None, kTechId.None }

    else return nil end
    
end

function MAC:OnOverrideDoorInteraction(inEntity)
    // MACs will not open the door if they are currently
    // welding it shut
    if self:GetHasOrder() then
        local order = self:GetCurrentOrder()
        local targetId = order:GetParam()
        local target = Shared.GetEntity(targetId)
        if (target ~= nil) then
            if (target == inEntity) then
               return false, 0
            end
        end
    end
    return true, 4
end

function MAC:UpdateIncludeRelevancyMask()
    SetAlwaysRelevantToCommander(self, true)
end

if Server then
	
	function MAC:GetCanReposition()
	    return true
	end
	
	function MAC:OverrideRepositioningSpeed()
	    return MAC.kMoveSpeed *.3
	end	
	
	function MAC:OverrideRepositioningDistance()
	    return 0.8
	end	

    function MAC:OverrideGetRepositioningTime()
	    return .5
	end

end

local function GetOrderMovesMAC(orderType)

    return orderType == kTechId.Move or
           orderType == kTechId.Attack or
           orderType == kTechId.Build or
           orderType == kTechId.Construct or
           orderType == kTechId.Weld

end

function MAC:OnUpdateAnimationInput(modelMixin)

    PROFILE("MAC:OnUpdateAnimationInput")
    
    local move = "idle"
    local currentOrder = self:GetCurrentOrder()
    if currentOrder then
    
        if GetOrderMovesMAC(currentOrder:GetType()) then
            move = "run"
        end
    
    end
    modelMixin:SetAnimationInput("move",  move)
    
    local currentTime = Shared.GetTime()
    local activity = "none"
    if currentTime - self:GetTimeOfLastAttackOrder() < 0.5 then
        activity = "primary"
    elseif self.constructing or self.welding then
        activity = "build"
    end
    modelMixin:SetAnimationInput("activity", activity)

end

function MAC:GetShowHitIndicator()
    return false
end

local kMACHealthbarOffset = Vector(0, 1.4, 0)
function MAC:GetHealthbarOffset()
    return kMACHealthbarOffset
end 

function MAC:OnDestroy()

    Entity.OnDestroy(self)

    if Client then

        for id,cinematic in ipairs(self.jetsCinematics) do

            Client.DestroyCinematic(cinematic)
            self.jetsCinematics[id] = nil

        end

    end
    
end

Shared.LinkClassToMap("MAC", MAC.kMapName, networkVars, true)
