// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockMagic.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// A utility to mock functions and objects generically with introspection tools.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// The global MockMagic interface.
MockMagic = { _mocks = { } }

// The following are utility functions to set the behavior of a mock object.

local function SetReturnValues(self, returnValueTable)

    ASSERT(self ~= nil)
    ASSERT(type(returnValueTable) == "table")
    
    self.ReturnValues = returnValueTable
    
end

local function AddCall(self, functionToCall)

    ASSERT(self ~= nil)
    ASSERT(type(functionToCall) == "function")
    
    table.insert(self.Calls, functionToCall)

end

local function RemoveCall(self, functionToCall)

    ASSERT(self ~= nil)
    ASSERT(type(functionToCall) == "function")
    
    return table.removevalue(self.Calls, functionToCall)

end

local function GetCallHistory(self)

    return self.CallHistory

end

local function GetCallCount(self)
    return #self.CallHistory
end

local addFunctionUtilities = { }
addFunctionUtilities["SetReturnValues"] = SetReturnValues
addFunctionUtilities["AddCall"] = AddCall
addFunctionUtilities["RemoveCall"] = RemoveCall
addFunctionUtilities["GetCallHistory"] = GetCallHistory
addFunctionUtilities["GetCallCount"] = GetCallCount

local function AddFunction(self, name)

    ASSERT(self ~= nil)
    ASSERT(type(name) == "string")
    
    local mockFunctionData = { Name = name, ReturnValues = { }, Calls = { }, CallHistory = { } }
    table.insert(self._mockfunctions, mockFunctionData)
    self[name] = function (...)
                    // Track history, latest events go to front of the history.
                    table.insert(mockFunctionData.CallHistory, 1, { passedParameters = {...} })
                    // Make all added Calls first.
                    local lastReturnValue = nil
                    for k, v in ipairs(mockFunctionData.Calls) do
                        // Remember the last non-nil return value.
                        lastReturnValue = v(...) or lastReturnValue
                    end
                    // If no return values specified, return whatever the last
                    // call returned.
                    if #mockFunctionData.ReturnValues == 0 then
                        return lastReturnValue
                    end
                    // Return the specified values.
                    return unpack(mockFunctionData.ReturnValues)
                 end
    mockFunctionData.Function = self[name]
    
    // Install utilities.
    for k, v in pairs(addFunctionUtilities) do
        mockFunctionData[k] = v
    end
    
    return mockFunctionData

end

local function GetFunction(self, name)

    ASSERT(self ~= nil)
    
    if type(name) == "string" then
        for k, v in ipairs(self._mockfunctions) do
            if v.Name == name then
                return v
            end
        end
        return nil
    end
    
    // If no name is passed in, return the meta call for this object.
    return self:GetFunction("_metacall")
    
end

local function RemoveFunction(self, mockFunctionData)

    ASSERT(self ~= nil)
    ASSERT(mockFunctionData ~= nil)
    
    if table.find(self._mockfunctions, mockFunctionData) then
        self[mockFunctionData.Name] = nil
        table.removevalue(self._mockfunctions, mockFunctionData)
        return true
    end
    return false

end

local function SetValue(self, name, defaultValue)

    ASSERT(self ~= nil)
    ASSERT(type(name) == "string")
    
    self[name] = defaultValue

end

local mockUtilities = { }
mockUtilities["AddFunction"] = AddFunction
mockUtilities["GetFunction"] = GetFunction
mockUtilities["RemoveFunction"] = RemoveFunction
mockUtilities["SetValue"] = SetValue

/**
 * Creates a mock object and returns it.
 */
function MockMagic.CreateMock()

    local newMock = { }
    table.insert(MockMagic._mocks, newMock)
    
    // Install utilities.
    for k, v in pairs(mockUtilities) do
        newMock[k] = v
    end
    
    // This is where all the functions added through AddFunction are stored for this mock object.
    newMock._mockfunctions = { }
    
    // Install metatable.
    newMock:AddFunction("_metacall")
    // Strip the table that is passed into a __call before calling the _metacall.
    local function StripTableFromMetaCall(mockTable, ...)
        return newMock._metacall(...)
    end
    local mockMetaTable = { __call = StripTableFromMetaCall }
    setmetatable(newMock, mockMetaTable)
    
    return newMock

end

/**
 * Create a new mock with the passed in name and make it available at global scope.
 */
function MockMagic.CreateGlobalMock(name)

    ASSERT(type(name) == "string")
    
    // Do not create a new global mock if one with this name exists.
    for k, v in ipairs(MockMagic._mocks) do
        if v.GlobalName == name then
            return v
        end 
    end
    
    local existingValue = _G[name]
    _G[name] = MockMagic.CreateMock()
    _G[name].GlobalName = name
    _G[name].ExistingValue = existingValue
    
    return _G[name]

end

function MockMagic.CreateGlobalMockValue(valueName, value)

    ASSERT(type(valueName) == "string")
    
    // Do not create a new global mock if one with this name exists.
    for k, v in ipairs(MockMagic._mocks) do
        if v.GlobalName == valueName then
            return v
        end 
    end
    
    local returnMock = MockMagic.CreateGlobalMock(valueName)
    
    // Override what CreateGlobalMock() did in setting up the global mock.
    _G[valueName] = value
    
    return returnMock

end

// Destroy the passed in mock object and remove it from global scope.
function MockMagic.DestroyMock(mockObject)

    local contained, atPos = table.contains(MockMagic._mocks, mockObject)
    if contained then
    
        if mockObject.GlobalName then
            _G[mockObject.GlobalName] = mockObject.ExistingValue
        end
        
        table.remove(MockMagic._mocks, atPos)
        
        return true
        
    end
    
    return false

end

function MockMagic.DestroyAllMocks()

    while MockMagic.GetNumberOfMocks() > 0 do
        MockMagic.DestroyMock(MockMagic._mocks[1])
    end

end

function MockMagic.GetNumberOfMocks()
    return #MockMagic._mocks
end