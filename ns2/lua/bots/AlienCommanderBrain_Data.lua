
Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")

local kHiveBuildDist = 15.0

local function CreateBuildNearHiveAction( techId, className, numToBuild, weightIfNotEnough )

    return CreateBuildStructureAction(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            },
            "Hive",
            kHiveBuildDist )
end

//----------------------------------------
//  
//----------------------------------------
kAlienComBrainActions =
{
    // By randomizing weights, each bot has its own "personality"
    CreateUpgradeStructureAction( kTechId.UpgradeToCragHive        , 1.0+math.random() ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeToShadeHive       , 1.0+math.random() ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeToShiftHive       , 1.0+math.random() ) , 

    // Passive ability structures
    CreateBuildNearHiveAction( kTechId.Crag  , "Crag"  , 4 , 1.0+math.random() ) , 
    CreateBuildNearHiveAction( kTechId.Shift , "Shift" , 4 , 1.0+math.random() ) , 
    CreateBuildNearHiveAction( kTechId.Shade , "Shade" , 2 , 1.0+math.random() ) , 
    //STEVETEMP CreateBuildNearHiveAction( kTechId.Whip  , "Whip"  , 8 , 0.3 ),

    // Trait-giving structures
    CreateBuildNearHiveAction( kTechId.Veil  , "Veil"  , 2 , 1.0+math.random() ) , 
    CreateBuildNearHiveAction( kTechId.Shell , "Shell" , 2 , 1.0+math.random() ) , 
    CreateBuildNearHiveAction( kTechId.Spur  , "Spur"  , 2 , 1.0+math.random() ) , 

    // Trait upgrades
    CreateUpgradeStructureAction( kTechId.UpgradeCarapaceShell     , 1.0+math.random(), kTechId.Carapace ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeRegenerationShell , 1.0+math.random(), kTechId.Regeneration ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeCeleritySpur      , 1.0+math.random(), kTechId.Celerity ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeAdrenalineSpur    , 1.0+math.random(), kTechId.Adrenaline ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeHyperMutationSpur , 1.0+math.random(), kTechId.HyperMutation ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeSilenceVeil       , 1.0+math.random(), kTechId.Silence ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeCamouflageVeil    , 1.0+math.random(), kTechId.Camouflage ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeAuraVeil          , 1.0+math.random(), kTechId.Aura ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeRegenerationShell , 1.0+math.random(), kTechId.Regeneration ) , 
    CreateUpgradeStructureAction( kTechId.UpgradeCarapaceShell     , 1.0+math.random(), kTechId.Carapace ) , 

    function(bot, brain)

        local name = "harvester"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local targetRP = nil

        if doables[kTechId.Harvester] ~= nil then

            targetRP = sdb:Get("resPointToTake")

            if targetRP ~= nil then
                weight = EvalLPF( sdb:Get("numHarvesters"),
                        {
                        {0, 10},
                        {1, 8},
                        {2, 6},
                        {3, 4}
                        })
            end

        end

        return { name = name, weight = weight,
            perform = function(move)
                if targetRP ~= nil then
                    local success = brain:ExecuteTechId( com, kTechId.Harvester, targetRP:GetOrigin(), com )
                    if success then
                        // reset the last cyst position for the next chaining
                        brain.lastPlacedCystPos = nil
                    end
                end
            end}
    end,

    function(bot, brain)

        local name = "cyst"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0

        if sdb:Get("resPointToTake") ~= nil then
            // there is a res point ready to take, so do not build any more cysts to conserve TRes
            weight = 0
        elseif doables[kTechId.Cyst] ~= nil and sdb:Get("bestCystPos") ~= nil then
            weight = 9
        end

        return { name = name, weight = weight,
            perform = function(move)
                local cystPos = sdb:Get("bestCystPos")
                local rp = sdb:Get("resPointToInfest")
                assert( cystPos ~= nil )
                assert( rp ~= nil )
                local offset = Vector(0,1,0)
                local success = brain:ExecuteTechId( com, kTechId.Cyst, cystPos, com )
                if success then
                    brain.lastPlacedCystPos = cystPos
                end
            end }

    end,

    function(bot, brain)

        local name = "hive"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local targetTP = nil

        if sdb:Get("numHarvesters") >= sdb:Get("numHarvsForHive") 
            or sdb:Get("overdueForHive") then

            // Find a hive slot!
            targetTP = sdb:Get("techPointToTake")

            if targetTP ~= nil then
                weight = 10
            end

        end

        return { name = name, weight = weight,
            perform = function(move)
                if doables[kTechId.Hive] and targetTP ~= nil then
                    brain:ExecuteTechId( com, kTechId.Hive, targetTP:GetOrigin(), com )
                else
                    // we cannot build a hive yet - wait for res to build up
                end
            end}
    end,

    function(bot, brain)

        return { name = "idle", weight = 1e-5,
            perform = function(move)
                if brain.debug then
                    DebugPrint("idling..")
                end 
            end}
    end
}

