
Script.Load("lua/TutorialUtils.lua")

if Server then
    Script.Load("lua/TutorialCommanderBot.lua")
end

local VidsURLPrefix = "file:///tutorial/resources/AlienVOs/"

gAlienTutorialSteps =
{
    {
        ServerBegin = function(self, tut)

            // create a dummy commander bot
            tut.comBot = TutorialCommanderBot()
            tut.comBot:Initialize( tonumber(kAlienTeamType), true )
            table.insert( gServerBots, tut.comBot )

            tut.studentTeam = kAlienTeamType

            // create a marine bot all the way in Terminal
            tut:SpawnPinnedDrone( "marine", kMarineTeamType,
            Vector(55.450622558594, -2.031877040863, 23.825286865234) )

        end,
        ClientBegin = function(self, tut)
            Print("begin alien tut steps")
        end
    },
    TutorialWait(2),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Welcome back to the ready room. Now walk towards the yellow waypoint to join the Alien team.", VidsURLPrefix.."1-ready.webm" )
        end,
        GetIsDone = function( self, tut )
            return tut:GetPlayer():GetTeamNumber() == kAlienTeamType
        end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    },
    {
        GetIsDone = function( self, tut, dt ) return GetGamerules():GetGameStarted() end
    },
    {
        // spawn cysts now so infestation spreads in time
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Please wait while you spawn.", VidsURLPrefix.."0-spawn.webm" )
        end,

        ServerBegin = function( self, tut )

            //----------------------------------------
            //  Create cyst chain in prep for infestation
            //----------------------------------------
            local cystPoss = {
Vector(180.54670715332, -0.81279993057251, 35.818260192871),
Vector(175.30563354492, -0.91440010070801, 35.137542724609),
Vector(164.25967407227, -0.81279999017715, 34.880920410156),
Vector(164.58393859863, -2.1347496509552, 45.678421020508),
Vector(154.70202636719, -2.0319986343384, 45.165573120117),
Vector(151.98243713379, -2.2925715446472, 35.786220550537),
            }

            for _,pos in ipairs(cystPoss) do
                CreateEntity( "cyst", pos, kAlienTeamType )
            end

            //----------------------------------------
            //  Create structures for regeneration upgrade
            //----------------------------------------
            tut.shell = CreateEntity( "shell",
                    Vector(180.140594, -0.779367, 8.486909),
                    kAlienTeamType )
            assert( tut.shell ~= nil )

            /* this can fail sometimes, due to infestation not spreading yet
               not really used in the tut right now
            tut.harvester = tut.comBot:DropStructure( 
                    Vector( 151.947815, -2.011799, 34.622425 ),
                    kTechId.Harvester, "Harvester" )
            assert( tut.harvester )
            */

        end,

        GetIsDone = function( self, tut )
            return tut:GetPlayer():isa("Skulk")
        end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    },

    TutorialWait(1),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Aliens start as skulks. You can walk up walls by going up to a wall, looking up, and pressing W. Walk up towards the ceiling fan now.", VidsURLPrefix.."2-wall.webm" )
        end,
        GetIsDone = function( self, tut, dt ) return tut:GetPlayer():GetOrigin().y > 9.0 end,
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Good. As long as you stay close to a wall or ceiling, you will not fall.", VidsURLPrefix.."3-fall.webm" )
        end,
    },
    TutorialWait(4),
    {
        ServerBegin = function( self, tut )
            tut.marineId = tut:SpawnPinnedDrone( "marine", kMarineTeamType, 
                Vector(185.55778503418, -0.81279999017715, 8.5951232910156))

        end,
        ClientBegin = function(self, tut)
            tut:ShowClientText( "A marine is below you! Climb down while staying behind him, sneak up, then left click to bite!", VidsURLPrefix.."5-bite.webm")
        end,
        GetIsDone = function( self, tut, dt )
            return GetAreAllDead({tut.marineId})
        end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    },
    TutorialWait(0.5),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Good work. Stand near the Hive, the large orange organism under the ceiling fan, to get healed.", VidsURLPrefix.."6-heal.webm" )
        end,
    },
    TutorialWait(3),
    {
        GetIsDone = function( self, tut, dt )
            return tut:GetPlayer():GetHealthFraction() > 0.99
        end,
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "If marines destroy all hives, they win. Defend them.", VidsURLPrefix.."8-defend.webm" )
        end,
    },
    TutorialWait(4),
    {
        ServerBegin = function( self, tut )
            tut.marineId = tut:SpawnPinnedDrone( "marine", kMarineTeamType, 
                    Vector(153.6395111084, 0.59082990884781, 1.915595293045) )
        end,
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Now hold C to use your map and go to Pressure Control. Find the marine there and dispatch him.", VidsURLPrefix.."9-pressure.webm" )
        end,
        GetIsDone = function( self, tut, dt )
            return GetAreAllDead({tut.marineId})
        end,
    },
    TutorialWait(1),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Good hunting! Open your map again, and note the thick orange line East of you. This is a vent. Find the entrance and go through it.", VidsURLPrefix.."10-vent.webm" )
        end,
        GetIsDone = function( self, tut, dt )
            return tut:GetPlayerDistanceTo( Vector(153.708649, 2.854800, 12.200196) ) < 1
        end,
    },
    {
        ServerBegin = function( self, tut )
            tut.marineId = tut:SpawnPinnedDrone( "marine", kMarineTeamType, 
                    Vector(153.2239074707, -2.3118197917938, 34.739826202393) )
        end,
        ClientBegin = function(self, tut)
            tut:ShowClientText( "You can hold SHIFT to silence your foot steps so enemies can't hear you.", VidsURLPrefix.."11-shift.webm" )
        end,
        GetIsDone = function( self, tut, dt ) return tut:GetPlayerDistanceToId( tut.marineId ) < 10 end,
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Get that marine down there!", VidsURLPrefix.."12-attack.webm" )
        end,
        GetIsDone = function( self, tut, dt )
            return GetAreAllDead({tut.marineId})
        end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    },
    TutorialWait(2),
    {
        ServerBegin = function( self, tut )
            tut:GetPlayer():SetResources( kGorgeCost+1 )
        end,
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Skulks are useful, but you can evolve into other life forms as well. Press B to open the evolve menu, then evolve into the Gorge.", VidsURLPrefix.."13-evolve.webm" )
        end,
        GetIsDone = function( self, tut, dt )
            return tut:GetPlayer():isa("Gorge")
        end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    },
    TutorialWait(2),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "The gorge is a defensive support life form that can heal and build small structures", VidsURLPrefix.."14-gorge.webm" )
        end,
    },
    TutorialWait(4.5),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Try building a few clogs. Press the number 2, then 2 again, then aim at something and left click. Build 3 of them.", VidsURLPrefix.."15-clogs.webm" )
        end,
        ServerBegin = function( self, tut )
            tut:GetPlayer():SetResources( kClogCost*3+1 )
            tut.numClogs = 0
        end,
        GetIsDone = function( self, tut, dt )
            return tut.numClogs >= 3
        end,
        OnClogCreated = function( self, tut, clog )
            tut.numClogs = tut.numClogs + 1
        end,
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "Clogs can block off passages and slow down marines.", VidsURLPrefix.."16-clogs.webm" )
        end,
    },
    TutorialWait(3),
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "You can also build hydras, which function as defensive turrets. Press the number 2, then the number 1 to select them. Build 3 of them.", VidsURLPrefix.."17-hydras.webm" )
        end,
        ServerBegin = function( self, tut )
            tut:GetPlayer():SetResources( kHydraCost*3+1 )
            tut.hydras = {}
        end,
        GetIsDone = function( self, tut, dt )
            return #tut.hydras >= 3
        end,
        OnHydraCreated = function( self, tut, hydra )
            table.insert( tut.hydras, hydra )
        end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "You need to heal them for them to grow. Aim at them and hold right click.", VidsURLPrefix.."18-speedup.webm" )
        end,
        GetIsDone = function( self, tut, dt )
            local allBuilt = true
            for _,hydra in ipairs( tut.hydras ) do
                if not hydra:GetIsBuilt() then
                    allBuilt = false
                    break
                end
            end
            return allBuilt
        end,
    },
    {
        ClientBegin = function(self, tut)
            tut:ShowClientText( "A marine is coming! But don't worry. Stand near your hydras and let them take care of him for you.", VidsURLPrefix.."19-hydras.webm" )
        end,
    },
    TutorialWait(4.5),
    {
        ServerBegin = function( self, tut )

            local bot = nil
            tut.marineId, bot = tut:SpawnEnemyDrone( "marine", kMarineTeamType,
                    Vector(140.64416503906, -2.0319976806641, 22.99015045166) )
            bot:SetTelepathic(true)

        end,
        GetIsDone = function( self, tut )
            // sometimes, the marine will spawn in a weird position and the hydras can't get him.
            // so, just auto kill if it takes too long
            if tut.stepElapsedTime > 30 then
                Shared.GetEntity(tut.marineId):Kill( nil, nil, nil, nil )
            end
            return GetAreAllDead({tut.marineId})
        end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    },
    TutorialWait(1),
    {
        ServerBegin = function( self, tut )
            tut:GetPlayer():SetResources( kLerkCost+1 )
        end,
        ClientBegin = function( self, tut )
            tut:ShowClientText("Finally, let's try out the flying Lerk. Press B and evolve into it now.", VidsURLPrefix.."20-lerk.webm")
        end,
        GetIsDone = function( self, tut, dt )
            return tut:GetPlayer():isa("Lerk")
        end,
    },
    {
        ClientBegin = function( self, tut )
            tut:ShowClientText("Lerks move by flying. Hold W and tap space bar repeatedly to fly forward, and hold space bar to glide. Try this now.", VidsURLPrefix.."21-fly.webm")
        end,
    },
    // TODO TODO should have them fly up to courtroom ceiling, then hold to glide a bit
    TutorialWait(10),
    {
        ServerBegin = function( self, tut )
            tut.marineId = tut:SpawnPinnedDrone( "marine", kMarineTeamType,
                    Vector(98.834777832031, 3.253809928894, 10.318949699402) )
        end,
        ClientBegin = function( self, tut )
            tut:ShowClientText("Use your map and fly to Courtyard.", VidsURLPrefix.."22-courtyard.webm")
        end,
        GetIsDone = function( self, tut, dt )
            return string.lower(tut:GetPlayer():GetLocationName()) == "courtyard"
        end,
    },
    {
        ClientBegin = function( self, tut )
            tut:ShowClientText("Fly around and dispatch the marine in Courtyard! Right-click to shoot projectives, left-click to bite.", VidsURLPrefix.."23-fight.webm")
        end,
        GetIsDone = function( self, tut, dt ) return GetAreAllDead({tut.marineId}) end,
        ClientEnd = function(self, tut) tut:HideClientText() end,
    },
    TutorialWait(2),
    {
        ServerBegin = function( self, tut )
            tut:GetPlayer():SetResources( 10 )
        end,
        ClientBegin = function( self, tut )
            tut:ShowClientText("Lastly, aliens can evolve traits. Press B, click the yellow icon labeled Regeneration on the bottom right of the circle, then click 'Evolve'.", VidsURLPrefix.."23b-traits.webm")
        end,
        GetIsDone = function( self, tut, dt ) return tut:GetPlayer():GetHasUpgrade(kTechId.Regeneration) end,
    },
    {
        ClientBegin = function( self, tut )
            tut:ShowClientText("Now your health will regenerate over time. Your commander decides which traits to make available, and each gives a specific benefit to any lifeform.", VidsURLPrefix.."23c-traits.webm")
        end,
        GetIsDone = function( self, tut, dt ) return tut:GetPlayer():GetHasUpgrade(kTechId.Regeneration) end,
    },
    TutorialWait(8),
    {
        ClientBegin = function( self, tut )
            tut:ShowClientText("Those are the basics of playing aliens. There are more life forms and abilities to learn about, and you can try them out in the Sandbox mode under the Training menu.", VidsURLPrefix.."24-end1.webm")
        end,
    },
    TutorialWait(8),
    {
        ClientBegin = function( self, tut )
            tut:ShowClientText("You can also practice against bots via the Training menu if you don't feel ready to play real games yet. Good luck and have fun!", VidsURLPrefix.."25-end2.webm")
        end,
    },
    TutorialWait(3),
}
