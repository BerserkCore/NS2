// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Sponitor2.lua
//
//    Created by:   Steven An (steve@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local kSponitor2Url = "http://sponitor2.herokuapp.com/api/send/"

local kDebugAlwaysPost = false

local function CollectActiveModIds()

    modIds = {}
    for modNum = 1, Server.GetNumActiveMods() do
        modIds[modNum] = Server.GetActiveModId(modNum)
    end
    return modIds

end

local function TechIdToString(techId)

    return LookupTechData( techId, kTechDataDisplayName, string.format("techId=%d", techId) )

end

local function TechIdToUpgradeCode(techId)

    return LookupTechData( techId, kTechDataSponitorCode, string.format("%d", techId) )

end

local function GetUpgradeAttribsString(ent)

    local out = ""

    if HasMixin( ent, "Upgradable" ) then

        local ups = ent:GetUpgradeList()

        for i = 1,#ups do
            out = out .. TechIdToUpgradeCode(ups[i])
        end
    end

    if ent:isa("Marine") then
        out = out .. string.format("W%dA%d", ent:GetWeaponLevel(), ent:GetArmorLevel() )
    end

    return out

end

//----------------------------------------
//   
//----------------------------------------
class 'ServerSponitor'

//----------------------------------------
//  'game' should be NS2Gamerules
//----------------------------------------
function ServerSponitor:Initialize( game )

    self.game = game

    self.matchId = nil
    self.reportDetails = false

end

//----------------------------------------
//  
//----------------------------------------
function ServerSponitor:ListenToTeam(team)

    team:AddListener("OnResearchComplete",
            function(structure, researchId)

                local node = team:GetTechTree():GetTechNode(researchId)

                if node:GetIsResearch() or node:GetIsUpgrade() then
                    self:OnTechEvent("DONE "..TechIdToString(researchId))
                end

            end )

    team:AddListener("OnCommanderAction",
            function(techId)
                self:OnTechEvent("CMDR "..TechIdToString(techId))
            end )

    team:AddListener("OnConstructionComplete",
            function(structure)
                self:OnTechEvent("BUILT "..TechIdToString(structure:GetTechId()))
            end )

    team:AddListener("OnEvolved",
            function(techId)
                self:OnTechEvent("EVOL "..TechIdToString(techId))
            end )
    
    team:AddListener("OnBought",
            function(techId)
                self:OnTechEvent("BUY "..TechIdToString(techId))
            end )

end

//----------------------------------------
//   
//----------------------------------------
function ServerSponitor:OnMatchStartResponse(response)

    local data, pos, err = json.decode(response)

    if err then
        DebugPrint("Could not parse match start response. Error: "..ToString(err)..". Response: "..response)
    else

        if data.matchId then
            self.matchId = data.matchId
        else
            self.matchId = nil
        end

        if data.reportDetails then
            self.reportDetails = data.reportDetails
        else
            self.reportDetails = false
        end

    end

end

//----------------------------------------
//   
//----------------------------------------
function ServerSponitor:OnStartMatch()

    local jsonData = json.encode(
    {
        startTime      = Shared.GetGMTString(false),
        version        = Shared.GetBuildNumber(),
        map            = Shared.GetMapName(),
        serverIp       = IPAddressToString(Server.GetIpAddress()),
        isRookieServer = Server.GetIsRookieFriendly(),
        modIds         = CollectActiveModIds(),
    })
    
    Shared.SendHTTPRequest( kSponitor2Url.."matchStart", "POST", {data=jsonData},
        function(response) self:OnMatchStartResponse(response) end )

end

//----------------------------------------
//   
//----------------------------------------
function ServerSponitor:OnEndMatch(winningTeam)

    if self.matchId or kDebugAlwaysPost then

        local startHiveTech = "None"

        if self.game.initialHiveTechId then
            startHiveTech = EnumToString(kTechId, self.game.initialHiveTechId)
        end

        local jsonData = json.encode(
        {
            matchId             = self.matchId,
            endTime             = Shared.GetGMTString(false),
            winner              = winningTeam:GetTeamType(),
            start_location1     = self.game.startingLocationNameTeam1,
            start_location2     = self.game.startingLocationNameTeam2,
            start_path_distance = self.game.startingLocationsPathDistance,
            start_hive_tech     = startHiveTech,
        })
        
        Shared.SendHTTPRequest( kSponitor2Url.."matchEnd", "POST", {data=jsonData} )

        self.matchId = nil

    end

end

//----------------------------------------
//   
//----------------------------------------
function ServerSponitor:OnEntityKilled(target, attacker, weapon)

    if not attacker or not target or not weapon then
        return
    end

    if (self.matchId and self.reportDetails) or kDebugAlwaysPost then

        local targetWeapon = "None"

        if target.GetActiveWeapon and target:GetActiveWeapon() then
            targetWeapon = target:GetActiveWeapon():GetClassName()
        end

        local attackerOrigin = attacker:GetOrigin()
        local targetOrigin = target:GetOrigin()

        local jsonData = json.encode(
        {
            matchId        = self.matchId,
            time           = Shared.GetGMTString(false),
            attackerClass  = attacker:GetClassName(),
            attackerTeam   = ((HasMixin(attacker, "Team") and attacker:GetTeamType()) or kNeutralTeamType),
            attackerWeapon = weapon:GetClassName(),
            attackerX      = string.format("%.2f", attackerOrigin.x),
            attackerY      = string.format("%.2f", attackerOrigin.y),
            attackerZ      = string.format("%.2f", attackerOrigin.z),
            attackerAttrs  = GetUpgradeAttribsString(attacker),
            targetClass    = target:GetClassName(),
            targetTeam     = target:GetTeamType(),
            targetWeapon   = targetWeapon,
            targetX        = string.format("%.2f", targetOrigin.x),
            targetY        = string.format("%.2f", targetOrigin.y),
            targetZ        = string.format("%.2f", targetOrigin.z),
            targetAttrs    = GetUpgradeAttribsString(target),
            targetLifeTime = string.format("%.2f", Shared.GetTime() - target:GetCreationTime()),
        })

        Shared.SendHTTPRequest( kSponitor2Url.."kill", "POST", {data=jsonData} )

    end

end

//----------------------------------------
//   
//----------------------------------------
function ServerSponitor:OnTechEvent(name)

    //DebugPrint("OnTechEvent %s", name)

    if (self.matchId and self.reportDetails) or kDebugAlwaysPost then

        local jsonData = json.encode(
        {
            matchId = self.matchId,
            time = Shared.GetGMTString(false),
            name = name,
        })

        Shared.SendHTTPRequest( kSponitor2Url.."tech", "POST", {data=jsonData} )

    end

end

