function draw_fish_battery(visual_opt, left_fish_caught, right_fish_caught, game_opt)
    % Constants

    % Calculate total fish caught
    total_fish_caught = left_fish_caught + right_fish_caught;

    % Check if the corridor is drawn
    % Horizontal battery position (centered at the bottom of the screen)
    battery_start_x = visual_opt.wWth / 2 - (game_opt.n_fish_to_catch * (visual_opt.SQUARE_SIZE + visual_opt.GAP)) / 2;
    battery_y = visual_opt.wHgt - visual_opt.MARGIN - visual_opt.SQUARE_SIZE;  % Bottom of the screen

    % Draw battery horizontally
    for i = 1:game_opt.n_fish_to_catch
        square_x = battery_start_x + (i-1) * (visual_opt.SQUARE_SIZE + visual_opt.GAP);
        square_rect = [square_x, battery_y, ...
                       square_x + visual_opt.SQUARE_SIZE, battery_y + visual_opt.SQUARE_SIZE];

        if i <= total_fish_caught
            % Fill square with color for caught fish
            Screen('FillRect', visual_opt.winPtr, [0, 255, 0], square_rect);  % Green for caught fish
        else
            % Fill square with default color for uncaught fish
            Screen('FillRect', visual_opt.winPtr, [128, 128, 128], square_rect);  % Gray for uncaught fish
        end
        % Draw white frame for all squares
        Screen('FrameRect', visual_opt.winPtr, [255, 255, 255], square_rect, 2);
    end
end