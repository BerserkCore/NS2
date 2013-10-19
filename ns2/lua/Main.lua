//=============================================================================
//
// lua/Main.lua
// 
// Created by Max McGuire (max@unknownworlds.com)
// Copyright 2012, Unknown Worlds Entertainment
//
// This file is loaded when the game first starts up and displays the main menu.
//
//=============================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/Render.lua")
Script.Load("lua/GUIManager.lua")
Script.Load("lua/NS2Utility.lua")
Script.Load("lua/MainMenu.lua")

local renderCamera = nil
    
MenuManager.SetMenuCinematic("cinematics/main_menu.cinematic")

// Precache the common surface shaders.
Shared.PrecacheSurfaceShader("shaders/Model.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Emissive.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Model_emissive.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Model_alpha.surface_shader")
Shared.PrecacheSurfaceShader("shaders/ViewModel.surface_shader")
Shared.PrecacheSurfaceShader("shaders/ViewModel_emissive.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Decal.surface_shader")
Shared.PrecacheSurfaceShader("shaders/Decal_emissive.surface_shader")

local function InitializeRenderCamera()
    renderCamera = Client.CreateRenderCamera()
    renderCamera:SetRenderSetup("renderer/Deferred.render_setup") 
end

local function OnUpdateRender()

    local cullingMode = RenderCamera.CullingMode_Occlusion
    local camera = MenuManager.GetCinematicCamera()
    
    if camera ~= false then
    
        renderCamera:SetCoords(camera:GetCoords())
        renderCamera:SetFov(camera:GetFov())
        renderCamera:SetNearPlane(0.01)
        renderCamera:SetFarPlane(10000.0)
        renderCamera:SetCullingMode(cullingMode)
        Client.SetRenderCamera(renderCamera)
        
    else
        Client.SetRenderCamera(nil)
    end
    
end

local function OnLoadComplete(message)
    
    Render_SyncRenderOptions()
    OptionsDialogUI_SyncSoundVolumes()
    
    MenuMenu_PlayMusic("sound/NS2.fev/Main Menu")
    MainMenu_Open()
    
    if message then
        MainMenu_SetAlertMessage(message)
    end
        
end

Event.Hook("UpdateRender", OnUpdateRender)
Event.Hook("LoadComplete", OnLoadComplete)

// Run bot-related unit tests. These are quick and silent.
Script.Load("lua/bots/UnitTests.lua")

// Initialize the camera at load time, so that the render setup will be
// properly precached during the loading screen.
InitializeRenderCamera()
