// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Cyst.lua
//
//    Created by:   Mats Olsson (mats.olsson@matsotech.se)
//
// A cyst controls and spreads infestation
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

Script.Load("lua/CommAbilities/Alien/EnzymeCloud.lua")
Script.Load("lua/CommAbilities/Alien/Rupture.lua")

class 'Cyst' (ScriptActor)

Cyst.kMaxEncodedPathLength = 30
Cyst.kMapName = "cyst"
Cyst.kModelName = PrecacheAsset("models/alien/cyst/cyst.model")

Cyst.kAnimationGraph = PrecacheAsset("models/alien/cyst/cyst.animation_graph")

Cyst.kEnergyCost = 25
Cyst.kPointValue = 5
// how fast the impulse moves
Cyst.kImpulseSpeed = 8

Cyst.kThinkInterval = 1 
Cyst.kImpulseColor = Color(1,1,0)
Cyst.kImpulseLightIntensity = 8
local kImpulseLightRadius = 1.5

Cyst.kExtents = Vector(0.2, 0.1, 0.2)

Cyst.kBurstDuration = 3

// range at which we can be a parent
Cyst.kCystParentRange = kCystParentRange

// size of infestation patch
Cyst.kInfestationRadius = kInfestationRadius
Cyst.kInfestationGrowthDuration = Cyst.kInfestationRadius / kCystInfestDuration

local networkVars =
{
    // Track our parentId
    parentId = "entityid",
    hasChild = "boolean",
        
    // when the last impulse was started. The impulse is inactive if the starttime + pathtime < now
    impulseStartTime = "time",
    
    // if we are connected. Note: do NOT use on the server side when calculating reconnects/disconnects,
    // as the random order of entity update means that you can't trust it to reflect the actual connect/disconnects
    // used on the client side by the ui to determine connection status for potently cyst building locations
    connected = "boolean",
    
    bursted = "boolean"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(PointGiverMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)

//
// To avoid problems with minicysts on walls connection to each other through solid rock,
// we need to move the start/end points a little bit along the start/end normals
//
local function CreateBetween(trackStart, startNormal, trackEnd, endNormal, startOffset, endOffset)

    trackStart = trackStart + startNormal * 0.01
    trackEnd = trackEnd + endNormal * 0.01
    
    local pathDirection = trackEnd - trackStart
    pathDirection:Normalize()
    
    if startOffset == nil then
        startOffset = 0.1
    end
    
    if endOffset == nil then
        endOffset = 0.1
    end
    
    // DL: Offset the points a little towards the center point so that we start with a polygon on a nav mesh
    // that is closest to the start. This is a workaround for edge case where a start polygon is picked on
    // a tiny island blocked off by an obstacle.
    trackStart = trackStart + pathDirection * startOffset
    trackEnd = trackEnd - pathDirection * endOffset
    
    local points = { }
    Pathing.GetPathPoints(trackEnd, trackStart, points)
    return points
    
end

//
// Convinience function when creating a path between two entities, submits the y-axis of the entities coords as
// the normal for use in CreateBetween()
//
function CreateBetweenEntities(srcEntity, endEntity)    
    return CreateBetween(srcEntity:GetOrigin(), srcEntity:GetCoords().yAxis, endEntity:GetOrigin(), endEntity:GetCoords().yAxis)    
end

if Server then
    Script.Load("lua/Cyst_Server.lua")
end

function Cyst:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, UmbraMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, FlinchMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, MaturityMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)    
    end

    self:SetPhysicsCollisionRep(CollisionRep.Move)
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
    self:SetLagCompensated(false)
    
end

function Cyst:OnDestroy()

    if Client then
    
        if self.light ~= nil then
            Client.DestroyRenderLight(self.light)
        end
        
    end
    
    ScriptActor.OnDestroy(self)
    
end

