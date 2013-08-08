// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ReadyRoomUnitTests.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("CommonMocks.lua")
Script.Load("MockMagic.lua")
Script.Load("MockLiveEntity.lua")
Script.Load("MockPlayerEntity.lua")
Script.Load("TestInclude.lua")
Script.Load("lua/MixinUtility.lua")
Script.Load("lua/ReadyRoomTeam.lua")

module( "ReadyRoomUnitTests", package.seeall, lunit.testcase )

function setup()

    MockMagic.CreateGlobalMock("MarineCommander").kMapName = "marine_commander_player"
    MockMagic.CreateGlobalMock("AlienCommander").kMapName = "alien_commander_player"
    MockMagic.CreateGlobalMock("ReadyRoomPlayer").kMapName = "ready_room_player"
    MockMagic.CreateGlobalMock("JetpackMarine").kMapName = "jetpackmarine"
    MockMagic.CreateGlobalMock("Spectator").kMapName = "spectator_player"
    MockMagic.CreateGlobalMock("AlienSpectator").kMapName = "alien_spectator_player"
    MockMagic.CreateGlobalMock("MarineSpectator").kMapName = "marine_spectator_player"
    MockMagic.CreateGlobalMock("Marine").kMapName = "marine_player"
    MockMagic.CreateGlobalMock("Embryo").kMapName = "embryo_player"
    MockMagic.CreateGlobalMock("Skulk").kMapName = "skulk_player"

    team = ReadyRoomTeam()
    team:Initialize("World", kTeamReadyRoom)    
    player = CreateMockPlayerEntity()
    player:AddFunction("GetPreviousMapName"):SetReturnValues({Skulk.kMapName})
    
end

function TestReadyRoomDefaultSpawnName()

    player.kMapName = MarineCommander.kMapName
    player:AddFunction("GetPreviousMapName"):SetReturnValues({Marine.kMapName})    
    assert_equal(Marine.kMapName, team:GetRespawnMapName(player))
    
    player.kMapName = AlienCommander.kMapName
    player:AddFunction("GetPreviousMapName"):SetReturnValues({Skulk.kMapName})    
    assert_equal(Skulk.kMapName, team:GetRespawnMapName(player))

    player.kMapName = Marine.kMapName
    assert_equal(Marine.kMapName, team:GetRespawnMapName(player))

    // Allow embryos to move around
    player.kMapName = Embryo.kMapName
    assert_equal(ReadyRoomPlayer.kMapName, team:GetRespawnMapName(player))

end

function TestOriginalMapNames()

    player.kMapName = Skulk.kMapName
    assert_equal(Skulk.kMapName, team:GetRespawnMapName(player))

end

function TestReadyRoomSpawnNameAfterDeath()

    player.kMapName = MarineCommander.kMapName
    player:AddFunction("GetPreviousMapName"):SetReturnValues({Marine.kMapName})    
    assert_equal(Marine.kMapName, team:GetRespawnMapName(player))
    
    player.kMapName = Spectator.kMapName
    player:AddFunction("GetPreviousMapName"):SetReturnValues({Skulk.kMapName})    
    assert_equal(Skulk.kMapName, team:GetRespawnMapName(player))

    player.kMapName = AlienSpectator.kMapName
    assert_equal(Skulk.kMapName, team:GetRespawnMapName(player))
    
    // Set as 
    
end