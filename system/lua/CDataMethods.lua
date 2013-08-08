//----------------------------------------
// Here we create meta-tables and bind the __call metamethods to constructors.
// The only reason we do it in this order is because LuaJIT FFI does not let us change the
// metatable contents after it is bound.
// Simple functions should be done in Lua to avoid FFI overhead.
//----------------------------------------

local ffi = require("ffi")
local ffi_new = ffi.new

// This is at least the epsilon of single-precision floats.
local EPSILON = 1e-7

local function BothAreCType(a,b,ctype)
    return ffi.istype(ctype, a) and ffi.istype(ctype, b)
end

local Vector_FFIIndex = _G.Vector_FFIIndex or {}

Vector_FFIIndex.kEpsilon = 0.0001

//----------------------------------------
//  
//----------------------------------------

// Add Lua-only methods, maybe override some FFI as well

local Vector = _G.Vector
local sqrt = math.sqrt

function Vector_FFIIndex:isa(className)
    return className == "Vector"
end

function Vector_FFIIndex:GetLength()
    return (sqrt(self.x*self.x + self.y*self.y + self.z*self.z))
end

function Vector_FFIIndex:GetLengthSquared()
    return (self.x*self.x + self.y*self.y + self.z*self.z)
end

function Vector_FFIIndex:GetLengthXZ()
    return (sqrt(self.x*self.x + self.z*self.z))
end

function Vector_FFIIndex:GetLengthSquaredXZ()
    return self.x*self.x + self.z*self.z
end

function Vector_FFIIndex:GetProjection(axis)
    return axis * self:DotProduct(axis)
end

function Vector_FFIIndex:GetPerpendicular()
    if math.abs(self.y) > 1.0 - EPSILON then
        local normalizer = 1.0 / sqrt(self.z*self.z + self.y*self.y)
        return (Vector(0.0, self.z * normalizer, -self.y * normalizer))
    else
        local normalizer = 1.0 / sqrt(self.z*self.z + self.x*self.x)
        return (Vector(-self.z * normalizer, 0.0, self.x * normalizer))
    end
end

function Vector_FFIIndex:GetUnit()
    return self / self:GetLength()
end

function Vector_FFIIndex:Normalize()
    local l = self:GetLength()
    if l > EPSILON then
        self:Scale(1.0/l)
        return l
    else
        return 0
    end
end


function Vector_FFIIndex:GetDistance(point)
    return ((point-self):GetLength())
end

function Vector_FFIIndex:GetDistanceSquared(point)
    return ((point-self):GetLengthSquared())
end

function Vector_FFIIndex:GetDistanceTo(v)
    return ((v-self):GetLength())
end

function Vector_FFIIndex:DotProduct(w)
    local v = self
    return v.x * w.x + v.y * w.y + v.z * w.z
end

function Vector_FFIIndex:CrossProduct(w)
    local v = self
    return (Vector(v.y * w.z - v.z * w.y, v.z * w.x - v.x * w.z, v.x * w.y - v.y * w.x))
end

function Vector_FFIIndex:ScaleAdd(s, v)
    self.x = self.x + s*v.x;
    self.y = self.y + s*v.y;
    self.z = self.z + s*v.z;
end

function Vector_FFIIndex:Add(v)
    self.x = self.x + v.x;
    self.y = self.y + v.y;
    self.z = self.z + v.z;
end

function Vector_FFIIndex:Scale(s)
    self.x = self.x*s;
    self.y = self.y*s;
    self.z = self.z*s;
end

// Metatable

local VectorMT = VectorMT or {__index = Vector_FFIIndex}

function VectorMT.__len(self)
    return (self:GetLength())
end

function VectorMT.__mul(a,b)
    local s, v
    if type(a) == "number" then
        s = a
        v = b
    else
        s = b
        v = a
    end
    return (Vector(s*v.x, s*v.y, s*v.z))
end

function VectorMT.__div(v,s)
    return (Vector(v.x/s, v.y/s, v.z/s))
end

function VectorMT.__eq(a,b)
    return BothAreCType(a,b,"Vector")
        and a.x == b.x
        and a.y == b.y
        and a.z == b.z
end

function VectorMT.__unm(v)
    return (Vector(-v.x, -v.y, -v.z))
end

function VectorMT.__tostring(v)
    assert( v ~= nil )
    assert( ffi.istype("Vector", v))
    return string.format("%f %f %f", v.x, v.y, v.z)
end

function VectorMT.__concat(s,v)
    return s .. tostring(v)
end

ffi.metatype("Vector", VectorMT)

// Some constants that were defined by Vec3.txt before..just have them here to avoid the C++ trip.
Vector_FFIIndex.origin = Vector(0,0,0)
Vector_FFIIndex.xAxis  = Vector(1,0,0)
Vector_FFIIndex.yAxis  = Vector(0,1,0)
Vector_FFIIndex.zAxis  = Vector(0,0,1)

//----------------------------------------
//  
//----------------------------------------

