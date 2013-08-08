
//----------------------------------------
//  FFI test. Eventually bind.php should generate this automatically.
//----------------------------------------

local ffi = require("ffi")
ffi.cdef[[
    typedef union {void* thisPtr;} CoordsWrapper;

    void* CoordsFFI_New();
    void CoordsFFI_Delete(void* thisPtr);
    void CoordsFFI_Scale(void* thisPtr, float s);
    void CoordsFFI_DebugPrint(void* thisPtr);
]]
local dll = ffi.load("Spark_Core.dll")

local createWrapper = ffi.metatype( "CoordsWrapper",
{
    __index =
    {
        // class methods go here
        Scale = function(self, scale) dll.CoordsFFI_Scale(self.thisPtr, scale) end,
        DebugPrint = function(self) dll.CoordsFFI_DebugPrint(self.thisPtr) end,
    }
})

local function deleter(wrapper) dll.CoordsFFI_Delete(wrapper.thisPtr) end

// We need this wrapping in order to associate the Delete function with the returned pointer
// Then, LuaJIT GC will call it when it cleans it up
function CoordsFFI()
    return ffi.gc( createWrapper( dll.CoordsFFI_New() ), deleter )
end
