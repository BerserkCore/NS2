
//----------------------------------------
//  Profile FFI, per recommendation by FSFOD
//----------------------------------------

local ffi = require("ffi")
local profile = ProfileLib


function __profile_start(idx)
    profile.ScriptProfileStart(idx)
end

function __profile_end(idx)
    profile.ScriptProfileEnd(idx)
end

//This is only called when profiling is disabled so it can be an empty function
_G["PRO".."FILE"] = function() end