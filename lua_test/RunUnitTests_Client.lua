// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// RunUnitTests.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Note: Don't use the word "test" in any function that isn't one of the testcases ("testSpawnPoint", 
// "RunTestCase"), or unpredictable behavior will result as lunit tries to call that function as 
// a testcase.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

require "lunit"

// Include new script test files here (runs on dev_test.level)
Script.Load("lua/Globals.lua")
Script.Load("ScoreboardTest.lua")

// If you want to run a test on a particular map, add a new RunMapTest line in ScriptTest.cpp

// Run the testbed
local stats = lunit.main()

if(stats.failed == 0 and stats.errors == 0) then
    print("RunUnitTests_Client SUCCESS (" .. stats.assertions .. " asserts).\n")    
else
    print("RunUnitTests_Client FAILED (" .. stats.failed .. " failed, " .. stats.errors .. " errors).\n")    
end