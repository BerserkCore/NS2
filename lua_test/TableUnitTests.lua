// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TableUnitTests.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/Table.lua")
module( "TableUnitTests", package.seeall, lunit.testcase )

local table1

function setup()

    table1 = { 1, true, "hello" }
    
end

function teardown()
end

function TestTableDuplicate()

    local table2 = table.duplicate(table1)
    
    // The tables should be unique.
    assert_not_equal(table1, table2)
    
    // Same number of items.
    assert_equal(table.count(table1), table.count(table2))
    
    // But they should contain the same items.
    assert_equal(table1[1], table2[1])
    assert_equal(table1[2], table2[2])
    assert_equal(table1[3], table2[3])
    
    //assert_equal(1, 2, "This test fails on purpose for testing the CI server")
    
end

function TestTableCopy()

    local table2 = { removeVal = 1 }
    // 3rd param is optional, it should clear the destination table if not set to true.
    table.copy(table1, table2)
    
    // The tables should be unique.
    assert_not_equal(table1, table2)
    
    // Same number of items.
    assert_equal(table.count(table1), table.count(table2))
    
    // But they should contain the same items.
    assert_equal(table1[1], table2[1])
    assert_equal(table1[2], table2[2])
    assert_equal(table1[3], table2[3])

end

function TestTableFind()

    local insideTable1 = { "Inside" }
    local insideTable2 = { "Inside" }
    local findTestTable = { "First", insideTable1, true, insideTable2, 85 }
    
    // If the value is in the table the index of the (first) matching element is returned.
    assert_equal(1, table.find(findTestTable, "First"))
    
    //If its not found the function returns nil.
    assert_equal(nil, table.find(findTestTable, "NotThere"))
    
    // Since insideTable1 and insideTable2 have equal elements, they should be the same
    // inside table.find so finding either should return the index of the first.
    assert_equal(2, table.find(findTestTable, insideTable1))
    assert_equal(2, table.find(findTestTable, insideTable2))

end

function TestTableContains()

    assert_true(table.contains({ 1, 2, 3 }, 1))
    assert_false(table.contains({ 1, 2, 3 }, 0))
    
    assert_true(table.contains({ "Hello", false }, false))
    assert_false(table.contains({ "Hello", false }, true))
    
    assert_true(table.contains({ Name1 = "Bob", Name2 = "Smith" }, "Bob"))
    assert_false(table.contains({ Name1 = "Bob", Name2 = "Smith" }, "Peter"))

end

function TestTableRandom()

    MockShared()
    
    // Should return nil if passed in an empty table.
    assert_equal(nil, table.random({ }))
    
    // Calling table.random with no parameters should cause an error.
    assert_error(function () table.random() end)
    // Or with something that isn't a table.
    assert_error(function () table.random(1) end)
    
    local testElement = "One element"
    local testRandomTable1 = { testElement }
    assert_equal(testElement, table.random(testRandomTable1))
    
    local testRandomTable2 = { 1, 2, 3 }
    local returnVal = table.random(testRandomTable2)
    assert_true(returnVal <= 3 and returnVal >= 1)

end

function TestTableChooseWeighted()

    MockShared()
    
    assert_equal(-1, table.chooseWeightedIndex({ }))
    
    local weightedTestTable = {{.9, "chooseOften"}, {.1, "chooseLessOften"}, {.001, "chooseAlmostNever"}}
    local chosenIndex = table.chooseWeightedIndex(weightedTestTable)
    // One of the indices from the test table should be returned.
    assert(chosenIndex >= 1 and chosenIndex <= table.maxn(weightedTestTable))

end

