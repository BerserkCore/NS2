-- Auto-generated from AnimationGraph.txt - Do not edit.
local pkg, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- AnimationGraph FFI method additions --

function AnimationGraph:GetTagName(model, tagIndex)
    return (ffi_string(pkg.AnimationGraph_GetTagName(self, model, tagIndex)))
end

function AnimationGraph:GetFileName()
    return (ffi_string(pkg.AnimationGraph_GetFileName(self)))
end

-- AnimationGraphState FFI method additions --

function AnimationGraphState:SetLogEnabled(logEnabled)
    pkg.AnimationGraphState_SetLogEnabled(self, logEnabled)
end

function AnimationGraphState:PrepareForGraph(graph)
    pkg.AnimationGraphState_PrepareForGraph(self, graph)
end

function AnimationGraphState:Reset(graph, model, time)
    pkg.AnimationGraphState_Reset(self, graph, model, time)
end

function AnimationGraphState:SetInputValue(graph, name, value)

    if(type(value) == "number") then
        pkg.AnimationGraphState_SetInputValue0(self, graph, name, value)
    elseif(type(value) == "string") then
        pkg.AnimationGraphState_SetInputValue1(self, graph, name, value)
    else
        pkg.AnimationGraphState_SetInputValue2(self, graph, name, value)
    end
end

function AnimationGraphState:GetBoneCoords(model, poseParams, boneCoords)
    pkg.AnimationGraphState_GetBoneCoords(self, model, poseParams, boneCoords)
end

function AnimationGraphState:SetTime(time)
    pkg.AnimationGraphState_SetTime(self, time)
end

function AnimationGraphState:GetCurrentNode(layer)
    return (pkg.AnimationGraphState_GetCurrentNode(self, layer))
end

function AnimationGraphState:SetCurrentNode(layer, nodeId)
    pkg.AnimationGraphState_SetCurrentNode(self, layer, nodeId)
end

function AnimationGraphState:SetCurrentAnimation(layerIndex, blendIndex, animationIndex, startTime, speed, blendTime)
    pkg.AnimationGraphState_SetCurrentAnimation(self, layerIndex, blendIndex, animationIndex, startTime, speed, blendTime)
end

function AnimationGraphState:GetCurrentAnimationStruct(layerIndex, blendIndex)
    local __cdataOut = ffi_new("CurrentAnimationInfo")
    pkg.AnimationGraphState_GetCurrentAnimationStruct(self, layerIndex, blendIndex, __cdataOut)

    return __cdataOut
end

function AnimationGraphState:LogState(graph, model)
    pkg.AnimationGraphState_LogState(self, graph, model)
end


