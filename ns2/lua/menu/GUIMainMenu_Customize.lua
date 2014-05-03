// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenu_Customize.lua
//
//    Created by:   Brian Arneson(samusdroid@gmail.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com ====================
Script.Load("lua/menu/MenuPoses.lua")  

local menuRefresed = false
local function InitCustomizationOptions(customizeElements)
        
    local function BoolToIndex(value)
        if value then
            return 2
        end
        return 1
    end
	
    local marineVariant = Client.GetOptionInteger("marineVariant", -1)
    local skulkVariant = Client.GetOptionInteger("skulkVariant", -1)
    local gorgeVariant = Client.GetOptionInteger("gorgeVariant", -1)
    local lerkVariant = Client.GetOptionInteger("lerkVariant", -1)
	local exoVariant = Client.GetOptionInteger("exoVariant", -1)
	local shoulderPadIndex = Client.GetOptionInteger("shoulderPad", 1)
	local rifleVariant = Client.GetOptionInteger("rifleVariant", -1)
	
	if not GetHasShoulderPad(shoulderPadIndex) then
	    shoulderPadIndex = 1
	end
	
    // if not set explicitly, always use the highest available tier
    if marineVariant == -1 then
    
        for variant = 1, GetEnumCount(kMarineVariant) do
        
            if GetHasVariant(kMarineVariantData, variant) then
            
                marineVariant = variant
                // do not break - use the highest one they have
                
            end
            
        end
        
    end
    
    if skulkVariant == -1 then
    
        for variant = 1, GetEnumCount(kSkulkVariant), 1 do
        
            if GetHasVariant(kSkulkVariantData, variant) then
            
                skulkVariant = variant
                // do not break - use the highest one they have
                
            end
            
        end
        
    end
    
    if gorgeVariant == -1 then
    
        for variant = 1, GetEnumCount(kGorgeVariant), 1 do
        
            if GetHasVariant(kGorgeVariantData, variant) then
            
                gorgeVariant = variant
                // do not break - use the highest one they have
                
            end
            
        end
        
    end
    
    if lerkVariant == -1 then
    
        for variant = 1, GetEnumCount(kLerkVariant), 1 do
        
            if GetHasVariant(kLerkVariantData, variant) then
            
                lerkVariant = variant
                // do not break - use the highest one they have
                
            end
            
        end
        
    end
	
	if exoVariant == -1 then
    
        for variant = 1, GetEnumCount(kExoVariant), 1 do
        
            if GetHasVariant(kExoVariantData, variant) then
            
                exoVariant = variant
                // do not break - use the highest one they have
                
            end
            
        end
        
    end
    
	if rifleVariant == -1 then
    
        for variant = 1, GetEnumCount(kRifleVariant), 1 do
        
            if GetHasVariant(kRifleVariantData, variant) then
            
                rifleVariant = variant
                // do not break - use the highest one they have
                
            end
            
        end
        
    end
	
    assert(marineVariant ~= -1)
    assert(skulkVariant ~= -1)
    assert(gorgeVariant ~= -1)
    assert(lerkVariant ~= -1)
	assert(exoVariant ~= -1)
	assert(rifleVariant ~= -1)
    
	Client.SetOptionInteger("marineVariant", marineVariant)
	Client.SetOptionInteger("shoulderPad", shoulderPadIndex)
    Client.SetOptionInteger("skulkVariant", skulkVariant)
    Client.SetOptionInteger("gorgeVariant", gorgeVariant)
    Client.SetOptionInteger("lerkVariant", lerkVariant)
    Client.SetOptionInteger("exoVariant", exoVariant)
	Client.SetOptionInteger("rifleVariant", rifleVariant)
	
    local sexType = Client.GetOptionString("sexType", "Male")
    Client.SetOptionString("sexType", sexType)

	customizeElements.SexType:SetValue(sexType)
	customizeElements.MarineVariantName:SetValue(GetVariantName(kMarineVariantData, marineVariant))
	customizeElements.ShoulderPad:SetValue(kShoulderPadNames[shoulderPadIndex])
    customizeElements.SkulkVariantName:SetValue(GetVariantName(kSkulkVariantData, skulkVariant))
    customizeElements.GorgeVariantName:SetValue(GetVariantName(kGorgeVariantData, gorgeVariant))
    customizeElements.LerkVariantName:SetValue(GetVariantName(kLerkVariantData, lerkVariant))
	customizeElements.ExoVariantName:SetValue(GetVariantName(kExoVariantData, exoVariant))
    customizeElements.RifleVariantName:SetValue(GetVariantName(kRifleVariantData, rifleVariant))
	
