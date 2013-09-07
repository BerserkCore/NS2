
Script.Load("lua/bots/BotUtils.lua")
Script.Load("lua/bots/BotDebug.lua")
Script.Load("lua/bots/ManyToOne.lua")

-- gBotDebug is only available on the server.
if gBotDebug then
    gBotDebug:AddBoolean("debugteam")
end

class 'TeamBrain'

local function GetSightedMapBlips(keepFunc, teamNum)

    local blips = {}

    for _, blip in ientitylist(Shared.GetEntitiesWithClassname("MapBlip")) do

    local ent = Shared.GetEntity( blip:GetOwnerEntityId() )
        if (blip:GetIsSighted() or blip:GetTeamNumber() == teamNum
                or blip:GetTeamNumber() == kTeamInvalid)
        and (keepFunc == nil or keepFunc(blip)) then
            table.insert( blips, blip )
        end
    end

    return blips

end

local function UpdateMemory(mem, blip)

    assert( mem.entId == blip:GetOwnerEntityId() )

    local ent = Shared.GetEntity(blip:GetOwnerEntityId())

    if ent ~= nil and ent.GetIsSighted and ent:GetIsSighted() then
        mem.btype = blip:GetType()  // ents do change type, such as aliens changing lifeform
        mem.lastSeenPos = ent:GetOrigin()
    end
    // otherwise, do not update it - keep the last known position/type
    mem.lastSeenTime = Shared.GetTime()

end

local function CreateMemory(blip)

    local mem =
    {
        entId = blip:GetOwnerEntityId(),
        lastSeenPos = blip:GetOrigin(),
        btype = blip:GetType()
    }
    UpdateMemory( mem, blip )
    return mem

end

local function MemoryToString(mem)

    local s = ""
    local ent = Shared.GetEntity(mem.entId)
    if ent ~= nil then
        s = s .. string.format("%d-%s", mem.entId, ent:GetClassName())
    else
        s = s .. "<NIL>"
    end
    
    return s
    
end

function TeamBrain:Initialize(label, teamNumber)

    // table of entity ID to remembered blips
    // remembered blips
    self.entId2memory = {}
    self.debug = false
    self.label = label
    self.teamNumber = teamNumber

    self.assignments = ManyToOne()
    self.assignments:Initialize()

    //----------------------------------------
    //  Do a quick unit test to confirm table-as-set idea..
    //----------------------------------------
    local set = {}
    assert( GetTableSize(set) == 0 )
    set[ "foo" ] = true
    set[ "bar" ] = true
    assert( GetTableSize(set) == 2 )
    set[ "foo" ] = nil
    assert( GetTableSize(set) == 1 )
    set[ "bar" ] = nil
    assert( GetTableSize(set) == 0 )

end

function TeamBrain:Reset()
    self.entId2memory = {}
    self.assignments:Reset()
end

function TeamBrain:GetMemories()
    return self.entId2memory
end

function TeamBrain:OnEntityChange(oldId, newId)

    // make sure we clear the memory
    // do not worry about the new ID, since it should get added via the normal blip code path

    if self.entId2memory[oldId] ~= nil then

        self.assignments:RemoveGroup(oldId)
        self.entId2memory[oldId] = nil

    end

end

function TeamBrain:DebugDraw()

    // TEMP
    if self.teamNumber ~= kMarineTeamType then
        return
    end

    for id,mem in pairs(self.entId2memory) do

        local lostTime = Shared.GetTime() - mem.lastSeenTime
        local ent = Shared.GetEntity(mem.entId)
        assert( ent ~= nil )

        Shared.DebugColor(0,1,1,1)
        Shared.DebugText( string.format("-- %s %0.2f (%d)",
                    ent:GetClassName(), lostTime,
                    self.assignments:GetNumAssignedTo(mem.entId)),
                mem.lastSeenPos, 0.0 )

        for playerId,_ in pairs(self.assignments:GetItems(mem.entId)) do
            local player = Shared.GetEntity(playerId)
            if player ~= nil then
                local playerPos = player:GetOrigin()
                local ofs = Vector(0,1,0)
                DebugLine( mem.lastSeenPos+ofs, playerPos+ofs, 0.0,
                        0.5,0.5,0.5,1,   true )
            end
        end

    end

end

