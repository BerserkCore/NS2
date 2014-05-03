// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\RifleVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

RifleVariantMixin = CreateMixin(RifleVariantMixin)
RifleVariantMixin.type = "RifleVariant"

local kDefaultVariantData = kRifleVariantData[ kDefaultRifleVariant ]

// precache models for all variants
RifleVariantMixin.kModelNames = { rifle = { } }

local function MakeModelPath( suffix )
    return "models/marine/rifle/rifle"..suffix..".model"
end

for variant, data in pairs(kRifleVariantData) do
	RifleVariantMixin.kModelNames.rifle[variant] = PrecacheAssetSafe( MakeModelPath( data.modelFilePart), MakeModelPath( kDefaultVariantData.modelFilePart) )
end

RifleVariantMixin.kDefaultModelName = RifleVariantMixin.kModelNames.rifle[kDefaultRifleVariant]

RifleVariantMixin.kRifleAnimationGraph = PrecacheAsset("models/marine/rifle/rifle_view.animation_graph")

RifleVariantMixin.networkVars =
{
    variant = "enum kRifleVariant",
	clientUserId = "integer"
}

function RifleVariantMixin:__initmixin()

    self.variant = kDefaultRifleVariant
	self.clientUserId = 0
	
end

function RifleVariantMixin:GetVariant()
    return self.variant
end

function RifleVariantMixin:GetClientId()
    return self.clientUserId
end

function RifleVariantMixin:GetVariantModel()
    return RifleVariantMixin.kModelNames.rifle[ self.variant ]
end

if Server then

    // Usually because the client connected or changed their options.
    function RifleVariantMixin:UpdateWeaponSkins(client)

        local data = client.variantData
        if data == nil then
            return
        end
		
		// Some entities using RifleVariantMixin don't care about model changes.
        if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
            return
        end
		
        if GetHasVariant(kRifleVariantData, data.rifleVariant, client) then
            // Cleared, pass info to clients.
            self.variant = data.rifleVariant
			self.clientUserId = client:GetUserId()
			
            assert(self.variant ~= -1)
            local modelName = self:GetVariantModel()
            assert(modelName ~= "")
            self:SetModel(modelName, RifleVariantMixin.kRifleAnimationGraph)
			
        else
            Print("ERROR: Client tried to request Rifle variant they do not have yet")
        end
        
    end
    
end

function RifleVariantMixin:OnUpdateRender()
 
	if self:GetRenderModel() ~= nil then
		self:GetRenderModel():SetMaterialParameter("textureIndex", self.variant-1)
	end

	local player = Client.GetLocalPlayer()
	if player and player:GetIsLocalPlayer() then
		
		if Client.GetSteamId() == self:GetClientId() then
			local viewModel = player:GetViewModelEntity()
			if viewModel and viewModel:GetRenderModel() then
				viewModel:GetRenderModel():SetMaterialParameter("textureIndex", self.variant-1)
			end
				
		end	
	end
end