function TestGetIsEquivalent()

    assert_false(table.getIsEquivalent(nil, { 1 }))
    assert_false(table.getIsEquivalent({ 2 }, nil))
    assert_false(table.getIsEquivalent({ 1, 2, 3 }, { 1, 2 }))
    assert_false(table.getIsEquivalent({ function() return false end }, { function() return false end }))
    
    assert_true(table.getIsEquivalent(nil, nil))
    assert_true(table.getIsEquivalent({ }, { }))
    assert_true(table.getIsEquivalent({ 1, true, "Apple", { 42 } }, { 1, true, "Apple", { 42 } }))
    assert_true(table.getIsEquivalent({ 1, true, "Apple", { 42 } }, { 1, "Apple", true, { 42 } }))
    assert_true(table.getIsEquivalent({ First = 1, Second = false, Third = 3.2 }, { Second = false, First = 1, Third = 3.2 }))
    local testFunction = function () return true end
    assert_true(table.getIsEquivalent({ testFunction, 2, 6, 4 }, { testFunction, 2, 4, 6 }))

end

function TestClear()

    local clearTestTable = { 1, 2, 3 }
    table.clear(clearTestTable)
    assert(table.getIsEquivalent({ }, clearTestTable))

end

function TestRemoveConditional()

    local removeTestTable = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
    table.removeConditional(removeTestTable, function (element) return element < 6 end)
    
    assert_equal(5, table.count(removeTestTable))
    for i, v in ipairs(removeTestTable) do
        assert_true(v >= 6)
    end
    
    local removeNoneTestTable = { true, "Apple", 834.3 }
    table.removeConditional(removeNoneTestTable, function (element) return element == nil end)
    
    assert_equal(3, table.count(removeNoneTestTable))
    
    // A function needs to be passed in for the second argument.
    assert_error(function () table.removeConditional({ 1, 2, 3 }, nil) end)

end

function TestRemoveValue()

    local testRemoveValueTable = { 2, "Hello", true }
    table.removevalue(testRemoveValueTable, "Hello")
    
    assert_equal(2, table.count(testRemoveValueTable))
    
    table.removevalue(testRemoveValueTable, "Hello")
    
    // It was already removed.
    assert_equal(2, table.count(testRemoveValueTable))
    
    local testDictionary = { First = 1, Second = "Hello", [23] = true }
    table.removevalue(testDictionary, 1)
    
    // table.removevalue doesn't work on dictionaries. Only tables that are indexed
    // with increasing numeric values (an array).
    assert_equal(3, table.countkeys(testDictionary))

end

function TestInsertUnique()

    local testInsertUniqueTable = { 1, 3.2, "Bunny" }
    table.insertunique(testInsertUniqueTable, 2)
    
    assert_equal(4, table.count(testInsertUniqueTable))
    
    table.insertunique(testInsertUniqueTable, 2)
    
    assert_equal(4, table.count(testInsertUniqueTable))
    
    assert_error(function() table.insertunique(testInsertUniqueTable, nil) end)
    
    // Does not insert nil into table.
    assert_equal(4, table.count(testInsertUniqueTable))
    
    local testDictionary = { First = 1, Second = "Hello", [23] = true }
    table.insertunique(testDictionary, "Tea")
    
    assert_equal(4, table.countkeys(testDictionary))
    
    // Non-unique value.
    table.insertunique(testDictionary, "Hello")
    
    // table.insertunique doesn't support dictionaries.
    assert_equal(5, table.countkeys(testDictionary))

end

function TestAddTable()

    local blankTestTable = { }
    local sourceTestTable = { 1, true, "Yellow" }
    table.addtable(sourceTestTable, blankTestTable)
    
    // The contents should be equal.
    assert_true(table.getIsEquivalent(sourceTestTable, blankTestTable))
    // But they should still be unique tables.
    assert_not_equal(sourceTestTable, blankTestTable)
    
    local twoElementsTestTable = { 6, 5.2 }
    table.addtable(sourceTestTable, twoElementsTestTable)
    
    assert_equal(3, table.count(sourceTestTable))
    assert_equal(5, table.count(twoElementsTestTable))
    assert_equal(6, twoElementsTestTable[1])
    assert_equal(5.2, twoElementsTestTable[2])
    assert_equal(1, twoElementsTestTable[3])
    assert_equal(true, twoElementsTestTable[4])
    assert_equal("Yellow", twoElementsTestTable[5])
    
    local noChangeTestTable = { "No Change", { 2, 3 }, false }
    local emptySourceTable = { }
    table.addtable(emptySourceTable, noChangeTestTable)
    
    assert_equal(3, table.count(noChangeTestTable))

