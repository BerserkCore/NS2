// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenu_Gather.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworld.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local gSelectedGatherId = -1
local gWasInGather = false

function GUIMainMenu:ProcessJoinGather(gatherId)

    gSelectedGatherId = gatherId
    
    local gatherInfo = Sabot.GetGatherInfo(gatherId)
    if gatherInfo then
    
        if gatherInfo.requiresPassword then
            self.gatherPasswordPromptWindow:SetIsVisible(true)
        else
            Sabot.JoinGather(gatherId)
            gWasInGather = false
        end
    
    end
    
end

local function UpdateGatherRoomContentSize(self)

    local contentSize = self.gatherRoom:GetParent().contentStencil:GetSize()
    self.gatherRoom:SetBackgroundSize(contentSize)

    self.gatherChat:SetTopOffset(contentSize.y - 40 - self.gatherChat:GetBackground():GetSize().y)
    self.gatherPlayersBackground:SetHeight(contentSize.y - 80)
    
    local imageAspect = 4/3
    local imageHeight = contentSize.y - 80 - self.gatherChat:GetBackground():GetSize().y - 100
    
    local imageSize = Vector(imageHeight * imageAspect,  imageHeight, 0)
    self.mapPicture:SetBackgroundSize(imageSize)

end

local function ShowGatherListPage(self)

    // hide all at first
    self:SetGatherMenuInvisible()
    
    // show items needed for this page
    self.gatherList:SetIsVisible(true)
    self.gatherWindow:SetSlideBarVisible(true)
    self.refreshGathersButton:SetIsVisible(true)
    
end

local function ShowCreateGatherPage(self)

    // hide all at first
    self:SetGatherMenuInvisible()

    // show items needed for this page
    self.createGather:SetIsVisible(true)
    self.hostGatherButton:SetIsVisible(true)
    UpdateGatherRoomContentSize(self)
    
end

local function ShowCurrentGatherPage(self)

    // hide all at first
    self:SetGatherMenuInvisible()

    self.gatherRoom:SetIsVisible(true)
    self.leaveGatherButton:SetIsVisible(true)
    self.gatherWindow:SetSlideBarVisible(false)
    
end

local function GetMaps()

    local mapNames = { }

    local shippedMaps = MainMenu_GetMapNameList()
    table.copy(shippedMaps, mapNames)
    
    return mapNames, modIds

end

local function CreateGatherPasswordPrompt(self)

    self.gatherPasswordPromptWindow = self:CreateWindow()
    local passwordPromptWindow = self.gatherPasswordPromptWindow
    passwordPromptWindow:SetWindowName("ENTER PASSWORD")
    passwordPromptWindow:SetInitialVisible(false)
    passwordPromptWindow:SetIsVisible(false)
    passwordPromptWindow:DisableResizeTile()
    passwordPromptWindow:DisableSlideBar()
    passwordPromptWindow:DisableContentBox()
    passwordPromptWindow:SetCSSClass("passwordprompt_window")
    passwordPromptWindow:DisableCloseButton()
        
    self.gatherPasswordForm = CreateMenuElement(passwordPromptWindow, "Form", false)
    self.gatherPasswordForm:SetCSSClass("passwordprompt")
    
    local textinput = self.gatherPasswordForm:CreateFormElement(Form.kElementType.TextInput, "PASSWORD", "")
    textinput:SetCSSClass("serverpassword")    
    textinput:AddEventCallbacks({
        OnEscape = function(self)
            passwordPromptWindow:SetIsVisible(false) 
        end
    })
    
    local descriptionText = CreateMenuElement(passwordPromptWindow.titleBar, "Font", false)
    descriptionText:SetCSSClass("passwordprompt_title")
    descriptionText:SetText("ENTER PASSWORD")
    
    local joinServer = CreateMenuElement(passwordPromptWindow, "MenuButton")
    joinServer:SetCSSClass("bottomcenter")
    joinServer:SetText("JOIN")
    
    joinServer:AddEventCallbacks({ OnClick =
    function (self)
    
        local formData = self.scriptHandle.gatherPasswordForm:GetFormData()
        Sabot.JoinGather(gSelectedGatherId, formData.PASSWORD)
        self.scriptHandle.gatherPasswordPromptWindow:SetIsVisible(false)
        gWasInGather = false
        
    end })

    passwordPromptWindow:AddEventCallbacks({ 
    
        OnBlur = function(self) 
            self:SetIsVisible(false) 
        end,
        
        OnEnter = function(self)
        
        local formData = self.scriptHandle.gatherPasswordForm:GetFormData()
        Sabot.JoinGather(gSelectedGatherId, formData.PASSWORD)
        self:SetIsVisible(false) 
        gWasInGather = false
        
        end,

        OnShow = function(self)
            GetWindowManager():HandleFocusBlur(self, textinput)
        end,

    })

