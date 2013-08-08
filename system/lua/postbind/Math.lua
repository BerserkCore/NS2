-- Auto-generated from Math.txt - Do not edit.
local pkg = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
if Math == nil then Math = {} end

function Math.Wrap(x, min, max)
    return (pkg.Math_Wrap(x, min, max))
end

function Math.Clamp(x, min, max)
    return (pkg.Math_Clamp(x, min, max))
end

function Math.Noise(x)
    return (pkg.Math_Noise(x))
end

function Math.Radians(x)
    return (pkg.Math_Radians(x))
end

function Math.Degrees(x)
    return (pkg.Math_Degrees(x))
end

function Math.GetIsFinite(x)
    return (pkg.Math_GetIsFinite(x))
end

function Math.CrossProduct(x, y)
    local __cdataOut = Vector()
    pkg.Math_CrossProduct(x, y, __cdataOut)

    return __cdataOut
end

function Math.DotProduct(x, y)
    return (pkg.Math_DotProduct(x, y))
end


