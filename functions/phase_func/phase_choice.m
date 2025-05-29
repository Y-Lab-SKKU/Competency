function curr_trial_data = phase_choice(curr_trial_data, visual_opt, game_opt, eye_opt, phase_str, device_opt)
    % PHASE_CHOICE - Handles the choice phase of the game/experiment
    
        % Create a substructure for the phase if it doesn't exist
    if ~isfield(curr_trial_data, phase_str)
        curr_trial_data.(phase_str) = struct();
        curr_trial_data.(phase_str).choice = -1;
    end
    
    curr_trial_data.(phase_str).phase_start = GetSecs();

    % Initialize avatar position to screen center
    avtr_pos = [visual_opt.wWth / 2, visual_opt.coordinate_window];
    choice_onset = true;
    
    % Calculate total number of time steps
    num_steps = round(visual_opt.refresh_rate * game_opt.choice_time);
    all_avatar_pos = -1 * ones(num_steps, 2);
    all_eye_data(num_steps) = struct('eyeX', [], 'eyeY', [], 'pupSize', []);
    all_joy_vec = zeros(num_steps, 2);
    
    % Initialize choice
    t_step = 1;
    
 

    while choice_onset
        loop_start_t = GetSecs();
        
        % Draw environment
        draw_avatar(avtr_pos, visual_opt.choice_color_avtr, game_opt.avatar_sz, visual_opt.winPtr);

        draw_monkey_choice_guide(visual_opt, game_opt, curr_trial_data);
        draw_corridor(visual_opt);
        
        Screen('Flip', visual_opt.winPtr);
    
        % Sample and store eye data
        eye_data = sample_eyes(eye_opt);
        all_eye_data(t_step).eyeX = eye_data.eyeX;
        all_eye_data(t_step).eyeY = eye_data.eyeY;
        all_eye_data(t_step).pupilSize = eye_data.eyePupSz;
    
        % Update position based on input
        [avtr_pos, joy_vec] = update_pos_avatar(avtr_pos, device_opt, game_opt.avatar_speed, ...
            visual_opt, game_opt);
    
        % Store position and joystick vector
        all_avatar_pos(t_step, :) = avtr_pos;
        all_joy_vec(t_step, :) = joy_vec;
    
        % Check for choice based on position
        if avtr_pos(1) < visual_opt.corridor_coord(1, 1)
            % TODO: if labjack is on, send pulse (add it to all functs after
    
            curr_trial_data.(phase_str).choice_side = 'left';
            curr_trial_data.(phase_str).choice = 1;
            choice_onset = false;
        elseif avtr_pos(1) > visual_opt.corridor_coord(3, 1)
            % TODO: if labjack is on, send pulse (add it to all functs after
            % loop_start_t
            curr_trial_data.(phase_str).choice_side  = 'right';
            curr_trial_data.(phase_str).choice  = 2;
            choice_onset = false;
        end
    
        check_duration(loop_start_t, 1/visual_opt.refresh_rate, device_opt.min_t_scale);
    
        % Update step and check time limit
        t_step = t_step + 1;
        if GetSecs() - curr_trial_data.(phase_str).phase_start > game_opt.choice_time
            choice_onset = false;
        end
    end
    
    
    
    % Update final data
    curr_trial_data = concatenate_pos_data(curr_trial_data, all_avatar_pos(1:t_step-1, :), ...
        -1, -1, all_eye_data(1:t_step-1), all_joy_vec(1:t_step-1, :), phase_str);
    
    % save end time
    curr_trial_data.(phase_str).phase_end = GetSecs();
    
    % save total time
    curr_trial_data.(phase_str).phase_duration = ...
        curr_trial_data.(phase_str).phase_end - curr_trial_data.(phase_str).phase_start;
end