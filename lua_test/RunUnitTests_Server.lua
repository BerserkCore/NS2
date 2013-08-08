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

// Include new script test files here (runs on dev_test.level)
Script.Load("GeneralTest.lua")
Script.Load("VectorTest.lua")
Script.Load("BitwiseTest.lua")
Script.Load("APITest.lua")
Script.Load("ActorTest.lua")
Script.Load("ScriptActorTest.lua")
Script.Load("SpawnTest.lua")
Script.Load("CommandStructureTest.lua")
Script.Load("PlayerTest.lua")
Script.Load("TeamTest.lua")
Script.Load("ResourceTest.lua")
Script.Load("StructureTest.lua")
Script.Load("DamageTest.lua")
Script.Load("CommanderTest.lua")
Script.Load("GamerulesTest.lua")
Script.Load("GamerulesExtendedTest.lua")
Script.Load("MarineTest.lua")
Script.Load("SkulkTest.lua")
Script.Load("GorgeTest.lua")
Script.Load("LerkTest.lua")
Script.Load("FadeTest.lua")
Script.Load("OnosTest.lua")
Script.Load("DrifterTest.lua")
Script.Load("MACTest.lua")
Script.Load("HiveTest.lua")
Script.Load("ViewModelTest.lua")
Script.Load("ModelTest.lua")
Script.Load("TechDataTest.lua")
Script.Load("TeamJoinTest.lua")
Script.Load("TraceTest.lua")
//Script.Load("SpectatorTest.lua")
Script.Load("ResourceTowerTest.lua")
Script.Load("ShotgunTest.lua")
Script.Load("DoorTest.lua")
Script.Load("CragTest.lua")
//Script.Load("WhipTest.lua")
//Script.Load("ShadeTest.lua")
Script.Load("SentryTest.lua")
// Very slow so run manually
//Script.Load("MapTest.lua")

Script.Load("RunLunit.lua")