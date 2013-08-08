// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lunit-xml.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// Outputs results of lunit testing to a standard XUnit XML format.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================



--[[

      begin()
        run(testcasename, testname)
          err(fullname, message, traceback)
          fail(fullname, where, message, usermessage)
          pass(testcasename, testname)
      done()

      Fullname:
        testcase.testname
        testcase.testname:setupname
        testcase.testname:teardownname

--]]

//  <?xml version="1.0" ?>
//  <testsuite name="DefaultSuite" tests="15" errors="1" failures="1" time="0.060000">
//    <testcase classname="DefaultSuite" name="GUISystemConstructorTest" time="0.057000">
//      <error message=".\GUISystemTest.cpp(29) : Expected 1 but was 2" />
//    </testcase>
//    <testcase classname="DefaultSuite" name="GUISystemCreateDestroyTest" time="0.001000" />
//    <testcase classname="DefaultSuite" name="GUISystemItemOriginTest" time="0.000000" />
//    <testcase classname="DefaultSuite" name="GUISystemItemRotationTest" time="0.000000" />
//    <system-out>
//      <![CDATA[   ]]>
//    </system-out>
//    <system-err>
//      <![CDATA[   ]]>
//    </system-err>
//  </testsuite>

require "lunit"

module( "lunit-xml", package.seeall )

local outputFilename = "..\\TESTS-Script-DefaultSuite.xml"
local xmlFile = io.open(outputFilename, "w")
if not xmlFile then
    error("Failed to open " .. outputFilename)
end

print("Outputting to XML file " .. outputFilename)

xmlFile:write("<?xml version=\"1.0\" ?>\n")

local totalTestCases = 0
local totalTests = 0
local totalErrors = 0
local totalFailures = 0
local testsData = { }
local currentTest = nil

function begin()

    for tcname in lunit.testcases() do
        totalTestCases = totalTestCases + 1
        for testname, test in lunit.tests(tcname) do
            totalTests = totalTests + 1
        end
    end
    
end

function run(testcasename, testname)

    currentTest = { CaseName = testcasename, TestName = testname }

end

function err(fullname, message, traceback)

    TestBedSetFail(fullname..": "..message)
    
    currentTest.Error = { FullName = fullname, Message = message, TraceBack = traceback }
    table.insert(testsData, currentTest)
    
    totalErrors = totalErrors + 1
    
end

function fail(fullname, where, message, usermessage)

    TestBedSetFail(where..": "..message)

    currentTest.Failure = { FullName = fullname, Where = where, Message = message, UserMessage = usermessage }
    table.insert(testsData, currentTest)
    
    totalFailures = totalFailures + 1
    
end

function pass(testcasename, testname)

    currentTest.Pass = { }
    table.insert(testsData, currentTest)
    
end

function done()

    xmlFile:write("<testsuite name=\"DefaultSuite\" tests=\"" .. totalTests .. "\" errors=\"" .. totalErrors .. "\" failures=\"" .. totalFailures .. "\">\n")
    
    for i, testData in ipairs(testsData) do

        if testData.Pass then
        
            xmlFile:write("  <testcase classname=\"DefaultSuite\" name=\"" .. testData.CaseName .. "." .. testData.TestName .. "\"/>\n")
            
        elseif testData.Error then
        
            local errorData = testData.Error
            xmlFile:write("  <testcase classname=\"DefaultSuite\" name=\"" .. testData.CaseName .. "." .. testData.TestName .. "\">\n")
            xmlFile:write("    <error message=\"Error: " .. errorData.FullName .. " (" .. table.concat(errorData.TraceBack, "\n\t") .. "): " .. errorData.Message .. "\" />\n")
            xmlFile:write("  </testcase>\n")
            
        elseif testData.Failure then
        
            local failureData = testData.Failure
            xmlFile:write("  <testcase classname=\"DefaultSuite\" name=\"" .. testData.CaseName .. "." .. testData.TestName .. "\">\n")
            xmlFile:write("    <error message=\"Failure: " .. failureData.FullName .. " (" .. failureData.Where .. "): " .. failureData.Message .. "\" />\n")
            xmlFile:write("  </testcase>\n")
            
        end
        
    end
    
    xmlFile:write("</testsuite>")
    xmlFile:close()
                
end





