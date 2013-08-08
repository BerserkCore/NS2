-- Auto-generated from Predict.txt - Do not edit.
local pkg, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
if Predict == nil then Predict = {} end

function Shared.GetIsRunningPrediction()
    return (pkg.Shared_GetIsRunningPrediction(world))
end

function Predict.GetIsPredictor()
    return (pkg.Predict_GetIsPredictor())
end


