
// Utility function for tutorial steps
function TutorialWait( secs )
    return
    {
        GetIsDone = function( self, tut )
            return tut.stepElapsedTime > secs
        end
    }
end

function GetAreAllDead( ids )

    local anyAlive = false
    for i,id in ipairs(ids) do
        local skulk = Shared.GetEntity(id)
        if skulk and skulk:GetIsAlive() then
            anyAlive = true
            break
        end
    end
    return not anyAlive

end

