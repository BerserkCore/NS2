
Script.Load("lua/Entity.lua")
Script.Load("lua/TutorialUtils.lua")

Script.Load("lua/MarineTutorial.lua")
Script.Load("lua/AlienTutorial.lua")

if Server then
    Script.Load("lua/EasyBot.lua")
end

class "Tutorial" (Entity)

local networkVars =
{
    stepNum = "integer",
}

function Tutorial:GetSteps()

    if self.steps == nil then
        // concatenate the two tutorial step sets
        self.steps = {}
        for _,step in ipairs(gMarineTutorialSteps) do
            table.insert( self.steps, step )
        end
        for _,step in ipairs(gAlienTutorialSteps) do
            table.insert( self.steps, step )
        end
    end
    return self.steps

end

function Tutorial:GetStep(stepNum)

    assert( self:GetSteps() ~= nil )

    local stepNum = stepNum or self.stepNum
    if stepNum ~= nil and stepNum > 0 and stepNum <= #self:GetSteps() then
        return self:GetSteps()[ stepNum ]
    end

end

// So we don't get destroyed on match reset
function Tutorial:GetIsMapEntity()
    return true
end

if Server then

    function Tutorial:OnCreate()

        self:SetUpdates(true)

        self.stepNum = 0
        self.mainClient = nil   // the client that the tutorial is aimed at.
        self.studentTeam = nil
        self.bots = {}

    end

    function Tutorial:Reset()
    
        if self:GetStep() and self:GetStep().OnMatchReset then
            self:GetStep():OnMatchReset(self)
        end

    end

    function Tutorial:OnClientConnect(client)

        // only start the tutorial when the clint connects
        if self.mainClient == nil then
            self.stepNum = 0
            self.mainClient = client
            self:_Advance()   // move to step 1
        else
            // do nothing - it is probably just a bot
        end

    end

    function Tutorial:GetCanJoinTeamNumber( teamNumber )
        // make sure the student has joined the intended team already
        if self:GetPlayer():GetTeamNumber() == self.studentTeam then
            // ok, let any bots join whatever team
            return true
        else
            return teamNumber == self.studentTeam
        end
    end

    function Tutorial:_Advance( delayTime )

        self.stepNum = self.stepNum+1
        self.stepElapsedTime = 0

        //DebugPrint("going to step "..self.stepNum)

        if self.stepNum > #self:GetSteps() then
            DebugPrint("tutorial done")
        else
            if self:GetStep().ServerBegin then
                self:GetStep():ServerBegin(self)
            end
        end

    end

    //----------------------------------------
    //  API for steps
    //----------------------------------------

    // returns the main player, ie. the player being taught
    function Tutorial:GetPlayer()
        return self.mainClient:GetPlayer()
    end

    function Tutorial:GetPlayerDistanceTo( pos )
        return self:GetPlayer():GetOrigin():GetDistance(pos)
    end

    function Tutorial:GetPlayerDistanceToId( entId )
        if Shared.GetEntity(entId) == nil then
            return 0
        else
            return self:GetPlayer():GetOrigin():GetDistance( Shared.GetEntity(entId):GetOrigin() )
        end
    end

    function Tutorial:GivePlayerMoveOrder( targetPos )

        local player = self.mainClient:GetPlayer()
        player:GiveOrder(
                kTechId.Move,
                Entity.invalidId, 
                targetPos,
                0, true, true, nil )

    end

    function Tutorial:ClearOrders()

        local player = self.mainClient:GetPlayer()
        player:ClearOrders()

    end

    function Tutorial:GetPlayerHasWeapon( weaponClassName )

        local player = self.mainClient:GetPlayer()
        local hasWeapon = false
        for i, child in ientitychildren(player, weaponClassName) do
            if child then
                hasWeapon = true
                break
            end
        end

        return hasWeapon

    end

    function Tutorial:SetMaxPres(x)
        self.maxPres = x
    end

    function Tutorial:SpawnEnemyDrone( entityMapName, teamNum, pos )

        local bot = EasyBot()
        bot:Initialize( teamNum, true )
        bot:SetTargetId( self:GetPlayer():GetId() )
        table.insert( gServerBots, bot )
    
        table.insert( self.bots, bot )

        bot:GetPlayer():Replace( entityMapName, teamNum, false, pos )
        return bot:GetPlayer():GetId(), bot

    end

    function Tutorial:SpawnPinnedDrone( entityMapName, teamNum, pos )

        local id, bot = self:SpawnEnemyDrone( entityMapName, teamNum, pos )
        bot:SetPinned(true)
        return id, bot

    end

    //----------------------------------------
    //  
    //----------------------------------------
    function Tutorial:OnUpdate(deltaTime)

        if self:GetStep() then

            self.stepElapsedTime = self.stepElapsedTime + deltaTime

            if self:GetStep().GetIsDone == nil
                or self:GetStep():GetIsDone(self)
            then
                self:_Advance()
            end
        end

        if self.maxPres ~= nil then
            local player = self.mainClient:GetPlayer()
            player:SetResources( math.min( player:GetResources(), self.maxPres ) )
        end

    end

    //----------------------------------------
    //  Events that dispatch to the step
    //----------------------------------------
    function Tutorial:OnKillEvent(victim)

        if self:GetStep() == nil then return end

        if self:GetStep().OnKillEvent then
            self:GetStep():OnKillEvent( victim, self )
        end

    end

    function Tutorial:OnBuiltEvent(struct, builder)

        if self:GetStep() and self:GetStep().OnBuiltEvent then
            self:GetStep():OnBuiltEvent( self, struct, builder )
        end

    end

    function Tutorial:OnClogCreated( clog )
        if self:GetStep() and self:GetStep().OnClogCreated then
            self:GetStep():OnClogCreated( self, clog )
        end
    end

    function Tutorial:OnHydraCreated( hydra )
        if self:GetStep() and self:GetStep().OnHydraCreated then
            self:GetStep():OnHydraCreated( self, hydra )
        end
    end

    function Tutorial:OnJoinTeam( player, newTeamNumber, force )

        if self:GetStep() and self:GetStep().OnJoinTeam then
            self:GetStep():OnJoinTeam( self, player, newTeamNumber, force )
        end
            
    end

end

if Client then

    function Tutorial:OnCreate()

        self.prevStepNum = 0
        self:SetUpdates(true)

    end

    //----------------------------------------
    //  Client only steps API
    //----------------------------------------
    function Tutorial:ShowClientText(text, videoURL)
        GUIObjective.main:Show(text, videoURL)
    end

    function Tutorial:HideClientText()
        GUIObjective.main:Hide()
    end

    //----------------------------------------
    //  
    //----------------------------------------
    function Tutorial:OnUpdate( dt )

        if self.prevStepNum ~= self.stepNum then

            if self.prevStepNum > 0 and self:GetStep(self.prevStepNum).ClientEnd then
                self:GetStep(self.prevStepNum):ClientEnd(self)
            end

            // execute begin/ends for all steps in between
            for skipped = self.prevStepNum+1, self.stepNum-1 do

                local step = self:GetStep(skipped)
                if step.ClientBegin then
                    step:ClientBegin(self)
                end
                if step.ClientEnd then
                    step:ClientEnd(self)
                end

            end

            // advance

            self.prevStepNum = self.stepNum

            if self:GetStep() and self:GetStep().ClientBegin then
                self:GetStep():ClientBegin(self)
            end

        end

        if self:GetStep() and self:GetStep().OnClientUpdate then
            self:GetStep():OnClientUpdate(self, dt)
        end

    end

end

Shared.LinkClassToMap("Tutorial", "tutorial", networkVars)
