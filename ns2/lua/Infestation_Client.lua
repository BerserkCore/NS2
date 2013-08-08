// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Infestation.lua
//
//    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Patch of infestation created by alien commander.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Infestation_Client_SparserBlobPatterns.lua")

local math_sin              = math.sin
local Shared_GetTime        = Shared.GetTime
local Shared_GetEntity      = Shared.GetEntity
local Entity_invalidId      = Entity.invalidId
local Client_GetLocalPlayer = Client.GetLocalPlayer

local kTimeToCloakIfParentMissing = 0.3

local kMaxOutCrop = 0.45 // should be low enough so skulks can always comfortably see over it
local kMinOutCrop = 0.1 // should be 

local _quality = nil
local _numBlobsGenerated = 0

// Purely for debugging/recording. This only affects the visual blobs, NOT the actual infestation radius
local kDebugVisualGrowthScale = 1.0

local function random(min, max)
    return math.random() * (max - min) + min
end

local function GetDisplayBlobs(self)

    if PlayerUI_IsOverhead() and self:GetCoords().yAxis:DotProduct(Vector(0, 1, 0)) < 0.2 then
        return false
    end

    return true    

end

function Infestation:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetUpdates(true)
    
    self.infestationMaterial = Client.CreateRenderMaterial()
    self.infestationMaterial:SetMaterial("materials/infestation/infestation_decal.material")

    // always create blob coords even if we do not display them sometimes
    self:ResetBlobPlacement()
    --self:EnforceOutcropLimits()
    --self:LimitBlobsAspectRatio()
    
    self.hasClientGeometry = false
    self.parentMissingTime = 0.0
    
end

local function TraceBlobRay(startPoint, endPoint)
    // we only want to place blobs on static level geometry, so we select this rep and mask
    // For some reason, ceilings do not get infested with Default physics mask. So use Bullets
    return Shared.TraceRay(startPoint, endPoint, CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll())
end

local kTuckCheckDirs = {
    Vector(1,-0.01,0):GetUnit(),
    Vector(-1,-0.01,0):GetUnit(),
    Vector(0,-0.01,1):GetUnit(),
    Vector(0,-0.01,-1):GetUnit(),
    //Vector(1,0.01,0):GetUnit(),
    //Vector(-1,0.01,0):GetUnit(),
    //Vector(0,0.01,1):GetUnit(),
    //Vector(0,0.01,-1):GetUnit(),

    // diagonals
    Vector(1,-0.01,1):GetUnit(),
    Vector(1,-0.01,-1):GetUnit(),
    Vector(-1,-0.01,-1):GetUnit(),
    Vector(-1,-0.01,1):GetUnit(),
}

function Infestation:CreateClientGeometry()

    if _quality == "rich" then
        self:CreateModelArrays(1, 0)
    else
        self.infestationDecal = Client.CreateRenderDecal()
        self.infestationDecal:SetMaterial(self.infestationMaterial)
        self.infestationDecal:SetCoords(self:GetCoords())
    end
    
    self.hasClientGeometry = true
    
end

function Infestation:DestroyClientGeometry()

    if self.infestationModelArray ~= nil then
        Client.DestroyRenderModelArray(self.infestationModelArray)
        self.infestationModelArray = nil
    end

    if self.infestationShellModelArray ~= nil then
        Client.DestroyRenderModelArray(self.infestationShellModelArray)
        self.infestationShellModelArray = nil
    end
    
    if self.infestationDecal ~= nil then
        Client.DestroyRenderDecal(self.infestationDecal)
        self.infestationDecal = nil
    end
    
    self.hasClientGeometry = false
    
end

