// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// RunLunit.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Shared include for each test case so it can be loaded individually.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

require "lunit"

// Run the testbed
local parameters = { }
if XML_OUTPUT == true then

    table.insert(parameters, "--runner")
    table.insert(parameters, "lunit-xml")

end

local stats = lunit.main(parameters)
if(stats.failed == 0 and stats.errors == 0) then
    TestBedPrint(" SUCCESS (" .. stats.assertions .. " asserts).")    
else
    TestBedPrint("\n\nFAILED (" .. stats.failed .. " failed, " .. stats.errors .. " errors).\n")    
end