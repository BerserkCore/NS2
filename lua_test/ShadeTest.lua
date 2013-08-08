// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ShadeTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "ShadeTest", package.seeall, lunit.testcase )

local marinePlayer, alienPlayer, shade = nil

function setup()

    SetPrintEnabled(true, "ShadeTest")
    
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
    
    shade = CreateStructure(kTechId.Shade, 2, true)
    
    // Put shade on ground to make sure it doesn't fall
    local shadeOrigin = GetPointOnGround()
    shade:SetOrigin(shadeOrigin)
    
    // Put alien and marine nearby, but also on ground
    shadeOrigin.x = shadeOrigin.x + 2
    alienPlayer:SetOrigin(shadeOrigin)
    marinePlayer:SetOrigin(shadeOrigin)

    GetGamerules():SetGameStarted()
    RunOneUpdate(1)
        
end

function teardown()    
    Cleanup()   
    marinePlayer = nil
    alienPlayer  = nil
    shade         = nil
end

// Trigger cloak and make sure nearby structures and players are cloaked for proper duration
function cloakTest()

    // No one cloaked
    assert_false(marinePlayer:GetGameEffectMask(kGameEffect.Cloaked))
    assert_false(alienPlayer:GetGameEffectMask(kGameEffect.Cloaked))
    assert_false(shade:GetGameEffectMask(kGameEffect.Cloaked))
    
    // Trigger cloak
    local timeOfCloak = Shared.GetTime()
    shade:TriggerCloak()

    // Run one frame
    RunUpdates(AlienTeam.kUpdateGameEffectsInterval + .1)
    
    // Make sure enemy isn't cloaked but friendly in-range players and structures are
    assert_false(marinePlayer:GetGameEffectMask(kGameEffect.Cloaked))
    assert_true(alienPlayer:GetGameEffectMask(kGameEffect.Cloaked))
    assert_true(shade:GetGameEffectMask(kGameEffect.Cloaked))
    
    // Make sure friendly player just inside cloak range remains cloaked
    MoveEntityDistanceFrom(alienPlayer, shade, Shade.kCloakRadius - .01)
    RunUpdate(AlienTeam.kUpdateGameEffectsInterval)    
    assert_true(alienPlayer:GetGameEffectMask(kGameEffect.Cloaked))
    
    // Friendly player just outside range no longer cloaked
    MoveEntityDistanceFrom(alienPlayer, shade, Shade.kCloakRadius + .01)    
    RunUpdates(AlienTeam.kUpdateGameEffectsInterval)
    assert_false(alienPlayer:GetGameEffectMask(kGameEffect.Cloaked))    
    
    // Let it run out and make sure it stops working
    RunUpdates(Shade.kCloakDuration - (Shared.GetTime() - timeOfCloak) + .1)        
    assert_false(marinePlayer:GetGameEffectMask(kGameEffect.Cloaked))
    assert_false(shade:GetGameEffectMask(kGameEffect.Cloaked))

end
