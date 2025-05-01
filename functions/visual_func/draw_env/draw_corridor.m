function draw_corridor(visual_opt)
    % This function is to draw a corridor with an adjustable gap between the upper and lower corridors.
    % Input arguments:
    %   visual_opt: struct containing visual options
    %   gap_size: the vertical space between upper and lower corridors
    
    % Get the corridor coordinates
    
        upper_left = visual_opt.corridor_coord(1, :);
        upper_right = visual_opt.corridor_coord(3, :);
        lower_left = visual_opt.corridor_coord(2, :);
        lower_right = visual_opt.corridor_coord(4, :);

        % Calculate x, y, width, and height for the upper and lower corridors
        x_upper = upper_left(1);
        y_upper = 0;  % Start from the top of the screen
        width_upper = upper_right(1) - upper_left(1);
        height_upper = upper_left(2) - visual_opt.gap_size;  % Reduce height of upper corridor by gap_size

        x_lower = lower_left(1);
        y_lower = lower_left(2) + visual_opt.gap_size;  % Increase y-coordinate of lower corridor by gap_size
        width_lower = lower_right(1) - lower_left(1);
        height_lower = visual_opt.wHgt - y_lower;

        % Validate rectangle dimensions
        if width_upper <= 0 || height_upper <= 0
            error('Invalid dimensions for upper corridor: width = %d, height = %d', width_upper, height_upper);
        end
        if width_lower <= 0 || height_lower <= 0
            error('Invalid dimensions for lower corridor: width = %d, height = %d', width_lower, height_lower);
        end

        % Draw upper corridor
        Screen('FillRect', visual_opt.winPtr, visual_opt.corridor_color, ...
               [x_upper, y_upper, x_upper + width_upper, y_upper + height_upper]);

        % Draw lower corridor
        Screen('FillRect', visual_opt.winPtr, visual_opt.corridor_color, ...
               [x_lower, y_lower, x_lower + width_lower, y_lower + height_lower]);
          
end
