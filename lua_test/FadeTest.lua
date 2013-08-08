// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// FadeTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "FadeTest", package.seeall, lunit.testcase )

local fade = nil

function setup()

    SetPrintEnabled(true, "FadeTest")
    
    GetGamerules():ResetGame()
    GetGamerules():SetGameStarted()

    fade = InitializePlayer(Fade.kMapName, 2)
        
end

function teardown()
    Cleanup()
    fade = nil
end

function test1()

    assert_equal(Fade.kModelName, fade:GetModelName())
    
    assert_equal(Fade.kHealth, fade:GetHealth())
    assert_equal(Fade.kHealth, fade:GetMaxHealth())
    
    assert_equal(Fade.kArmor, fade:GetArmor())
    assert_equal(Fade.kArmor, fade:GetMaxArmor())

    // Make sure we have valid view model
    assert_not_nil(fade:GetViewModelEntity())    
    assert_not_equal(0, fade:GetViewModelEntity():GetModelIndex()) 
    
end

function test2()

    // Have fade blink and make sure we can't take damage
    assert_true(GetGamerules():CanEntityDoDamageTo(nil, fade))
    
    local swipeBlink = fade:GetActiveWeapon()
    assert_not_nil(swipeBlink)
    assert_equal(SwipeBlink.kMapName, swipeBlink:GetMapName())
    
    local kBlinkTime = 1.2
    swipeBlink:SetBlinkDuration(kBlinkTime)
    assert_false(GetGamerules():CanEntityDoDamageTo(nil, fade))
    
    RunUpdate(kBlinkTime - GetMinServerUpdateInterval())    
    assert_false(GetGamerules():CanEntityDoDamageTo(nil, fade))
    
    RunUpdate(GetMinServerUpdateInterval() + .01)
    assert_true(GetGamerules():CanEntityDoDamageTo(nil, fade))
    
    // Blink again
    kBlinkTime = 4
    
    swipeBlink:SetBlinkDuration(kBlinkTime)
    assert_false(GetGamerules():CanEntityDoDamageTo(nil, fade))
    
    RunUpdate(kBlinkTime - GetMinServerUpdateInterval())
    assert_false(GetGamerules():CanEntityDoDamageTo(nil, fade))
    
    RunUpdate(GetMinServerUpdateInterval() + 1)
    assert_true(GetGamerules():CanEntityDoDamageTo(nil, fade))    
    
end