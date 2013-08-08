-- Auto-generated from GUIView.txt - Do not edit.
local pkg, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- GUIView FFI method additions --

function GUIView:Load(scriptFile)
    pkg.GUIView_Load(self, scriptFile)
end

function GUIView:SetTargetTexture(targetName)
    pkg.GUIView_SetTargetTexture(world, self, targetName)
end

function GUIView:SetGlobal(name, value)

    if(type(value) == "number") then
        pkg.GUIView_SetGlobal0(self, name, value)
    else
        pkg.GUIView_SetGlobal1(self, name, value)
    end
end


