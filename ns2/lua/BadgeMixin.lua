// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
//    
// lua\BadgeMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

// Code given to players during PAX 2012 week.

kBadges = enum({ 'None', 'PAX2012' })
local kBadgeData =
{
    [kBadges.PAX2012] = { Texture = "ui/badge_pax2012.dds", ProductId = 4931 }
}

function BadgeMixin_GetMaxBadges()
    // +1 for donation rewards
    return #kBadges-1 + 1
end

BadgeMixin = CreateMixin( BadgeMixin )
BadgeMixin.type = "Badge"

BadgeMixin.networkVars =
{
    currentBadge = "enum kBadges"
}

function BadgeMixin:__initmixin()
    self.currentBadge = kBadges.None
end

if Server then

    function BadgeMixin:InitializeBadges()

        for badgeEnum, badgeData in pairs(kBadgeData) do
        
            local client = Server.GetOwner(self)
            if client and Server.GetIsDlcAuthorized(client, badgeData.ProductId) then
            
                self:SetBadge(badgeEnum)
                break
                
            end
            
        end
        
    end
    
end

function BadgeMixin:SetBadge(badge)
    self.currentBadge = badge
end

/**
 * nil is returned if the current badge is None.
 */
function BadgeMixin:GetBadgeIcon()

    if self.GetShowBadgeOverride and not self:GetShowBadgeOverride() then
        return nil
    end

    if self.currentBadge == kBadges.None then
        return nil
    end
    
    return kBadgeData[self.currentBadge].Texture
    
end
