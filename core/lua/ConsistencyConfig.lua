// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// core/ConsistencyConfig.lua
//
// Created by Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ConfigFileUtility.lua")

local consistencyConfigFileName = "ConsistencyConfig.json"
local finishedChecking = false
local finishedIgnoring = false
local finishedRestricting = false
local startTime = Shared.GetSystemTime()
// Write out the default file if it doesn't exist.
local defaultConfig = { check = { "game_setup.xml", "*.lua", "*.hlsl", "*.shader", "*.screenfx", "*.surface_shader", "*.fxh", "*.render_setup", "*.shader_template", "*.level",
                                  "*.dds", "*.jpg", "*.png", "*.cinematic", "*.material", "*.model", "*.animation_graph", "*.polygons", "*.fev", "*.fsb" },
                        ignore = { "ui/*.dds", "*_view*.dds", "*_view*.material", "*_view*.model", "models/marine/hands/*" },
                        restrict = { "lua/entry/*.entry" } }
WriteDefaultConfigFile(consistencyConfigFileName, defaultConfig)

/** 
 * Loads information from the consistency config file.
 */
local consistencyConfig = LoadConfigFile(consistencyConfigFileName)

if consistencyConfig then

    if type(consistencyConfig.check) == "table" then
        local check = consistencyConfig.check
        for c = 1, #check do
            local numHashed = Server.AddFileHashes(check[c])
            Shared.Message("Hashed " .. numHashed .. " " .. check[c] .. " files for consistency")
        end
		finishedChecking = true
    end

    if type(consistencyConfig.ignore) == "table" then
        local ignore = consistencyConfig.ignore
        for c = 1, #ignore do
            local numHashed = Server.RemoveFileHashes(ignore[c])
            Shared.Message("Skipped " .. numHashed .. " " .. ignore[c] .. " files for consistency")
        end
		finishedIgnoring = true
    end
    
    if type(consistencyConfig.restrict) == "table" then
        local check = consistencyConfig.restrict
        for c = 1, #check do
            local numHashed = Server.AddRestrictedFileHashes(check[c])
            Shared.Message("Hashed " .. numHashed .. " " .. check[c] .. " files for consistency")
        end
		finishedRestricting = true
    end
    
	if finishedChecking == true and finishedIgnoring == true and finishedRestricting == true then
		local endTime = Shared.GetSystemTime()
		Print("Consistency checking took " .. ToString(endTime - startTime) .. " seconds")
	end
    
end