function Infestation:UpdateClientGeometry()
    
    local cloakFraction = 0
    local infestationParentId = self.infestationParentId
    
    if GetAreEnemies( self, Client_GetLocalPlayer() ) then
        // we may be invisible to enemies

        if infestationParentId ~= Entity_invalidId then
            local infestationParent = Shared_GetEntity(infestationParentId)

            if infestationParent then
            
                if HasMixin(infestationParent, "Cloakable") then
                    cloakFraction = infestationParent:GetCloakedFraction()
                end
                
                self.parentMissingTime = -1.0
                
            else
            
                // parent is missing, but one was expected
                // assume it is because the parent is invisible/irrelevant to the local player, who may be a commander or something
                // But, due to a quirk with how state is sync'd, delay this hiding to avoid flickering.
                if self.parentMissingTime < 0 then
                    self.parentMissingTime = Shared_GetTime()
                elseif (Shared_GetTime() - self.parentMissingTime) > kTimeToCloakIfParentMissing then
                    cloakFraction = 1.0
                end
                
            end
        else
            self.parentMissingTime = -1.0
        end
    end
    
    local radius = self:GetRadius()
    local maxRadius = self:GetMaxRadius()
    local radiusFraction = (radius / maxRadius) * kDebugVisualGrowthScale
    
    local decal = self.infestationDecal
    if decal then
        
        // lets the infestation decals genlty shrink and expand
        local kClientPulseAmount = 0.05
        
        // the decals opacity drop off on the borders, so we increase it's radius client side to make the visuals match the game play
        local kClientAddRange = 1
        local kClientScalarRange = 1.1
        
        local radiusMod = math_sin(Shared_GetTime() + (self:GetId() % 10))
        local radiusMod = radiusMod * kClientPulseAmount + (1 - radiusFraction) * radiusMod * radius * .2
            
        local clientRadius = radius * kClientScalarRange + kClientAddRange * (radiusFraction) + radiusMod
        
        decal:SetExtents( Vector(clientRadius, Infestation.kDecalVerticalSize, clientRadius) )
        self.infestationMaterial:SetParameter("intensity", 1-cloakFraction)
        
    end
    
    if self.infestationModelArray then
        local origin = self.growthOrigin
        local amount = radiusFraction
        
        if self.growStartTime ~= nil then
            local time = Shared.GetTime() - self.growStartTime
            amount = math.min(time * 5, amount)
        end

        // apply cloaking effects
        amount = amount * (1-cloakFraction)
        
        SetMaterialParameters(self.infestationModelArray, amount, origin, maxRadius)
        SetMaterialParameters(self.infestationShellModelArray, amount, origin, maxRadius)
    end

end

function Infestation:LimitBlobOutcrop( coords, allowedOutcrop )

    local c = coords

    // Directly enforce it in the normal direction
    local yLen = c.yAxis:GetLength()
    if yLen > allowedOutcrop then
        c.yAxis:Scale( allowedOutcrop/yLen )
    end

    function TuckIn( amounts, amount )

        if math.abs(amounts.x) > 0 then
            local oldLen = c.xAxis:GetLength()
            local s = math.max(allowedOutcrop, oldLen-math.abs(amounts.x))/oldLen
            c.xAxis:Scale(s)
        end
        if math.abs(amounts.y) > 0 then
            local oldLen = c.yAxis:GetLength()
            local s = math.max(allowedOutcrop, oldLen-math.abs(amounts.y))/oldLen
            c.yAxis:Scale(s)
        end
        if math.abs(amounts.z) > 0 then
            local oldLen = c.zAxis:GetLength()
            local s = math.max(allowedOutcrop, oldLen-math.abs(amounts.z))/oldLen
            c.zAxis:Scale(s)
        end
    end

    function CheckAndTuck( bsDir )

        local startPt = c:TransformPoint(bsDir)
        local trace = TraceBlobRay( startPt, c.origin )
        local toCenter = c.origin-startPt

//DebugLine( startPt, c.origin, 1.0,    1,0,0,1)

        // Have some tolerance for the normal check
        if trace.fraction < 1.0 and trace.normal:DotProduct(toCenter) < -0.01 then
            // a valid hit
            local outcrop = (trace.endPoint-startPt):GetLength()
            local tuckAmount = math.max( 0, outcrop-allowedOutcrop )
            TuckIn( bsDir * tuckAmount )
            
        end

    end

    for dirNum, dir in ipairs(kTuckCheckDirs) do
        CheckAndTuck( dir )
    end
    
