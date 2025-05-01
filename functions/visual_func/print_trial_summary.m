function print_trial_summary(trial_num, data, game_opt, save_directory)
    % Print a formatted summary of the trial results using colored output and save to log file
    %
    % Parameters:
    %   trial_num - The trial number
    %   data - Trial data structure
    %   game_opt - Game options structure
    %   save_directory - Directory where log file should be saved (optional)
    %
    % Note: This function requires the third-party function cprintf.
    
    % Get the right and left eels info
    [left_eel_curr_pos, right_eel_curr_pos, ...
        left_eel_original_competency, right_eel_original_competency, ...
        left_eel_original_potent, right_eel_original_potent, ...
        left_eel_color, right_eel_color, ...
        left_eel_rely, right_eel_rely] = ...
        check_eel_side_info(data, game_opt);
 
    % Define separator for visibility
    separator = '--------------------------------------------------------------------------------';
    
    % Retrieve reward information
    reward_str = 'N/A';
    if isfield(data, 'reward_info')
        reward_probability = data.reward_info.probability_this_trial;
        left_reward = data.reward_info.left_reward_this_trial;
        right_reward = data.reward_info.right_reward_this_trial;
        if data.reward_info.reward_given
            reward_str = 'Yes';
        else
            reward_str = 'No';
        end
    else
        reward_probability = NaN;
        left_reward = NaN;
        right_reward = NaN;
    end
    
    % Calculate total fish caught
    total_fish = data.PURSUIT.left_fish_caught + data.PURSUIT.right_fish_caught;
    
    % Determine eel color names for better display
    left_eel_color_name = get_eel_color_name(left_eel_color);
    right_eel_color_name = get_eel_color_name(right_eel_color);
    
    % Use fixed color strings that are compatible with cprintf
    % This prevents the color mixing issues
    if strcmp(left_eel_color_name, 'Blue')
        left_eel_cprintf_color = 'blue';
    elseif strcmp(left_eel_color_name, 'Purple')
        left_eel_cprintf_color = 'magenta'; % Use magenta for purple in cprintf
    else
        left_eel_cprintf_color = 'text'; % Default to normal text
    end
    
    if strcmp(right_eel_color_name, 'Blue')
        right_eel_cprintf_color = 'blue';
    elseif strcmp(right_eel_color_name, 'Purple')
        right_eel_cprintf_color = 'magenta'; % Use magenta for purple in cprintf
    else
        right_eel_cprintf_color = 'text'; % Default to normal text
    end
 
    % Print summary using cprintf
    cprintf('text', '\n%s\n', separator);
    cprintf('text', 'Trial: %2d\n', trial_num);
    
    % Print information about the left eel
    cprintf('text', '| Left Eel (');
    cprintf(left_eel_cprintf_color, '%s', left_eel_color_name);
    cprintf('text', '): ');
    cprintf('text', 'Reliability: ');
    cprintf(left_eel_cprintf_color, '%.2f', left_eel_rely);
    cprintf('text', ' | Competency: ');
    cprintf(left_eel_cprintf_color, '%.2f', left_eel_original_competency);
    cprintf('text', ' | Fish Caught: ');
    cprintf(left_eel_cprintf_color, '%d', data.PURSUIT.left_fish_caught);
    cprintf('text', ' | Reward Contribution: ');
    cprintf(left_eel_cprintf_color, '%.2f', left_reward);
    
    % Print information about the right eel
    cprintf('text', '\n| Right Eel (');
    cprintf(right_eel_cprintf_color, '%s', right_eel_color_name);
    cprintf('text', '): ');
    cprintf('text', 'Reliability: ');
    cprintf(right_eel_cprintf_color, '%.2f', right_eel_rely);
    cprintf('text', ' | Competency: ');
    cprintf(right_eel_cprintf_color, '%.2f', right_eel_original_competency);
    cprintf('text', ' | Fish Caught: ');
    cprintf(right_eel_cprintf_color, '%d', data.PURSUIT.right_fish_caught);
    cprintf('text', ' | Reward Contribution: ');
    cprintf(right_eel_cprintf_color, '%.2f', right_reward);
    
    % Print total reward information
    cprintf('text', '\n| Total Fish Caught: ');
    cprintf('green', '%d', total_fish);
    cprintf('text', ' | Total Reward Probability: ');
    cprintf('green', '%.2f', reward_probability);
    cprintf('text', ' | Rewarded: ');
    if strcmp(reward_str, 'Yes')
        cprintf('green', '%s', reward_str);
    else
        cprintf('red', '%s', reward_str);
    end
    
    cprintf('text', '\n%s\n', separator);
    
    % If save_directory is provided, write the log to a file
    if nargin >= 4 && ~isempty(save_directory)
        % Create the directory if it doesn't exist
        if ~exist(save_directory, 'dir')
            mkdir(save_directory);
        end
        
        % Create a log file with timestamp in the filename
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        log_filename = fullfile(save_directory, sprintf('trial_log_%s.txt', timestamp));
        
        % Check if the log file exists for this session
        session_log = fullfile(save_directory, 'session_log.txt');
        file_exists = exist(session_log, 'file');
        
        % Open the file in append mode
        fid = fopen(session_log, 'a');
        
        % Write header if this is a new file
        if ~file_exists
            fprintf(fid, 'TRIAL SUMMARY LOG\n');
            fprintf(fid, 'Created: %s\n\n', datestr(now));
        end
        
        % Write trial information to log file without color formatting
        fprintf(fid, '\n%s\n', separator);
        fprintf(fid, 'Trial: %2d\n', trial_num);
        
        fprintf(fid, '| Left Eel (%s): ', left_eel_color_name);
        fprintf(fid, 'Reliability: %.2f', left_eel_rely);
        fprintf(fid, ' | Competency: %.2f', left_eel_original_competency);
        fprintf(fid, ' | Fish Caught: %d', data.PURSUIT.left_fish_caught);
        fprintf(fid, ' | Reward Contribution: %.2f\n', left_reward);
        
        fprintf(fid, '| Right Eel (%s): ', right_eel_color_name);
        fprintf(fid, 'Reliability: %.2f', right_eel_rely);
        fprintf(fid, ' | Competency: %.2f', right_eel_original_competency);
        fprintf(fid, ' | Fish Caught: %d', data.PURSUIT.right_fish_caught);
        fprintf(fid, ' | Reward Contribution: %.2f\n', right_reward);
        
        fprintf(fid, '| Total Fish Caught: %d', total_fish);
        fprintf(fid, ' | Total Reward Probability: %.2f', reward_probability);
        fprintf(fid, ' | Rewarded: %s\n', reward_str);
        
        fprintf(fid, '%s\n', separator);
        
        % Close the log file
        fclose(fid);
        
        % Display confirmation message
        cprintf('text', 'Log saved to: %s\n', session_log);
    end
end

% Helper function to determine eel color name
function color_name = get_eel_color_name(rgb_color)
    % Identify eel color based on exact RGB values
    % The experiment only has two eel colors:
    % - Blue: [0, 0, 255]
    % - Purple: [157, 0, 255]
    
    % Round the RGB values for more reliable comparison
    rgb_rounded = round(rgb_color);
    
    % Check if it matches blue eel color [0, 0, 255]
    if rgb_rounded(1) == 0 && rgb_rounded(2) == 0 && rgb_rounded(3) == 255
        color_name = 'Blue';
    % Check if it matches purple eel color [157, 0, 255]
    elseif rgb_rounded(1) == 157 && rgb_rounded(2) == 0 && rgb_rounded(3) == 255
        color_name = 'Purple';
    else
        % Fallback for other colors (should not occur in normal operation)
        color_name = sprintf('RGB:[%d,%d,%d]', rgb_rounded(1), rgb_rounded(2), rgb_rounded(3));
    end
end