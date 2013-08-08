// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\InsightNetworkMessages.lua
//
// Created by: Jon Hughes (jon@jhuze.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kHealthMessage =
{
    clientIndex = "integer",
    health = "integer",
    maxHealth = "integer",
    armor = "integer",
    maxArmor = "integer"
}

function BuildHealthMessage(player)

    local t = {}

    t.clientIndex       = player:GetClientIndex()
    t.health            = player:GetHealth()
    t.maxHealth         = player:GetMaxHealth()
    t.armor             = player:GetArmor()
    t.maxArmor          = player:GetMaxArmor()

    return t

end

Shared.RegisterNetworkMessage( "Health", kHealthMessage )

local kTechPointsMessage =
{
    entityIndex = "integer",
    teamNumber = "integer",
    techId = "integer",
    builtFraction = "float",
    location = string.format("string (%d)", 32),
    health = "integer",
    maxHealth = "integer",
    armor = "integer",
    maxArmor = "integer"
}

function BuildTechPointsMessage(techPoint, commandStructures)

    local t = {}
    local techPointLocation = techPoint:GetLocationName()
    t.entityIndex = techPoint:GetId()
    t.location = techPointLocation   
    t.teamNumber = 0

    for index, structure in ientitylist(commandStructures) do
        local structureLocation = structure:GetLocationName()
        if techPointLocation == structureLocation then
            t.teamNumber        = structure:GetTeamNumber()
            t.techId            = structure:GetTechId()
            if structure:GetIsAlive() then
                t.builtFraction = structure:GetBuiltFraction()
                t.health        = math.ceil(structure:GetHealth())
                t.armor         = structure:GetArmor()
            else
                t.builtFraction = -1
                t.health        = -1
                t.armor         = -1
            end
            t.maxHealth         = structure:GetMaxHealth()
            t.maxArmor          = structure:GetMaxArmor()
            return t
        end
    end

    return t

end

Shared.RegisterNetworkMessage( "TechPoints", kTechPointsMessage )


local kRecycleMessage =
{
    resLost = "float",
    techId = "enum kTechId",
    resGained = "integer"
}

function BuildRecycleMessage(resLost, techId, resGained)

    local t = {}

    t.resLost = resLost
    t.techId = techId
    t.resGained = resGained

    return t

end

Shared.RegisterNetworkMessage( "Recycle", kRecycleMessage )

-- empty network message for game reset
Shared.RegisterNetworkMessage( "Reset" )