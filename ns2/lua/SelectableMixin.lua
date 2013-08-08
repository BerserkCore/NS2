// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\SelectableMixin.lua    
//    
//    Created by:   Brian Cronin (brianc@unknownworlds.com)    
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/FunctionContracts.lua")

/**
 * SelectableMixin marks entities as selectable to a commander.
 */
SelectableMixin = CreateMixin( SelectableMixin )
SelectableMixin.type = "Selectable"

SelectableMixin.optionalCallbacks =
{
    OnGetIsSelectable = "Returns if this entity is selectable or not"
}

function SelectableMixin:GetIsSelectable(byPlayer)

    if self.GetIsAlwaysSelectAbleBy then
        return self:GetIsAlwaysSelectAbleBy(byPlayer)
    end

    local isValid = true
    
    if self.OnGetIsSelectable then
    
        // A table is passed in so that all the OnGetIsSelectable functions
        // have a say in the matter.
        local resultTable = { selectable = true }
        self:OnGetIsSelectable(resultTable, byPlayer)
        isValid = resultTable.selectable
        
    end
    
    return isValid and HasMixin(self, "Team") and self:GetTeamNumber() == byPlayer:GetTeamNumber()
    
end
AddFunctionContract(SelectableMixin.GetIsSelectable, { Arguments = { "Entity", "Player" }, Returns = { "boolean" } })