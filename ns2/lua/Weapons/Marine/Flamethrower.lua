// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Flamethrower.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) 
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/Weapons/Marine/Flame.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/LiveMixin.lua")

class 'Flamethrower' (ClipWeapon)

if Client then
    Script.Load("lua/Weapons/Marine/Flamethrower_Client.lua")
end

Flamethrower.kMapName = "flamethrower"

Flamethrower.kModelName = PrecacheAsset("models/marine/flamethrower/flamethrower.model")
local kViewModelName = PrecacheAsset("models/marine/flamethrower/flamethrower_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/flamethrower/flamethrower_view.animation_graph")

local kFlameFullCinematic = PrecacheAsset("cinematics/marine/flamethrower/flame_trail_full.cinematic")
local kFlameHalfCinematic = PrecacheAsset("cinematics/marine/flamethrower/flame_trail_half.cinematic")
local kFlameShortCinematic = PrecacheAsset("cinematics/marine/flamethrower/flame_trail_short.cinematic")
local kFlameImpactCinematic = PrecacheAsset("cinematics/marine/flamethrower/flame_impact3.cinematic")
local kFlameSmokeCinematic = PrecacheAsset("cinematics/marine/flamethrower/flame_trail_light.cinematic")

local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/flamethrower/attack_loop")

local kRange = kFlamethrowerRange
local kUpgradedRange = kFlamethrowerUpgradedRange

local kParticleEffectRate = .05
local kSmokeEffectRate = 1.5
local kImpactEffectRate = 0.3
local kPilotEffectRate = 0.3
local kTrailLength = 9.5
local kConeWidth = 0.17

local kFirstPersonTrailCinematics =
{
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part3.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part3.cinematic"),
}

local kTrailCinematics =
{
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_part3.cinematic"),
}

local kFirstPersonFadeOutCinematicNames =
{
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part3.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part3.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part3.cinematic"),
}

local networkVars =
{ 
    createParticleEffects = "boolean",
    createImpactEffects = "boolean",
    animationDoneTime = "float",
    loopingSoundEntId = "entityid",
    range = "integer (0 to 11)"
}

AddMixinNetworkVars(LiveMixin, networkVars)

function Flamethrower:OnCreate()

    ClipWeapon.OnCreate(self)
    
    self.loopingSoundEntId = Entity.invalidId
    
    if Server then
    
        self.createParticleEffects = false
        self.createImpactEffects = false
        self.animationDoneTime = 0
        
        self.loopingFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingFireSound:SetAsset(kFireLoopingSound)
        self.loopingFireSound:SetParent(self)
        self.loopingSoundEntId = self.loopingFireSound:GetId()
        
    elseif Client then
    
        self:SetUpdates(true)
        self.lastAttackEffectTime = 0.0
        
    end
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)

end

function Flamethrower:OnDestroy()

    ClipWeapon.OnDestroy(self)
    
    // The loopingFireSound was already destroyed at this point, clear the reference.
    if Server then
        self.loopingFireSound = nil
    elseif Client then
    
        if self.trailCinematic then
            Client.DestroyTrailCinematic(self.trailCinematic)
            self.trailCinematic = nil
        end
        
    end
    
end

function Flamethrower:GetAnimationGraphName()
    return kAnimationGraph
end

function Flamethrower:GetWeight()
    return kFlamethrowerWeight
end

function Flamethrower:OnHolster(player)

    ClipWeapon.OnHolster(self, player)
    
    self.createParticleEffects = false
    self.createImpactEffects = false
    
end

function Flamethrower:OnDraw(player, previousWeaponMapName)

    ClipWeapon.OnDraw(self, player, previousWeaponName)
    
    self.createParticleEffects = false
    self.createImpactEffects = false
    self.animationDoneTime = Shared.GetTime()
    
end

function Flamethrower:GetClipSize()
    return kFlamethrowerClipSize
end

function Flamethrower:CreatePrimaryAttackEffect(player)

    // Remember this so we can update gun_loop pose param
    self.timeOfLastPrimaryAttack = Shared.GetTime()

end

function Flamethrower:GetRange()
    return self.range
end

function Flamethrower:GetWarmupTime()
    return 0.7
