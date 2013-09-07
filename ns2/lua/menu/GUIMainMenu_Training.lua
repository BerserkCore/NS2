// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenu_Tutorial.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local function GetPageSize()
    return Vector(Client.GetScreenWidth() * 0.9, Client.GetScreenHeight() * 0.9, 0)
end

Script.Load("lua/GUITipVideo.lua")
Script.Load("lua/GUITipVideo_SpawnVideos.lua")
local gVideos = gSpawnTipVideos

local kOrderedVideoCategories = 
{
    "General",
    "Marine Basics",
    "Marine Advanced",
    "Marine Weapons",
    "Marine Items",
    "Alien Basics",
    "Alien Advanced",
    "Skulk & Lerk",
    "Gorge",
    "Fade & Onos",
    "Evolution Traits",
}

local function FindIn( list, query )

    for i,item in ipairs(list) do
        if item == query then
            return i
        end
    end

    return -1

end

// for a given category
function GUIMainMenu:ShowVideoLinksForCategory(cat)

    self:ClearVideoLinks()

    // find all videos for this cat

    local vids = {}
    for _,video in ipairs(gVideos) do

        if video.category == cat then
            table.insert( vids, video )
        end

    end

    // first link is BACK

    self.videoLinks[1]:SetText("[BACK]")
    self.videoLinks[1].OnClick = function()
        self:ShowVideoCategoryLinks()
    end

    // setup links

    for i,vid in ipairs(vids) do

        if i+1 > #self.videoLinks then
            Print("Too many vids in category "..cat)
            break
        end

        local link = self.videoLinks[i+1]
        link:SetText(vid.title)
        link.OnClick = function()
            GUITipVideo.singleton:TriggerVideo(vid, 8, kGUILayerTrainingMenuTipVideos)
        end

    end

end

function GUIMainMenu:ShowVideoCategoryLinks()

    self:ClearVideoLinks()

    for i,cat in ipairs(kOrderedVideoCategories) do

        local link = self.videoLinks[i]
        link:SetText(cat)
        link.OnClick = function()
            self:ShowVideoLinksForCategory(cat)
        end

    end

end

function GUIMainMenu:ClearVideoLinks()

    for i,link in ipairs(self.videoLinks) do
        link:SetText("")
        link.OnClick = nil
    end

end

local function CreateVideosPage(self)

    // Create our video player
    if GUITipVideo.singleton == nil then
        self.videoPlayer = GetGUIManager():CreateGUIScript("GUITipVideo")
    end

    self.videosPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.videosPage:SetCSSClass("play_now_content")
    self.videosPage:AddEventCallbacks({
            OnHide = function()
                GUITipVideo.singleton:Hide()
            end
            })

    self.videoLinks = {}

    // gather unique categories, make sure they are all in our ordered list

    local categorySet = {}
    for _,data in ipairs(gVideos) do

        local cat = data.category

        if not categorySet[ cat ] then
            categorySet[ cat ] = true
            if FindIn(kOrderedVideoCategories, cat) == -1 then
                Print("** ERROR: Could not find category "..cat.." in kOrderedVideoCategories" )
            end
        end

    end

    // verify other direction
    // make sure all categories in our list are accounted for
    for _,cat in ipairs(kOrderedVideoCategories) do
        if categorySet[cat] == nil then
            Print("** ERROR: Could not find category "..cat.." in the video data")
        end
    end

    // create link elements

    for linkId = 0,13 do

        local link = CreateMenuElement(self.videosPage, "Link")
        table.insert( self.videoLinks, link )

        link:SetCSSClass("vid_link_"..linkId)
        link:SetText("link "..linkId)
        link:EnableHighlighting()

    end

    self:ShowVideoCategoryLinks()
    
end

local function CreateTutorialPage(self)

    self.tutorialPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.tutorialPage:SetCSSClass("play_now_content")
    
    self.playTutorialButton = CreateMenuElement(self.trainingWindow, "MenuButton")
    self.playTutorialButton:SetCSSClass("play_tutorial")
    self.playTutorialButton:SetText("PLAY TUTORIAL")
    
    self.playTutorialButton:AddEventCallbacks({
             OnClick = function (self) self.scriptHandle:StartTutorial() end
        })

    local note = CreateMenuElement( self.tutorialPage, "Font", false )
    note:SetCSSClass("tutorial_note")
    note:SetText(
[[10-15 minute interactive tutorial for new players.
This will teach you the basics of both Marines and Aliens, highlighting what is most
unique about NS2 compared to similar games. It assumes you are familiar with FPS basics.]])
    
end

