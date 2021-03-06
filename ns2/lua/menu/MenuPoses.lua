// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\menu\MenuPoses.lua
//
//    Created by:   Brian Arneson (samusdroid@gmail.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/AnimatedModel.lua")

class 'MenuPoses' (AnimatedModel)

local manager = nil

local function CreateManager()
    manager = MenuPoses()
	manager:Initialize()
    return manager
end

local function UpdateManager()
	if not manager then 
		return MenuPoses()
	else
		return manager
	end
end

local kViewModel = PrecacheAsset("models/marine/rifle/rifle.model")
local kAnimationGraph = PrecacheAsset("models/marine/rifle/rifle.animation_graph")

local kMenuPoseBackground = PrecacheAsset("cinematics/customization_menu.cinematic") 
local fadeOut = false
local renderLight = nil

local modelYaw = 0
local angles = nil

function MenuPoses_SetPose(pose, modelType, destroy)
	
	local lastShownModel = Client.GetOptionString("lastShownModel", "")

	if destroy == true or lastShownModel ~= modelType then
		if model then
			model:Destroy()
			model = nil
		end
	end
	
	local modelVariant = Client.GetOptionInteger("marineVariant", -1) 
	local skulkVariant = Client.GetOptionInteger("skulkVariant", -1)
	local gorgeVariant = Client.GetOptionInteger("gorgeVariant", -1)
    local lerkVariant = Client.GetOptionInteger("lerkVariant", -1)
	local sexType = string.lower(Client.GetOptionString("sexType", "Male"))
	local exoVariant = Client.GetOptionInteger("exoVariant", -1)
	local rifleVariant = Client.GetOptionInteger("rifleVariant", -1)
	
	local modelPath
	
	if modelType == "skulk" then
		modelPath =  "models/alien/" .. modelType .. "/" .. modelType .. GetVariantModel(kSkulkVariantData, skulkVariant)
	elseif modelType == "gorge" then
		modelPath =  "models/alien/" .. modelType .. "/" .. modelType .. GetVariantModel(kGorgeVariantData, gorgeVariant)
	elseif modelType == "lerk" then
		modelPath =  "models/alien/" .. modelType .. "/" .. modelType .. GetVariantModel(kLerkVariantData, lerkVariant)
	elseif modelType == "exo" then
		modelPath =  "models/marine/exosuit/exosuit_cm.model"
	elseif modelType == "rifle" then
		modelPath = "models/marine/rifle/rifle" .. GetVariantModel(kRifleVariantData, rifleVariant)
	else
		modelPath = "models/marine/" .. sexType .. "/" .. sexType .. GetVariantModel(kMarineVariantData, modelVariant)
	end

	if model == nil and modelPath ~= nil then
		model = CreateAnimatedModel(modelPath)
		model.renderModel:InstanceMaterials()
	else
		model = CreateAnimatedModel("models/marine/" .. sexType .. "/" .. sexType .. GetVariantModel(kMarineVariantData, modelVariant))
		model:SetIsVisible(false)
	end
	
	if modelType == "rifle" then
		model:SetAnimation("idle")
		model:SetQueuedAnimation("idle")
	else
		model:SetAnimation("idle")
		model:SetQueuedAnimation(pose)
		model:SetPoseParam("body_yaw", 30)
		model:SetPoseParam("body_pitch", -8)
	end
	
	model:SetCastsShadows(true)
	model:SetIsVisible(false)
	model.renderModel:SetMaterialParameter("highlight", 0)
	
	if modelType == "exo" then 
		model.renderModel:SetMaterialParameter("textureIndex", exoVariant - 1)
	end
	if modelType == "rifle" then 
		model.renderModel:SetMaterialParameter("textureIndex", rifleVariant - 1)
	end
	
	UpdateManager():CycleModel(Shared.GetTime(), true)
	
	MainMenu_OnCustomizationHover()
	
end

function MenuPoses:Initialize()
	if not cinematic then
		cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
		cinematic:SetCinematic(kMenuPoseBackground)
		cinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
		cinematic:SetIsVisible(true)
	end
end

function MenuPoses_Initialize()
	CreateManager()
	return CreateManager()
end

function MenuPoses_Function()
	return UpdateManager()
end

function MenuPoses:Update(deltaTime)

	PROFILE("MenuPoses:Update")
	
	if not MainMenu_GetIsOpened() then
		
	elseif MainMenu_GetIsOpened() and model == nil then
		MenuPoses_SetPose("idle", Client.GetOptionString("lastShownModel", "marine"), true)
	elseif MainMenu_GetIsOpened() and MainMenu_IsInGame() then
		local player = Client.GetLocalPlayer()
		player:SetViewAngles(Angles(0, 0, player:GetViewAngles().roll))
		coords = player:GetViewAngles():GetCoords()

		player:SetCameraYOffset(10000)
		
		angles = Angles(player:GetViewAngles())
		angles.pitch = 0
		angles.roll = 0
		
		if Client.GetOptionString("currentModel", "marine") == "RifleVariantName" then
			self:SetCoordsOffset("rifle")
		else
			self:SetCoordsOffset(Client.GetOptionString("lastShownModel", "marine"))
		end

		self:CycleModel()
		model:Update(deltaTime)
		model.renderModel:SetMaterialParameter("patchIndex", Client.GetOptionInteger("shoulderPad", 1) -2)
		model:SetIsVisible(true)
	end
end