end

function Flamethrower:GetViewModelName()
    return kViewModelName
end

local function BurnSporesAndUmbra(self, startPoint, endPoint)

    local toTarget = endPoint - startPoint
    local distanceToTarget = toTarget:GetLength()
    toTarget:Normalize()
    
    local stepLength = 2

    for i = 1, 5 do
    
        // stop when target has reached, any spores would be behind
        if distanceToTarget < i * stepLength then
            break
        end
    
        local checkAtPoint = startPoint + toTarget * i * stepLength
        local spores = GetEntitiesWithinRange("SporeCloud", checkAtPoint, kSporesDustCloudRadius)
        
        local umbras = GetEntitiesWithinRange("CragUmbra", checkAtPoint, CragUmbra.kRadius)
        table.copy(GetEntitiesWithinRange("StormCloud", checkAtPoint, StormCloud.kRadius), umbras, true)
        table.copy(GetEntitiesWithinRange("MucousMembrane", checkAtPoint, MucousMembrane.kRadius), umbras, true)
        table.copy(GetEntitiesWithinRange("EnzymeCloud", checkAtPoint, EnzymeCloud.kRadius), umbras, true)
        
        local bombs = GetEntitiesWithinRange("Bomb", checkAtPoint, 1.6)
        table.copy(GetEntitiesWithinRange("WhipBomb", checkAtPoint, 1.6), bombs, true)
        
        for index, bomb in ipairs(bombs) do
            bomb:TriggerEffects("burn_bomb", { effecthostcoords = Coords.GetTranslation(bomb:GetOrigin()) } )
            DestroyEntity(bomb)
        end
        
        for index, spore in ipairs(spores) do
            self:TriggerEffects("burn_spore", { effecthostcoords = Coords.GetTranslation(spore:GetOrigin()) } )
            DestroyEntity(spore)
        end
        
        for index, umbra in ipairs(umbras) do
            self:TriggerEffects("burn_umbra", { effecthostcoords = Coords.GetTranslation(umbra:GetOrigin()) } )
            DestroyEntity(umbra)
        end
    
    end

end

local function CreateFlame(self, player, position, normal, direction)

    // create flame entity, but prevent spamming:
    local nearbyFlames = GetEntitiesForTeamWithinRange("Flame", self:GetTeamNumber(), position, 1.5)    

    if table.count(nearbyFlames) == 0 then
    
        local flame = CreateEntity(Flame.kMapName, position, player:GetTeamNumber())
        flame:SetOwner(player)
        
        local coords = Coords.GetTranslation(position)
        coords.yAxis = normal
        coords.zAxis = direction
        
        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        coords.xAxis:Normalize()
        
        coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)
        coords.zAxis:Normalize()
        
        flame:SetCoords(coords)
        
    end

end

local function ApplyConeDamage(self, player)
    
    local barrelPoint = self:GetBarrelPoint() - Vector(0, 0.4, 0)
    local ents = {}
    
    local range = self:GetRange()
    
    local fireDirection = GetNormalizedVector((player:GetEyePos() - Vector(0, 0.3, 0) + player:GetViewCoords().zAxis * range) - barrelPoint)
    local extents = Vector(kConeWidth, kConeWidth, kConeWidth)
    local remainingRange = range
    local startPoint = barrelPoint
    local filterEnts = {}
    
    for i = 1, 20 do
    
        if remainingRange <= 0 then
            break
        end
        
        local trace = TraceMeleeBox(self, startPoint, fireDirection, extents, remainingRange, PhysicsMask.Bullets, EntityFilterList(filterEnts))
        
        //DebugLine(startPoint, trace.endPoint, 0.3, 1, 0, 0, 1)        
        
        // Check for spores in the way.
        if Server and i == 1 then
            BurnSporesAndUmbra(self, startPoint, trace.endPoint)
        end
        
        if trace.fraction ~= 1 then
        
            if trace.entity then
            
                if HasMixin(trace.entity, "Live") then
                    table.insertunique(ents, trace.entity)
                end
                
                table.insertunique(filterEnts, trace.entity)
                
            else
            
                // Make another trace to see if the shot should get deflected.
                local lineTrace = Shared.TraceRay(startPoint, startPoint + remainingRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterOne(player))
                
                if lineTrace.fraction < 0.8 then
                
                    fireDirection = fireDirection + trace.normal * 0.55
                    fireDirection:Normalize()
                    
                    if Server then
                        CreateFlame(self, player, lineTrace.endPoint, lineTrace.normal, fireDirection)
                    end
                    
                end
                
                remainingRange = remainingRange - (trace.endPoint - startPoint):GetLength()
                startPoint = trace.endPoint // + fireDirection * kConeWidth * 2
                
            end
        
        else
            break
        end

    end
    
    for index, ent in ipairs(ents) do
    
        if ent ~= player then
        
            local toEnemy = GetNormalizedVector(ent:GetModelOrigin() - barrelPoint)
            local health = ent:GetHealth()
            
            self:DoDamage(kFlamethrowerDamage, ent, ent:GetModelOrigin(), toEnemy)
            
            // Only light on fire if we successfully damaged them
            if ent:GetHealth() ~= health and HasMixin(ent, "Fire") then
                ent:SetOnFire(player, self)
            end
            
            if Server and ent:isa("Alien") then
                ent:CancelEnzyme()
            end
            
        end
    
    end