end

local function CreateGatherListPage(self)

    self.gatherList = CreateMenuElement(self.gatherWindow:GetContentBox(), "GatherList")
    self.gatherList:AddEventCallbacks({
    
        OnShow = function (self)        
            Sabot.RefreshGatherList() 
        end
    
        })
    
    self.refreshGathersButton = CreateMenuElement(self.gatherWindow, "MenuButton")
    self.refreshGathersButton:SetCSSClass("apply")
    self.refreshGathersButton:SetText("REFRESH")
    
    self.refreshGathersButton:AddEventCallbacks({
             OnClick = function (self) 
             
                Sabot.RefreshGatherList() 
                self.scriptHandle.gatherList:ClearChildren()                
                
             end
        })
        
    CreateGatherPasswordPrompt(self)
    
end

local function CreateCurrentGatherPage(self)
    
    self.gatherRoom = CreateMenuElement(self.gatherWindow:GetContentBox(), "Image")
    self.gatherRoom:SetCSSClass("play_now_content")
    self.gatherRoom:AddEventCallbacks({ OnHide = function(self)
            UpdateGatherRoomContentSize(self.scriptHandle)
            end })
    
    self.leaveGatherButton = CreateMenuElement(self.gatherWindow, "MenuButton")
    self.leaveGatherButton:SetCSSClass("apply")
    self.leaveGatherButton:SetText("LEAVE")

    self.leaveGatherButton:AddEventCallbacks({
             OnClick = function (self) 
             
                Sabot.QuitGather()
                self.scriptHandle.gatherMenuTabs[1]:OnClick()
 
            end
        })
        
    self.mapPicture = CreateMenuElement(self.gatherRoom, "Image")
    self.mapPicture:SetCSSClass("gather_mappicture")
    
    self.gatherPlayersBackground = CreateMenuElement(self.gatherRoom, "Image")
    self.gatherPlayersBackground:SetCSSClass("gatherplayersbg")
    
    self.gatherPlayers = {}
    
    self.gatherChat = CreateMenuElement(self.gatherRoom, "GatherChat")
    self.gatherChat:SetCSSClass("gatherchat")
         
end

local function SaveGatherSettings(formData)

    Client.SetOptionString("gatherRoomName", formData.name)
    Client.SetOptionString("gatherNapName", formData.map)

    Client.SetOptionInteger("gatherPlayerLimit", formData.playerSlots)
    Client.SetOptionInteger("spectatorLimit", formData.spectatorSlots)
    
    Client.SetOptionBoolean("gatherAllowPubServers", formData.publicServer)
    
    Client.SetOptionString("lastUsedGatherAddress", formData.serverIp)
    Client.SetOptionString("lastUsedGatherServerPort", formData.serverPort)
    Client.SetOptionString("lastUsedGatherServerPassword", formData.serverPassword)
    
end