/*
    // tuck in the blob by doing some raytraces
    
    function GetOutCropAmount(dir)

        local startpt = c.origin + dir.x*c.xAxis + dir.y*c.yAxis + dir.z*c.zAxis
        local endpt = c.origin - dir.x*c.xAxis - dir.y*c.yAxis - dir.z*c.zAxis
        local trace = TraceBlobRay(startpt, endpt)
        
        local delta = endpt-startpt
        local length = delta:GetLength()

        if trace.normal:DotProduct(delta) > 0.0 then
            // hit a backface - no out cropping
            return 0.0
        elseif math.abs(trace.normal:DotProduct(delta)) < 0.01 then
            // hit a face that is way too glancing - do not count this
            return 0.0
        else
            return trace.fraction * length
        end
    end

    function TuckInSide(amount, axisNum, side)

        local axis = nil
        if axisNum == 1 then axis = c.xAxis
        elseif axisNum == 2 then axis = c.yAxis
        else axis = c.zAxis end
                
        local oldRadius = axis:GetLength()
        local len = 2*oldRadius
        local absAmount = math.min( len, math.abs(amount) )
        local newRadius = (len - absAmount)/2.0
        local originOffset = 0
        if side == 1 then
            originOffset = (-1*oldRadius + newRadius)
        else
            originOffset = (oldRadius - newRadius)
        end

        // Adjust origin/axis
        local unitAxis = axis / oldRadius
        c.origin = c.origin + originOffset*unitAxis
        local newAxis = unitAxis*newRadius

        if axisNum == 1 then c.xAxis = newAxis
        elseif axisNum == 2 then c.yAxis = newAxis
        else c.zAxis = newAxis end
    end


    function ReduceOutCrop(axis, side)

        local amount = GetOutCropAmount(Vector(
                    side*ConditionalValue(axis == 1, 1.0, 0.0),
                    side*ConditionalValue(axis == 2, 1.0, 0.0),
                    side*ConditionalValue(axis == 3, 1.0, 0.0)))

        if amount > allowedOutcrop then
            TuckInSide( amount-allowedOutcrop, axis, side )
        end
    end

    function ReduceOutCropAllSides()
    
        // This is definitely a pretty sparse sampling that can suffer from aliasing issues
        ReduceOutCrop( 1, 1 )
        ReduceOutCrop( 1, -1 )
        ReduceOutCrop( 2, 1 )
        ReduceOutCrop( 2, -1 )
        ReduceOutCrop( 3, 1 )
        ReduceOutCrop( 3, -1 )

    end

    ReduceOutCropAllSides()

    // do it again if lengths exceed a threshold..
    local xL = c.xAxis:GetLength()
    local yL = c.yAxis:GetLength()
    local zL = c.zAxis:GetLength()
    if xL > 2.0 or yL > 2.0 or zL > 2.0 then
        ReduceOutCropAllSides()
    end

*/

end

function Infestation:EnforceOutcropLimits()

    if self.blobCoords == nil then
        return
    end

    for id, coords in ipairs(self.blobCoords) do
        if self.blobOutcrops then
            self:LimitBlobOutcrop( coords, self.blobOutcrops[id] )
        else
            self:LimitBlobOutcrop( coords, kMaxOutCrop )
        end
    end

end

local kMaxAspectRatio = 2.0

function Infestation:LimitBlobsAspectRatio()

    // ONLY in the XZ directions. We want to allow pancakes

    if self.blobCoords == nil then
        return
    end

    for id, c in ipairs(self.blobCoords) do
        xL = c.xAxis:GetLength()
        zL = c.zAxis:GetLength()
        local maxLen = kMaxAspectRatio * math.min( xL, zL )
        if xL > maxLen then c.xAxis:Scale( maxLen/xL ) end
        if zL > maxLen then c.zAxis:Scale( maxLen/zL ) end
    end

end


