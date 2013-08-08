
//----------------------------------------
//  FFI test. Eventually bind.php should generate this automatically.
//  Alternate method, DIRECTLY going into coords
//----------------------------------------

local ffi = require("ffi")
ffi.cdef[[
    typedef struct { float x, y, z; } Vec3;
    typedef struct { Vec3 xAxis, yAxis, zAxis, origin; } DirectCoords;
    void DirectCoords_DebugPrint(DirectCoords& c);
    void DirectCoords_Scale(DirectCoords& c, float scale);
    DirectCoords DirectCoords_Doubled(DirectCoords* c);
]]
local SparkCore = ffi.load("Spark_Core")

Vec3 = ffi.metatype("Vec3",
{
    __index =
    {
        Scale = function(self,s)
            self.x = self.x*s
            self.y = self.y*s
            self.z = self.z*s
        end,
    }
})

DirectCoords = ffi.metatype( "DirectCoords",
{
    __index =
    {
        // class methods go here
        Scale = function(self, scale)
            self.xAxis:Scale(scale)
            self.yAxis:Scale(scale)
            self.zAxis:Scale(scale)
        end,

        FFIScale = function(self, scale)
            SparkCore.DirectCoords_Scale(self, scale)
        end,

        FFIDoubled = function(self)
            return SparkCore.DirectCoords_Doubled(self)
        end,

        DebugPrint = function(self)
            Print("%f %f %f, %f %f %f, %f %f %f",
                self.xAxis.x, self.xAxis.y, self.xAxis.z,
                self.yAxis.x, self.yAxis.y, self.yAxis.z,
                self.zAxis.x, self.zAxis.y, self.zAxis.z )
        end,
    }
})

