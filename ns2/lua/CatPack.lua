// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\CatPack.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/DropPack.lua")
Script.Load("lua/PickupableMixin.lua")

class 'CatPack' (DropPack)
CatPack.kMapName = "catpack"

CatPack.kModelName = PrecacheAsset("models/marine/catpack/catpack.model")
CatPack.kPickupSound = PrecacheAsset("sound/NS2.fev/marine/common/catalyst")

function CatPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel(CatPack.kModelName)
    
    InitMixin(self, PickupableMixin, { kRecipientType = {"Marine", "Exo"} })
    
    if Server then
        self:_CheckForPickup()
    end

end

function CatPack:OnTouch(recipient)

    StartSoundEffectAtOrigin(CatPack.kPickupSound, self:GetOrigin())
    recipient:ApplyCatPack()
    
end

/**
 * Any Marine is a valid recipient.
 */
function CatPack:GetIsValidRecipient(recipient)
    return not GetIsVortexed(recipient) and (recipient.GetCanUseCatPack and recipient:GetCanUseCatPack())    
end

Shared.LinkClassToMap("CatPack", CatPack.kMapName)