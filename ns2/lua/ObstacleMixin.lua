// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\ObstacleMixin.lua    
//
// Created by: Dushan Leska (dushan@unknownworlds.com) 
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/FunctionContracts.lua")

ObstacleMixin = CreateMixin( ObstacleMixin )
ObstacleMixin.type = "Obstacle"

gAllObstacles = { }

function RemoveAllObstacles()
    for obstacle, v in pairs(gAllObstacles) do
        obstacle:RemoveFromMesh()
    end
end

function ObstacleMixin:__initmixin()
    self.obstacleId = -1
end

function ObstacleMixin:OnInitialized()
    self:AddToMesh()
end

function ObstacleMixin:OnDestroy()
    self:RemoveFromMesh()
end

function ObstacleMixin:AddToMesh()

   local position, radius, height = self:_GetPathingInfo()   
   self.obstacleId = Pathing.AddObstacle(position, radius, height)   
    if self.obstacleId ~= -1 then
        gAllObstacles[self] = true
    end
end

function ObstacleMixin:RemoveFromMesh()
    if self.obstacleId ~= -1 then    
        Pathing.RemoveObstacle(self.obstacleId)
        self.obstacleId = -1
        gAllObstacles[self] = nil
    end
end

function ObstacleMixin:GetObstacleId()
    return self.obstacleId
end

// TODO: Fix this mess!
function ObstacleMixin:_GetPathingInfo()
  local radius = 1.0
  local height = 2.0
  local position = self:GetOrigin()    
  local model = Shared.GetModel(self.modelIndex)  
  if (model ~= nil) then
    local min, max = model:GetExtents()        
    local extents = max
    radius = (extents.x + extents.z * 0.5) / 2
    height = extents.y;
  end
  
  position = position + Vector(0, -100, 0)
  
  if (self.GetPathingInfoOverride) then
    self:GetPathingInfoOverride(position, radius, height)
  end
  
  return position, radius, 1000
end