function Cyst:OnInitialized()

    InitMixin(self, InfestationMixin)
    
    ScriptActor.OnInitialized(self)
    
    self.parentId = Entity.invalidId

    if Server then
    
        // start out as disconnected; wait for impulse to arrive
        self.connected = false
        
        // mark us as not having received an impulse
        self.lastImpulseReceived = -1000
        
        self.lastImpulseSent = Shared.GetTime() 
        self.nextUpdate = Shared.GetTime()
        self.impulseActive = false
        self.bursted = false
        self.timeBursted = 0
        self.children = { }
        
        // initalize impulse setup
        self.impulseStartTime = 0
        
        InitMixin(self, SleeperMixin)
        InitMixin(self, StaticTargetMixin)

        self:SetModel(Cyst.kModelName, Cyst.kAnimationGraph)
        
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end       
        
    elseif Client then    
    
        InitMixin(self, UnitStatusMixin)
    
        // create the impulse light
        self.light = Client.CreateRenderLight()
        
        self.light:SetType( RenderLight.Type_Point )
        self.light:SetCastsShadows( false )

        self.lightCoords = CopyCoords(self:GetCoords())
        self.light:SetCoords( self.lightCoords )
        self.light:SetRadius(kImpulseLightRadius)
        self.light:SetIntensity( Cyst.kImpulseLightIntensity ) 
        self.light:SetColor( Cyst.kImpulseColor )
            
        self.light:SetIsVisible(true) 

    end
    
    self.points = nil
    self.pathLen = 0
    self.index = 1
    
    self:SetUpdates(true)
    
end

function Cyst:GetInfestationGrowthRate()
    return Cyst.kInfestationGrowthDuration
end

local kCystHealthbarOffset = Vector(0, 0.5, 0)
function Cyst:GetHealthbarOffset()
    return kCystHealthbarOffset
end 

/**
 * Infestation never sights nearby enemy players.
 */
function Cyst:OverrideCheckVision()
    return false
end

function Cyst:GetIsFlameAble()
    return true
end

function Cyst:GetMaturityRate()
    return kCystMaturationTime
end

function Cyst:GetMatureMaxHealth()
    return kMatureCystHealth
end 

function Cyst:GetMatureMaxArmor()
    return kMatureCystArmor
end 

function Cyst:GetMatureMaxEnergy()
    return 0
end

function Cyst:GetCanSleep()
    return true
end    

function _DebugTrack(points, dur, r, g, b, a, force)
    if force then
        local prevP = nil
        for _,p in ipairs(points) do
            if prevP then
                DebugLine(prevP, p,dur, r, g, b, a)
                DebugLine(p, p + Vector.yAxis , dur, r, g, b, a)
            end
            prevP = p
        end
    end
end

/**
 * Draw the track using the given color/dur (defaults to 30/green)
 */
function Cyst:Debug(dur, color)
    dur = dur or 30
    color = color or { 0, 1, 0, 1 }
    
    local r,g,b,a = unpack(color)
    
    _DebugTrack(self.points, dur,r,g,b,a, true)
end

function Cyst:StartOnSegment(index)

    assert(index <= table.count(self.points))
    assert(index >= 1)
    
    self.index = index
    if index < self.pathLen then
        self.segment = self.points[index+1]-self.points[index]
    else
        self.segment = Vector(0, 0, 0)
    end
    self.length = self.segment:GetLength()
    self.segmentLengthRemaining = self.length
    
end

function Cyst:GetTechButtons(techId)
  
    return  { kTechId.Rupture, kTechId.Infestation,  kTechId.None, kTechId.None,
              kTechId.None, kTechId.None, kTechId.None, kTechId.None }

end

local function AdvanceTo(self, time)

    if self.index == self.pathLen then
        return nil
    end
    
    if self.pathLen and self.pathLen == 1 then
        return nil
    end
    
    local deltaTime = time - self.currentTime
    self.currentTime = time
    
    local length = self.speed * deltaTime
    
    while self.segmentLengthRemaining > 0 and length > self.segmentLengthRemaining do
    
        self.index = self.index + 1
        if self.index == self.pathLen then
            return nil
        end
        
        length = length - self.segmentLengthRemaining
        self:StartOnSegment(self.index)
        
    end
    
    self.segmentLengthRemaining = math.max(0, self.segmentLengthRemaining - length)
    local fraction = (self.length - self.segmentLengthRemaining) / self.length
    return self.points[self.index] + self.segment * fraction
    
end

function Cyst:GetInfestationRadius()
    return Cyst.kInfestationRadius
end

function Cyst:GetCystParentRange()
    return Cyst.kCystParentRange
end  

/**
 * Note: On the server side, used GetIsActuallyConnected()!
 */
function Cyst:GetIsConnected() 
    return self.connected
end

function Cyst:GetDescription()

    local prePendText = ConditionalValue(self:GetIsConnected(), "", "Unconnected ")
    return prePendText .. ScriptActor.GetDescription(self)
    
end