/*
function Infestation:ResetBlobPlacement()

    self.blobCoords = {}
    self.blobOutcrops = {}
    
    local infestMaxRadius = self:GetMaxRadius()
    local infestCoords = self:GetCoords()
    
    function PlaceBlobForOffset( xOffset, zOffset, radius )
    
        // Move up a bit, offset on XZ plane, then trace down
        local startPoint = infestCoords.origin + infestCoords.yAxis * 1.0
        
        startPoint = startPoint + infestCoords.xAxis * xOffset
        startPoint = startPoint + infestCoords.zAxis * zOffset
        
        // trace down up to 2 meters
        local endPoint = startPoint - infestCoords.yAxis * 3
        local trace = TraceBlobRay(startPoint, endPoint)
        
        if trace.fraction < 1 then
           
            // hit something - is it close enough to the actual infestation?
            if (trace.endPoint - infestCoords.origin):GetLength()+radius > infestMaxRadius then
                return false
            end

            // hit something - place a blob there
            local coords = Coords.GetLookIn( trace.endPoint, trace.normal )
            coords:Scale( radius )
            coords.zAxis, coords.yAxis = coords.yAxis, coords.zAxis // we want Y to be up, not Z
            table.insert(self.blobCoords, coords)            

            // now choose a random allowed out crop, not exceeding the max, but with some random variety
            local randval = math.random()
            local allowedOutcrop = LerpNumber( kMinOutCrop, kMaxOutCrop, randval*randval )
            table.insert(self.blobOutcrops, allowedOutcrop)
            
            return true
            
        else
            return false
        end

    end

    // see how many splats we wanna do for this infestation
    // e.g. the Hive does 3 splats, since it is larger
    local num = 1
    local parent = Shared.GetEntity(self.infestationParentId)
    if parent and parent.GetInfestationNumBlobSplats then
        num = parent:GetInfestationNumBlobSplats()
    end

    for splatNum = 1,num do    

        if false then

            // Old method, just uniformly sampling a circle
            local numPlaced = 0
            local numTries = 0
        
            // random offsetting/radii
            while numPlaced < 100 and numTries < 10000 do

                local blobRadius = math.random()
                local xOffset, zOffset = SampleCircleUniform( 0, 0, infestMaxRadius-blobRadius )
                if PlaceBlobForOffset( xOffset, zOffset, blobRadius ) then
                    numPlaced = numPlaced + 1
                end
                numTries = numTries + 1
                
            end

        else

            // randomly choose a pre-computed pattern
            local patternId = math.random(1,#kBlobPatterns)
            local pattern = kBlobPatterns[ patternId ]

            // randomly rotate it
            local rotRads = 2*math.pi*math.random()
            local rotCos = math.cos(rotRads)
            local rotSin = math.sin(rotRads)

            function ApplyRotation(x,y)
                return rotCos*x - rotSin*y, rotSin*x + rotCos*y
            end

            for id,sample in ipairs(pattern) do

                // scale all quantities by the radius of the infestation
                xOfs = sample[1] * infestMaxRadius
                zOfs = sample[2] * infestMaxRadius
                radius = sample[3] * infestMaxRadius

                // randomize the radius just a little bit
                radius = radius * LerpNumber(0.8,1.0, math.random())

// TEMP limit size to 2
// this is mainly for the hive blobs. later, we should have patterns that are big enough for the biggest
// infestations, and just not scale them at all
radius = math.min(2,radius)

                xOfs, zOfs = ApplyRotation(xOfs, zOfs)
                PlaceBlobForOffset( xOfs, zOfs, radius )

            end
        end    
    end    

end
*/

local function TraceBlobSpaceRay(x, z, hostCoords)

    local checkDistance = 2
    local startPoint = hostCoords.origin + hostCoords.yAxis * checkDistance / 2 + hostCoords.xAxis * x + hostCoords.zAxis * z
    local endPoint   = startPoint - hostCoords.yAxis * checkDistance
    return Shared.TraceRay(startPoint, endPoint, CollisionRep.Default, EntityFilterAll())
end

local function GetBlobPlacement(x, z, xRadius, hostCoords)

    local trace = TraceBlobSpaceRay(x, z, hostCoords)
    
    // No geometry to place the blob on
    if trace.fraction == 1 then
        return nil
    end
    
    local position = trace.endPoint
    local normal   = trace.normal

    // Trace some rays to determine the average position and normal of
    // the surface the blob will cover.    
    
    local numTraces = 3
    local numHits   = 0
    local point = { }
    
    local maxDistance = 2
    
    for i=1,numTraces do
    
        local q = ((i - 1) * math.pi * 2) / numTraces
        local xOffset = math.cos(q) * xRadius * 1
        local zOffset = math.sin(q) * xRadius * 1
        local randTrace = TraceBlobSpaceRay(x + xOffset, z + zOffset, hostCoords)
        
        if randTrace.fraction == 1 or (randTrace.endPoint - position):GetLength() > maxDistance then
            return nil
        end
        
        point[i] = randTrace.endPoint
    
    end
    
    local normal = Math.CrossProduct( point[3] - point[1], point[2] - point[1] ):GetUnit()
    return position, normal

end

