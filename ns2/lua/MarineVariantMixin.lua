// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\MarineVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")

MarineVariantMixin = CreateMixin(MarineVariantMixin)
MarineVariantMixin.type = "MarineVariant"

// Utiliy function for other models that are dependent on marine variant
function GenerateMarineViewModelPaths(weaponName)

    local viewModels = { male = { }, female = { } }

    for variant, data in pairs(kMarineVariantData) do
        viewModels.male[variant] = PrecacheAsset("models/marine/"..weaponName.."/"..weaponName.."_view"..data.viewModelFilePart ..".model" )
    end

    for variant, data in pairs(kMarineVariantData) do
        viewModels.female[variant] = PrecacheAsset("models/marine/"..weaponName.."/female_"..weaponName.."_view"..data.viewModelFilePart..".model" )
    end
    
    return viewModels
    
end

// precache models fror all variants
MarineVariantMixin.kModelNames = { male = { }, female = { } }

for variant, data in pairs(kMarineVariantData) do
    MarineVariantMixin.kModelNames.male[variant] = PrecacheAsset("models/marine/male/male" .. data.modelFilePart .. ".model" )
end

for variant, data in pairs(kMarineVariantData) do
    MarineVariantMixin.kModelNames.female[variant] = PrecacheAsset("models/marine/female/female" .. data.modelFilePart .. ".model" )
end

MarineVariantMixin.kDefaultModelName = MarineVariantMixin.kModelNames.male[kDefaultMarineVariant]

MarineVariantMixin.kMarineAnimationGraph = PrecacheAsset("models/marine/male/male.animation_graph")

MarineVariantMixin.networkVars =
{
    shoulderPadIndex = "integer (0 to 4)",
    isMale = "boolean",
    variant = "enum kMarineVariant",
}

function MarineVariantMixin:__initmixin()

    self.isMale = true
    self.variant = kDefaultMarineVariant
    self.shoulderPadIndex = 0
    
end

function MarineVariantMixin:GetGenderString()
    return self.isMale and "male" or "female"
end

function MarineVariantMixin:GetIsMale()
    return self.isMale
end

function MarineVariantMixin:GetVariant()
    return self.variant
end

function MarineVariantMixin:GetEffectParams(tableParams)
    tableParams[kEffectFilterSex] = self:GetGenderString()
end

function MarineVariantMixin:GetVariantModel()
    return MarineVariantMixin.kModelNames[ self:GetGenderString() ][ self.variant ]
end

if Server then

    // Usually because the client connected or changed their options
    function MarineVariantMixin:OnClientUpdated(client)

        Player.OnClientUpdated(self, client)

        local data = client.variantData
        if data == nil then
            return
        end

        local changed = data.isMale ~= self.isMale or data.marineVariant ~= self.variant

        self.isMale = data.isMale

        if GetHasVariant( kMarineVariantData, data.marineVariant, client ) then

            // cleared, pass info to clients
            self.variant = data.marineVariant
            local modelName = self:GetVariantModel()

            if modelName ~= nil then
                self:SetModel(modelName, MarineVariantMixin.kMarineAnimationGraph)
            else
                Print("ERROR: bad model name for marine variant "..EnumToString(kMarineVariant, self.variant))
            end

        else

            Print("ERROR: Client tried to request marine variant they do not have yet")

        end
            
        // set the highest level shoulder pad
        for padId = 1, #kShoulderPad2ProductId do

            if GetHasShoulderPad( padId, client ) then
                self.shoulderPadIndex = padId
            end

        end

        if changed then
            // trigger a weapon switch, to update the view model
            if self:GetActiveWeapon() ~= nil then
                self:GetActiveWeapon():OnDraw(self)
            end
        end

    end

end