end

GUIMainMenu.CreateCustomizeForm = function(mainMenu, content, options, customizeElements)

    local form = CreateMenuElement(content, "Form", true)
    
    local rowHeight = 50
    local y = 0
    for i = 1, #options do
 
        local option = options[i]
        local input
        local defaultInputClass = "customize_input"

		y = y + rowHeight
		y = y + rowHeight
		
        if option.type == "select" then
            input = form:CreateFormElement(Form.kElementType.DropDown, option.name, option.value)
            if option.values then
                input:SetOptions(option.values)
            end       
		end
        
        if option.callback then
            input:AddSetValueCallback(option.callback)
        end
        local inputClass = defaultInputClass
        if option.inputClass then
            inputClass = option.inputClass
        end
        
		for index, child in ipairs(input:GetChildren()) do
		child:AddEventCallbacks({ 
			OnMouseIn = function(self)

			local currentModel = Client.GetOptionString("currentModel", "")
			Client.SetOptionString("currentModel", input:GetFormElementName())
			
			local modelType

				if input:GetFormElementName() ~= currentModel or menuRefresed == true then
					if input:GetFormElementName() == "MarineVariantName" or input:GetFormElementName() == "SexType" then
						modelType = "marine"
					elseif input:GetFormElementName() == "ShoulderPad" then
						modelType = "decal"
					elseif input:GetFormElementName() == "SkulkVariantName" then
						modelType = "skulk"
					elseif input:GetFormElementName() == "GorgeVariantName" then
						modelType = "gorge"
					elseif input:GetFormElementName() == "LerkVariantName" then
						modelType = "lerk"
					elseif input:GetFormElementName() == "ExoVariantName" then
						modelType = "exo"
					elseif input:GetFormElementName() == "RifleVariantName" then
						modelType = "rifle"
					else
						modelType = ""
					end
						
					if Client.GetOptionString("lastShownModel", "") ~= modelType then
						MenuPoses_SetPose("idle", modelType, true)
						MenuPoses_Function():SetCoordsOffset(modelType)
					end

					Client.SetOptionString("lastShownModel", modelType)
					Client.SetOptionString("lastModel", input:GetFormElementName())
					menuRefresed = false
				end
				
			end,
			})
		end
		
        input:SetCSSClass(inputClass)
        input:SetTopOffset(y)
		input.label:SetCSSClass("customize_label_" .. option.side)
        input:SetLabel(option.label)
        customizeElements[option.name] = input
    end
    
    form:SetCSSClass("options")

    return form

end

local function OnSexChanged(formElement)
    local sexType = formElement:GetValue()
    Client.SetOptionString("sexType", firstToUpper(sexType))
	MenuPoses_SetPose("idle", "marine", true)
	MenuPoses_Function():SetCoordsOffset("marine")
	SendPlayerVariantUpdate()
end

local function OnMarineChanged(formElement)
    local marineVariantName = formElement:GetValue()
    Client.SetOptionInteger("marineVariant", FindVariant(kMarineVariantData, marineVariantName))
	MenuPoses_SetPose("idle", "marine", true)
	MenuPoses_Function():SetCoordsOffset("marine")
	SendPlayerVariantUpdate()
end

local function OnDecalChanged(formElement)
    local shoulderPadName = formElement:GetValue()
	Client.SetOptionInteger("shoulderPad", GetShoulderPadIndexByName(shoulderPadName))
	MenuPoses_SetPose("idle", "decal", true)
	MenuPoses_Function():SetCoordsOffset("decal")
	SendPlayerVariantUpdate()
end

local function OnExoChanged(formElement)
    local exoVariantName = formElement:GetValue()
    Client.SetOptionInteger("exoVariant", FindVariant(kExoVariantData, exoVariantName))
	MenuPoses_SetPose("idle", "exo", true)
	MenuPoses_Function():SetCoordsOffset("exo")
	SendPlayerVariantUpdate()
end