function Infestation:PlaceBlobs(numBlobGens)

    PROFILE("Infestation:PlaceBlobs")
   
    local xOffset = 0
    local zOffset = 0
    local maxRadius = self:GetMaxRadius()
    
    local hostCoords = self:GetCoords()
    local numBlobs   = 0
    local numBlobTries = numBlobGens * 3

    for j = 1, numBlobTries do
    
        local xRadius = random(0.5, 1.5)
        local yRadius = xRadius * 0.5   // Pancakes
        
        local minRand = 0.2
        local maxRand = self:GetMaxRadius() - xRadius

        // Get a uniformly distributed point the circle
        local x, z
        repeat
            x = random(-maxRand, maxRand)
            z = random(-maxRand, maxRand)
        until x * x + z * z < maxRand * maxRand
        
        local position, normal = GetBlobPlacement(x, z, xRadius, hostCoords)
        
        if position then
        
            local angles = Angles(0, 0, 0)
            angles.yaw = GetYawFromVector(normal)
            angles.pitch = GetPitchFromVector(normal) + (math.pi / 2)
            
            local normalCoords = angles:GetCoords()
            normalCoords.origin = position
            
            local coords = CopyCoords(normalCoords)
            
            coords.xAxis  = coords.xAxis * xRadius
            coords.yAxis  = coords.yAxis * yRadius
            coords.zAxis  = coords.zAxis * xRadius
            coords.origin = coords.origin - coords.yAxis * 0.3 // Embed slightly in the surface
            
            table.insert(self.blobCoords, coords)
            numBlobs = numBlobs + 1
            
            if numBlobs == numBlobGens then
                break
            end

        end
    
    end

end

function Infestation:ResetBlobPlacement()

    PROFILE("Infestation:ResetBlobPlacement")

    self.blobCoords = { }
    
    local numBlobGens = 50
    local parent = Shared.GetEntity(self.infestationParentId)
    if parent and parent.GetInfestationNumBlobSplats then
        numBlobGens = numBlobGens * parent:GetInfestationNumBlobSplats()
    end    
    
    self.numBlobsToGenerate = numBlobGens

end

local kGrowingRadialDistance = 0.2

// t in [0,1]
local function EaseOutElastic( t )
	local ts = t*t;
	local tc = ts*t;
    return -13.495*tc*ts + 36.2425*ts*ts - 29.7*tc + 3.40*ts + 4.5475*t
end

local function OnHostKilledClient(self)

    self.maxRadius = self:GetRadius()
    self.radiusCached = nil
    
end

local gDebugDrawBlobs = false
local gDebugDrawInfest = false

function Infestation:DebugDrawBlobs()

    local player = Client.GetLocalPlayer()

    if self.blobCoords and player then

        for id,c in ipairs(self.blobCoords) do

            // only draw blobs within 5m of player - too slow otherwise
            if (c.origin-player:GetOrigin()):GetLength() < 5.0 then

                //DebugLine( c.origin, c.origin+c.xAxis, 0, 1,0,0,1 )
                DebugLine( c.origin, c.origin+c.yAxis * 2, 0, 0,1,0,1 )
                //DebugLine( c.origin, c.origin+c.zAxis, 0, 0,0,1,1 )
                //DebugLine( c.origin, c.origin-c.xAxis, 0, 1,1,1,1 )
                //DebugLine( c.origin, c.origin-c.yAxis, 0, 1,1,1,1 )
                //DebugLine( c.origin, c.origin-c.zAxis, 0, 1,1,1,1 )

            end
        end
    end

end

function Infestation:DebugDrawInfest()

    DebugWireSphere( self:GetOrigin(), 1.0, 0,   1,0,0,1 )
    DebugLine( self:GetOrigin(), self:GetOrigin()+self:GetCoords().yAxis*2, 0,     0,1,0,1)

end

