function time_info = initialize_time_info(time_info)
    %INITIALIZE_TIME_INFO_STRUCT Initialize the time_info structure with default values.
    %   This function creates and returns a structure for storing timing 
    %   information for trials and ITI (Inter-Trial Interval).
    
    % Create an empty structure and initialize its fields
    time_info.trial_start_time = [];
    time_info.trial_end_time = [];
    time_info.ITI_start_time = [];
    time_info.ITI_end_time = [];
    time_info.frame_init_time = [];
    time_info.reward_start_time = [];
    time_info.reward_end_time = [];
    time_info.reward_duration = [];
end
