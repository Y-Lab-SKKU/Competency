function curr_trial_data = phase_pursuit(curr_trial_data, visual_opt, ...
    device_opt, game_opt, eye_opt, phase_str)
    % Add explicit timing parameters
    game_opt.initial_side_time = game_opt.pursuit_time;  % Initial time allowed

    % Create a substructure for the phase if it doesn't exist
    if ~isfield(curr_trial_data, phase_str)
        curr_trial_data.(phase_str) = struct();
    end

    curr_trial_data.(phase_str).phase_start = GetSecs();
    curr_trial_data.(phase_str).side_switch_frames = [];  % Initialize list for side switch frames
    curr_trial_data.switched = true;
    %% STEP 1. Initialize
    % Initialize avatar position in the center
    initial_x_pos = visual_opt.wWth / 2;
    
    % Apply boost based on choice (0=left, 1=right)

    if curr_trial_data.CHOICE.choice == 1  % Left side chosen
        initial_x_pos = initial_x_pos - game_opt.boost_pxls;
    elseif curr_trial_data.CHOICE.choice == 2  % Right side chosen
        initial_x_pos = initial_x_pos + game_opt.boost_pxls;
    end

    
    % Set avatar position with the boosted x coordinate
    avtr_curr_pos = [initial_x_pos, visual_opt.coordinate_window];

    % Get the right and left eels info
    [left_eel_curr_pos, right_eel_curr_pos, ...
          left_eel_competency, right_eel_competency, ...
          left_eel_original_potent, right_eel_original_potent, ...
          left_eel_color, right_eel_color, ...
          left_eel_rely, right_eel_rely] = ...
          check_eel_side_info(curr_trial_data, game_opt);

    % Generate initial fish positions for both sides
    left_fish_curr_pos = generate_fish_locs(left_eel_curr_pos, game_opt);
    right_fish_curr_pos = generate_fish_locs(right_eel_curr_pos, game_opt);

    % Initialize previous fish positions
    left_fish_prev_pos = left_fish_curr_pos;
    right_fish_prev_pos = right_fish_curr_pos;

    % Initialize counters for caught fish
    curr_trial_data.(phase_str).left_fish_caught = 0;
    curr_trial_data.(phase_str).right_fish_caught = 0;

    choice_onset = true;
    t_step = 1;

    % Calculate the total number of time steps
    num_steps = round(visual_opt.refresh_rate * (game_opt.pursuit_time));

    all_right_eel_pos = nan * ones(num_steps, 2);
    all_left_eel_pos = nan * ones(num_steps, 2);
    all_right_fish_pos = nan * ones(num_steps, game_opt.n_fishes, 2); 
    all_left_fish_pos = nan * ones(num_steps, game_opt.n_fishes, 2); 
    all_avatar_pos = nan * ones(num_steps, 2);

    all_eye_data(num_steps) = struct('eyeX', [], 'eyeY', [], 'pupSize', []);

    % Initialize caught fish animation data
    caught_fish_data = struct('positions', [], 'frames_remaining', [], 'frame_caught', []);

    current_allowed_time = game_opt.initial_side_time;

    % Variable to track the previous valid side (1 = LEFT, 2 = RIGHT)
    prev_valid_side = [];

    while choice_onset
        current_time = GetSecs();
        elapsed_time = current_time - curr_trial_data.(phase_str).phase_start;
        loop_start_t = current_time;

        % Sample eye data
        eye_data = sample_eyes(eye_opt);
        all_eye_data(t_step).eyeX = eye_data.eyeX;
        all_eye_data(t_step).eyeY = eye_data.eyeY;
        all_eye_data(t_step).pupSize = eye_data.eyePupSz;

        % Update avatar position
        avtr_future_pos = update_pos_avatar(avtr_curr_pos, device_opt, game_opt.avatar_speed, visual_opt, game_opt);

        % Determine current side (1 = LEFT, 2 = RIGHT, other = center)
        side = check_avatar_side(avtr_future_pos(1), visual_opt, game_opt);

        % Record a switch only when moving between valid sides (ignore center)
        if side == 1 || side == 2
            if isempty(prev_valid_side)
                prev_valid_side = side;
            elseif side ~= prev_valid_side
                % Append the frame number when a side switch occurs
                curr_trial_data.(phase_str).side_switch_frames(end+1) = t_step;
                curr_trial_data.switched = true;

                prev_valid_side = side;
            end
        end

        % Handle movement and drawing based on current side
        if side == 1 % LEFT SIDE 
            % Move eels and fish on left side
            [left_eel_future_pos, game_opt] = move_eel(left_eel_curr_pos, left_fish_curr_pos, game_opt, visual_opt);

            left_fish_future_pos = move_fishes(left_fish_curr_pos, left_fish_prev_pos, left_eel_future_pos, ...
                avtr_future_pos, visual_opt, left_eel_original_potent, game_opt, left_eel_competency);

            % Check for caught fish
            [left_fish_future_pos, new_caught, caught_fish_data] = check_catch(left_fish_future_pos, ...
                avtr_curr_pos, game_opt, caught_fish_data, t_step, visual_opt);

            % Only add new caught fish if it won't exceed the total limit of 3
            remaining_catches = 3 - (curr_trial_data.(phase_str).left_fish_caught + curr_trial_data.(phase_str).right_fish_caught);
            new_caught = min(new_caught, remaining_catches);
            curr_trial_data.(phase_str).left_fish_caught = curr_trial_data.(phase_str).left_fish_caught + new_caught;

            % Draw scene for left side
            draw_scene(avtr_curr_pos, left_eel_future_pos, left_fish_future_pos, ...
                visual_opt, game_opt, side, curr_trial_data, left_eel_original_potent, loop_start_t, caught_fish_data, phase_str, left_eel_color);

            % Save positions
            all_left_fish_pos(t_step, :, :) = left_fish_future_pos;
            all_left_eel_pos(t_step, :) = left_eel_future_pos;

            % Update positions
            left_fish_prev_pos = left_fish_curr_pos;
            left_eel_curr_pos = left_eel_future_pos;
            left_fish_curr_pos = left_fish_future_pos;

        elseif side == 2 % RIGHT SIDE 
            % Move eels and fish on right side
            [right_eel_future_pos, game_opt] = move_eel(right_eel_curr_pos, right_fish_curr_pos, game_opt, visual_opt);

            right_fish_future_pos = move_fishes(right_fish_curr_pos, right_fish_prev_pos, right_eel_future_pos, ...
                avtr_future_pos, visual_opt, right_eel_original_potent, game_opt, right_eel_competency);

            % Check for caught fish
            [right_fish_future_pos, new_caught, caught_fish_data] = check_catch(right_fish_future_pos, ...
                avtr_curr_pos, game_opt, caught_fish_data, t_step, visual_opt);

            % Only add new caught fish if it won't exceed the total limit of 3
            remaining_catches = 3 - (curr_trial_data.(phase_str).left_fish_caught + curr_trial_data.(phase_str).right_fish_caught);
            new_caught = min(new_caught, remaining_catches);
            curr_trial_data.(phase_str).right_fish_caught = curr_trial_data.(phase_str).right_fish_caught + new_caught;

            % Draw scene for right side
            draw_scene(avtr_curr_pos, right_eel_future_pos, right_fish_future_pos, ...
                visual_opt, game_opt, side, curr_trial_data, right_eel_original_potent, loop_start_t, caught_fish_data, phase_str, right_eel_color);

            % Save positions
            all_right_fish_pos(t_step, :, :) = right_fish_future_pos;
            all_right_eel_pos(t_step, :) = right_eel_future_pos;

            % Update positions
            right_fish_prev_pos = right_fish_curr_pos;
            right_eel_curr_pos = right_eel_future_pos;
            right_fish_curr_pos = right_fish_future_pos;
        else
            % Draw scene for middle corridor (center) - do not record as a side switch
            draw_scene(avtr_curr_pos, [], [], visual_opt, game_opt, side, curr_trial_data, [], loop_start_t, [], phase_str, []);
        end

        % Save avatar position and update for next iteration
        all_avatar_pos(t_step, :) = avtr_future_pos;
        avtr_curr_pos = avtr_future_pos;

        % Timing control
        check_duration(loop_start_t, 1/visual_opt.refresh_rate - game_opt.buffer_t, device_opt.min_t_scale);

        % Check end conditions
        if elapsed_time >= current_allowed_time || ...
           (curr_trial_data.(phase_str).left_fish_caught + curr_trial_data.(phase_str).right_fish_caught >= game_opt.n_fish_to_catch)
            choice_onset = false;
        end

        % Update step counter and ensure we do not exceed preallocated size
        t_step = t_step + 1;
        if t_step > num_steps
            break;
        end
    end

    % Create structures to hold all positions
    all_eels_pos = struct('left', all_left_eel_pos(1:t_step-1, :), ...
                          'right', all_right_eel_pos(1:t_step-1, :));

    % For fish positions, if only one fish exists, use squeeze to remove the singleton dimension.
    if game_opt.n_fishes == 1
        all_fish_pos = struct('left', squeeze(all_left_fish_pos(1:t_step-1, :, :)), ...
                              'right', squeeze(all_right_fish_pos(1:t_step-1, :, :)));
    else
        all_fish_pos = struct('left', all_left_fish_pos(1:t_step-1, :, :), ...
                              'right', all_right_fish_pos(1:t_step-1, :, :));
    end

    % Store all position data
    curr_trial_data = concatenate_pos_data(curr_trial_data, all_avatar_pos(1:t_step-1, :), ...
        all_eels_pos, all_fish_pos, all_eye_data(1:t_step-1), phase_str);

    % Store phase timing
    curr_trial_data.(phase_str).phase_end = GetSecs();
    curr_trial_data.(phase_str).phase_duration = ...
        curr_trial_data.(phase_str).phase_end - curr_trial_data.(phase_str).phase_start;
end