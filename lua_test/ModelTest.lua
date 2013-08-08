// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// ModelTest.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("TestInclude.lua")
module( "ModelTest", package.seeall, lunit.testcase )

Script.Load("lua/TechTreeConstants.lua")

function setup()
end

function teardown()
    Cleanup()
end

function validateModel(modelName, techId)

    // Make sure we don't exceed our max animations
    local modelIndex = Shared.GetModelIndex(modelName)
    local model = Shared.GetModel(modelIndex)
    assert_not_nil(model, string.format("validateModel(%s, %s)", modelName, ToString(techId)))
    
end

function testModels()

    for index, techId in pairs(kTechId) do
    
        local modelName = LookupTechData(techId, kTechDataModel)
        if modelName ~= nil and modelName ~= "" then
        
            validateModel(modelName, techId)
            
        end
        
    end
    
end

function testTags()

    local modelIndex = Shared.GetModelIndex(Skulk.kModelName)
    assert(modelIndex ~= 0)
    
    local model = Shared.GetModel(modelIndex)
    assert_not_nil(model)
    local runSequence = model:GetSequenceIndex("run")
    assert_equal(1, runSequence)
    
    local poseParams = PoseParams()
    local paramIndex = model:GetPoseParamIndex("move_speed")
    assert_true(paramIndex ~= -1)
    poseParams:Set(paramIndex, 1)
    
    local tag, time = model:GetTagPassed(runSequence, poseParams, 0.0, 0.2)
    assert_float_equal(0.166, time)
    assert_equal("step", tag)
    
    tag, time = model:GetTagPassed(runSequence, poseParams, 0, 0.165)
    assert_float_equal(-1, time)
    assert_equal("", tag)
    
    tag, time = model:GetTagPassed(runSequence, poseParams, 1.42, 1.50)
    assert_float_equal(1.433, time)
    assert_equal("step", tag)
    
    tag, time = model:GetTagPassed(runSequence, poseParams, 0.79, 0.81)
    assert_float_equal(0.8, time)
    assert_equal("step", tag)
    
    tag = model:GetTagPassed(runSequence, poseParams, 6, 7)
    assert_equal("step", tag)
    
    tag = model:GetTagPassed(runSequence, poseParams, 300, 301.4)
    assert_equal("step", tag)
    
    tag = model:GetTagPassed(runSequence, poseParams, 0, 0)
    assert_equal("", tag)
    
end