local function OnRifleChanged(formElement)
    local rifleVariantName = formElement:GetValue()
    Client.SetOptionInteger("rifleVariant", FindVariant(kRifleVariantData, rifleVariantName))
	Client.SetOptionString("lastShownModel", "rifle")
	MenuPoses_SetPose("idle", "rifle", true)
	MenuPoses_Function():SetCoordsOffset("rifle")
	SendPlayerVariantUpdate()
end

local function OnSkulkChanged(formElement)
    local skulkVariantName = formElement:GetValue()
    Client.SetOptionInteger("skulkVariant", FindVariant(kSkulkVariantData, skulkVariantName))
	MenuPoses_SetPose("idle", "skulk", true)
	SendPlayerVariantUpdate()
end

local function OnGorgeChanged(formElement)
    local gorgeVariantName = formElement:GetValue()
    Client.SetOptionInteger("gorgeVariant", FindVariant(kGorgeVariantData, gorgeVariantName))
	MenuPoses_SetPose("idle", "gorge", true)
	SendPlayerVariantUpdate()
end

local function OnLerkChanged(formElement)
    local lerkVariantName = formElement:GetValue()
    Client.SetOptionInteger("lerkVariant", FindVariant(kLerkVariantData, lerkVariantName))
	MenuPoses_SetPose("idle", "lerk", true)
	SendPlayerVariantUpdate()
end