function MenuPoses:SetCoordsOffset(name)
local armorOffsetY = -1
local armorOffsetZ = 3.75

local decalOffsetY = -1.5
local decalOffsetZ = 1.5

local alienOffsetY = -0.75
local alienOffsetZ = 4.15

local rifleOffsetY = -0.075
local rifleOffsetZ = 1.4

	if coords then
		if name == "decal" then
			angles.yaw = (modelYaw + 0.5)*math.pi
			coords = angles:GetCoords()
			coords.origin = coords.origin + Vector(0, decalOffsetY, decalOffsetZ)
		elseif name == "marine" then
			angles.yaw = (modelYaw + 1)*math.pi
			coords = angles:GetCoords()
			coords.origin = coords.origin + Vector(0, armorOffsetY, armorOffsetZ)
		elseif name == "rifle" then
			angles.yaw = (modelYaw + 0.75)*math.pi
			angles.pitch = -0.5*math.pi
			coords = angles:GetCoords()
			coords.origin = coords.origin + Vector(0, rifleOffsetY, rifleOffsetZ)
		elseif name == "exo" then
			angles.yaw = (modelYaw + 1)*math.pi
			coords = angles:GetCoords()
			coords.origin = coords.origin + Vector(0, armorOffsetY, armorOffsetZ)
			coords.xAxis = coords.xAxis * 0.7
			coords.yAxis = coords.yAxis * 0.7
			coords.zAxis = coords.zAxis * 0.7
		else //Aliens
			angles.yaw = (modelYaw + 1)*math.pi
			coords = angles:GetCoords()
			coords.xAxis = coords.xAxis * 0.9
			coords.yAxis = coords.yAxis * 0.9
			coords.zAxis = coords.zAxis * 0.9
			coords.origin = coords.origin + Vector(0, armorOffsetY, armorOffsetZ)
		end
		model:SetCoords(coords)
	end
	
end

function MenuPoses:CycleModel(time, newLoop)
		
	if time and not animStartTime then
		animStartTime = time
	end
	if newLoop then
		if time then
			animStartTime = time
		end
		fadeOut = false
	end

	if animStartTime then
		if fadeOut == false then
			local animTime = Clamp(Shared.GetTime() - animStartTime, 0, 0.25)
			local animFraction = Easing.outCubic(animTime, 0.0, 1.0, 0.25)
			model.renderModel:SetMaterialParameter("hiddenAmount", 1*Clamp(animFraction, 0, 1))
			if animFraction == 1 then
				fadeOut = true
				animStartTime = Shared.GetTime()
			end
		elseif fadeOut == true then
			local animTime = Clamp(Shared.GetTime() - animStartTime, 0, 0.25)
			local animFraction = Easing.inCubic(animTime, 0.0, 1.0, 0.25)
			model.renderModel:SetMaterialParameter("hiddenAmount", 1-Clamp(animFraction, 0, 1))
			if animFraction == 2 then
				fadeOut = false
				animStartTime = Shared.GetTime()
			end
		end

	end
end

function MenuPoses:Destroy()

	if model then
		model:Destroy()
		model = nil
	end
	
	if cinematic then
		Client.DestroyCinematic(cinematic)
		cinematic = nil
	end
	
	if renderLight then
		Client.DestroyRenderLight(renderLight)
		renderLight = nil
	end
	
	if renderLightAmbient then
		Client.DestroyRenderLight(renderLightAmbient)
		renderLightAmbient = nil
	end
	if renderReflectionProbe then
		Client.DestroyRenderReflectionProbe(renderReflectionProbe)
		renderReflectionProbe = nil
	end
	
	if self.ammoDisplay then
		Client.DestroyGUIView(self.ammoDisplay)
		self.ammoDisplay = nil
	end
	
end

function MenuPoses_SetViewModel(value)
	local player = Client.GetLocalPlayer()
	if player then
		local viewModel = player:GetViewModelEntity()
		local weapon = player:GetWeapon(Rifle.kMapName)
		Client.SetZoneFov( RenderScene.Zone_ViewModel, GetScreenAdjustedFov(math.rad(65), 1900/1200) )
		if viewModel then
			if value == true then
				viewModel:SetIsVisible(true)
			else
				viewModel:SetIsVisible(false)
			end
		end
	end
end

function MenuPoses_Update(deltaTime)
	UpdateManager():Update(deltaTime)
end

function MenuPoses_Destroy()
	UpdateManager():Destroy()
end

function MenuPoses_SetModelAngle(yaw)
	modelYaw = (yaw-0.5)*2 or 0
end

function MenuPoses_GetCameraOffset()
	local player = Client.GetLocalPlayer()
	if player then
		originalCameraOffset = player:GetCameraYOffset()
		if player:isa("Alien") then 
			player:SetDarkVision(false)
		end
	end
end

function MenuPoses_RestoreCameraOffset()
	local player = Client.GetLocalPlayer()
	if player then
		originalCameraOffset = player:SetCameraYOffset(originalCameraOffset or 0)
	end
end

function MenuPoses_OnMenuOpened()
	MenuPoses_SetViewModel(false)
	MenuPoses_GetCameraOffset()
	ClientUI.EvaluateUIVisibility(Client.GetLocalPlayer())
end

function MenuPoses_OnMenuClosed()
	MenuPoses_SetViewModel(true)
	MenuPoses_RestoreCameraOffset()
	MenuPoses_Destroy()
	ClientUI.EvaluateUIVisibility(Client.GetLocalPlayer())
end