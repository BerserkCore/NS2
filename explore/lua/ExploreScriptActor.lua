// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ExploreExploreScriptActor.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/HighlightMixin.lua")

local onCreate = ScriptActor.OnCreate

function ScriptActor:OnCreate()

    onCreate(self)
    
    if Client then    
        InitMixin(self, HighlightMixin)
    end
    
end