end

function TestAddUniqueTable()

    local testAddUniqueTable1 = { 1, 3, 4, 5, 6 }
    local testAddUniqueTable2 = { 2, 4, 6 }
    table.adduniquetable(testAddUniqueTable1, testAddUniqueTable2)
    
    // The source should not have been modified.
    assert_equal(5, table.count(testAddUniqueTable1))
    
    // The destination should have been given the unique elements in the source.
    assert_equal(6, table.count(testAddUniqueTable2))

end

function TestForEachFunctor()

    local testResult = 0
    local testForEachFunctorTable = { 4, 8, 15, 16, 23, 42 }
    table.foreachfunctor(testForEachFunctorTable, function (element) testResult = testResult + element end)
    
    assert_equal(6, table.count(testForEachFunctorTable))
    assert_equal(108, testResult)
    
end

function TestTableCount()

    local testCountTable = { "Vitamin", true, 53, 92.4 }
    assert_equal(4, table.count(testCountTable))
    
    local emptyTable = { }
    assert_equal(0, table.count(emptyTable))
    
    local nilTable = nil
    // Returns 0 if nil is passed in.
    assert_equal(0, table.count(nilTable))
    
    // Doesn't work for pure dictionaries.
    local testDictionary = { First = 1, Second = true, Third = "Hello" }
    assert_equal(0, table.count(testDictionary))
    
    testDictionary[33] = "Today"
    // Uses the largest numeric element as the count.
    assert_equal(33, table.count(testDictionary))

end

function TestTableCountKeys()

    // Works for tables defined with no keys.
    assert_equal(3, table.countkeys(table1))
    // Same as table.count.
    assert_equal(3, table.count(table1))
    
    local insertedTable = { }
    table.insert(insertedTable, "test")
    table.insert(insertedTable, 42)
    table.insert(insertedTable, true)
    table.insert(insertedTable, { 1, 2, 3 })
    // And for tables created with insert.
    assert_equal(4, table.countkeys(insertedTable))
    // Same as table.count.
    assert_equal(4, table.count(insertedTable))
    
    // And for dictionaries, which other counting methods don't support.
    local testDictionary = { TestKey = 2, SkyIsBlue = true, Three = 3, OtherDict = { "yellow", "blue", Orange = "orange" }, Today = "Monday" }
    assert_equal(5, table.countkeys(testDictionary))
    // Not the same as table.count.
    assert_equal(0, table.count(testDictionary))

end

function TestRemoveTable()

    local testSourceTable = { 1, 2, 3, 4, 3, 5, "Yerba" }
    local testDestinationTable = { 1, true, 3, false, 3, 5, "Rooibos" }
    table.removeTable(testSourceTable, testDestinationTable)
    
    assert_equal(3, table.count(testDestinationTable))
    assert_equal(7, table.count(testSourceTable))

end

function TestDiffTable()

    local testTable1 = { 1, 2, 3, 4, 5, 6, 7 }
    local testTable2 = { 1, 8, 3, 9, 5, 10, 7 }
    local resultTable = table.diff(testTable1, testTable2)
    
    assert_equal(6, table.count(resultTable))
    assert_true(table.getIsEquivalent(resultTable, { 2, 8, 4, 9, 6, 10 }))

end

function TestTableToString()

    local simpleTable = { 1 }
    assert_equal("{1}", table.tostring(simpleTable))
    
    // nils are not printed.
    local tableInTable = { "One", 2, { true, 4.23 }, nil, "two" }
    assert_equal("{\"One\",2,{\"true\",4.23},\"two\",}", table.tostring(tableInTable))
    // Even though nil does technically take up a spot in the table.
    assert_equal(5, table.count(tableInTable))
    
    local functionInTable = { function () return 1 end }
    // tostring works on functions with a format "{"function: 0x03143da8"}" for example.
    assert_not_equal(nil, string.find(table.tostring(functionInTable), "{\"function: "))
    
    local notATable = 23
    // A error string is returned if a non-table is passed in.
    assert_equal("{<data is \"" .. type(notATable) .. "\", not \"table\">}", table.tostring(notATable))

end