function GUIMainMenu:CreateCustomizeWindow()

    self.customizeFrame = self:CreateWindow()
    self:SetupWindow(self.customizeFrame, "CUSTOMIZE PLAYER")
    self.customizeFrame:AddCSSClass("customize_window")
    self.customizeFrame:ResetSlideBar()    // so it doesn't show up mis-drawn
	self.customizeFrame:DisableSlideBar()
    self.customizeFrame:GetContentBox():SetCSSClass("customize_content")
	self.customizeLeft = CreateMenuElement(self.mainWindow, "ContentBox", true)
	self.customizeLeft:SetCSSClass("customize_left")
	self.customizeRight = CreateMenuElement(self.mainWindow, "ContentBox", true)
	self.customizeRight:SetCSSClass("customize_right")

	self.sliderAngleBar = CreateMenuElement(self.mainWindow, "SlideBar", false)
	self.sliderAngleBar:SetCSSClass("customize_slider")
    self.sliderAngleBar:SetBackgroundSize(Vector(750, 32, 0), true)
    self.sliderAngleBar:ScrollMax()
	self.sliderAngleBar:Register( self.customizeFrame:GetContentBox(), SLIDE_HORIZONTAL)
	
	self.sliderAngleBarLabel = CreateMenuElement(self.mainWindow, "Font", false)
	self.sliderAngleBarLabel:SetCSSClass("customize_slider_label")
	self.sliderAngleBarLabel:SetText("Drag to rotate")
	
	self.marineLogo = CreateMenuElement(self.customizeLeft, "Image", true)
	self.marineLogo:SetCSSClass("customize_logo_marine")
	
	self.alienLogo = CreateMenuElement(self.customizeRight, "Image", true)
	self.alienLogo:SetCSSClass("customize_logo_alien")
	
	/*self.badgesButton = CreateMenuElement(self.mainWindow, "MenuButton", true)
	self.badgesButton:SetCSSClass("customize_badges")
	self.badgesButton:SetText("Customize Badges")
	self.badgesButton:AddEventCallbacks( { OnClick = function() Client.ShowWebpage("http://hive.naturalselection2.com/manage-badges") end } )
	*/
	
    local function InitCustomizationWindow()
        InitCustomizationOptions(self.customizeElements)
    end
	
    MenuPoses_Initialize()
	
    local back = CreateMenuElement(self.mainWindow, "MenuButton")
    back:SetCSSClass("customize_back")
    back:SetText("BACK")
    back:AddEventCallbacks( { OnClick = function() self.customizeFrame:SetIsVisible(false) end } )
	
	local hideTickerCallbacks =
    {
        OnShow = function(self)
            self.scriptHandle.tweetText:SetIsVisible(false)
			MenuPoses_OnMenuOpened()
			if self.scriptHandle.sliderAngleBar then
				self.scriptHandle.sliderAngleBar:SetValue(0)
			end
			menuRefresed = true
        end,
        
        OnHide = function(self)
            self.scriptHandle.tweetText:SetIsVisible(true)
			self.scriptHandle.customizeLeft:SetIsVisible(false)
			self.scriptHandle.customizeRight:SetIsVisible(false)
			self.scriptHandle.sliderAngleBar:SetIsVisible(false)
			self.scriptHandle.sliderAngleBarLabel:SetIsVisible(false)
			//self.scriptHandle.badgesButton:SetIsVisible(false)
			back:SetIsVisible(false)
			MenuPoses_OnMenuClosed()
        end
    }
    
    self.customizeFrame:AddEventCallbacks( hideTickerCallbacks )

    local contentLeft = self.customizeLeft
	local contentRight = self.customizeRight

    local shoulderPadNames = {}
    local marineVariantNames = { }
    local skulkVariantNames = { }
    local gorgeVariantNames = { }
    local lerkVariantNames = { }
	local exoVariantNames = { }
	local rifleVariantNames = { }

    for index, name in pairs(kShoulderPadNames) do
        if GetHasShoulderPad(index) then
            table.insert(shoulderPadNames, name)
        end
    end
	
    for key, value in pairs(kMarineVariantData) do
        if GetHasVariant(kMarineVariantData, key) then
            table.insert(marineVariantNames, value.displayName)
        end
    end
    
    for key, value in pairs(kSkulkVariantData) do
        if GetHasVariant(kSkulkVariantData, key) then
            table.insert(skulkVariantNames, value.displayName)
        end
    end
    
    for key, value in pairs(kGorgeVariantData) do
        if GetHasVariant(kGorgeVariantData, key) then
            table.insert(gorgeVariantNames, value.displayName)
        end
    end
    
    for key, value in pairs(kLerkVariantData) do
        if GetHasVariant(kLerkVariantData, key) then
            table.insert(lerkVariantNames, value.displayName)
        end
    end
	
	for key, value in pairs(kExoVariantData) do
        if GetHasVariant(kExoVariantData, key) then
            table.insert(exoVariantNames, value.displayName)
        end
    end
	
	for key, value in pairs(kRifleVariantData) do
        if GetHasVariant(kRifleVariantData, key) then
            table.insert(rifleVariantNames, value.displayName)
        end
    end
    
    local sexTypes = { "Male", "Female" }
	local sexType = Client.GetOptionString("sexType", "Male")
    Client.SetOptionString("sexType", sexType)
	
    local leftOptions =
        {
			{
                name    = "SexType",
                label   = "MARINE GENDER",
                type    = "select",
				side 	= "left",
                values  = sexTypes,
				callback = OnSexChanged
            },
			{
                name    = "MarineVariantName",
                label   = "MARINE ARMOR",
                type    = "select",
				side 	= "left",
                values  = marineVariantNames,
				callback = OnMarineChanged
            },
            {
                name    = "ShoulderPad",
                label   = "SHOULDER PAD",
                type    = "select",
				side 	= "left",
                values  = shoulderPadNames,
				callback = OnDecalChanged
            },
			{
                name    = "ExoVariantName",
                label   = "EXO ARMOR",
                type    = "select",
				side 	= "left",
                values  = exoVariantNames,
				callback = OnExoChanged
            },
			{
                name    = "RifleVariantName",
                label   = "Rifle Skin",
                type    = "select",
				side 	= "left",
                values  = rifleVariantNames,
				callback = OnRifleChanged
            },
		}
		
    local rightOptions =
        {
            {
                name    = "SkulkVariantName",
                label   = "SKULK TYPE",
                type    = "select",
				side 	= "right",
                values  = skulkVariantNames,
				callback = OnSkulkChanged
            },
            {
                name    = "GorgeVariantName",
                label   = "GORGE TYPE",
                type    = "select",
				side 	= "right",
                values  = gorgeVariantNames,
				callback = OnGorgeChanged
            },
            {
                name    = "LerkVariantName",
                label   = "LERK TYPE",
                type    = "select",
				side 	= "right",
                values  = lerkVariantNames,
				callback = OnLerkChanged
            },
		}
	
    // save our option elements for future reference
    self.customizeElements = { }
    
    local customizeFormLeft      = GUIMainMenu.CreateCustomizeForm(self, contentLeft, leftOptions, self.customizeElements)      
	local customizeFormRight     = GUIMainMenu.CreateCustomizeForm(self, contentRight, rightOptions, self.customizeElements)       	

	InitCustomizationWindow()
	
end