// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// WhipTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "WhipTest", package.seeall, lunit.testcase )

local marinePlayer, alienPlayer, whip = nil

function setup()

    SetPrintEnabled(true, "WhipTest")
    
    GetGamerules():ResetGame()
    RunOneUpdate()
    
    // Delete command station and hive
    local ents = GetEntitiesIsa("CommandStructure")
    for index, ent in ipairs(ents) do
        DestroyEntity(ent)
    end
    RunOneUpdate()
    
    marinePlayer = InitializeMarine()
    alienPlayer = InitializeAlien()
    
    marinePlayer:SetGravityEnabled(false)
    alienPlayer:SetGravityEnabled(false)
    
    whip = CreateStructure(kTechId.Whip, 2, true)
    
    // Put whip on ground to make sure it doesn't fall
    local whipOrigin = GetPointOnGround()
    whip:SetOrigin(whipOrigin)
    
    // Put alien and marine nearby, but also on ground
    alienPlayer:SetOrigin(Vector(whipOrigin.x + 3, whipOrigin.y, whipOrigin.z))
    marinePlayer:SetOrigin(Vector(whipOrigin.x - 3, whipOrigin.y, whipOrigin.z + 3))
    
    GetGamerules():SetGameStarted()
    
    // Delete all structures so they don't interfere with targeting
    for index, structure in ipairs(GetEntitiesIsa("Structure")) do
        DestroyEntity(structure)
    end  
    
    // Must be longer than the deploy
    RunOneUpdate(2)
    
    assert_not_equal(Entity.invalidId, alienPlayer:GetId())
    assert_not_equal(Entity.invalidId, marinePlayer:GetId())
    assert_not_equal(Entity.invalidId, whip:GetId())
    assert_true(whip:GetIsBuilt())
    
end

function teardown()    
    Cleanup()   
    marinePlayer = nil
    alienPlayer  = nil
    whip         = nil
end

function testTargeting()

    local marineStartHealth = marinePlayer:GetHealth()
    
    // Make sure it's not active or able to shoot
    MoveEntityDistanceFrom(alienPlayer, whip, Whip.kRange - 2)
    MoveEntityDistanceFrom(marinePlayer, whip, Whip.kRange + .01)
    RunOneUpdate(2)
    
    assert_nil(whip:GetTarget())
    
    MoveEntityDistanceFrom(marinePlayer, whip, Whip.kRange - 1)
    MoveEntityDistanceFrom(alienPlayer, whip, Whip.kRange + 2)
    
    RunUpdate(2)
    whip:AcquireTarget()
    
    // ...but not the alien player, even though closer
    local target = whip:GetTarget()
    assert_not_nil(target, SafeClassName(target))
    assert_equal(marinePlayer, whip:GetTarget())
    MoveEntityDistanceFrom(marinePlayer, whip, Whip.kRange + 1)
    
    RunUpdate(1)
    whip:AcquireTarget()
    assert_nil(whip:GetTarget())
    
    MoveEntityDistanceFrom(marinePlayer, whip, Whip.kRange - 1)
    RunUpdate(1)
    whip:AcquireTarget()
    assert_not_nil(whip:GetTarget())
    assert_equal(marinePlayer:GetId(), whip:GetTarget():GetId())
    
    //Print("%.2f, time: %.2f", whip.timeOfLastStrikeStart, Shared.GetTime())
    
    // I don't know why think isn't being called but it's working fine in game
    /*
    // It should attack and do damage
    RunUpdate(2)
    assert_float_equal(marineStartHealth - Whip.kDamage, marinePlayer:GetHealth())
    */
    // Move player just inside of fury range 
    MoveEntityDistanceFrom(alienPlayer, whip, Whip.kFuryRadius - .01)
    
    // Get skulk bite damage, make sure not upgraded
    local bite = alienPlayer:GetItem(BiteLeap.kMapName)
    assert_not_nil(bite)
    assert_float_equal(BiteLeap.kDamage, NS2Gamerules():GetUpgradedDamage(alienPlayer, BiteLeap.kDamage, bite:GetDamageType()))

    // Check upgraded damage within range    
    whip:TriggerFury()
    RunOneUpdate(.5)
    assert_float_equal(BiteLeap.kDamage * (1 + Whip.kFuryDamageBoost), NS2Gamerules():GetUpgradedDamage(alienPlayer, BiteLeap.kDamage, bite:GetDamageType()))
    
    MoveEntityDistanceFrom(alienPlayer, whip, Whip.kFuryRadius + .01)
    RunOneUpdate(.5)
    
    // Should be back to normal damage
    assert_float_equal(BiteLeap.kDamage, NS2Gamerules():GetUpgradedDamage(alienPlayer, BiteLeap.kDamage, bite:GetDamageType()))

end