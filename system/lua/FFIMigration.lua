//----------------------------------------
//  Steven An, 2012
//  These were written to migrate from C/API bindings to LuaJIT-FFI.
//  They are meant to accomodate some special-case features, like multiple return values from C functions.
//  This should be loaded after all system/lua/ffi files have been loaded
//----------------------------------------
local ffi = require("ffi")
local jit = require("jit")

if(GUIItem) then

local GUIItem_SetTexture = GUIItem.SetTexture

function GUIItem:SetTexture(textureFileName)
    GUIItem_SetTexture(self, textureFileName or "")   
end
    
end

function TraceStopPoint()
  return
end 

jit.setalwayslink(TraceStopPoint)
jit.setfunctionhot(TraceStopPoint)
TraceStopPoint()

if(not Model) then
	return
end

local GetEntity = Shared.GetEntity
local GetParentId = Entity.GetParentId

function Entity:GetParent()
   //Shared.GetEntity can speclize for invalid ids so we don't have to worry about it
   return (GetEntity(GetParentId(self)))
end

local Entity_GetCoords = Entity.GetCoords
local Entity_GetAngles = Entity.GetAngles


function Entity:GetCoords()
   
    //Just stay in Lua and use tracable calls if the entity has no parent 
    if(GetParentId(self) == -1) then
        
        local coords = Entity_GetAngles(self):GetCoords()
        coords.origin = self:GetOrigin()
        
        return coords
    else
        //May call GetAttachPointCoords 
        return Entity_GetCoords(self)
    end
end

function Entity:GetDistance(other)
   
    if(type(other) == "cdata") then
        return (self:GetDistanceToVector(other))
    else
        return self:GetDistanceToEntity(other)
    end
   
end

function Entity:GetDistanceSquared(other)
   
    if(type(other) == "cdata") then
        return (self:GetDistanceSquaredToVector(other))
    else
        return self:GetDistanceSquaredToEntity(other)
    end
   
end

function CollisionObject:SetBoneCoords(coords, boneCoords)
    
    if(not self:SetBoneCoordsInternal(coords, boneCoords)) then
        error("Infinite coords")
    end
end

function CollisionObject:SetCoords(coords)

    if(not self:SetCoordsInternal(coords)) then
        error("Infinite coords")
    end
end


function CollisionObject:SetPosition(position)
    
    if(not self:SetPositionInternal(position)) then
        error("Infinite position")
    end
end


local GetExtentsMin, GetExtentsMax = Model.GetExtentsMin, Model.GetExtentsMax

// MRV
function Model:GetExtents(coords)
    
    if(not coords) then
        return GetExtentsMin(self), GetExtentsMax(self)
    else
        
        local min, max = Vector(), Vector()
        self:GetExtentsForPose(coords, min, max)
        
        return min, max
    end
end

// MRV
function AnimationGraphState:GetCurrentAnimation(layerIndex, blendIndex)
    local info = self:GetCurrentAnimationStruct(layerIndex, blendIndex)
    return info.animationIndex, info.startTime, info.speed, info.blendTime
end


if(RenderModel) then

    function RenderModel:SetModel(model)
      
	    if(type(model) == "number") then
            self:SetModelByIndex(model)
        else
            self:SetModelByName(model)
        end
    end
    
    function RenderModelArray:SetModel(model)
      
	    if(type(model) == "number") then
            self:SetModelByIndex(model)
        else
            self:SetModelByName(model)
        end
    end 
  
  	local SetParameter = ScreenEffect.SetParameter
  
   	function ScreenEffect:SetParameter(name, index, value)
      
	    if(not value) then
	    	SetParameter(self, name, index)
	    else
	    	self:SetParameterIndex(name, index, value)
	    end
    end      
end


//----------------------------------------
//  So we can treat GetPathPoints output like a Lua table
//  NOTE: This is a very specific, hacky thing for array-like objects..
//----------------------------------------

local inst = PointArray()
local mt = getmetatable(inst)

mt.__index = function(self, b0Idx)
    return (PointArray.Get(self, b0Idx-1))// base1 to base0..
end

mt.__len = function(self)
    return (PointArray.GetSize(self))
end

    --[[
local inst = PointArray()
local mt = getmetatable(inst)
local cppIndex = mt.__index
mt.__index = $tableVar
setmetatable($tableVar, {__index = cppIndex})
    ]]--


//----------------------------------------
//  STEVETEMP turn jit off see if it fixes errors
//----------------------------------------
//require("jit").off()
//Shared.Message("WARNING JIT is turned OFF")


