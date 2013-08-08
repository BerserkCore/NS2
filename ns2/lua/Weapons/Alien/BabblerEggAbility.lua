// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\Alien\BabblerEggAbility.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'BabblerEggAbility' (StructureAbility)

function BabblerEggAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end

function BabblerEggAbility:GetGhostModelName(ability)
    return Babbler.kEggModelName
end

function BabblerEggAbility:GetDropStructureId()
    return kTechId.Babbler
end

function BabblerEggAbility:GetSuffixName()
    return "babbler"
end

function BabblerEggAbility:GetDropClassName()
    return "Babbler"
end

function BabblerEggAbility:GetDropRange()
    return 1.5
end

function BabblerEggAbility:GetDropMapName()
    return Babbler.kMapName
end
