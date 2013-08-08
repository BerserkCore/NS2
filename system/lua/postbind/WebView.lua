-- Auto-generated from WebView.txt - Do not edit.
local pkg, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- WebView FFI method additions --

function WebView:LoadUrl(url)
    pkg.WebView_LoadUrl(self, url)
end

function WebView:GetUrlLoaded()
    return (pkg.WebView_GetUrlLoaded(self))
end

function WebView:SetTargetTexture(targetName)
    pkg.WebView_SetTargetTexture(world, self, targetName)
end

function WebView:OnMouseMove(x, y)
    pkg.WebView_OnMouseMove(self, x, y)
end

function WebView:OnMouseDown(button)
    pkg.WebView_OnMouseDown(self, button)
end

function WebView:OnMouseUp(button)
    pkg.WebView_OnMouseUp(self, button)
end

function WebView:OnMouseWheel(vertPixels, horzPixels)
    pkg.WebView_OnMouseWheel(self, vertPixels, horzPixels)
end

function WebView:SetIsVisible(visible)
    pkg.WebView_SetIsVisible(self, visible)
end