local function CreateHostGatherPage(self)
    
    self.createGather = CreateMenuElement(self.gatherWindow:GetContentBox(), "Image")
    self.createGather:SetCSSClass("play_now_content")
    self.createGather:AddEventCallbacks({ OnHide = function()
            SaveGatherSettings(self.createGatherForm:GetFormData())
            end })

    local playerLimitOptions    = { 12, 14, 16, 18, 20 }
    local spectatorLimitOptions    = { 0, 1, 2, 3, 4 }

    local gameModes = CreateServerUI_GetGameModes()

    local hostOptions = 
        {
            {   
                name   = "name",            
                label  = "NAME",
                value  = Client.GetOptionString("gatherRoomName", OptionsDialogUI_GetNickname() .. "'s Gather")
            },
            {   
                name   = "password",            
                label  = "PASSWORD [OPTIONAL]",
                value  = ""
            },
            {
                name    = "map",
                label   = "MAP",
                type    = "select",
                value  = Client.GetOptionString("gatherNapName", "Summit")
            }, 
            {
                name    = "playerSlots",
                label   = "PLAYER LIMIT",
                type    = "select",
                values  = playerLimitOptions,
                value   = Client.GetOptionInteger("gatherPlayerLimit", 12)
            },                      
            {
                name    = "spectatorSlots",
                label   = "SPECTATOR LIMIT",
                type    = "select",
                values  = spectatorLimitOptions,
                value   = Client.GetOptionInteger("spectatorLimit", 0)
            },
            {
                name    = "publicServer",
                label   = "USE PUBLIC SERVERS",
                type    = "checkbox",
                value   = Client.GetOptionBoolean("gatherAllowPubServers", false)
            }, 
            {   
                name   = "serverIp",            
                label  = "SERVER ADDRESS [OPTIONAL]",
                value  = Client.GetOptionString("lastUsedGatherAddress", "")
            },
            {   
                name   = "serverPort",            
                label  = "SERVER PORT [OPTIONAL]",
                value  = Client.GetOptionString("lastUsedGatherServerPort", "")
            },
            {   
                name   = "serverPassword",            
                label  = "SERVER PASSWORD [OPTIONAL]",
                value  = Client.GetOptionString("lastUsedGatherServerPassword", "")
            },
        }
        
    local createdElements = {}
    
    local content = self.createGather
    local createGatherForm = GUIMainMenu.CreateOptionsForm(self, content, hostOptions, createdElements)
    
    self.createGatherForm = createGatherForm
    self.createGatherForm:SetCSSClass("createserver")
    
    local mapList = createdElements.map
    
    self.hostGatherButton = CreateMenuElement(self.gatherWindow, "MenuButton")
    self.hostGatherButton:SetCSSClass("apply")
    self.hostGatherButton:SetText("CREATE")
    
    self.hostGatherButton:AddEventCallbacks({
    
             OnClick = function (self)
                
                local formData = self.scriptHandle.createGatherForm:GetFormData()
                Sabot.CreateGather(formData)
                
             end
             
        })

    self.createGather:AddEventCallbacks({
             OnShow = function (self)
                local mapNames
                mapNames = GetMaps()
                mapList:SetOptions( mapNames )
            end
        })
    
end

function GUIMainMenu:SetGatherMenuInvisible()

    // disable all elements and sub elements here
    self.createGather:SetIsVisible(false)
    self.hostGatherButton:SetIsVisible(false)
    self.gatherList:SetIsVisible(false)
    self.gatherRoom:SetIsVisible(false)
    self.leaveGatherButton:SetIsVisible(false)
    self.refreshGathersButton:SetIsVisible(false)
    
end

