// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Weapons\ExploreViewModel.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/HighlightMixin.lua")

local onCreate = ViewModel.OnCreate

function ViewModel:OnCreate()

    onCreate(self)
    
    if Client then    
        InitMixin(self, HighlightMixin)
    end

end