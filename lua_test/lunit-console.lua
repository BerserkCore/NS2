
--[[--------------------------------------------------------------------------

    This file is part of lunit 0.5.

    For Details about lunit look at: http://www.mroth.net/lunit/

    Author: Michael Roth <mroth@nessie.de>

    Copyright (c) 2006-2008 Michael Roth <mroth@nessie.de>

    Permission is hereby granted, free of charge, to any person 
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without restriction,
    including without limitation the rights to use, copy, modify, merge,
    publish, distribute, sublicense, and/or sell copies of the Software,
    and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be 
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--]]--------------------------------------------------------------------------



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


require "lunit"

module( "lunit-console", package.seeall )

local function printformat(format, ...)
    TestBedPrint(string.format(format, ...))
end

local columns_printed = 0

local msgs = {}

function begin()

    local total_tc = 0
    local total_tests = 0
    
    for tcname in lunit.testcases() do
        total_tc = total_tc + 1
        for testname, test in lunit.tests(tcname) do
            total_tests = total_tests + 1
        end
    end
    
    --printformat("Loaded testsuite with %d tests in %d testcases.\n\n", total_tests, total_tc)
    
end


function run(testcasename, testname)
end


function err(fullname, message, traceback)

    TestBedSetFail(fullname..": "..message)
    
    msgs[#msgs+1] = "Error! ("..fullname.."): \n"..message.."\n\n\t"..table.concat(traceback, "\n\t")
    
end


function fail(fullname, where, message)

    TestBedSetFail(where..": "..message)
    
    local text =  "Failure ("..fullname.."): \n"..
                  where..": "..message
    
    msgs[#msgs+1] = text
    
end


function pass(testcasename, testname)
end

function done()

    --printformat("\n\n%d Assertions checked.\n", lunit.stats.assertions )
    --print()

    for i, msg in ipairs(msgs) do
        printformat( "\n\n%3d) %s", i, msg )
    end

    --printformat("Testsuite finished (%d passed, %d failed, %d errors).\n",
    --    lunit.stats.passed, lunit.stats.failed, lunit.stats.errors )
    
end