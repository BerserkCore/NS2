// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TechDataTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
Script.Load("lua/TechTreeConstants.lua")
Script.Load("lua/TechData.lua")
module( "TechDataUnitTests", package.seeall, lunit.testcase )

function setup()   
end

function teardown()
end

function testInsert()

    local kTechDataFakeDisplayName = "fakedisplayname"
    local kTechDataFakeModel = "fakemodel"
    
    // Check existing data 
    local displayName = ""
    assert_nil(GetCachedTechData(kTechId.Rifle, kTechDataFakeDisplayName))
    
    assert_true(SetCachedTechData(kTechId.Rifle, kTechDataFakeDisplayName, "testing"))
    assert_equal("testing", GetCachedTechData(kTechId.Rifle, kTechDataFakeDisplayName))

    assert_nil(GetCachedTechData(kTechId.Rifle, kTechDataFakeModel))
    assert_true(SetCachedTechData(kTechId.Rifle, kTechDataFakeModel, "model"))
    
    assert_not_nil(GetCachedTechData(kTechId.Rifle, kTechDataFakeModel))
    assert_equal("model", GetCachedTechData(kTechId.Rifle, kTechDataFakeModel))

    assert_equal("testing", GetCachedTechData(kTechId.Rifle, kTechDataFakeDisplayName))

end

function testRecycleValues()

    // Populate with fake data
    assert_true(SetCachedTechData(kTechId.Extractor, kTechDataCostKey, 1))
    assert_true(SetCachedTechData(kTechId.ExtractorUpgrade, kTechDataCostKey, 2))
    
    assert_true(SetCachedTechData(kTechId.Harvester, kTechDataCostKey, 1))
    assert_true(SetCachedTechData(kTechId.HarvesterUpgrade, kTechDataCostKey, 2))
    
    assert_true(SetCachedTechData(kTechId.CommandStation, kTechDataCostKey, 1))
    
    assert_true(SetCachedTechData(kTechId.Hive, kTechDataCostKey, 1))
    
    assert_true(SetCachedTechData(kTechId.Armory, kTechDataCostKey, 1))
    assert_true(SetCachedTechData(kTechId.AdvancedArmoryUpgrade, kTechDataCostKey, 2))
    assert_true(SetCachedTechData(kTechId.WeaponsModule, kTechDataCostKey, 3))

    // Test that recycle values are used
    assert(GetRecycleAmount(kTechId.Extractor, 0) < GetRecycleAmount(kTechId.Extractor, 1))
    assert(GetRecycleAmount(kTechId.Extractor, 1) < GetRecycleAmount(kTechId.Extractor, 2))
    assert(GetRecycleAmount(kTechId.Extractor, 2) < GetRecycleAmount(kTechId.Extractor, 3))
    assert_equal(GetRecycleAmount(kTechId.Extractor, 3), 7)
    
    assert(GetRecycleAmount(kTechId.Harvester, 0) < GetRecycleAmount(kTechId.Harvester, 1))
    assert(GetRecycleAmount(kTechId.Harvester, 1) < GetRecycleAmount(kTechId.Harvester, 2))
    assert(GetRecycleAmount(kTechId.Harvester, 2) < GetRecycleAmount(kTechId.Harvester, 3))
    assert_equal(GetRecycleAmount(kTechId.Harvester, 3), 7)
    
    //assert(GetRecycleAmount(kTechId.CommandStation) < GetRecycleAmount(kTechId.CommandFacility))
    //assert(GetRecycleAmount(kTechId.CommandFacility) < GetRecycleAmount(kTechId.CommandCenter))
    assert_equal(GetRecycleAmount(kTechId.CommandStation), 1)
    //assert_equal(GetRecycleAmount(kTechId.CommandFacility), 3)
    //assert_equal(GetRecycleAmount(kTechId.CommandCenter), 6)

    //assert(GetRecycleAmount(kTechId.Hive) < GetRecycleAmount(kTechId.HiveMass))
    //assert(GetRecycleAmount(kTechId.HiveMass) < GetRecycleAmount(kTechId.HiveColony))
    assert_equal(GetRecycleAmount(kTechId.Hive), 1)
    //assert_equal(GetRecycleAmount(kTechId.HiveMass), 3)
    //assert_equal(GetRecycleAmount(kTechId.HiveColony), 6)
    
    assert(GetRecycleAmount(kTechId.Armory) < GetRecycleAmount(kTechId.AdvancedArmory))
    //assert(GetRecycleAmount(kTechId.AdvancedArmory) < GetRecycleAmount(kTechId.WeaponsModule))
    assert_equal(GetRecycleAmount(kTechId.Armory), 1)
    assert_equal(GetRecycleAmount(kTechId.AdvancedArmory), 3)    
    //assert_equal(GetRecycleAmount(kTechId.WeaponsModule), 6)    
    
end