function Cyst:OnOverrideSpawnInfestation(infestation)

    infestation.maxRadius = kInfestationRadius
    // New infestation starts partially built, but this allows it to start totally built at start of game 
    local radiusPercent = math.max(infestation:GetRadius(), .2)
    infestation:SetRadiusPercent(radiusPercent)
    
end

function Cyst:Restart(time)

    self.startTime = time
    self.currentTime = time
    self.index = 1
    self.speed = Cyst.kImpulseSpeed
    self.pathLen = #(self.points)
    self:StartOnSegment(1)
    
end

function Cyst:GetReceivesStructuralDamage()
    return true
end

local function ServerUpdate(self, point, deltaTime)
    
    if not self:GetIsAlive() then
        return
    end
    
    if self.bursted then    
        self.bursted = self.timeBursted + Cyst.kBurstDuration > Shared.GetTime()    
    end
    
    local now = Shared.GetTime()
    
    if now > self.nextUpdate then
    
        local connectedNow = self:GetIsActuallyConnected()
        
        // the very first time we are placed, we try to connect 
        if not self.madeInitialConnectAttempt then
        
            if not connectedNow then 
                connectedNow = self:TryToFindABetterParent()
            end
            
            self.madeInitialConnectAttempt = true
            
        end
        
        // try a single reconnect when we become disconnected
        if self.connected and not connectedNow then
            connectedNow = self:TryToFindABetterParent()
        end
        
        // if we become connected, see if we have any unconnected cysts around that could use us as their parents
        if not self.connected and connectedNow then
            self:ReconnectOthers()
        end
        
        self.connected = connectedNow
        
        // point == nil signals that the impulse tracker is done
        if self.impulseActive and point == nil then
        
            self.lastImpulseReceived = now
            self.impulseActive = false
            
        end
        
        // if we have received an impulse but hasn't sent one out yet, send one
        if self.lastImpulseReceived > self.lastImpulseSent then
        
            self:FireImpulses(now)
            self.lastImpulseSent = now
            
        end
        // avoid clumping; don't use now when calculating next think time (large kThinkTime)
        self.nextUpdate = self.nextUpdate + Cyst.kThinkTime
        
        // Take damage if not connected 
        if not self.connected then
            self:TriggerDamage()
        end
        
    end
    
end

function Cyst:GetHasChild()
    return self.hasChild
end

