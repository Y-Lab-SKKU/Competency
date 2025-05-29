
function [curr_trial_data, game_opt] = phase_iti(curr_trial_data, visual_opt, ...
                                        game_opt, eye_opt, device_opt, initial_ITI, phase_str)
% phase_iti - Handles the Inter-Trial Interval (ITI) phase of the game.
%
% Syntax:
%   [curr_trial_data, game_opt] = phase_iti(curr_trial_data, visual_opt, ...
%                                           game_opt, eye_opt, device_opt, ...
%                                           initial_ITI, phase_str)
%
% Inputs:
%   curr_trial_data - Struct containing current trial data.
%   visual_opt      - Struct containing visual options.
%   game_opt        - Struct containing game options.
%   eye_opt         - Struct containing eye-tracking options.
%   device_opt      - Struct containing device options.
%   initial_ITI     - Boolean indicating if it's the initial ITI.
%   phase_str       - String identifier for the current phase.
%
% Outputs:
%   curr_trial_data - Updated trial data struct (merged).
%   game_opt        - Updated game options struct (if modified).

    %% Initialization

    % Record the start time of the ITI phase in the current trial data
    curr_trial_data.(sprintf('%s', phase_str)).phase_start = GetSecs();
    
    % Create a blank screen with the specified screen color
    generate_color_blank(visual_opt, visual_opt.screen_color);
    
    % Setup timing variables for the ITI phase loop
    phase_onset = true;
    t_step = 0;
    num_steps = round(visual_opt.refresh_rate * game_opt.ITI_time);
    all_eye_data(num_steps) = struct('eyeX', [], 'eyeY', [], 'pupSize', []);
    
    
    if initial_ITI
         curr_trial_data = generate_eels_info(curr_trial_data, visual_opt, game_opt);
    end 
    
    %% Main ITI Loop
    while phase_onset
        loop_start_t = GetSecs();
        t_step = t_step + 1;
        
        % Sample eye data during the ITI phase
        eye_data = sample_eyes(eye_opt);
        all_eye_data(t_step).eyeX = eye_data.eyeX;
        all_eye_data(t_step).eyeY = eye_data.eyeY;
        all_eye_data(t_step).pupSize = eye_data.eyePupSz;
        
        % Enforce timing control based on the refresh rate and buffer time
        check_duration(loop_start_t, 1/visual_opt.refresh_rate - game_opt.buffer_t, device_opt.min_t_scale);
        
        % End the ITI phase once the allotted ITI time has elapsed
        if (GetSecs() - curr_trial_data.(sprintf('%s', phase_str)).phase_start) > game_opt.ITI_time
            phase_onset = false;
        end
    end

    %% Final Data Storage and Timing
    % Concatenate the position and eye data information
    curr_trial_data = concatenate_pos_data(curr_trial_data, -1, -1, -1, all_eye_data, -1, phase_str);
    
    % Record the end time of the ITI phase and calculate the duration
    curr_trial_data.(sprintf('%s', phase_str)).phase_end = GetSecs();
    curr_trial_data.(sprintf('%s', phase_str)).phase_duration = ...
        curr_trial_data.(sprintf('%s', phase_str)).phase_end  - curr_trial_data.(sprintf('%s', phase_str)).phase_start;
end