function TeamBrain:Update(dt)

    if gBotDebug:Get("spam") then
        Print("TeamBrain:Update")
    end

    local currBlips = GetSightedMapBlips(nil, self.teamNumber)

    // update our entId2memory, keyed by blip ent IDs
    for _, blip in ipairs(currBlips) do

        local entId = blip:GetOwnerEntityId()
        local mem = self.entId2memory[ entId ]
        if mem ~= nil then
            UpdateMemory( mem, blip )
        else
            self.entId2memory[ entId ] = CreateMemory(blip)
        end

    end

    // remove entId2memory that no longer exist
    // NOTE: This is technically cheating a little, ie. letting us know instantly when things no longer exist 

    local removedIds = {}

    for id, mem in pairs(self.entId2memory) do
        if Shared.GetEntity(id) == nil then
            self.assignments:RemoveGroup(id)
            table.insert(removedIds, id)
        end
    end

    for _,id in ipairs(removedIds) do
        self.entId2memory[id] = nil
    end

    //----------------------------------------
    //  Remove memories that have been investigated (ie. a marine went to the last known pos),
    //  but it has been a while since we last saw it
    //----------------------------------------
    removedIds = {}

    for memEntId, mem in pairs(self.entId2memory) do

        local ent = Shared.GetEntity(memEntId)
        assert( ent ~= nil )
        local entPos = ent:GetOrigin()
        local memTooOld = (Shared.GetTime() - mem.lastSeenTime) > 5.0

        for playerId,_ in ipairs(self.assignments:GetItems(mem.entId)) do

            local player = Shared.GetEntity(playerId)
            local playerPos = player:GetOrigin()
            local didInvestigate = mem.lastSeenPos:GetDistance(playerPos) < 4.0

            if didInvestigate and memTooOld then
                table.insert(removedIds, memEntId)
                break
            end

        end

    end

    for _,id in ipairs(removedIds) do
        self.entId2memory[id] = nil
    end

    //DebugPrint("%s mem has %d blips", self.label, GetTableSize(self.entId2memory) )

    if gBotDebug:Get("debugall") or gBotDebug:Get("debugteam") then
        self:DebugDraw()
    end

end

//----------------------------------------
//  Events from bots
//----------------------------------------

//----------------------------------------
//  Bots should call this when they assign themselves to a memory, e.g. a bot deciding to attack a hive.
//  Used for load-balancing purposes.
//----------------------------------------
function TeamBrain:AssignBotToMemory( bot, mem )

    local player = bot:GetPlayer()
    assert(player ~= nil)
    assert(mem ~= nil)
    local playerId = player:GetId()

    self.assignments:Assign( playerId, mem.entId )

end

function TeamBrain:AssignBotToEntity( bot, entId )

    local mem = self.entId2memory[entId]
    assert( mem ~= nil )
    self:AssignBotToMemory( bot, mem )

end

function TeamBrain:UnassignBot( bot )

    local player = bot:GetPlayer()
    assert(player ~= nil)
    local playerId = player:GetId()

    self.assignments:Unassign(playerId)

end

function TeamBrain:GetIsBotAssignedTo( bot, mem )

    local player = bot:GetPlayer()
    assert(player ~= nil)
    local playerId = player:GetId()

    return self.assignments:GetIsAssignedTo(playerId, mem.entId)

end

function TeamBrain:GetNumAssignedTo( mem, countsFunc )

    return self.assignments:GetNumAssignedTo( mem.entId, countsFunc )

end

function TeamBrain:GetNumAssignedToEntity( entId, countsFunc )

    assert( self.entId2memory[entId] ~= nil )
    return self.assignments:GetNumAssignedTo( entId, countsFunc )

end

function TeamBrain:GetNumOthersAssignedToEntity( entId, exceptBot )

    return self:GetNumAssignedToEntity( entId, function(otherId)
            return otherId ~= exceptBot:GetPlayer():GetId()
            end)

end

function TeamBrain:DebugDump()

    function Group2String(memEntId)
        local mem = self.entId2memory[memEntId]
        return MemoryToString(mem)
    end

    function Item2String(playerId)
        local player = Shared.GetEntity(playerId)
        assert( player ~= nil )
        return player:GetName()
    end

    self.assignments:DebugDump( Item2String, Group2String )

end
