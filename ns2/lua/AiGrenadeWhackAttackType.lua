//=============================================================================
//
// lua\AiGrenadeWhackAttackType.lua
//
// Created by Mats Olsson (mats.olsson@matsotech.se)
//
// This attacks whacks away grenades headed for the whip
//
//=============================================================================

Script.Load("lua/AiAttackType.lua")

class "AiGrenadeWhackAttackType" (AiAttackType)

kGrenadeScanTime = 0.25
kAttackWindupTime = 0.6

function AiGrenadeWhackAttackType:Init(aiEntity)

    AiAttackType.Init(self, aiEntity, 0, nil)
    
    self.whacking = true
    self.minScanInterval = kGrenadeScanTime
    return self
    
end

// work-around
function AiGrenadeWhackAttackType:GetClassName()
    return "AiGrenadeWhackAttackType"
end

function AiGrenadeWhackAttackType:IsValid()
    return ( not HasMixin(self.aiEntity, "Fire") or not self.aiEntity:GetIsOnFire() ) and (not HasMixin(self.aiEntity, "Maturity") or self.aiEntity:GetMaturityLevel() == kMaturityLevel.Mature) and self:ValidateTarget(self:GetTarget())
end

function AiGrenadeWhackAttackType:ValidateTarget(target)

    if target and target:GetClassName() == "Grenade" and not target:IsWhacked() then
    
        local whacker = target:GetWhacker()
        return not whacker or whacker == self.aiEntity
        
    end
    
    return false
    
end

function AiGrenadeWhackAttackType:UpdateGrenadeScan(now)

    self.targetId, self.grenadeAttackTime = self:ScanForGrenades()
    if self.grenadeAttackTime then
        self.nextAttackTime = self.grenadeAttackTime
    end
    
end

// No ordering around grenade whacking 
function AiGrenadeWhackAttackType:TryAttackOnOrder(order, now)
    return false
end

function AiGrenadeWhackAttackType:TryAttackOnAny(now)

    if now >= self.nextAttackTime then
        self:UpdateGrenadeScan(now)
    end
    
    if not self.grenadeAttackTime then
    
        self.nextAttackTime = now + self.minScanInterval
        return false
        
    end
    
    return AiAttackType.TryAttackOnAny(self, now)  
    
end

function AiGrenadeWhackAttackType:AcquireTarget(now)

    self:UpdateGrenadeScan(now)
    return Shared.GetEntity(self.targetId)
    
end

function AiGrenadeWhackAttackType:StartAttackOnTarget(target)

    target:PrepareToBeWhackedBy(self.aiEntity)  
    
    AiAttackType.StartAttackOnTarget(self, target)
    
end

local function GetWhackDirection(whip, grenadePos)

    local friendlies = GetEntitiesForTeamWithinRange("ScriptActor", whip:GetTeamNumber(), grenadePos, 30)
    
    local numVectors = 0
    local vectorSum = Vector(0,0,0)
    
    for _, friendly in ipairs(friendlies) do
    
        numVectors = numVectors + 1
        // TODO: probably assign priorities? like hive and players twice as important
        vectorSum = vectorSum + GetNormalizedVector( grenadePos - friendly:GetOrigin() )
    
    end
    
    if numVectors ~= 0 then    
        return GetNormalizedVector( vectorSum / numVectors )  
    end

    return GetNormalizedVector(grenadePos - whip:GetOrigin())  

end

local kMinWhackSpeed = 12
local kWhackSpeed = 16

function AiGrenadeWhackAttackType:OnHit()

    local grenade = self:GetTarget()
    if grenade and grenade:isa("Grenade") then
    
        local range = (grenade:GetOrigin() - self.aiEntity:GetOrigin()):GetLength() 
        if range < Whip.kRange then
        
            // fling it away from friendly units
            local awayFromFriendlies = GetWhackDirection(self.aiEntity, grenade:GetOrigin())
            awayFromFriendlies.y = math.max(0.5, awayFromFriendlies.y)
            
            //DebugLine(grenade:GetOrigin(),  grenade:GetOrigin() + awayFromFriendlies * 3, 4, 1, 1, 1, 1)
            
            local whackVelocity = awayFromFriendlies * grenade:GetVelocity():GetLength()
            
            if whackVelocity:GetLength() < kMinWhackSpeed then
            
                // need to fling it back with enough speed
                local player = grenade:GetOwner()
                if player then 
                    whackVelocity = Ballistics.GetAimDirection(grenade:GetOrigin(), player:GetEngagementPoint(), kWhackSpeed) * kWhackSpeed
                end
                
            end
            
            grenade:Whack(whackVelocity)
            
        end
        
    end
    
end

/**
 * Calculate when the grenade will arrive inside our kWhackRange, and subtract our attack wind-up time
 * Return nil if not an interesting grenade.
 *
 * This will not take into consideration any bouncing, so smart marines will be able to bounce the grenades into unsuspecting
 * aiEntitys.
 * 
 * Google line sphere intersection for algorithm 
 */
function AiGrenadeWhackAttackType:CalcWhenToWhack(grenade)

    // translate our origin to 0,0,0 and our velocity to 1 to simplify
    local origin = self.aiEntity:GetOrigin() - grenade:GetOrigin()
    local direction = grenade:GetVelocity()
    direction:Normalize()
    
    local a = direction:DotProduct(origin)
    local b = origin:GetLengthSquared()
    local c = Whip.kWhackRange * Whip.kWhackRange
    local discriminant = a*a - b + c
    
    if discriminant < 0 then 
        return nil
    end
    
    local distance = direction:DotProduct(origin) - math.sqrt(discriminant)
    local timeToIntersect = distance / grenade:GetVelocity():GetLength()
    local timeOfIntersect = Shared.GetTime() + timeToIntersect
    local timeToWhack = timeOfIntersect - kAttackWindupTime 
    return timeToWhack
    
end

/**
 * Scan for grenades around us
 */
function AiGrenadeWhackAttackType:ScanForGrenades()

    local nextAttackTime = nil
    local targetId = Entity.invalidId
    // Look for any grenades flying around in our vicinity and check when we should start whacking it
    local grenades = GetEntitiesWithinRange("Grenade", self.aiEntity:GetOrigin(), Whip.kWhackInterrestRange)
    
    for index, grenade in ipairs(grenades) do
    
        local attackTime = self:CalcWhenToWhack(grenade)
        if attackTime and (nextAttackTime == nil or attackTime < nextAttackTime) then
        
            // ignore grenades already getting whacked
            if not grenade:GetWhacker() then
                targetId, nextAttackTime = grenade:GetId(), attackTime
            end
            
        end
        
    end
    
    return targetId, nextAttackTime
    
end

function AiGrenadeWhackAttackType:OnStart()
     self.aiEntity:TriggerEffects("whip_attack")
end