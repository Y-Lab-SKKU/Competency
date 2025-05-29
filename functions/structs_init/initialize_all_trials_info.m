function [all_trials_info] = initialize_all_trials_info()
    %INITIALIZE_TRAILS_STRUCT Initialize the trials structure with default values.
    %   This function initializes the trials structure and returns it along 
    %   with the second input argument.
   
    
    % Initialize the trials structure with necessary fields
    all_trials_info = struct();
    all_trials_info.current_trial = 1; % Current trial number
    all_trials_info.all_trials_water = 0;
    all_trials_info.current_trial_water = 0; % Initialize reward amount
    all_trials_info.max_trial_num = 1500; % Maximum number of trials.
    
    all_trials_info.total_actual_reward = 0;
    all_trials_info.total_expected_reward = 0;
    
    % Frame counts 
    all_trials_info.itis_frame_cnt = [0,0,0];
    all_trials_info.passives_frame_cnt = [0,0]; 
    all_trials_info.choice_frame_cnt=[0];
    all_trials_info.pursuit_frame_cnt=[0];
    
    all_trials_info.reliability_swaps = [];
end

