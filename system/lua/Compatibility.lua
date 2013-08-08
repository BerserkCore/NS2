// This function contains wrappers to provide backwards compatibility for when the Engine API
// changes

// Removed in 234 since this function had no effect
if Client then
    local reported = false
	function Client.SetEnableFog(fog)
	    if not reported then
	        Shared.Message("Client.SetEnableFog function no longer exists (had no effect). Called from:")
	        Shared.Message(Script.CallStack())
	        reported = true
	    end
	end
end	