function GUIMainMenu:StartTutorial()

    local modIndex = Client.GetLocalModId("tutorial")
    
    if modIndex == -1 then
        Shared.Message("Tutorial mod does not exist!")
        return
    end

    local password      = "dummypassword"..ToString(math.random())
    local port          = 27015
    local maxPlayers    = 24    // need room for bots
    local serverName    = "private tutorial server"
    local mapName       = "ns2_docking"
    Client.SetOptionString("lastServerMapName", mapName)
    Client.SetOptionBoolean("playedTutorial", true)
    
    if Client.StartServer(modIndex, mapName, serverName, password, port, 1, true) then
        LeaveMenu()
    end
    
end

local function CreateSandboxPage(self)

    self.sandboxPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.sandboxPage:SetCSSClass("play_now_content")

    local formOptions = {
        {
            name  = "Map",
            label = "MAP",
            type  = "select",
            value = "Docking",
        },
    }
    
    local createdElements = {}
    self.sandboxPage.optionsForm = GUIMainMenu.CreateOptionsForm(self, self.sandboxPage, formOptions, createdElements)
    local mapList = createdElements.Map:SetOptions( MainMenu_GetMapNameList() );

    self.playSandboxButton = CreateMenuElement(self.trainingWindow, "MenuButton")
    self.playSandboxButton:SetCSSClass("play_sandbox")
    self.playSandboxButton:SetText("PLAY SANDBOX")
    
    self.playSandboxButton:AddEventCallbacks({
             OnClick = function (self) self.scriptHandle:CreateSandboxServer() end
        })

    local note = CreateMenuElement( self.sandboxPage, "Font", false )
    note:SetCSSClass("sandbox_note")
    note:SetText(
[[Sandbox mode allows you to freely practice and try out various parts of the game.
You can join the Marines and purchase any weapon from the Armory and Prototype Lab.
You can join the Aliens and evolve into any lifeform with any traits.]])
    
end

function GUIMainMenu:CreateSandboxServer()
    
    local password      = "dummypassword"
    local port          = 27015
    local maxPlayers    = 24
    local serverName    = "private tutorial server"
    local mapName       = "ns2_"..string.lower(self.sandboxPage.optionsForm:GetFormData().Map)
    Client.SetOptionString("lastServerMapName", mapName)
    
    if Client.StartServer(mapName, serverName, password, port, 1) then
        Client.SetOptionBoolean("sandboxMode", true)
        LeaveMenu()
    end
    
end

local function CreateBotsPage(self)

    self.botsPage = CreateMenuElement(self.trainingWindow:GetContentBox(), "Image")
    self.botsPage:SetCSSClass("play_now_content")
    
    local minPlayers            = 2
    local maxPlayers            = 32
    local playerLimitOptions    = { }
    
    for i = minPlayers, maxPlayers do
        table.insert(playerLimitOptions, i)
    end

    local hostOptions = 
    {
        {   
            name   = "ServerName",            
            label  = "SERVER NAME",
            value  = "Training vs. Bots"
        },
        {   
            name   = "Password",            
            label  = "PASSWORD [OPTIONAL]",
        },
        {
            name    = "Map",
            label   = "MAP",
            type    = "select",
            value  = "Descent",
        },
        {
            name    = "PlayerLimit",
            label   = "PLAYER LIMIT",
            type    = "select",
            values  = playerLimitOptions,
            value   = 16
        },
        {
            name    = "NumMarineBots",
            label   = "# MARINE BOTS",
            value   = "8"
        },
        {
            name = "MarineSkillLevel",
            label = "MARINE SKILL LEVEL",
            type = "select",
            values = {"Beginner", "Intermediate", "Expert"},
            value = "Intermediate"
        },
        {
            name    = "AddMarineCommander",
            label   = "MARINE COMMANDER BOT",
            value   = "false",
            type    = "checkbox"
        },
        {
            name    = "NumAlienBots",
            label   = "# ALIEN BOTS",
            value   = "8"
        },
        {
            name    = "AddAlienCommander",
            label   = "ALIEN COMMANDER BOT",
            value   = "true",
            type    = "checkbox"
        }
    }
        
    local createdElements = {}
    local content = self.botsPage
    local form = GUIMainMenu.CreateOptionsForm(self, content, hostOptions, createdElements)
    form:SetCSSClass("createserver")
    
    local mapList = createdElements.Map
    
    self.playBotsButton = CreateMenuElement(self.trainingWindow, "MenuButton")
    self.playBotsButton:SetCSSClass("apply")
    self.playBotsButton:SetText("PLAY")
    
    self.playBotsButton:AddEventCallbacks(
    {
        OnClick = function()

            local formData = form:GetFormData()

            // validate
            if tonumber(formData.NumMarineBots) == nil then
                MainMenu_SetAlertMessage("Not a valid number for # MARINE BOTS: "..formData.NumMarineBots)
            elseif tonumber(formData.NumAlienBots) == nil then
                MainMenu_SetAlertMessage("Not a valid number for # ALIEN BOTS: "..formData.NumAlienBots)
            else

                // start server!
                local password   = formData.Password
                local port       = 27015
                local maxPlayers = formData.PlayerLimit
                local serverName = formData.ServerName
                local mapName    = "ns2_" .. string.lower(formData.Map)
                Client.SetOptionString("lastServerMapName", mapName)

                Client.SetOptionBoolean("sendBotsCommands", true)
                Client.SetOptionInteger("botsSettings_numMarineBots", tonumber(formData.NumMarineBots))
                Client.SetOptionString("botsSettings_marineSkillLevel", formData.MarineSkillLevel)
                Client.SetOptionInteger("botsSettings_numAlienBots", tonumber(formData.NumAlienBots))
                Client.SetOptionBoolean("botsSettings_marineCom", formData.AddMarineCommander)
                Client.SetOptionBoolean("botsSettings_alienCom", formData.AddAlienCommander)
                
                if Client.StartServer(mapName, serverName, password, port, maxPlayers) then
                    LeaveMenu()
                end

            end
            
        end
    })

    local note = CreateMenuElement( form, "Font", false )
    note:SetCSSClass("bot_note")
    note:SetText(
[[NOTE: Bots are meant for learning the game, so they may not present a challenge to
experienced players. You can have friends join your game, but make sure your ports are
forwarded. Enjoy!]])

    self.botsPage:AddEventCallbacks(
    {
     OnShow = function (self)
            mapList:SetOptions( MainMenu_GetMapNameList() )
        end
    })
    
