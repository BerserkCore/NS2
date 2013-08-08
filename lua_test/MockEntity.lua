// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockEntity.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks the Entity class and objects for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("MockShared.lua")
Script.Load("CommonMocks.lua")

/**
 * Usually the Entity class would be created by the Game but that doesn't
 * happen in the test framework so mock it here.
 */
class 'Entity'

function Entity:OnCreate()

    self.origin = Vector(0, 0, 0)
    
end

function Entity:SetSynchronizes()
end

function Entity:SetPropagate()
end

function Entity:SetRelevancyDistance()
end

function Entity:SetUpdates()
end

function Entity:GetOrigin()
    return self.origin
end

Entity.invalidId = -1

function MockEntitySharedFunctions()

    local entityMock = MockMagic.CreateGlobalMock("Entity")
    entityMock:SetValue("invalidId", -1)
    
    local mockSharedObject = MockShared()
    // Store the entity list on the mock Shared object so it is reset every test.
    mockSharedObject:SetValue("__entityList", { })
    mockSharedObject:AddFunction("GetEntity"):AddCall(function(entityId) return mockSharedObject.__entityList[entityId] end)
    
    local function MakeGetEntitiesFunction(filterFunction)
    
        return function(filterData, origin, range)
        
            local matchingEntities = { }
            
            for id, entity in pairs(Shared.__entityList) do
            
                if filterFunction(entity, filterData, origin, range) then
                    table.insert(matchingEntities, entity)
                end
                
            end
            
            function matchingEntities:GetSize() return table.count(self) end
            function matchingEntities:GetEntityAtIndex(index) return self[index + 1] end
            return matchingEntities
            
        end
        
    end
    
    local function ClassTagFilterFunction(entity, filterData, origin, range)
    
        if origin and (entity:GetOrigin() - origin):GetLength() > range then
            return false
        end
        
        local classStart, classEnd = string.find(filterData, "class:")
        if classStart then
            return entity:isa(string.sub(filterData, classEnd + 1, string.len(filterData)))
        else
            return HasMixin(entity, filterData)
        end
        
    end
    
    mockSharedObject:AddFunction("GetEntitiesWithTagInRange"):AddCall(MakeGetEntitiesFunction(ClassTagFilterFunction))
    mockSharedObject:AddFunction("GetEntitiesWithClassname"):AddCall(MakeGetEntitiesFunction(function(entity, filterData) return entity:isa(filterData) end))
    mockSharedObject:AddFunction("DestroyEntity"):AddCall(function(entity) mockSharedObject.__entityList[entity:GetId()] = nil end)

end

/**
 * This function returns a generic mock entity with the most common calls mocked.
 */
local entityIdCounter = 1
function CreateMockEntity()

    // Mock the Shared.GetEntity() function if it hasn't been mocked yet.
    if Shared == nil or Shared.GetEntity == nil then
    
        MockEntitySharedFunctions()
        
    end
    
    local mockEntity = MockMagic.CreateMock()
    SetMockType(mockEntity, "Entity")
    mockEntity.origin = Vector()
    mockEntity.angles = Angles()
    
    local entityId = entityIdCounter
    entityIdCounter = entityIdCounter + 1
    mockEntity:AddFunction("GetId"):SetReturnValues({entityId})
    mockEntity:AddFunction("GetOrigin"):AddCall(function() return mockEntity.origin end)
    mockEntity:AddFunction("SetOrigin"):AddCall(function(self, setOrigin) mockEntity.origin = setOrigin end)
    mockEntity:AddFunction("GetAngles"):AddCall(function() return mockEntity.angles end)
    mockEntity:AddFunction("GetParent")
    mockEntity:AddFunction("GetDistanceSquared"):AddCall(function(self, toPoint) return self.origin:GetDistanceSquared(toPoint) end)
    mockEntity:AddFunction("GetIsDestroyed"):SetReturnValues({false})
    // Add it to the Shared.GetEntity() list to be retrieved later.
    Shared.__entityList[entityId] = mockEntity
    return mockEntity
    
end