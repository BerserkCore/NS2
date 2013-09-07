// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\PlayerVariantMixin.lua
//
// ==============================================================================================

PlayerVariantMixin = CreateMixin(PlayerVariantMixin)
PlayerVariantMixin.type = "PlayerVariant"

kPlayerVariantType = enum( { 'green', 'special', 'deluxe' } )

PlayerVariantMixin.networkVars =
{
    male = "boolean",
    variantType = "enum kPlayerVariantType"
}

PlayerVariantMixin.optionalCallbacks =
{
    OnVariantUpdated = "Called when the varient and/or sex changes."
}

function PlayerVariantMixin:__initmixin()

    self.male = true
    self.variantType = kPlayerVariantType.green
    
end

function PlayerVariantMixin:SetVariant(typeName, sex)

    self.variantType = kPlayerVariantType[typeName]
    
    local prevMale = self.male
    self.male = string.lower(sex) == "male"
    
    if self.OnVariantUpdated then
        self:OnVariantUpdated()
    end
    
end

function PlayerVariantMixin:GetVariant()
    return kPlayerVariantType[self.variantType]
end

function PlayerVariantMixin:GetSex()
    return self.male and "male" or "female"
end

function PlayerVariantMixin:GetEffectParams(tableParams)
    tableParams[kEffectFilterSex] = self:GetSex()
end