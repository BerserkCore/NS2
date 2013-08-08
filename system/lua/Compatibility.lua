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

// Removed in 236 because they break the abstaction with the sound system implementation.
// No implementation is possible for these functions, however they were not currently in
// use when they were removed.
if Client then
    local reported = false
    function Client.SetSoundPropertyFloat() 
	    if not reported then
	        Shared.Message("Client.SetSoundPropertyFloat function no longer exists. Called from:")
	        Shared.Message(Script.CallStack())
	        reported = true
	    end
	end
end
if Client then
    local reported = false
    function Client.SetSoundPropertyInt() 
	    if not reported then
	        Shared.Message("Client.SetSoundPropertyInt function no longer exists. Called from:")
	        Shared.Message(Script.CallStack())
	        reported = true
	    end
	end
end


// Removed in 236 because they break the abstaction with the sound system implementation
if Client then

    local kFmodVolumePropertyIndex      = 1
    local kFmodPitchPropertyIndex       = 4   
    local kFmodRolloffPropertyIndex     = 16
    local kFmodMinDistancePropertyIndex = 17
    local kFmodMaxDistancePropertyIndex = 18
    local kFmodPositioningPropertyIndex = 19
    
    local kFmodWorldRelative            = 524288
    local kFmodHeadRelative             = 262144
    
    local kFmodLogarithmicRolloff       = 1048576
    local kFmodLinearRolloff            = 2097152
    local kFmodCustomRolloff            = 67108864
    
    do
        local reported = false
        function SoundEventInstance:SetPropertyFloat(propertyIndex, value, thisInstance)
            
            if not reported then
	            Shared.Message("SoundEventInstance:SetPropertyFloat function no longer exists. Called from:")
	            Shared.Message(Script.CallStack())
	            reported = true
	        end
	        
            if propertyIndex == kFmodVolumePropertyIndex then
                self:SetVolume(value)
            elseif properyIndex == kFmodPitchPropertyIndex then
                self:SetPitch(value)
            elseif propertyIndex == kFmodMinDistancePropertyIndex then
                self:SetMinDistance(value)
            elseif propertyIndex == kFmodMaxDistancePropertyIndex then
                self:SetMaxDistance(value)
            end
            
        end
    end    
    
    do
        local reported = false
        function SoundEventInstance:SetPropertyInt(propertyIndex, value, thisInstance)
        
            if not reported then
	            Shared.Message("SoundEventInstance:SetPropertyInt function no longer exists. Called from:")
	            Shared.Message(Script.CallStack())
	            reported = true
	        end
        
            if propertyIndex == kFmodPositioningPropertyIndex then
                self:SetPositional(value == kFmodWorldRelative)
            elseif propertyIndex == kFmodRolloffPropertyIndex then
                if value == kFmodLogarithmicRolloff then
                    self:SetRolloff(SoundSystem.Rolloff_Logarithmic)
                elseif value == kFmodLinearRolloff then
                    self:SetRolloff(SoundSystem.Rolloff_Linear)
                else
                    self:SetRolloff(SoundSystem.Rolloff_Custom)
                end
            end
            
        end
    end
    
end

// Removed in 238 because it requires the entire level to be kept in memory
if Client then
    local reported = false
    function Client.LoadSoundGeometry() 
	    if not reported then
	        Shared.Message("Client.LoadSoundGeometry function no longer exists. Called from:")
	        Shared.Message(Script.CallStack())
	        reported = true
	    end
	end
end