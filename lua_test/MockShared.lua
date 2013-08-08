// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// MockShared.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com) and
//
// Mocks the Shared script interface for testing purposes.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("MockMagic.lua")

function MockShared()

    if Shared then
        return MockMagic.CreateGlobalMock("Shared")
    end
    
    local sharedMock = MockMagic.CreateGlobalMock("Shared")

    local messageFunction = sharedMock:AddFunction("Message")
    messageFunction:AddCall(function (text) print(text) end)

    local getRandomIntFunction = sharedMock:AddFunction("GetRandomInt")
    getRandomIntFunction:AddCall(function (min, max) return math.random(min, max) end)

    local getRandomFloatFunction = sharedMock:AddFunction("GetRandomFloat")
    getRandomFloatFunction:AddCall(function (min, max)
                                     if min and max then
                                         return min + ((max - min) * math.random())
                                     end
                                     return math.random()
                                   end)

    local getIsRunningPredictionFunction = sharedMock:AddFunction("GetIsRunningPrediction")
    getIsRunningPredictionFunction:AddCall(function () return false end)

    local getTimeFunction = sharedMock:AddFunction("GetTime")
    getTimeFunction:SetReturnValues({0})
    
    sharedMock:AddFunction("GetCheatsEnabled"):SetReturnValues({ false })
    sharedMock:AddFunction("GetDevMode"):SetReturnValues({ false })
    
    local traceRayFunction = sharedMock:AddFunction("TraceRay")
    traceRayFunction:AddCall(
        function(origin, target, physicsMask, entityFilter)
            return { endPoint = target }
        end)
    
    sharedMock.mapToClass = { }
    sharedMock:AddFunction("LinkClassToMap"):AddCall(function(className, mapName, netVars) sharedMock.mapToClass[mapName] = className end)
    
    return sharedMock
    
end

MockShared()