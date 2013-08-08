-- Auto-generated from Model.txt - Do not edit.
local pkg, world = ...
local ffi = require("ffi")
local ffi_new, ffi_string = ffi.new, ffi.string
local Vector, Angles, Coords, Color, Trace, Move = _G.Vector, _G.Angles, _G.Coords, _G.Color, _G.Trace, _G.Move
-- Model FFI method additions --

function Model:GetFileName()
    return (ffi_string(pkg.Model_GetFileName(self)))
end

function Model:GetSequenceIndex(name)
    return (pkg.Model_GetSequenceIndex(self, name))
end

function Model:GetReferencePose(poses)
    pkg.Model_GetReferencePose(self, poses)
end

function Model:AccumulateSequenceNoParams(sequenceIndex, time, poses)
    pkg.Model_AccumulateSequenceNoParams(self, sequenceIndex, time, poses)
end

function Model:AccumulateSequence(sequenceIndex, time, poseParams, poses)
    pkg.Model_AccumulateSequence(self, sequenceIndex, time, poseParams, poses)
end

function Model:GetIsLooping(sequenceIndex)
    return (pkg.Model_GetIsLooping(self, sequenceIndex))
end

function Model:GetBoneCoords(poses, boneCoords)
    pkg.Model_GetBoneCoords(self, poses, boneCoords)
end

function Model:GetSequenceLength(sequenceIndex)

    if(type(sequenceIndex) == "number") then
        return (pkg.Model_GetSequenceLength0(self, sequenceIndex))
    else
        return (pkg.Model_GetSequenceLength1(self, sequenceIndex))
    end
end

function Model:GetNumSequences()
    return (pkg.Model_GetNumSequences(self))
end

function Model:GetPoseParamIndex(name)
    return (pkg.Model_GetPoseParamIndex(self, name))
end

function Model:GetPoseParamName(index)
    return (ffi_string(pkg.Model_GetPoseParamName(self, index)))
end

function Model:GetNumPoseParameters()
    return (pkg.Model_GetNumPoseParameters(self))
end

function Model:GetOrigin()
    local __cdataOut = Vector()
    pkg.Model_GetOrigin(self, __cdataOut)

    return __cdataOut
end

function Model:GetExtentsMin()
    local __cdataOut = Vector()
    pkg.Model_GetExtentsMin(self, __cdataOut)

    return __cdataOut
end

function Model:GetExtentsMax()
    local __cdataOut = Vector()
    pkg.Model_GetExtentsMax(self, __cdataOut)

    return __cdataOut
end

function Model:GetExtentsForPose(boneCoords, min, max)
    pkg.Model_GetExtentsForPose(self, boneCoords, min, max)
end

function Model:GetHasHitBoxes()
    return (pkg.Model_GetHasHitBoxes(self))
end

function Model:TraceRay(start, endPt, boneCoords)
    local __cdataOut = Trace()
    pkg.Model_TraceRay(self, start, endPt, boneCoords, __cdataOut)

    return __cdataOut
end

function Model:GetAttachPointExists(attachPointIndex)
    return (pkg.Model_GetAttachPointExists(self, attachPointIndex))
end

function Model:GetAttachPointBoneExists(attachPointIndex, boneCoords)
    return (pkg.Model_GetAttachPointBoneExists(self, attachPointIndex, boneCoords))
end

function Model:GetAttachPointIndex(attachPointName)
    return (pkg.Model_GetAttachPointIndex(self, attachPointName))
end

function Model:GetAttachPointCoords(attachPointIndex, boneCoords)
    local __cdataOut = Coords()
    pkg.Model_GetAttachPointCoords(self, attachPointIndex, boneCoords, __cdataOut)

    return __cdataOut
end

function Model:GetNumCameras()
    return (pkg.Model_GetNumCameras(self))
end

function Model:GetCameraName(cameraIndex)
    return (ffi_string(pkg.Model_GetCameraName(self, cameraIndex)))
end

function Model:GetTagName(tagIndex)
    return (ffi_string(pkg.Model_GetTagName(self, tagIndex)))
end

-- PosesArray FFI method additions --

-- PoseParams FFI method additions --

function PoseParams:Set(index, value)
    pkg.PoseParams_Set(self, index, value)
end

function PoseParams:Get(index)
    return (pkg.PoseParams_Get(self, index))
end

if Model == nil then Model = {} end

function Model.GetBlendedPoses(poses1, poses2, fraction)
    pkg.Model_GetBlendedPoses(poses1, poses2, fraction)
end