end

local function ShootFlame(self, player)

    local viewAngles = player:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()
    
    viewCoords.origin = self:GetBarrelPoint(player) + viewCoords.zAxis * (-0.4) + viewCoords.xAxis * (-0.2)
    local endPoint = self:GetBarrelPoint(player) + viewCoords.xAxis * (-0.2) + viewCoords.yAxis * (-0.3) + viewCoords.zAxis * self:GetRange()
    
    local trace = Shared.TraceRay(viewCoords.origin, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())
    
    local range = (trace.endPoint - viewCoords.origin):GetLength()
    if range < 0 then
        range = range * (-1)
    end
    
    if trace.endPoint ~= endPoint and trace.entity == nil then
    
        local angles = Angles(0,0,0)
        angles.yaw = GetYawFromVector(trace.normal)
        angles.pitch = GetPitchFromVector(trace.normal) + (math.pi/2)
        
        local normalCoords = angles:GetCoords()
        normalCoords.origin = trace.endPoint
        range = range - 3
        
    end
    
    ApplyConeDamage(self, player)
    
    TEST_EVENT("Flamethrower primary attack")
    
end

function Flamethrower:FirePrimary(player, bullets, range, penetration)
    if not GetIsVortexed(player) then
        ShootFlame(self, player)
    end
end

function Flamethrower:GetDeathIconIndex()
    return kDeathMessageIcon.Flamethrower
end

function Flamethrower:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function Flamethrower:GetIsAffectedByWeaponUpgrades()
    return false
end

function Flamethrower:OnPrimaryAttack(player)

    if not self:GetIsReloading() then
    
        ClipWeapon.OnPrimaryAttack(self, player)
        
        if self:GetIsDeployed() and self:GetClip() > 0 and self:GetPrimaryAttacking() then
        
            if not self.createParticleEffects then
                self:TriggerEffects("flamethrower_attack_start")
            end
        
            self.createParticleEffects = true
            self.createImpactEffects = true
            
            if Server and not self.loopingFireSound:GetIsPlaying() then
                self.loopingFireSound:Start()
            end
            
        end
        
        if self.createParticleEffects and self:GetClip() == 0 then
        
            self.createParticleEffects = false
            self.createImpactEffects = false
            
            if Server then
                self.loopingFireSound:Stop()
            end
            
        end
    
        // Fire the cool flame effect periodically
        // Don't crank the period too low - too many effects slows down the game a lot.
        if Client and self.createParticleEffects and self.lastAttackEffectTime + 0.5 < Shared.GetTime() then
            
            self:TriggerEffects("flamethrower_attack")
            self.lastAttackEffectTime = Shared.GetTime()

        end
        
    end
    
end

function Flamethrower:OnPrimaryAttackEnd(player)

    ClipWeapon.OnPrimaryAttackEnd(self, player)

    self.createParticleEffects = false
    self.createImpactEffects = false
        
    if Server then    
        self.loopingFireSound:Stop()        
    end
    
end

