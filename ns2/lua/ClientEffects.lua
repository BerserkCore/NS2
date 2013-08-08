// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CommonEffects.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// Use this file to set up looping effects that are always playing on specific units in the game.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kClientEffectData = 
{
    on_init =
    {
        initEffects =
        {
            {looping_cinematic = "cinematics/alien/gorge/spit.cinematic", classname = "Spit", done = true},
            
            // Play spin for spinning infantry portal
            {looping_cinematic = "cinematics/marine/infantryportal/spin.cinematic", classname = "InfantryPortal", active = true, done = true},
            
            // Destroy it if not spinning
            {stop_cinematic = "cinematics/marine/infantryportal/spin.cinematic", classname = "InfantryPortal", active = false, done = true},
        },
    },  
    
    on_destroy =
    {
        destroyEffects = 
        {
        },
    },
    
    client_cloak_changed =
    {
        cloakChangedSound =
        {
            // no sound for drifters
            {sound = "", classname = "Drifter", done = true},
            {sound = "sound/NS2.fev/alien/structures/shade/cloak_start", volume = .5, cloaked = true, done = true},
            {sound = "sound/NS2.fev/alien/structures/shade/cloak_end", volume = .5, cloaked = false, done = true},        
        }
    },

}

GetEffectManager():AddEffectData("ClientEffectData", kClientEffectData)