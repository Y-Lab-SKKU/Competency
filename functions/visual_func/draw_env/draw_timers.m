function draw_timers(visual_opt, game_opt, phase_start_time, current_time, current_side)
    % Calculate elapsed time
    elapsed_time = current_time - phase_start_time;

    % Calculate time limits
    initial_time = game_opt.pursuit_time;  % Total time for the phase
    remaining_time = max(0, min(initial_time, initial_time - elapsed_time));

    % Determine the position for the timer
    if current_side == -1 && visual_opt.show_timer_from_start
        % Center the timer at the very top of the screen
        timer_x1 = visual_opt.wWth / 4;  % Start at 25% of screen width
        timer_x2 = 3 * visual_opt.wWth / 4;  % End at 75% of screen width
        timer_y1 = 0;  % Flush with the top bezel
        timer_y2 = timer_y1 + visual_opt.time_bar_height;
    elseif current_side == 1
        % Left side
        timer_x1 = 0;
        timer_x2 = visual_opt.wWth / 2 - visual_opt.corridor_thickness;
        timer_y1 = 0;
        timer_y2 = visual_opt.time_bar_height;
    elseif current_side == 2
        % Right side
        timer_x1 = visual_opt.wWth / 2 + visual_opt.corridor_thickness;
        timer_x2 = visual_opt.wWth;
        timer_y1 = 0;
        timer_y2 = visual_opt.time_bar_height;
    else
        % If current_side is -1 and show_timer_from_start is false, do not draw
        return;
    end

    % Calculate the fraction of remaining time
    fraction_remaining = remaining_time / initial_time;
    filled_width = fraction_remaining * (timer_x2 - timer_x1);

    % Calculate the gradient color (green to red)
    current_color = [1 - fraction_remaining, fraction_remaining, 0] * 255;  % RGB gradient

    % Draw the timer background (gray, full width)
    Screen('FillRect', visual_opt.winPtr, visual_opt.time_background_color, ...
           [timer_x1, timer_y1, timer_x2, timer_y2]);

    % Draw the filled timer bar with gradient color
    Screen('FillRect', visual_opt.winPtr, current_color, ...
           [timer_x1, timer_y1, timer_x1 + filled_width, timer_y2]);
end