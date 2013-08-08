// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\Absorb.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Gorge damage absorption ability.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/Ability.lua")

class 'Absorb' (Ability)

local networkVars = { }

Absorb.kMapName = "absorb"

// View model animations
Absorb.kAnimAttackTable = {{1, "attack"}/*, {1, "attack2"}, {1, "attack3"}, {1, "attack4"}*/}

// Balance

// Primary
Absorb.kPrimaryEnergyCost = 10

// Secondary
Absorb.kSecondaryEnergyCost = 20     

function Absorb:GetPrimaryEnergyCost(player)
    return Absorb.kPrimaryEnergyCost
end

function Absorb:GetSecondaryEnergyCost(player)
    return Absorb.kSecondaryEnergyCost
end

function Absorb:PerformPrimaryAttack(player)
    return true
end

function Absorb:PerformSecondaryAttack(player)

    Shared.PlaySound(player, Absorb.kStabSound)
    
    return true
    
end

Shared.LinkClassToMap("Absorb", Absorb.kMapName, networkVars)