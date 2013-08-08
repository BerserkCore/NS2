//----------------------------------------
// This is a hand-optimized library of low-level classes using LuaJIT FFI
// Declare CTypes here and add Lua-only code (which is often faster than going into C++)
// TODO: need a way to override FFI metatable entries if we want a Lua impl instead.
//----------------------------------------

local ffi = require("ffi")

ffi.cdef("typedef float Real;")

if(not Vector) then
  // This must match M4::Vec3 and must be called Vector_t to match with C/++ FFI decls
ffi.cdef([[
    typedef struct Vector_s { Real x, y, z; } Vector_t;
  	typedef struct Angles_s { Real pitch, yaw, roll; } Angles_t;
  	typedef struct Coords_s { Vector_t xAxis, yAxis, zAxis, origin; } Coords_t;
  	
]])

end


ffi.cdef
[[
typedef struct Color_t { Real r, g, b, a; } Color_t;
// Must match CollisionScene::Velocity
typedef struct Velocity_s { Vector_t linearVelocity, angularVelocity; } Velocity_t;

// Must match RenderDevice::DisplayMode
typedef struct DisplayMode_s { unsigned int xResolution, yResolution; } DisplayMode_t;

// Must match Model.txt
typedef struct Extents_s { Vector_t min, max; } Extents_t;

// Must match AnimationGraph.txt
typedef struct CurrentAnimationInfo_s
{
    int animationIndex;
    float startTime;
    float speed;
    float blendTime;
}
CurrentAnimationInfo_t;

]]

if(not Move) then
ffi.cdef
[[
typedef struct Move_s
{
    Real     absTime;  // 
    Real     time;  // **** This actually corresponds to deltaTime in C++ Move. The Lua code refers to move.time all the time when it really should say move.deltaTime - the old bindings just masked it, so here I am doing it again.
    Vector_t move;
    Real     yaw;
    Real     pitch;
    uint32_t commands;
    uint8_t  hotkey;
} Move_t;
// Must match Trace.h
typedef struct Trace_s
{
    Real      fraction;
    Vector_t  m_normal;
    Vector_t  m_endPoint; // in C++, this is 'end'
    int       entityId;
	const char*	surfaceCData;
} Trace_t;
]]
end

Vector = ffi.typeof("Vector_t")
Angles = ffi.typeof("Angles_t")
Coords = ffi.typeof("Coords_t")
Color = ffi.typeof("Color_t")

Move = ffi.typeof("Move_t")
Trace = ffi.typeof("Trace_t")