function Cyst:OnUpdate(deltaTime)

    PROFILE("Cyst:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)
    
    local point = nil
    local now = Shared.GetTime()
    
    // Make a connect to the parent so we can do the visual whatevers
    // the client and server could differ in these paths but to be honest
    // the server is always the authority the client is just for visuals
    // which could be out of sync
    if self.points == nil then
    
        local parent = self:GetCystParent()
        if parent ~= nil then
        
            // Create the connect between me and my parent
            local parentOrigin = parent:GetOrigin()
            local myOrigin = self:GetOrigin()
            
            self.points = CreateBetweenEntities(self, parent)
            if self.points and #self.points > 0 then
                self:Restart(self.impulseStartTime)
            end
            
        end
        
    elseif #self.points > 0 then
    
        // if we have a tracker, check if we need to restart it
        if self.impulseStartTime ~= self.startTime then
            self:Restart(self.impulseStartTime)
        end
        
        // Advanced the point on the timeline
        point = AdvanceTo(self, now)
        
    end
    
    if Server then
    
        ServerUpdate(self, point, deltaTime)
        self.hasChild = #self.children > 0
        
    elseif Client then
    
        self.light:SetIsVisible(point ~= nil and not self:GetIsCloaked())
        
        if point then
        
            self.lightCoords.origin = point
            self.light:SetCoords(self.lightCoords)
            
        end
        
        if not self.connectedFraction then
            self.connectedFraction = self.connected and 1 or 0
        end
        
        local animate = 1
        if not self.connected then
            animate = -1
        end

        self.connectedFraction = Clamp(self.connectedFraction + animate * deltaTime, 0, 1)
        
    end
    
end

function Cyst:GetCystParent()

    local parent = nil
    
    if self.parentId and self.parentId ~= Entity.invalidId then
        parent = Shared.GetEntity(self.parentId)
    end
    
    return parent
    
end

/**
 * Returns a parent and the track from that parent, or nil if none found.
 */
function GetCystParentFromPoint(origin, normal, connectionMethodName, optionalIgnoreEnt)

    PROFILE("Cyst:GetCystParentFromPoint")
    
    local ents = GetSortedListOfPotentialParents(origin)
    
    for i, ent in ipairs(ents) do
    
        // must be either a built hive or an cyst with a connected infestation
        if optionalIgnoreEnt ~= ent and
           ((ent:isa("Hive") and ent:GetIsBuilt()) or (ent:isa("Cyst") and ent[connectionMethodName](ent))) then
            
            local range = (origin - ent:GetOrigin()):GetLength()
            if range <= ent:GetCystParentRange() then
            
                // check if we have a track from the entity to origin
                local endOffset = 0.1
                if ent:isa("Hive") then
                    endOffset = 3
                end
                
                local path = CreateBetween(origin, normal, ent:GetOrigin(), ent:GetCoords().yAxis, 0.1, endOffset)
                if path then
                
                    // Check that the total path length is within the range.
                    local pathLength = GetPointDistance(path)
                    if pathLength <= ent:GetCystParentRange() then
                        return ent, path
                    end
                    
                end
                
            end
            
        end
        
    end
    
    return nil, nil
    
end

/**
 * Return true if a connected cyst parent is availble at the given origin normal. 
 */
function GetCystParentAvailableAndSpaceClear(techId, origin, normal, commander)

    local parent, path = GetCystParentFromPoint(origin, normal, "GetIsConnected")
    local spaceClear = #GetEntitiesWithinRange("Cyst", origin, 2) == 0
    return parent ~= nil and spaceClear
    
end

/**
 * Returns a ghost-guide table for gui-use. 
 */
function GetCystGhostGuides(commander)

    local parent, path = commander:GetCystParentFromCursor()
    local result = { }
    
    if parent then
        result[parent] = parent:GetCystParentRange()
    end
    
    return result
    
end

function GetSortedListOfPotentialParents(origin)
    
    function sortByDistance(ent1, ent2)
        return (ent1:GetOrigin() - origin):GetLength() < (ent2:GetOrigin() - origin):GetLength()
    end
    
    // first, check for hives
    local hives = GetEntitiesWithinRange("Hive", origin, kHiveCystParentRange)
    table.sort(hives, sortByDistance)
    
    // add in the cysts. We get all cysts here, but mini-cysts have a shorter parenting range (bug, should be filtered out)
    local cysts = GetEntitiesWithinRange("Cyst", origin, kCystParentRange)
    table.sort(cysts, sortByDistance)
    
    local parents = {}
    table.copy(hives, parents)
    table.copy(cysts, parents, true)
    
    return parents
    
end

// Temporarily don't use "target" attach point
function Cyst:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, 0.2, 0)
end

function Cyst:GetIsHealableOverride()
  return self:GetIsAlive() and self:GetIsConnected()
end

function Cyst:PerformActivation(techId, position, normal, commander)

    if techId == kTechId.Rupture and self:GetMaturityLevel() == kMaturityLevel.Mature then
            
        CreateEntity(Rupture.kMapName, self:GetOrigin(), self:GetTeamNumber())            
        self.bursted = true
        self.timeBursted = Shared.GetTime()
        self:ResetMaturity()
        
        return true, true
        
    end
    
    return false, true
    
end

function Cyst:OnUpdateRender()

    PROFILE("Cyst:OnUpdateRender")

    local model = self:GetRenderModel()
    if model and self.connectedFraction then
        model:SetMaterialParameter("connected", self.connectedFraction)
    end

end

function Cyst:OverrideHintString(hintString)

    if not self:GetIsConnected() then
        return "CYST_UNCONNECTED_HINT"
    end
    
    return hintString
    
end

local kCystTraceStartPoint =
{
    Vector(0.2, 0.3, 0.2),
    Vector(-0.2, 0.3, 0.2),
    Vector(0.2, 0.3, -0.2),
    Vector(-0.2, 0.3, -0.2),

}

local kDownVector = Vector(0, -1, 0)

function AlignCyst(coords, normal)

    if Server and normal then
    
        // get average normal:
        for _, startPoint in ipairs(kCystTraceStartPoint) do
        
            local startTrace = coords:TransformPoint(startPoint)
            local trace = Shared.TraceRay(startTrace, startTrace + kDownVector, CollisionRep.Select, PhysicsMask.CommanderBuild, EntityFilterAll())
            if trace.fraction ~= 1 then
                normal = normal + trace.normal
            end
        
        end
        
        normal:Normalize()

        coords.yAxis = normal
        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)

    end
    
    return coords

end

Shared.LinkClassToMap("Cyst", Cyst.kMapName, networkVars)