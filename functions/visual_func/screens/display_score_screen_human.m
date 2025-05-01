function [data, all_trials] = display_score_screen_human(data, visual_opt, game_opt, device_opt, all_trials)
    % Start timing for the score phase
    phase_str = 'score';
    data.(phase_str).phase_start = GetSecs();

    % Calculate unused pursuit time
    time = game_opt.pursuit_time - data.PURSUIT.phase_duration;

    % Define screen color (grey background)
    SCREEN_COLOR = visual_opt.screen_color ;

    % Clear the screen
    Screen('FillRect', visual_opt.winPtr, SCREEN_COLOR);

    % Calculate total fish caught
    left_fish_count = data.PURSUIT.left_fish_caught;
    right_fish_count = data.PURSUIT.right_fish_caught;
    fraction_remaining = time / game_opt.pursuit_time;

    % Get eel info
    [~, ~, ~, ~, ~, ~, left_eel_color, right_eel_color, left_eel_rely, right_eel_rely] = ...
        check_eel_side_info(data, game_opt);
    
    % Updated reward calculation - multiply fish count by reliability value directly
    % No more baseline + interval, just fish_count * reliability_percentage
    left_reward = left_fish_count * left_eel_rely;
    right_reward = right_fish_count * right_eel_rely;

    reward_probability = min(left_reward + right_reward, 1);
    
    % Store reward info in a structured format
    data.reward_info = struct();
    data.reward_info.left_reward_this_trial = left_reward;
    data.reward_info.right_reward_this_trial = right_reward;
    data.reward_info.probability_this_trial = reward_probability;
    data.rand_num_generated =  rand();
    disp(data.rand_num_generated);
    data.reward_info.reward_given = data.rand_num_generated < reward_probability;
    
    % Compute actual and expected rewards
    actual_reward = game_opt.reward_value * data.reward_info.reward_given;
    all_trials.total_actual_reward = all_trials.total_actual_reward + actual_reward;

    data.current_trial_reward = actual_reward;
    data.current_trial_expected_reward = game_opt.reward_value;
    data.cumulative_trial_reward = all_trials.total_actual_reward;
    
    % Define a gray color for muting
    MUTE_GRAY = [128, 128, 128];  
    mute_factor = 0.6;

    % Muted eel colors
    left_eel_color_muted = left_eel_color * mute_factor + MUTE_GRAY * (1 - mute_factor);
    right_eel_color_muted = right_eel_color * mute_factor + MUTE_GRAY * (1 - mute_factor);

    % Define the number of circles
    numCircles = 3;
    circleRadius = 30;
    horizontalSpacing = 80;

    % Positioning adjustments for centering vertically
    screenX = visual_opt.wWth / 2;
    screenY = visual_opt.wHgt / 2;

    % Define colors for reward text
    GREEN_COLOR = [0, 180, 0];  % Darker green for reward
    WHITE_COLOR = [0,0, 0];  % White for no reward

    % Set larger text size but normal style (not bold)
    oldTextSize = Screen('TextSize', visual_opt.winPtr, 48);  % Increase text size
    oldTextStyle = Screen('TextStyle', visual_opt.winPtr, 0);  % 0 = normal (not bold)

    % Calculate circle positions first to determine text positioning
    circle_positions = zeros(numCircles, 1);
    circleY = screenY;  % Center circles vertically

    % First just calculate and store all circle positions without drawing
    for i = 1:numCircles
        circleX = screenX + (i - (numCircles + 1) / 2) * horizontalSpacing;
        circle_positions(i) = circleX;
    end

    % Calculate exact center of the circle arrangement
    text_center_x = (circle_positions(1) + circle_positions(end)) / 2;

    % Prepare all text strings first
    if data.reward_info.reward_given
        reward_str = sprintf('reward:   %d', round(actual_reward));
    else
        reward_str = sprintf('reward:   %d', round(actual_reward));
    end
    total_str = sprintf('total:   %d', round(all_trials.total_actual_reward));

    % Calculate text bounds for exact centering
    reward_bounds = Screen('TextBounds', visual_opt.winPtr, reward_str);
    total_bounds = Screen('TextBounds', visual_opt.winPtr, total_str);

    % Calculate actual positions ensuring center alignment
    reward_x = text_center_x - reward_bounds(3)/2;
    reward_y = screenY - 120;
    total_x = text_center_x - total_bounds(3)/2;
    total_y = screenY - 60;

    % Now draw the circles
    for i = 1:numCircles
        if i <= left_fish_count
            circleColor = left_eel_color_muted;
        elseif i <= (left_fish_count + right_fish_count)
            circleColor = right_eel_color_muted;
        else
            circleColor = [169, 169, 169];  % Gray for no fish caught
        end

        % Draw the circle
        circleX = circle_positions(i);
        Screen('FillOval', visual_opt.winPtr, circleColor, ...
            [circleX - circleRadius, circleY - circleRadius, circleX + circleRadius, circleY + circleRadius]);
    end

    % Draw reward text - special handling for colored number if rewarded
    if data.reward_info.reward_given
        % Split the reward text to color only the number
        [~, ~, ~] = DrawFormattedText(visual_opt.winPtr, 'reward: ', reward_x, reward_y, WHITE_COLOR);
        num_width = Screen('TextBounds', visual_opt.winPtr, 'reward: ');
        % Add a space after 'reward:' for clarity
        DrawFormattedText(visual_opt.winPtr, sprintf(' %d', round(actual_reward)), reward_x + num_width(3), reward_y, GREEN_COLOR);
    else
        DrawFormattedText(visual_opt.winPtr, reward_str, reward_x, reward_y, WHITE_COLOR);
    end

    % Draw total text
    DrawFormattedText(visual_opt.winPtr, total_str, total_x, total_y, WHITE_COLOR);

    % Reset text properties to original values
    Screen('TextSize', visual_opt.winPtr, oldTextSize);
    Screen('TextStyle', visual_opt.winPtr, oldTextStyle);

    % Flip the screen
    Screen('Flip', visual_opt.winPtr);

    %% Keep the score screen visible
    start_time = GetSecs();
    while (GetSecs() - start_time) < game_opt.score_time
        loop_start_t = GetSecs();
        check_duration(loop_start_t, 1 / visual_opt.refresh_rate, device_opt.min_t_scale);
    end

    % Record phase end time and duration
    data.(phase_str).phase_end = GetSecs();
    data.(phase_str).phase_duration = data.(phase_str).phase_end - data.(phase_str).phase_start;
end