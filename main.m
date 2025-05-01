%% MAIN FILE

% This is the entry file for the experiment.
% Before running this script, please ensure that you have checked and configured 
% the 'init' function and the options: 'visual_opt', 'game_opt', and 'eye_opt'
% to make sure the parameters match your system.

[visual_opt, device_opt, game_opt, eye_opt, save_directory] = initalize();
 
% Define the break structure
trials_per_session = 150; % Number of trials before each break
total_trials = 300; % Total number of trials (from your task summary)
 
trial_onset = true;
 
%% (From Hyerin's Code)
time_info = struct(); 
time_info.exp_init_time = GetSecs;
all_trials = initialize_all_trials_info();
 
% Set up reliability mapping based on eel colors.
[game_opt, all_trials] = initialize_reliability(game_opt, all_trials, visual_opt);
 
%%
[prev_trial_idx] = get_last_saved_trial(save_directory);

% Initialize current_session based on prev_trial_idx
current_session = floor(prev_trial_idx / trials_per_session) + 1;
 
% Prompt user if ready
display_start_screen(visual_opt, device_opt);
 
while trial_onset && prev_trial_idx < total_trials
    %% Initialize info for the trial
    time_info = initialize_time_info(time_info);
    time_info.trial_init_time = GetSecs;
    
    curr_trial_data = struct();
    curr_trial_data.trial_idx = prev_trial_idx + 1;
    
    if curr_trial_data.trial_idx > 25 
       visual_opt.visualize_pot = false; % Visualize eel potentials
    end 
    
    % Run the trial phases
    [curr_trial_data, game_opt] = phase_iti(curr_trial_data, visual_opt, game_opt, eye_opt, device_opt, true, 'ITI1'); 
    curr_trial_data = phase_choice(curr_trial_data, visual_opt, game_opt, eye_opt, 'CHOICE', device_opt);
    
    if curr_trial_data.CHOICE.choice ~= -1 
        curr_trial_data = phase_pursuit(curr_trial_data, visual_opt, device_opt, game_opt, eye_opt, 'PURSUIT');
        [curr_trial_data, all_trials] = display_score_screen_human(curr_trial_data, visual_opt, game_opt, device_opt, all_trials);
        print_trial_summary(curr_trial_data.trial_idx, curr_trial_data, game_opt, save_directory);
 
    else
        display_gray_screen(visual_opt, game_opt);
    end
    
    
    % Print trial summary and save data
    full_file_path = fullfile(save_directory, ['trial_', num2str(curr_trial_data.trial_idx), '.mat']);
    save(full_file_path, 'curr_trial_data');
    
    prev_trial_idx = curr_trial_data.trial_idx;
    
    % Check if we need a break
    if mod(curr_trial_data.trial_idx, trials_per_session) == 0 && curr_trial_data.trial_idx < total_trials
        % We've completed a session, time for a break
        display_break_screen(visual_opt, device_opt, current_session, ceil(total_trials/trials_per_session));
        
        current_session = current_session + 1;
    end
end
% At the end of the experiment, after all trials are complete
display_end_screen(visual_opt);
 
 
if device_opt.EYELINK
    quit_eyelink();
end 
 
Screen('CloseAll');

% Function to get the last saved trial number
function [next_trial_idx] = get_last_saved_trial(save_directory)
    % Get all trial files in the directory
    files = dir(fullfile(save_directory, 'trial_*.mat'));
    
    if isempty(files)
        next_trial_idx = 0;
        return;
    end
    
    % Extract trial numbers from filenames
    trial_nums = zeros(length(files), 1);
    for i = 1:length(files)
        filename = files(i).name;
        trial_nums(i) = str2double(regexprep(filename, 'trial_|.mat', ''));
    end
    
    % Find the highest trial number
    last_trial_idx = max(trial_nums);
    
    % Next trial index is the last trial index
    next_trial_idx = last_trial_idx;
end
