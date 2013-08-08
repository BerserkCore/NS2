// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// TestInclude.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// Shared include for each test case so it can be loaded individually.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

require "lunit"
// Not fully working just yet.
//package.path = package.path .. ";.\\luacov-0.2\\src\\?.lua"
//require "luacov"

// Utility/shared includes
Script.Load("lua/Globals.lua")
Script.Load("UtilityTest.lua")