end

function GUIMainMenu:HideAll()

    self.videosPage:SetIsVisible(false)
    self.tutorialPage:SetIsVisible(false)
    self.botsPage:SetIsVisible(false)
    self.trainingWindow:DisableSlideBar()
    self.trainingWindow:ResetSlideBar()
    self.playTutorialButton:SetIsVisible(false)
    self.playBotsButton:SetIsVisible(false)
    self.playSandboxButton:SetIsVisible(false)
    self.sandboxPage:SetIsVisible(false)

end

function GUIMainMenu:CreateTrainingWindow()

    self.trainingWindow = self:CreateWindow()
    self.trainingWindow:DisableCloseButton()
    self:SetupWindow(self.trainingWindow, "TRAINING")
    self.trainingWindow:SetCSSClass("tutorial_window")
    
    local back = CreateMenuElement(self.trainingWindow, "MenuButton")
    back:SetCSSClass("back")
    back:SetText("BACK")
    back:AddEventCallbacks( { OnClick = function() self.trainingWindow:SetIsVisible(false) end } )
    
    local tabs = 
    {
        { label = "TUTORIAL", func = function(self)
                self.scriptHandle:HideAll()
                self.scriptHandle.tutorialPage:SetIsVisible(true)
                self.scriptHandle.playTutorialButton:SetIsVisible(true)
                end },
        { label = "TIP CLIPS", func = function(self)
                self.scriptHandle:HideAll()
                self.scriptHandle.videosPage:SetIsVisible(true) end },
        { label = "VS. BOTS", func = function(self)
                self.scriptHandle:HideAll()
                self.scriptHandle.botsPage:SetIsVisible(true)
                self.scriptHandle.playBotsButton:SetIsVisible(true)
                end },
        { label = "SANDBOX", func = function(self)
                self.scriptHandle:HideAll()
                self.scriptHandle.sandboxPage:SetIsVisible(true)
                self.scriptHandle.playSandboxButton:SetIsVisible(true)
                end },
    }
        
    local xTabWidth = 256

    local tabBackground = CreateMenuElement(self.trainingWindow, "Image")
    tabBackground:SetCSSClass("tab_background")
    tabBackground:SetIgnoreEvents(true)
    
    local tabAnimateTime = 0.1
        
    for i = 1,#tabs do
    
        local tab = tabs[i]
        local tabButton = CreateMenuElement(self.trainingWindow, "MenuButton")
        
        local function ShowTab()
            for j =1,#tabs do
                local tabPosition = tabButton.background:GetPosition()
                tabBackground:SetBackgroundPosition( tabPosition, false, tabAnimateTime ) 
            end
        end
    
        tabButton:SetCSSClass("tab")
        tabButton:SetText(tab.label)
        tabButton:AddEventCallbacks({ OnClick = tab.func })
        tabButton:AddEventCallbacks({ OnClick = ShowTab })
        
        local tabWidth = tabButton:GetWidth()
        tabButton:SetBackgroundPosition( Vector(tabWidth * (i - 1), 0, 0) )
        
    end

    CreateBotsPage(self)
    CreateVideosPage(self)
    CreateTutorialPage(self)
    CreateSandboxPage(self)
    
    self:HideAll()
    self.tutorialPage:SetIsVisible(true)
    self.playTutorialButton:SetIsVisible(true)

end