//----------------------------------------
//  Build the senses database
//----------------------------------------

function CreateAlienComSenses()

    local s = BrainSenses()
    s:Initialize()

    s:Add("gameMinutes", function(db)
            return (Shared.GetTime() - GetGamerules():GetGameStartTime()) / 60.0
            end)

    s:Add("doableTechIds", function(db)
            return db.bot.brain:GetDoableTechIds( db.bot:GetPlayer() )
            end)

    s:Add("hives", function(db)
            return GetEntitiesForTeam("Hive", kAlienTeamType)
            end)

    s:Add("cysts", function(db)
            return GetEntitiesForTeam("Cyst", kAlienTeamType)
            end)

    s:Add("numHarvesters", function(db)
            return GetNumEntitiesOfType("Harvester", kAlienTeamType)
            end)

    s:Add("numHarvsForHive", function(db)

            if db:Get("numHives") == 1 then
                return 3
            elseif db:Get("numHives") == 2 then
                return 5
            else
                return 8
            end
            
            return 0

            end)

    s:Add("overdueForHive", function(db)

            if db:Get("numHives") == 1 then
                return db:Get("gameMinutes") > 7
            elseif db:Get("numHives") == 2 then
                return db:Get("gameMinutes") > 14
            else
                return false
            end

            end)

    s:Add("numHives", function(db)
            return GetNumEntitiesOfType("Hive", kAlienTeamType)
            end)

    s:Add("techPointToTake", function(db)
            local tps = GetAvailableTechPoints()
            local hives = db:Get("hives")
            local dist, tp = GetMinTableEntry( tps, function(tp)
                return GetMinDistToEntities( tp, hives )
                end)
            return tp
            end)

    // RPs that are not taken, not necessarily good or on infestation
    s:Add("availResPoints", function(db)
            return GetAvailableResourcePoints()
            end)

    s:Add("resPointToTake", function(db)
            local rps = db:Get("availResPoints")
            local hives = db:Get("hives")
            local dist, rp = GetMinTableEntry( rps, function(rp)
                // Check infestation
                if GetIsPointOnInfestation(rp:GetOrigin()) then
                    return GetMinDistToEntities( rp, hives )
                end
                return nil
                end)
            return rp
            end)

    s:Add("resPointToInfest", function(db)
            local rps = db:Get("availResPoints")
            local hives = db:Get("hives")
            local dist, rp = GetMinTableEntry( rps, function(rp)
                // Check infestation
                if not GetIsPointOnInfestation(rp:GetOrigin()) then
                    return GetMinDistToEntities( rp, hives )
                end
                return nil
                end)
            return rp
            end)

    s:Add("lastInfestorPos", function(db)
            local rp = db:Get("resPointToInfest")

            if rp == nil then
                // not trying to infest, no point in keeping track
                return nil
            end

            // due to pathing hysteresis issues, we want to use the last built cyst pos
            // and not choose based on nearest euclidian
            local lastPlacedCystPos = db.bot.brain.lastPlacedCystPos

            if lastPlacedCystPos ~= nil then

                // make sure the cyst is still there
                local cysts = GetEntitiesForTeamWithinRange( "Cyst", kAlienTeamType, lastPlacedCystPos, 2.0 )
                if #cysts >= 1 then
                    return lastPlacedCystPos
                else
                    // the cyst must be destroyed - clear the state
                    db.bot.brain.lastPlacedCystPos = nil
                end
            end

            // find the nearest cyst/hive and return its position
            local rpPos = rp:GetOrigin()
            local cysts = db:Get("cysts")
            local dist, cyst = GetMinTableEntry( cysts, function(cyst)
                if cyst:GetIsAlive() and cyst:GetIsActuallyConnected() then
                    return cyst:GetOrigin():GetDistance(rpPos)
                end
                return nil
                end)

            if cyst ~= nil then
                return cyst:GetOrigin()
            else
                // just find the nearest built hive
                local dist, hive = GetMinTableEntry( db:Get("hives"), function(hive)
                    if hive:GetIsBuilt() and hive:GetIsAlive() then
                        return hive:GetOrigin():GetDistance(rpPos)
                    end
                    return nil
                    end)
                return hive:GetOrigin()
            end

            return nil
            end)

    s:Add("nearestInfestorCloseEnough", function(db)
            local rp = db:Get("resPointToInfest")
            if rp ~= nil then
                local infestorPos = db:Get("lastInfestorPos")
                assert(infestorPos ~= nil)
                // technically not accurate for hive, but whatever
                local closeEnoughDist = kCystRedeployRange + 1
                return infestorPos:GetDistance(rp:GetOrigin()) < closeEnoughDist
            end
            return nil
            end)

    // Expensive, since it uses pathing. Use sparingly and lazily!
    s:Add("bestCystPos", function(db)

            local rp = db:Get("resPointToInfest")
            if rp ~= nil then

                local rpPos = rp:GetOrigin()

                if db:Get("nearestInfestorCloseEnough") then
                    // no need to make a new cyst - wait for infest spread
                    return nil
                end

                local lastInfestorPos = db:Get("lastInfestorPos")

                if lastInfestorPos ~= nil then

                    // DebugPrint("finding path from %s to %s", ToString(lastInfestorPos), ToString(rpPos))
                    local pathPoints = PointArray()
                    local reachable = Pathing.GetPathPoints( lastInfestorPos, rpPos, pathPoints )

                    if not reachable then

                        assert(false)
                        Print("ERROR: Could not reach %s (at %s) from cyst/hive (at %s)",
                            rp:GetClassName(), ToString(rpPos),
                            ToString(lastInfestorPos))
                    else

                        // walk the path until we get within cyst parenting range
                        local prevPos = nil
                        local totalDist = 0
                        
                        for i=1,#pathPoints do
                            
                            local pos = pathPoints[i]
                            
                            if prevPos ~= nil then
                                totalDist = totalDist + prevPos:GetDistance(pos)

                                // use 3m tolerance, just in case
                                if totalDist >= (kCystMaxParentRange-3.0) then
                                    // we are just over the border - use previous pos
                                    break
                                end

                                // but also do not get too close to RP
                                local distToRp = pos:GetDistance(rpPos)
                                if distToRp < 2 then
                                    // too close, use previous pos
                                    break
                                end
                            end
                            prevPos = pos
                        end

                        // prevPos should now be the valid pos
                        if prevPos ~= nil then
                            // make sure we get a safe position around the pathed point
                            prevPos = GetRandomBuildPosition( kTechId.Cyst, prevPos, 2.0 )
                        end
                        return prevPos

                    end
                end
            end

            return nil

            end)

    return s

end

//----------------------------------------
//  
//----------------------------------------


