function curr_trial_data = phase_report(curr_trial_data, visual_opt, game_opt, eye_opt, device_opt, phase_str, prev_choice, prev_eel_color)
    % PHASE_REPORT - Handles the reporting phase where participants report their belief about eel states
    %
    % Inputs:
    %   curr_trial_data - Struct containing current trial data
    %   visual_opt      - Struct containing visual options
    %   game_opt        - Struct containing game options
    %   eye_opt         - Struct containing eye-tracking options
    %   device_opt      - Struct containing device options
    %   phase_str       - String identifier for the current phase
    %   prev_choice     - Integer indicating previous choice (1=left, 2=right, -1=no choice)
    %   prev_eel_color  - RGB color array of the previously chosen eel
    %
    % Outputs:
    %   curr_trial_data - Updated trial data struct with reporting information

    % Create a substructure for the phase if it doesn't exist
    if ~isfield(curr_trial_data, phase_str)
        curr_trial_data.(phase_str) = struct();
        % Initialize all fields with explicit types and default values
        curr_trial_data.(phase_str).choice = -1;                    % Integer: -1 for no choice, 1-4 for state choice
        curr_trial_data.(phase_str).choice_side = '';              % String: 'left' or 'right'
        curr_trial_data.(phase_str).reported_competency = -1;      % Integer: 0 for low, 1 for high
        curr_trial_data.(phase_str).reported_reliability = -1;     % Integer: 0 for low, 1 for high
        curr_trial_data.(phase_str).reporting_on_left = false;     % Boolean: true if reporting on left eel
        curr_trial_data.(phase_str).corner_assignments = [];       % Array: mapping of states to corners
        curr_trial_data.(phase_str).random_rotation = 0;           % Float: random rotation angle in degrees
        curr_trial_data.(phase_str).state_positions = [];          % Array: [x,y] positions of each state
        curr_trial_data.(phase_str).target_eel_idx = -1;          % Integer: index of the eel being reported on
        curr_trial_data.(phase_str).target_eel_color = [];        % Array: RGB color of target eel
        curr_trial_data.(phase_str).target_eel_side = -1;         % Integer: 1 for left, 2 for right
        curr_trial_data.(phase_str).target_eel_reliability = -1;  % Float: actual reliability of target eel
        curr_trial_data.(phase_str).target_eel_competency = -1;   % Float: actual competency of target eel
        curr_trial_data.(phase_str).phase_start = 0;              % Float: phase start time
        curr_trial_data.(phase_str).phase_end = 0;                % Float: phase end time
        curr_trial_data.(phase_str).phase_duration = 0;           % Float: total phase duration
        curr_trial_data.(phase_str).choice_time = -1;             % Float: time when choice was made
        curr_trial_data.(phase_str).choice_position = [];         % Array: [x,y] position when choice was made
        curr_trial_data.(phase_str).all_avatar_pos = [];          % Array: all avatar positions during phase
        curr_trial_data.(phase_str).all_eye_data = [];            % Struct array: all eye tracking data
        curr_trial_data.(phase_str).all_joy_vec = [];            % Array: all joystick vectors during phase
        curr_trial_data.(phase_str).reporting_on_choice = -1;   % Integer: -1 for no choice, 1 for yes choice, 0 for random 
    end

    % Record phase start time
    curr_trial_data.(phase_str).phase_start = GetSecs();

    % Get eel information
    [~, ~, ~, ~, ~, ~, left_eel_color, right_eel_color, ~, ~] = ...
        check_eel_side_info(curr_trial_data, game_opt);

    % Determine which eel to report on based on previous choice
    report_left = true; % Default to left as fallback
    use_random_selection = false;
    
    % First, determine if we should randomly select an eel (25% chance)
    % even when there's a valid previous choice
    force_random = rand() < 0.25;
    
    % Check if previous choice and eel color are valid
    if nargin >= 7 && ~isempty(prev_eel_color) && prev_choice ~= -1
        if force_random
            % 25% chance: randomly select which eel to report on
            report_left = rand() < 0.5;
            use_random_selection = true;
        else
            % 75% chance: use the previous choice to determine eel
            % Calculate color similarity with both current eels
            left_color_diff = sum(abs(left_eel_color - prev_eel_color));
            right_color_diff = sum(abs(right_eel_color - prev_eel_color));
            
            % Match to the eel with the most similar color
            if left_color_diff < right_color_diff
                report_left = true;
            else
                report_left = false;
            end
            use_random_selection = false;
        end
    else
        % If no valid previous choice, randomly select which eel to report on (50/50 chance)
        report_left = rand() < 0.5;
        use_random_selection = true;
    end
    
    curr_trial_data.(phase_str).reporting_on_left = report_left;
    
    % Store whether reporting was based on choice or random
    if use_random_selection
        curr_trial_data.(phase_str).reporting_on_choice = 0; % 0 = random selection
    else
        curr_trial_data.(phase_str).reporting_on_choice = 1; % 1 = based on choice
    end
    
    % Store target eel information
    if report_left
        eel_color = left_eel_color;
        target_side = 1;  % Left
    else
        eel_color = right_eel_color;
        target_side = 2;  % Right
    end
    
    % Find and store target eel information
    for i = 1:length(curr_trial_data.eels)
        if curr_trial_data.eels(i).initial_side == target_side
            curr_trial_data.(phase_str).target_eel_idx = i;
            curr_trial_data.(phase_str).target_eel_color = curr_trial_data.eels(i).eel_col;
            curr_trial_data.(phase_str).target_eel_side = target_side;
            curr_trial_data.(phase_str).target_eel_reliability = curr_trial_data.eels(i).reliability;
            curr_trial_data.(phase_str).target_eel_competency = curr_trial_data.eels(i).competency;
            break;
        end
    end

    % Define visual states (reliability, competency)
    states = {
        [1, 1],  % High reliability, High competency
        [0, 1],  % Low reliability, High competency
        [1, 0],  % High reliability, Low competency
        [0, 0]   % Low reliability, Low competency
    };

    % Colors for text
    LABEL_COLOR = [120 120 120];          % Gray for the P/S labels
    HIGH_VALUE_COLOR = [0 150 255];       % Blue for high values (H)
    LOW_VALUE_COLOR = [255 150 0];        % Orange for low values (L)

    % Define a gray color for muting
    MUTE_GRAY = [128, 128, 128];  
    mute_factor = 0.6;

    % Muted eel colors
    left_eel_color_muted = left_eel_color * mute_factor + MUTE_GRAY * (1 - mute_factor);
    right_eel_color_muted = right_eel_color * mute_factor + MUTE_GRAY * (1 - mute_factor);

    % Randomly assign states to corners and store the mapping
    corner_assignments = randperm(4);
    curr_trial_data.(phase_str).corner_assignments = corner_assignments;

    % Calculate positions in a circle around the center
    center_x = visual_opt.wWth / 2;
    center_y = visual_opt.wHgt / 2;
    circle_radius = 200;  % Distance from center to options
    
    % Calculate base angles for equal spacing (90 degrees apart)
    base_angles = [0, 90, 180, 270];
    
    % Add random rotation to all angles and store it
    random_rotation = rand() * 360;  % Random rotation between 0 and 360 degrees
    curr_trial_data.(phase_str).random_rotation = random_rotation;
    angles = mod(base_angles + random_rotation, 360);
    
    % Convert angles to radians and calculate positions
    positions = zeros(4, 2);
    for i = 1:4
        angle_rad = deg2rad(angles(i));
        positions(i, 1) = center_x + circle_radius * cos(angle_rad);
        positions(i, 2) = center_y + circle_radius * sin(angle_rad);
    end
    curr_trial_data.(phase_str).state_positions = positions;

    % Initialize avatar position to screen center
    avtr_pos = [center_x, center_y];
    choice_onset = true;

    % Calculate total number of time steps
    num_steps = round(visual_opt.refresh_rate * game_opt.report_time);
    all_avatar_pos = -1 * ones(num_steps, 2);
    all_eye_data(num_steps) = struct('eyeX', [], 'eyeY', [], 'pupSize', []);
    all_joy_vec = zeros(num_steps, 2);

    % Initialize step counter
    t_step = 1;

    % Define box size for collision detection
    box_size = 120;  % Size of the choice boxes
    box_padding = 10;  % Padding between elements
    
    % Save current text size and set new sizes
    oldTextSize = Screen('TextSize', visual_opt.winPtr);
    
    % Cell spacing for the grid-like layout
    cell_spacing = 30;  % Space between cells in the grid

    while choice_onset
        loop_start_t = GetSecs();

        % Draw the eel cue circle in the center
        cue_radius = 50;
        cue_rect = [center_x - cue_radius, center_y - cue_radius, ...
                   center_x + cue_radius, center_y + cue_radius];
        Screen('FillOval', visual_opt.winPtr, eel_color, cue_rect);

        % Draw the four state options around the circle
        for i = 1:4
            % Calculate box rectangle centered on the circle position
            box_rect = [positions(i,1) - box_size/2, positions(i,2) - box_size/2, ...
                       positions(i,1) + box_size/2, positions(i,2) + box_size/2];
            
            % Draw box with eel color border
            Screen('FrameRect', visual_opt.winPtr, eel_color, box_rect, 2);
            
            % Get the state for this position
            state = states{corner_assignments(i)};
            reliability = state(1);
            competency = state(2);
            
            % Calculate grid positions
            grid_center_x = positions(i,1);
            grid_center_y = positions(i,2);
            
            % Left column (P - Reliability)
            p_label_x = grid_center_x - cell_spacing;
            p_label_y = grid_center_y - cell_spacing/2;
            p_value_x = p_label_x;
            p_value_y = grid_center_y + cell_spacing/2;
            
            % Right column (S - Competency)
            s_label_x = grid_center_x + cell_spacing;
            s_label_y = grid_center_y - cell_spacing/2;
            s_value_x = s_label_x;
            s_value_y = grid_center_y + cell_spacing/2;
            
            % Set small font size for labels
            Screen('TextSize', visual_opt.winPtr, 20);
            
            % Draw "Prob" label (for reliability)
            DrawFormattedText(visual_opt.winPtr, 'Prob', p_label_x-7, p_label_y, LABEL_COLOR, [], [], [], [], [], []);
            
            % Draw "Speed" label (for competency)
            DrawFormattedText(visual_opt.winPtr, 'Speed', s_label_x-7, s_label_y, LABEL_COLOR, [], [], [], [], [], []);
            
            % Set larger font size for values
            Screen('TextSize', visual_opt.winPtr, 30);
            
            % Draw reliability value
            if reliability == 1
                % High reliability - 'H' in blue
                rel_letter = 'H';
                rel_color = HIGH_VALUE_COLOR;
            else
                % Low reliability - 'L' in orange
                rel_letter = 'L';
                rel_color = LOW_VALUE_COLOR;
            end
            DrawFormattedText(visual_opt.winPtr, rel_letter, p_value_x-10, p_value_y, rel_color, [], [], [], [], [], []);
            
            % Draw competency value
            if competency == 1
                % High competency - 'S' in blue
                comp_letter = 'F';
                comp_color = HIGH_VALUE_COLOR;
            else
                % Low competency - 'L' in orange
                comp_letter = 'S';
                comp_color = LOW_VALUE_COLOR;
            end
            DrawFormattedText(visual_opt.winPtr, comp_letter, s_value_x-10, s_value_y, comp_color, [], [], [], [], [], []);

            % Check for collision between avatar and this box
            if choice_onset  % Only check if we haven't made a choice yet
                if check_box_collision(avtr_pos, game_opt.avatar_sz, box_rect)
                    % Get the state that was assigned to this position
                    chosen_state = corner_assignments(i);
                    state = states{chosen_state};
                    
                    % Record the choice and additional metadata
                    curr_trial_data.(phase_str).choice = chosen_state;
                    curr_trial_data.(phase_str).choice_time = GetSecs();
                    curr_trial_data.(phase_str).choice_position = avtr_pos;
                    
                    if report_left
                        curr_trial_data.(phase_str).choice_side = 'left';
                    else
                        curr_trial_data.(phase_str).choice_side = 'right';
                    end
                    curr_trial_data.(phase_str).reported_competency = 1 - state(2); % Inverted: L speed means High competency, H speed means Low competency
                    curr_trial_data.(phase_str).reported_reliability = state(1);
                    
                    choice_onset = false;
                    break;
                end
            end
        end

        % Draw avatar
        draw_avatar(avtr_pos, visual_opt.choice_color_avtr, game_opt.avatar_sz, visual_opt.winPtr);

        % Flip screen
        Screen('Flip', visual_opt.winPtr);

        % Sample and store eye data
        eye_data = sample_eyes(eye_opt);
        all_eye_data(t_step).eyeX = eye_data.eyeX;
        all_eye_data(t_step).eyeY = eye_data.eyeY;
        all_eye_data(t_step).pupSize = eye_data.eyePupSz;

        % Update position based on input
        [avtr_pos, joy_vec] = update_pos_avatar(avtr_pos, device_opt, game_opt.avatar_speed, ...
            visual_opt, game_opt, true);

        % Store position and joystick vector
        all_avatar_pos(t_step, :) = avtr_pos;
        all_joy_vec(t_step, :) = joy_vec;

        % Timing control
        check_duration(loop_start_t, 1/visual_opt.refresh_rate, device_opt.min_t_scale);

        % Update step and check time limit
        t_step = t_step + 1;
        if GetSecs() - curr_trial_data.(phase_str).phase_start > game_opt.report_time
            choice_onset = false;
        end
    end

    % Restore the original text size
    Screen('TextSize', visual_opt.winPtr, oldTextSize);

    % Update final data
    curr_trial_data = concatenate_pos_data(curr_trial_data, all_avatar_pos(1:t_step-1, :), ...
        -1, -1, all_eye_data(1:t_step-1), all_joy_vec(1:t_step-1, :), phase_str);

    % Save end time and duration
    curr_trial_data.(phase_str).phase_end = GetSecs();
    curr_trial_data.(phase_str).phase_duration = ...
        curr_trial_data.(phase_str).phase_end - curr_trial_data.(phase_str).phase_start;
end 