
Script.Load("lua/TutorialUtils.lua")

if Server then
    Script.Load("lua/TutorialCommanderBot.lua")
end

local VidsURLPrefix = "file:///tutorial/resources/MarineVOs/"
local BuildTime = 3
local RPOrigin = Vector(42.780823, -1.219200, -27.418228) 

local function DoesMarineNeedArmory(player)

    local inNeed = false
    
    if player:GetHealthFraction() < 0.99 then
        inNeed = true
    else

        // Do any weapons need ammo?
        // This assumes that the player had to empty at least one clip
        for i, child in ientitychildren(player, "ClipWeapon") do
        
            if child:GetNeedsAmmo(false) then
                inNeed = true
                break
            end
            
        end
        
    end

    return inNeed

end

gMarineTutorialSteps =
{
    {
        ServerBegin = function(self, tut)

            // create a dummy commander bot
            tut.comBot = TutorialCommanderBot()
            tut.comBot:Initialize( tonumber(kMarineTeamType), true )
            table.insert( gServerBots, tut.comBot )
            tut:SetMaxPres( 19.8 )

            tut.studentTeam = kMarineTeamType

        end,

        ClientBegin = function(self, tut)
            DebugPrint("tutorial begin!")
        end
    },
    TutorialWait(1),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Welcome to the ready room. NS2 is a team vs. team game, so walk towards the blue waypoint to join the Marine team.", VidsURLPrefix.."readyroom.webm" )
        end,
        GetIsDone = function( self, tut )
            return tut:GetPlayer():GetTeamNumber() == kMarineTeamType
        end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    },
    {
        GetIsDone = function( self, tut, dt ) return GetGamerules():GetGameStarted() end
    },
    TutorialWait(2),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Each team has one commander and everyone else is a ground troop. For now, you will be a ground troop", VidsURLPrefix.."eachteam.webm" )
        end
    },
    TutorialWait(4.5),
    {
        ServerBegin = function(self, tut)
            tut.armory = tut.comBot:DropStructure(
                    Vector(52.839367, -2.540000, 32.917885),
                    kTechId.Armory, "Armory" )
            tut.armory:Construct( tut.armory:GetTotalConstructionTime()-BuildTime )
        end,
    },
    TutorialWait(3.5),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Your commander has dropped an armory, a very important structure. Go up to the blue ghost and hold E to build it.", VidsURLPrefix.."armory.webm" )
        end,
        GetIsDone = function( self, tut, dt ) return tut.armory:GetIsBuilt() end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    },
    TutorialWait(2),
    {
        ServerBegin = function( self, tut )
            tut.skulkId = tut:SpawnEnemyDrone("skulk", kAlienTeamType, Vector(54.355857849121, -2.031925201416, 10.075595855713))
            tut.gorgeId = tut:SpawnEnemyDrone("gorge", kAlienTeamType, Vector(50.355857849121, -2.031925201416, 10.075595855713))
        end,
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Good work. But there are enemies nearby. Go to the other side of the room, find them, and dispatch them. [You cannot die in the tutorial]", VidsURLPrefix.."enemies1.webm" )
        end,
        GetIsDone = function( self, tut, dt ) return GetAreAllDead( {tut.skulkId, tut.gorgeId} ) end,
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Good shooting! Go back to the armory to refill your ammo and health.", VidsURLPrefix.."goodshooting.webm" )
        end,
    },
    TutorialWait(3),
    {
        GetIsDone = function( self, tut, dt )
            local player = tut.mainClient:GetPlayer()
            return player:GetOrigin():GetDistance( tut.armory:GetOrigin() ) < 10
        end,
    },

    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Simply stand near the armory and look at it to resupply.", VidsURLPrefix.."standnear.webm" )
        end,
        GetIsDone = function( self, tut, dt ) return not DoesMarineNeedArmory( tut:GetPlayer() ) end,
        ClientEnd = function(self, tut) tut:HideClientText(); end,
    },
    TutorialWait(2),

    {
        ServerBegin = function( self, tut )

            tut.comStation = GetEntitiesForTeam("CommandStation", kMarineTeamType)[1]
            assert( tut.comStation ~= nil )

            local bot = nil
            tut.skulkId, bot = tut:SpawnEnemyDrone( "skulk", kAlienTeamType,
                    Vector(49.524036407471, -2.539999961853, 36.187225341797) )
            bot:SetTargetId( tut.comStation:GetId() )

        end,
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Another enemy has snuck in and is attacking your command station, the large structure behind the armory. Defend it!", VidsURLPrefix.."7-defendcom.webm" )
        end,
        GetIsDone = function( self, tut, dt ) return GetAreAllDead( {tut.skulkId} ) end,
        ClientEnd = function(self, tut) tut:HideClientText(); end,
    },
    {
        ServerBegin = function(self, tut)
            tut.comStation:SetArmor( tut.comStation:GetMaxArmor()*0.8, false )
        end,
        ClientBegin = function(self, tut)
            tut:ShowClientText( "The command station is damaged. Go back to the armory, press E, and use your mouse to buy the welder.", VidsURLPrefix.."8-buywelder.webm" )
        end,
        GetIsDone = function( self, tut, dt ) return tut:GetPlayerHasWeapon("Welder") end,
    },
    TutorialWait(1.0),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Buying equipment costs personal resources, displayed at the bottom right of the screen.", VidsURLPrefix.."pres.webm" )
        end,
    },
    TutorialWait(5.0),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Use your welder to repair the command station by going up to it and holding the left mouse button.", VidsURLPrefix.."10-repaircom.webm" )
        end,
        GetIsDone = function( self, tut, dt ) return (tut.comStation:GetArmor()/tut.comStation:GetMaxArmor()) > 0.99 end,
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Good work! If the aliens destroy all command stations, marines will lose. Defend them and repair them.", VidsURLPrefix.."11-comstations.webm" )
        end,
    },
    TutorialWait(5),
    {
        ClientEnd = function(self, tut) tut:HideClientText(); end,
        ServerBegin = function(self, tut)
                // drop obs, then wait 1 second
                tut.obs = tut.comBot:DropStructure( 
                        Vector(55.450622558594, -2.031877040863, 23.825286865234),
                        kTechId.Observatory, "Observatory" )
                tut.obs:Construct( tut.obs:GetTotalConstructionTime()-BuildTime )
            end,
    },
    TutorialWait(3.5),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Now use your welder to build the observatory your commander just dropped by going up to it and holding the left mouse button. The welder builds faster.", VidsURLPrefix.."12-buildobs.webm" )
        end,
        GetIsDone = function( self, tut, dt ) return tut.obs:GetIsBuilt() end,
        ClientEnd = function(self, tut) tut:HideClientText(); end,
    },
    TutorialWait(3),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Press the 1 key to switch back to your primary weapon.", VidsURLPrefix.."press1.webm" )
        end,
        GetIsDone = function( self, tut, dt ) return tut:GetPlayer():GetActiveWeapon():isa("Rifle") end,
        ClientEnd = function(self, tut) tut:HideClientText(); end,
    },
    TutorialWait(1),
    {
        ServerBegin = function(self, tut)

            tut.skulkIds = {}
            local poss =
            {
                Vector(55.375549316406, -2.0319166183472, 5.0747475624084),
                Vector(43.733531951904, -2.0319995880127, 12.145395278931),
                Vector(64.094696044922, -2.0319147109985, 9.9994192123413),
            }

            table.insert( tut.skulkIds, (tut:SpawnEnemyDrone( "skulk", kAlienTeamType, poss[1] )) )
            table.insert( tut.skulkIds, (tut:SpawnEnemyDrone( "gorge", kAlienTeamType, poss[2] )) )
            table.insert( tut.skulkIds, (tut:SpawnEnemyDrone( "fade", kAlienTeamType, poss[3] )) )

        end,

        ClientBegin = function(self, tut)

            self.toldAboutSwitching = false
            tut:ShowClientText( "The observatory has detected more enemies! They show up as red dots on your minimap on the top left of the screen. Find them and take care of them.", VidsURLPrefix.."obsenemies.webm" )

        end,

        GetIsDone = function( self, tut, dt ) return GetAreAllDead( tut.skulkIds ) end,

        OnClientUpdate = function( self, tut, dt )

            local player = Client.GetLocalPlayer()
            local weapon = player:GetActiveWeapon()

            if not self.toldAboutSwitching
                and weapon:isa("ClipWeapon")
                and weapon:GetAmmo() < 10
            then
                self.toldAboutSwitching = true
                tut:ShowClientText( "If you run out of ammo, you can switch to other weapons using the 2 and 3 keys.", VidsURLPrefix.."switchweapons.webm" )
            end
        end
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Great, go back to the armory again to refill your ammo and health. ",
                    VidsURLPrefix.."goBackToTheArmory.webm" )

        end,
        GetIsDone = function( self, tut, dt ) return not DoesMarineNeedArmory( tut:GetPlayer() ) end,
        ClientEnd = function(self, tut) tut:HideClientText(); end,
    },
    {
        ClientBegin = function( self, tut )
            tut:ShowClientText( "Always remember where the nearest armory is in case you need to retreat.",
               VidsURLPrefix.."alwaysRemember.webm")
        end,
    },
    TutorialWait(4),
    {
        // give shotgun tech
        ServerBegin = function( self, tut )
            local tree = tut.armory:GetTeam():GetTechTree()
            local node = tree:GetTechNode(kTechId.ShotgunTech)
            node:SetResearchProgress(1)
            node:SetResearched(true)
            tree:SetTechNodeChanged(node, string.format("researchProgress = 1.00"))
            tree:QueueOnResearchComplete( kTechId.ShotgunTech, tut.armory )
        end
    },
    TutorialWait(4),
    {
        ClientBegin = function( self, tut )
            tut:ShowClientText( "Your commander has used team resources to research shotguns! But you need 20 personal resources to buy one.", VidsURLPrefix.."notenough.webm")
        end,
    },
    TutorialWait(6.5),
    {
        ServerBegin = function(self, tut)

            tut.enemyIds = {}
            for _,pos in ipairs({
Vector(14.396168708801, -2.0320000648499, -13.506900787354),
Vector(22.347322463989, -1.2191998958588, -15.101121902466),
Vector(32.842208862305, -1.2191997766495, -15.460061073303),
            })
            do
                table.insert( tut.enemyIds, (tut:SpawnEnemyDrone("skulk", kAlienTeamType, pos )) )
            end

        end,

        ClientBegin = function( self, tut )
            tut:ShowClientText( "To gain resources faster, help your team capture and secure resource points around the map. Hold C to open your detailed map and use it to navigate to Cafeteria.", VidsURLPrefix.."cafeteria.webm")
        end,

        GetIsDone = function( self, tut, dt )
            local player = tut.mainClient:GetPlayer()
            return string.lower(player:GetLocationName()) == "cafeteria"
        end,
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "There are enemies here! Dispatch all of them to secure the area.", VidsURLPrefix.."secure.webm" )
        end,
        GetIsDone = function(self, tut) return GetAreAllDead( tut.enemyIds ) end
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Good work. Resource points are nozzles on the ground that emit gas. Find the one in cafeteria and stand on it.", VidsURLPrefix.."standrespoint.webm" )
        end,

        GetIsDone = function( self, tut, dt )
            local player = tut.mainClient:GetPlayer()
            return player:GetOrigin():GetDistance( RPOrigin ) < 2
        end,
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "You've found the resource point. Your commander will drop an extractor to harvest its resources. Build it.", VidsURLPrefix.."buildextractor.webm")
            end,
    },
    TutorialWait(4),
    {
        ServerBegin = function(self, tut)
            tut:ClearOrders()
            tut.extractor = tut.comBot:DropStructure( RPOrigin, kTechId.Extractor, "Extractor" )
            tut.extractor:Construct( tut.extractor:GetTotalConstructionTime()-BuildTime )
        end,
        GetIsDone = function( self, tut, dt ) return tut.extractor:GetIsBuilt() end,
    },
    TutorialWait(3),
    {
        ServerBegin = function(self, tut)
            local power = GetPowerPointForLocation( tut.extractor:GetLocationName() )
            power:Construct( power:GetTotalConstructionTime()-BuildTime )
        end,

        ClientBegin = function(self, tut)
            tut:ShowClientText( "However, all marine structures need power to function. Build the nearby power node." , VidsURLPrefix.."powernode.webm")
        end,

        GetIsDone = function( self, tut, dt )
            local power = GetPowerPointForLocation( tut.extractor:GetLocationName() )
            return power:GetIsBuilt()
        end
    },
    TutorialWait(2),
    {
        ServerBegin = function( self, tut )
            tut:SetMaxPres( nil )
            if tut:GetPlayer():GetResources() < 19.5 then
                tut:GetPlayer():SetResources( 19.5 )
            end
        end,
        ClientBegin = function(self, tut)
            tut:ShowClientText( "The extractor will now produce resources. You will soon have enough to buy the shotgun back at the armory. Go buy it. [Hold SHIFT to sprint]" , VidsURLPrefix.."buyshotgun.webm")
        end,
        GetIsDone = function( self, tut, dt ) return tut:GetPlayerHasWeapon("Shotgun") end,
    },
    {
        ClientBegin = function( self, tut )
            tut:ShowClientText( "Awesome! Other weapons can be unlocked if your commander researches them.", VidsURLPrefix.."awesome.webm")
        end,
    },
    TutorialWait(5),
    {
        ServerBegin = function(self, tut)

            tut.skulkIds = {}
            table.insert( tut.skulkIds, (tut:SpawnEnemyDrone( "skulk", kAlienTeamType, Vector(61.20544052124, -2.0318963527679, 17.316940307617)) ))
            table.insert( tut.skulkIds, (tut:SpawnEnemyDrone( "skulk", kAlienTeamType, Vector(55.842697143555, -2.031895160675, 12.812198638916)) ))
            table.insert( tut.skulkIds, (tut:SpawnEnemyDrone( "lerk", kAlienTeamType, Vector(48.975254058838, -2.0318822860718, 18.205169677734)) ))
            table.insert( tut.skulkIds, (tut:SpawnEnemyDrone( "skulk", kAlienTeamType, Vector(52.249988555908, -2.0319385528564, 8.207836151123)) ))
            table.insert( tut.skulkIds, (tut:SpawnEnemyDrone( "lerk", kAlienTeamType, Vector(64.581016540527, -2.0319242477417, 8.8174991607666)) ))

        end,

        ClientBegin = function(self, tut)
            tut:ShowClientText( "More enemies have arrived! You know what to do!", VidsURLPrefix.."moreenemies.webm" )
        end,

        GetIsDone = function( self, tut, dt )

            // Wait for player to kill em all

            local anyAlive = false
            for i,id in ipairs(tut.skulkIds) do
                local skulk = Shared.GetEntity(id)
                if skulk and skulk:GetIsAlive() then
                    anyAlive = true
                    break
                end
            end

            return not anyAlive
        end
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Good work, rookie. Those are the basics of playing marines, but there are plenty more weapons, structures, and upgrades to discover!" , VidsURLPrefix.."end1.webm")
        end
    },
    TutorialWait(7),
    {
        ServerBegin = function( self, tut )

            // Actually, do not do this to avoid auto-balance crap
            /*
            tut.comBot:Disconnect()
            tut.comBot = nil
            */
        end,
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Now press F4 to go back to the ready room and learn about the alien side.", VidsURLPrefix.."pressF4.webm")
        end,
        GetIsDone = function( self, tut )
            return tut:GetPlayer():GetTeamNumber() == kTeamReadyRoom
        end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    }
}