function GUIMainMenu:CreateGatherWindow()

    self.gatherWindow = self:CreateWindow()
    self:SetupWindow(self.gatherWindow, "PLAY")
    self.gatherWindow:AddCSSClass("gather_window")
    self.gatherWindow:ResetSlideBar()    // so it doesn't show up mis-drawn
    self.gatherWindow:GetContentBox():SetCSSClass("gather_content")
    
    local hideTickerCallbacks =
    {
        OnShow = function(self)
            self.scriptHandle.tweetText:SetIsVisible(false)
            
            if Sabot.GetIsInGather() then
                self.scriptHandle.gatherMenuTabs[3]:OnClick()
            else
                self.scriptHandle.gatherMenuTabs[1]:OnClick()
            end    
                
        end,
        
        OnHide = function(self)
            self.scriptHandle.tweetText:SetIsVisible(true)
        end
    }
    
    self.gatherWindow:AddEventCallbacks( hideTickerCallbacks )
    
    local back = CreateMenuElement(self.gatherWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText("BACK")
    back:AddEventCallbacks( { OnClick = function() self.gatherWindow:SetIsVisible(false) end } )
    
    local tabs = 
        {
            { label = "GATHERS", func = function(self) ShowGatherListPage(self.scriptHandle) end },
            { label = "CREATE", func = function(self) ShowCreateGatherPage(self.scriptHandle) end },
            { label = "CURRENT", func = function(self) if Sabot.GetIsInGather() then ShowCurrentGatherPage(self.scriptHandle) end end },
        }
        
    local xTabWidth = 256

    local tabBackground = CreateMenuElement(self.gatherWindow, "Image")
    tabBackground:SetCSSClass("tab_background")
    tabBackground:SetIgnoreEvents(true)
    
    local tabAnimateTime = 0.1
    
    self.gatherMenuTabs = {}
    
    for i = 1,#tabs do
    
        local tab = tabs[i]
        local tabButton = CreateMenuElement(self.gatherWindow, "MenuButton")
        
        local function ShowTab(index)        
            return function (self)

                if index ~= 3 or Sabot.GetIsInGather() then
                    local tabPosition = tabButton.background:GetPosition()
                    tabBackground:SetBackgroundPosition( tabPosition, false, tabAnimateTime ) 
                end
                
            end
        end
    
        tabButton:SetCSSClass("tab")
        tabButton:SetText(tab.label)
        tabButton:AddEventCallbacks({ OnClick = tab.func })
        tabButton:AddEventCallbacks({ OnClick = ShowTab(i) })
        
        local tabWidth = tabButton:GetWidth()
        tabButton:SetBackgroundPosition( Vector(tabWidth * (i - 1), 0, 0) )
        
        self.gatherMenuTabs[i] = tabButton
        
    end

    CreateGatherListPage(self)
    CreateHostGatherPage(self)
    CreateCurrentGatherPage(self)
    
    self:SetGatherMenuInvisible()
    ShowGatherListPage(self)
    
    self.updateList = true
    
end

local function GetMapTexture(mapName)

    local textureName = "ui/menu/sabot/ns2icon.dds"
    
    local searchResult = {}
    Shared.GetMatchingFileNames( string.format("screens/%s/1.jpg", mapName ), false, searchResult )

    if #searchResult > 0 then
        return searchResult[1]
    end

    return textureName

end

function GUIMainMenu:UpdateGatherList(deltaTime)

    if not self.gatherWindow or not self.gatherWindow:GetIsVisible() then
        return
    end    

    if Sabot.GetIsInGather() then
    
        local currentGatherId = Sabot.GetCurrentGatherId()
        local gatherInfo = Sabot.GetGatherInfo(currentGatherId)

        self.mapPicture:SetBackgroundTexture(GetMapTexture(gatherInfo.map))
        self.gatherChat:SetChatData(Sabot.GetChatMessates())
        
        local playerNames = Sabot.GetPlayerNames()
        
        local numStoredPlayers = #self.gatherPlayers
        local numCurrentPlayers = #playerNames
        
        if numStoredPlayers > numCurrentPlayers then
        
            for i = 1, numStoredPlayers - numCurrentPlayers do
            
                self.gatherPlayers[#self.gatherPlayers]:Uninitialize()
                self.gatherPlayers[#self.gatherPlayers] = nil

            end
        
        elseif numCurrentPlayers > numStoredPlayers then
        
            for i = 1, numCurrentPlayers - numStoredPlayers do
            
                local entry = CreateMenuElement(self.gatherPlayersBackground, "Font")
                entry:SetCSSClass("gatherplayername", false)
                table.insert(self.gatherPlayers, entry) 
            
            end
        
        end

        // update names and position of text elements        
        if numCurrentPlayers > 0 then
            
            local topOffset = 20
            local fontSize = self.gatherPlayers[1]:GetBackground():GetSize().y
            
            for i = 1, numCurrentPlayers do        
                self.gatherPlayers[i]:SetText(playerNames[i])        
                self.gatherPlayers[i]:SetTopOffset(20 + fontSize * (i-1))
            end
        
        end

    end

    self.gatherMenuTabs[3]:SetIsVisible(Sabot.GetIsInGather())

    if self.gatherList:GetIsVisible() and (self.updateList or self.gatherList:GetNumEntries() ~= Sabot.GetNumGathers()) then
    
        local gathers = Sabot.GetGathers()

        for index, gather in pairs(gathers) do
            
            if not self.gatherList:UpdateEntry(gather) then
                self.gatherList:AddEntry(gather)
            end
            
        end
        
        self.gatherList:RenderNow()
        self.updateList = false
    
    end
    
    if gWasInGather ~= Sabot.GetIsInGather() then
    
        if not Sabot.GetIsInGather() then
            self.gatherMenuTabs[1]:OnClick()
        else
            self.gatherMenuTabs[3]:OnClick()
        end    
        
        gWasInGather = Sabot.GetIsInGather()
    
    end

end