function Infestation:OnUpdate(deltaTime)

    PROFILE("Infestation:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)
    
    if self.clientHostAlive ~= self.hostAlive then
    
        self.clientHostAlive = self.hostAlive
        if not self.hostAlive then
            OnHostKilledClient(self)
        end
        
    end
    
    if gDebugDrawBlobs then
        self:DebugDrawBlobs()
    end

    if gDebugDrawInfest then
        self:DebugDrawInfest()
    end

    if self.numBlobsToGenerate > 0 then
        numBlobGens = math.min(_numBlobsToGenerate, self.numBlobsToGenerate)
        self:PlaceBlobs(numBlobGens)
        self.numBlobsToGenerate = self.numBlobsToGenerate - numBlobGens
        _numBlobsToGenerate = _numBlobsToGenerate - numBlobGens
        if _numBlobsToGenerate == 0 then
            self.growStartTime = Shared.GetTime()
        end
    end
    
    if self.numBlobsToGenerate == 0 then
        self:UpdateBlobAnimation()
    end
    
end

function SetMaterialParameters(modelArray, radiusFraction, origin, maxRadius)

    modelArray:SetMaterialParameter("amount", radiusFraction)
    modelArray:SetMaterialParameter("origin", origin)
    modelArray:SetMaterialParameter("maxRadius", maxRadius)

end

function Infestation:UpdateBlobAnimation()

    PROFILE("Infestation:UpdateBlobAnimation")
    
    if not self.hasClientGeometry and GetDisplayBlobs(self) then
        self:CreateClientGeometry()
    end
    
    if self.hasClientGeometry and not GetDisplayBlobs(self) then
        self:DestroyClientGeometry()
    end    
  
    self:UpdateClientGeometry()  
  
end

local function CreateInfestationModelArray(modelName, blobCoords, origin, radialOffset, growthFraction, maxRadius, radiusScale, radiusScale2 )

    local modelArray = nil
    
    if #blobCoords > 0 then
            
        local coordsArray = { }
        local numModels = 0
        
        for index, coords in ipairs(blobCoords) do

            local c  = Coords()
            c.xAxis  = coords.xAxis  * radiusScale
            c.yAxis  = coords.yAxis  * radiusScale2
            c.zAxis  = coords.zAxis  * radiusScale
            c.origin = coords.origin
            
            numModels = numModels + 1
            coordsArray[numModels] = c
            
        end
        
        if numModels > 0 then

            modelArray = Client.CreateRenderModelArray(RenderScene.Zone_Default, numModels)
            modelArray:SetCastsShadows(false)
            modelArray:InstanceMaterials()

            modelArray:SetModel(modelName)
            modelArray:SetModels( coordsArray )

        end
        
    end
    
    return modelArray

end

function Infestation:CreateModelArrays( growthFraction, radialOffset )
    
    // Make blobs on the ground thinner to so that Skulks and buildings aren't
    // obscured.
    local scale = 1
    if self:GetCoords().yAxis.y > 0.5 then
        scale = 0.75
    end

    self.infestationModelArray      = CreateInfestationModelArray( "models/alien/infestation/infestation_blob.model", self.blobCoords, self.growthOrigin, radialOffset, growthFraction, self:GetMaxRadius(), 1, 1 * scale )
    self.infestationShellModelArray = CreateInfestationModelArray( "models/alien/infestation/infestation_shell.model", self.blobCoords, self.growthOrigin, radialOffset, growthFraction, self:GetMaxRadius(), 1.75, 1.25 * scale )
    
end

local function OnCommandResizeBlobs()

// NOTE: not sure if this works anymore

    if Client  then

        local function Filter(entity)
            return true
        end

        local infests = GetEntitiesWithFilter( Shared.GetEntitiesWithClassname("Infestation"), Filter )

        for id,infest in ipairs(infests) do
            infest:EnforceOutcropLimits()
            infest:LimitBlobsAspectRatio()
            // force recreation of model arrays
            infest:DestroyClientGeometry()
        end

    end

end

function Infestation_SetQuality(quality)

    _quality = quality
    Client.SetRenderSetting("infestation", _quality)
    
    local function Filter(entity)
        return true
    end

    local ents = GetEntitiesWithFilter( Shared.GetEntitiesWithClassname("Infestation"), Filter )
    for id,ent in ipairs(ents) do
        ent:DestroyClientGeometry()
    end
    
end

function Infestation_UpdateForPlayer()
    
    // Maximum number of blobs to generate in a frame
    _numBlobsToGenerate = 100

    // Change the texture scale when we're viewing top down to reduce the
    // tiling and make it look better.
    if PlayerUI_IsOverhead() then
        Client.SetRenderSetting("infestation_scale", 0.15)
    else
        Client.SetRenderSetting("infestation_scale", 0.30)
    end

end

function Infestation_SyncOptions()
    Infestation_SetQuality( Client.GetOptionString("graphics/infestation", "rich") )
end

local function OnLoadComplete()
    if Client then
        Infestation_SyncOptions()
    end
end

Event.Hook("Console_resizeblobs", OnCommandResizeBlobs)
Event.Hook("Console_debugblobs", function() gDebugDrawBlobs = not gDebugDrawBlobs end)
Event.Hook("Console_debuginfest", function() gDebugDrawInfest = not gDebugDrawInfest end)
Event.Hook("LoadComplete", OnLoadComplete)

Event.Hook("Console_blobspeed", function(scale)
    if tonumber(scale) then
        kDebugVisualGrowthScale = tonumber(scale)
    else
        Print("Usage: blobspeed 2.0")
    end
    Print("blobspeed = %f", kDebugVisualGrowthScale)
end)
