// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AlienTechMap.lua
//
// Created by: Andreas Urwalek (and@unknownworlds.com)
//
// Formatted alien tech tree.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIUtility.lua")

kAlienTechMapYStart = 1
local function CheckHasTech(techId)

    local techTree = GetTechTree()
    return techTree ~= nil and techTree:GetHasTech(techId)

end

local function SetShellIcon(icon)

    if CheckHasTech(kTechId.ThreeShells) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.ThreeShells)))
    elseif CheckHasTech(kTechId.TwoShells) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.TwoShells)))
    else
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Shell)))
    end    

end

local function SetVeilIcon(icon)

    if CheckHasTech(kTechId.ThreeVeils) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.ThreeVeils)))
    elseif CheckHasTech(kTechId.TwoVeils) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.TwoVeils)))
    else
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Veil)))
    end
    
end

local function SetSpurIcon(icon)    

    if CheckHasTech(kTechId.ThreeSpurs) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.ThreeSpurs)))
    elseif CheckHasTech(kTechId.TwoSpurs) then
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.TwoSpurs)))
    else
        icon:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Spur)))
    end 

end

kAlienTechMap =
{

                    { kTechId.Harvester, 5, 1 },                           { kTechId.Hive, 7, 1 },{ kTechId.ResearchBioMassOne, 9, 1 },{ kTechId.ResearchBioMassTwo, 10, 1 },
  
                   { kTechId.CragHive, 4, 3 },                               { kTechId.ShadeHive, 7, 3 },                            { kTechId.ShiftHive, 10, 3 },
              { kTechId.Shell, 4, 4, SetShellIcon },                     { kTechId.Veil, 7, 4, SetVeilIcon },                    { kTechId.Spur, 10, 4, SetSpurIcon },
  { kTechId.Carapace, 3.5, 5 },{ kTechId.Regeneration, 4.5, 5 }, { kTechId.Phantom, 6.5, 5 },{ kTechId.Aura, 7.5, 5 },{ kTechId.Celerity, 9.5, 5 },{ kTechId.Adrenaline, 10.5, 5 },
  

                                   {kTechId.Whip, 4, 6},                                                                          {kTechId.Crag, 10, 6},
  {kTechId.BileBomb, 2.5, 7},{kTechId.Stab, 3.5, 7},{kTechId.Xenocide, 4.5, 7},{kTechId.Stomp, 5.5, 7},            {kTechId.Umbra, 9, 7},{kTechId.BoneShield, 10, 7},{kTechId.WebTech, 11, 7},
  
  
                          {kTechId.Shift, 4, 8.5},                                                                   {kTechId.Shade, 10, 8.5},
   {kTechId.GorgeTunnelTech, 3, 9.5}, {kTechId.Charge, 4, 9.5}, {kTechId.Leap, 5, 9.5},  {kTechId.ShadowStep, 9, 9.5},{kTechId.Spores, 10, 9.5},{kTechId.Vortex, 11, 9.5}, 
   
   
  
}

kAlienLines = 
{
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Harvester, kTechId.Hive),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.ResearchBioMassOne),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ResearchBioMassOne, kTechId.ResearchBioMassTwo),
    { 7, 1, 7, 2.5 },
    { 4, 2.5, 10, 2.5},
    { 4, 2.5, 4, 3},{ 7, 2.5, 7, 3},{ 10, 2.5, 10, 3},
    GetLinePositionForTechMap(kAlienTechMap, kTechId.CragHive, kTechId.Shell),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShadeHive, kTechId.Veil),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShiftHive, kTechId.Spur),
    
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Carapace),GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Regeneration),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Phantom),GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Aura),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Celerity),GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Adrenaline),
    
    
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Whip, kTechId.BileBomb),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Whip, kTechId.Stab),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Whip, kTechId.Xenocide),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Whip, kTechId.Stomp),

    GetLinePositionForTechMap(kAlienTechMap, kTechId.Crag, kTechId.Umbra),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Crag, kTechId.BoneShield),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Crag, kTechId.WebTech),
    
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shift, kTechId.GorgeTunnelTech),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shift, kTechId.Charge),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shift, kTechId.Leap),

    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shade, kTechId.ShadowStep),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shade, kTechId.Spores),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shade, kTechId.Vortex),

}