function Flamethrower:OnReload(player)

    if self:CanReload() then
    
        if Server then
        
            self.createParticleEffects = false
            self.createImpactEffects = false
            self.loopingFireSound:Stop()
        
        end
        
        self:TriggerEffects("reload")
        self.reloading = true
        
    end
    
end

function Flamethrower:GetUpgradeTechId()
    return kTechId.FlamethrowerRangeTech
end

function Flamethrower:GetHasSecondary(player)
    return false
end

function Flamethrower:GetSwingSensitivity()
    return .8
end

function Flamethrower:Dropped(prevOwner)

    ClipWeapon.Dropped(self, prevOwner)

    if Server then
    
        self.createParticleEffects = false
        self.createImpactEffects = false
        self.loopingFireSound:Stop()
        
    elseif Client then
    
        if self.trailCinematic then
            Client.DestroyTrailCinematic(self.trailCinematic)
            self.trailCinematic = nil
        end
        
    end
    
end

function Flamethrower:GetAmmoPackMapName()
    return FlamethrowerAmmo.kMapName
end

// client side only effects:

if Client then

    local function UpdateClientFlameEffects(self, deltaTime)
    
        // check if we have the correct effects loaded
        if (self:GetParent() == Client.GetLocalPlayer() and not self.loadedFirstPersonEffect) or not self.trailCinematic then
        
            if self.trailCinematic then
                Client.DestroyTrailCinematic(self.trailCinematic)
                self.trailCinematic = nil
            end
            
            self:InitTrailCinematic()            
        end
    
        local drawWorld = true
        local firstPerson = false
        
        local parent = self:GetParent()
        
        if parent then
            firstPerson = not parent:GetIsThirdPerson()
            drawWorld = ((Client.GetLocalPlayer() ~= parent) or not firstPerson) and parent:GetIsVisible() and not GetIsVortexed(parent)
        end
        
        local effectsVisible = self.createParticleEffects and ( drawWorld or firstPerson )
        
        self.trailCinematic:SetIsVisible(effectsVisible)
        
        if self.createImpactEffects and effectsVisible then
            self:CreateImpactEffect(self:GetParent())
        end
        
        return true

    end
    
    local function UpdatePilotEffect(self, deltaTime)
    
        local isDrawn = self.animationDoneTime < Shared.GetTime()
        local player = self:GetParent()
        
        if self:GetIsActive() and self:GetClip() > 0 and isDrawn then
            self:TriggerEffects("flamethrower_pilot")  
        end
        
        return true
        
    end
    
    function Flamethrower:InitTrailCinematic()
    
        self.trailCinematic = Client.CreateTrailCinematic(RenderScene.Zone_Default)
        
        local minHardeningValue = 0.5
        local trailLengthMod = 0

        if self:GetParent() == Client.GetLocalPlayer() then
        
            self.trailCinematic:SetCinematicNames(kFirstPersonTrailCinematics)
            self.trailCinematic:SetFadeOutCinematicNames(kFirstPersonFadeOutCinematicNames)
            trailLengthMod = -1
        
            // set an attach function which returns the player view coords if we are the local player 
            self.trailCinematic:AttachToFunc(self, TRAIL_ALIGN_Z, Vector(-0.09, -0.08, 0.5),
                function (attachedEntity, deltaTime)
                
                    local player = Client.GetLocalPlayer()
                    return player:GetViewCoords()
                
                end
            )
            
            self.loadedFirstPersonEffect = true

        else
        
            self.trailCinematic:SetCinematicNames(kTrailCinematics)
        
            // attach to third person fx node otherwise with an X offset since we align it along the X-Axis (the attackpoint is oriented in the model like that)
            self.trailCinematic:AttachTo(self, TRAIL_ALIGN_X,  Vector(0.3, 0, 0), "fxnode_flamethrowermuzzle")
            minHardeningValue = 0.1
            
            self.loadedFirstPersonEffect = false
        
        end
        
        self.trailCinematic:SetIsVisible(false)
        self.trailCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.trailCinematic:SetOptions( {
                numSegments = 6,
                collidesWithWorld = true,
                visibilityChangeDuration = 0.2,
                fadeOutCinematics = true,
                stretchTrail = false,
                trailLength = kTrailLength + trailLengthMod,
                minHardening = minHardeningValue,
                maxHardening = 2,
                hardeningModifier = 0.8,
                trailWeight = 0.2
            } )
    
    end
    
    function Flamethrower:OnInitialized()
    
        ClipWeapon.OnInitialized(self)
        
        if self.trailCinematic == nil then
            self:InitTrailCinematic()
        end
        
        self:AddTimedCallback(UpdateClientFlameEffects, kParticleEffectRate)

        if Client.GetLocalPlayer() == self:GetParent() then
            self:AddTimedCallback(UpdatePilotEffect, kPilotEffectRate)
        end
    
    end
    
    function Flamethrower:CreateSmokeEffect(player)
    
        if not self.timeLastLightningEffect or self.timeLastLightningEffect + kSmokeEffectRate < Shared.GetTime() then
        
            self.timeLastLightningEffect = Shared.GetTime()
            
            local viewAngles = player:GetViewAngles()
            local viewCoords = viewAngles:GetCoords()
            
            viewCoords.origin = self:GetBarrelPoint(player) + viewCoords.zAxis * 1 + viewCoords.xAxis * (-0.4) + viewCoords.yAxis * (-0.3)
            
            local cinematic = kFlameSmokeCinematic
            
            local effect = Client.CreateCinematic(RenderScene.Zone_Default)    
            effect:SetCinematic(cinematic)
            effect:SetCoords(viewCoords)
            
        end
    
    end
    
    function Flamethrower:CreateImpactEffect(player)
    
        if (not self.timeLastImpactEffect or self.timeLastImpactEffect + kImpactEffectRate < Shared.GetTime()) and player then
        
            self.timeLastImpactEffect = Shared.GetTime()
        
	        local viewAngles = player:GetViewAngles()
            local viewCoords = viewAngles:GetCoords()
    
            viewCoords.origin = self:GetBarrelPoint(player) + viewCoords.zAxis * (-0.4) + viewCoords.xAxis * (-0.2)
            local endPoint = self:GetBarrelPoint(player) + viewCoords.xAxis * (-0.2) + viewCoords.yAxis * (-0.3) + viewCoords.zAxis * self:GetRange()

            local trace = Shared.TraceRay(viewCoords.origin, endPoint, CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll())
    
            local range = (trace.endPoint - viewCoords.origin):GetLength()
            if range < 0 then
                range = range * (-1)
            end
    
            if trace.endPoint ~= endPoint and trace.entity == nil then

                local angles = Angles(0,0,0)
                angles.yaw = GetYawFromVector(trace.normal)
                angles.pitch = GetPitchFromVector(trace.normal) + (math.pi/2)
        
                local normalCoords = angles:GetCoords()
                normalCoords.origin = trace.endPoint            
               
                Shared.CreateEffect(nil, kFlameImpactCinematic, nil, normalCoords)
                
            end
            
        end
        
	end
    
    function Flamethrower:TriggerImpactCinematic(coords)
    
        local cinematic = kFlameImpactCinematic
        
        local effect = Client.CreateCinematic(RenderScene.Zone_Default)    
        effect:SetCinematic(cinematic)    
        effect:SetCoords(coords)
        
    end
    
    function Flamethrower:GetUIDisplaySettings()
        return { xSize = 128, ySize = 256, script = "lua/GUIFlamethrowerDisplay.lua" }
    end
    
end

function Flamethrower:GetNotifiyTarget()
    return false
end

function Flamethrower:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function Flamethrower:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function Flamethrower:OnKill()
        DestroyEntity(self)
    end
    
    function Flamethrower:GetSendDeathMessageOverride()
        return false
    end 
    
    function Flamethrower:OnProcessMove(input)
        
        ClipWeapon.OnProcessMove(self, input)
        
        local hasRangeTech = false
        local parent = self:GetParent()
        if parent then
            hasRangeTech = GetHasTech(parent, kTechId.FlamethrowerRangeTech)
        end
        
        self.range = hasRangeTech and kUpgradedRange or kRange

    end
    
end

Shared.LinkClassToMap("Flamethrower", Flamethrower.kMapName, networkVars)
