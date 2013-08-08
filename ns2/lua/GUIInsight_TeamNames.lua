-- ==============================================================================================
--
-- lua\GUIInsight_TeamNames.lua
--
-- Created by: Jon 'Huze' Hughes (jon@jhuze.com)
--
-- Spectator: Displays team names and gametime
--
-- ==============================================================================================

class "GUIInsight_TeamNames" (GUIScript)

GUIInsight_TeamNames.kTexture = "ui/teamnames.dds"

local scale = 0.65
GUIInsight_TeamNames.kMarineTextureCoords = {0,0,400,99}
GUIInsight_TeamNames.kAlienTextureCoords = {400,0,800,99}
GUIInsight_TeamNames.kBackgroundSize = GUIScale(Vector(400, 35, 0))
GUIInsight_TeamNames.kTeamBackgroundSize = GUIScale(Vector(scale*400, scale*100, 0))

GUIInsight_TeamNames.kGameTimeFontSize = GUIScale(21)
GUIInsight_TeamNames.kTeamNameFontSize = GUIScale(19)

function GUIInsight_TeamNames:Initialize()

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(self.kBackgroundSize)
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.background:SetPosition( Vector(- self.kBackgroundSize.x / 2, 0, 0) )
    self.background:SetColor( Color(0,0,0,0) )
    self.background:SetLayer(kGUILayerInsight)
    
    local marineBackground = GUIManager:CreateGraphicItem()
    marineBackground:SetAnchor( GUIItem.Middle, GUIItem.Top )
    marineBackground:SetSize( self.kTeamBackgroundSize )
    marineBackground:SetTexture( self.kTexture )
    marineBackground:SetTexturePixelCoordinates( unpack(self.kMarineTextureCoords) )
    marineBackground:SetPosition( Vector(- self.kTeamBackgroundSize.x, 0, 0) )
    self.background:AddChild(marineBackground)

    local alienBackground = GUIManager:CreateGraphicItem()
    alienBackground:SetAnchor( GUIItem.Middle, GUIItem.Top )
    alienBackground:SetSize( self.kTeamBackgroundSize )
    alienBackground:SetTexture( self.kTexture )
    alienBackground:SetTexturePixelCoordinates( unpack(self.kAlienTextureCoords) )
    self.background:AddChild(alienBackground)

    self.team1Text = GUIManager:CreateTextItem()
    self.team1Text:SetAnchor( GUIItem.Middle, GUIItem.Center )
    self.team1Text:SetColor( kBlueColor )
    self.team1Text:SetFontIsBold( true )
    self.team1Text:SetFontSize( self.kTeamNameFontSize )
    self.team1Text:SetTextAlignmentX( GUIItem.Align_Center )
    self.team1Text:SetTextAlignmentY( GUIItem.Align_Center )
    self.team1Text:SetPosition( -Vector(self.kTeamBackgroundSize.x/2,0,0) )
    self.background:AddChild(self.team1Text)

    self.team2Text = GUIManager:CreateTextItem()
    self.team2Text:SetAnchor( GUIItem.Middle, GUIItem.Center )
    self.team2Text:SetColor( kRedColor )
    self.team2Text:SetFontIsBold( true )
    self.team2Text:SetFontSize( self.kTeamNameFontSize )
    self.team2Text:SetTextAlignmentX( GUIItem.Align_Center )
    self.team2Text:SetTextAlignmentY( GUIItem.Align_Center )
    self.team2Text:SetPosition( Vector(self.kTeamBackgroundSize.x/2 - GUIScale(20),0,0) )
    self.background:AddChild(self.team2Text)

    self.gameTimeBack = GUIManager:CreateTextItem()
    self.gameTimeBack:SetFontSize(self.kGameTimeFontSize)
    self.gameTimeBack:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.gameTimeBack:SetTextAlignmentX(GUIItem.Align_Center)
    self.gameTimeBack:SetTextAlignmentY(GUIItem.Align_Center)
    self.gameTimeBack:SetFontIsBold( true )
    self.gameTimeBack:SetColor(Color(0, 0, 0, 1))
    self.gameTimeBack:SetText("")
    self.gameTimeBack:SetPosition(Vector(2,2,0))
    self.background:AddChild(self.gameTimeBack)
    
    self.gameTime = GUIManager:CreateTextItem()
    self.gameTime:SetFontSize(self.kGameTimeFontSize)
    self.gameTime:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.gameTime:SetTextAlignmentX(GUIItem.Align_Center)
    self.gameTime:SetTextAlignmentY(GUIItem.Align_Center)
    self.gameTime:SetFontIsBold( true )
    self.gameTime:SetColor(Color(1, 1, 1, 1))
    self.gameTime:SetText("")
    self.background:AddChild(self.gameTime)
        
    self:SetText("Frontiersmen", "Kharaa")

end


function GUIInsight_TeamNames:Uninitialize()

    GUI.DestroyItem(self.background)
    self.background = nil

end

function GUIInsight_TeamNames:OnResolutionChanged(oldX, oldY, newX, newY)

    self:Uninitialize()
    
    GUIInsight_TeamNames.kBackgroundSize = GUIScale(Vector(400, 35, 0))
    GUIInsight_TeamNames.kTeamBackgroundSize = GUIScale(Vector(scale*400, scale*100, 0))
    GUIInsight_TeamNames.kGameTimeFontSize = GUIScale(21)
    GUIInsight_TeamNames.kTeamNameFontSize = GUIScale(19)

    self:Initialize()

end

function GUIInsight_TeamNames:SetIsVisible( bool )

    if bool ~= self.isVisible then
        self.background:SetIsVisible(bool)
    end

end

function GUIInsight_TeamNames:Update(deltaTime)

    local gameTime = PlayerUI_GetGameStartTime()

    if gameTime ~= 0 then
        gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
    end

    local minutes = math.floor(gameTime/60)
    local seconds = gameTime - minutes*60
    local gameTimeText = string.format("%d:%02d", minutes, seconds)

    self.gameTime:SetText(gameTimeText)
    self.gameTimeBack:SetText(gameTimeText)

end


function GUIInsight_TeamNames:SetText( team1Name, team2Name )
    
    if team1Name == nil then
    
        self.team2Text:SetText(team2Name)
        
    elseif team2Name == nil then
    
        self.team1Text:SetText(team1Name)
        
    else
    
        self.team1Text:SetText( team1Name )
        self.team2Text:SetText( team2Name )
        
    end
    
end