// override this with simpler Lua 
function Angles_FFIIndex:isa(className)
    return className == "Angles"
end

local AnglesMT = _G.AnglesMT or {__index = Angles_FFIIndex}

function AnglesMT.__eq(a,b)
    return BothAreCType(a,b,"Angles")
        and a.pitch == b.pitch
        and a.yaw == b.yaw
        and a.roll == b.roll
end


ffi.metatype("Angles", AnglesMT)

//----------------------------------------
//  
//----------------------------------------

local Coords = _G.Coords

// override this with simpler Lua 
function Coords_FFIIndex:isa(className)
    return className == "Coords"
end

local CoordsMT = _G.CoordsMT or  { __index = Coords_FFIIndex }

function CoordsMT.__mul(b,c)

    a = Coords()

    a.xAxis.x = b.xAxis.x * c.xAxis.x + b.yAxis.x * c.xAxis.y + b.zAxis.x * c.xAxis.z;
    a.xAxis.y = b.xAxis.y * c.xAxis.x + b.yAxis.y * c.xAxis.y + b.zAxis.y * c.xAxis.z;
    a.xAxis.z = b.xAxis.z * c.xAxis.x + b.yAxis.z * c.xAxis.y + b.zAxis.z * c.xAxis.z;

    a.yAxis.x = b.xAxis.x * c.yAxis.x + b.yAxis.x * c.yAxis.y + b.zAxis.x * c.yAxis.z;
    a.yAxis.y = b.xAxis.y * c.yAxis.x + b.yAxis.y * c.yAxis.y + b.zAxis.y * c.yAxis.z;
    a.yAxis.z = b.xAxis.z * c.yAxis.x + b.yAxis.z * c.yAxis.y + b.zAxis.z * c.yAxis.z;

    a.zAxis.x = b.xAxis.x * c.zAxis.x + b.yAxis.x * c.zAxis.y + b.zAxis.x * c.zAxis.z;
    a.zAxis.y = b.xAxis.y * c.zAxis.x + b.yAxis.y * c.zAxis.y + b.zAxis.y * c.zAxis.z;
    a.zAxis.z = b.xAxis.z * c.zAxis.x + b.yAxis.z * c.zAxis.y + b.zAxis.z * c.zAxis.z;

    a.origin.x = b.xAxis.x * c.origin.x + b.yAxis.x * c.origin.y + b.zAxis.x * c.origin.z + b.origin.x; 
    a.origin.y = b.xAxis.y * c.origin.x + b.yAxis.y * c.origin.y + b.zAxis.y * c.origin.z + b.origin.y;
    a.origin.z = b.xAxis.z * c.origin.x + b.yAxis.z * c.origin.y + b.zAxis.z * c.origin.z + b.origin.z;

    return a;

end

function CoordsMT.__tostring(c)
    return string.format("[x=%s; y=%s; z=%s; o=%s]",
            tostring(c.xAxis), tostring(c.yAxis), tostring(c.zAxis),
            tostring(c.origin))
end

function Coords_FFIIndex.GetIdentity()
    return (Coords(Coords.identity))
end

ffi.metatype("Coords", CoordsMT)

Coords_FFIIndex.identity = Coords( Vector.xAxis, Vector.yAxis, Vector.zAxis, Vector.origin )

//----------------------------------------
//  
//----------------------------------------

local Color = _G.Color

// override this with simpler Lua 
function Color_FFIIndex:isa(className)
    return className == "Color"
end

local ColorMT = {__index = Color_FFIIndex}

function ColorMT.__eq(a,b)
    return BothAreCType(a,b,"Color")
        and a.r == b.r
        and a.g == b.g
        and a.b == b.b
        and a.a == b.a
end

function ColorMT.__add(a,b)
    return (Color(a.r+b.r, a.g+b.g, a.b+b.b, a.a+b.a))
end

function ColorMT.__mul(a,b)
    local s, c
    if type(a) == "number" then
        s = a
        c = b
    else
        s = b
        c = a
    end
    return (Color(s*c.r, s*c.g, s*c.b, s*c.a))
end

function ColorMT.__new(self, r, g, b, a)
	
	if(not r) then
        return (ffi_new(Color, 0, 0, 0, 1.0))
	elseif(not g) then
	    
	    if(type(r) == "number") then
	        return (ColorFromPacked(r))
	    else
	        return (ffi_new(Color, r))
	    end
	    
	elseif(not a) then 
		return (ffi_new(Color, r, g, b, 1.0))
	else
	    return (ffi_new(Color, r, g, b, a))
	end
	
end

ffi.metatype("Color", ColorMT)

function ColorLerp(a,b,t)
    return (1-t)*a + t*b
end

//----------------------------------------
//  
//----------------------------------------

ffi.metatype("Trace", TraceMT)

function Move_FFIIndex:Clear()
    self.time = 0.0
    self.move = Vector(0,0,0)
    self.yaw = 0.0
    self.pitch = 0.0
    self.commands = 0
    self.hotkey = 0
end
 
ffi.metatype("Move", MoveMT)
