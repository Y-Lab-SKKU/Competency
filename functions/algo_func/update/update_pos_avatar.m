function [new_pos, joy_vec] = update_pos_avatar(current_pos, device_opt, movement_speed, visual_opt, game_opt, bypass_corridor_collision)
    % Add a default value for the new parameter if not provided
    if nargin < 6
        bypass_corridor_collision = false;
    end

    new_pos = current_pos;

    % Avatar parameters (circle)
    avatar_radius = game_opt.avatar_sz / 2;

    % Screen boundaries
    screen_left = avatar_radius;
    screen_right = visual_opt.wWth - avatar_radius;
    screen_top = avatar_radius;
    screen_bottom = visual_opt.wHgt - avatar_radius;

    joy_vec = [0, 0]; % Initialize joy_vec

    % Get movement input (Keyboard)
    if device_opt.KEYBOARD
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('LeftArrow'))
                joy_vec(1) = joy_vec(1) - 1;
            elseif keyCode(KbName('RightArrow'))
                joy_vec(1) = joy_vec(1) + 1;
            end
            if keyCode(KbName('UpArrow'))
                joy_vec(2) = joy_vec(2) - 1;
            elseif keyCode(KbName('DownArrow'))
                joy_vec(2) = joy_vec(2) + 1;
            end
        end
    end

    % Get movement input (Joystick)
    if device_opt.JOYSTICK
        [joy_temp, ~] = JoyMEX(0);
        joy_temp = joy_temp(1:2);
        if norm(joy_temp) >= device_opt.minInput
            joy_vec = joy_vec + joy_temp;
        end
    end

    % Apply dead zone and normalization
    if norm(joy_vec) < device_opt.minInput % deadzone
        joy_vec = [0, 0];
        isJoyMoved = false;
    else
        joy_vec = norm_joy(joy_vec);
        isJoyMoved = true;
    end

    if isJoyMoved
        % Compute new potential position
        movement = joy_vec * movement_speed;
        potential_pos_x = current_pos(1) + movement(1);
        potential_pos_y = current_pos(2) + movement(2);

        % Conditionally execute corridor collision check
        if ~bypass_corridor_collision
            % Corridor collision check (accounting for avatar radius)
            % Get corridor coordinates
            upper_left = visual_opt.corridor_coord(1, :);
            upper_right = visual_opt.corridor_coord(3, :);
            lower_left = visual_opt.corridor_coord(2, :);
            lower_right = visual_opt.corridor_coord(4, :);

            % Upper corridor rectangle parameters
            x_upper = upper_left(1);
            y_upper = 0;  % starting at top of screen
            width_upper = upper_right(1) - upper_left(1);
            height_upper = upper_left(2) - visual_opt.gap_size;  % reduced by gap_size
            rect_upper = [x_upper, y_upper, x_upper + width_upper, y_upper + height_upper];

            % Lower corridor rectangle parameters
            x_lower = lower_left(1);
            y_lower = lower_left(2) + visual_opt.gap_size;  % increased by gap_size
            width_lower = lower_right(1) - lower_left(1);
            rect_lower = [x_lower, y_lower, x_lower + width_lower, visual_opt.wHgt];

            % Check collision with either corridor using circle-rectangle collision detection
            if check_wall_collision([potential_pos_x, potential_pos_y], avatar_radius, rect_upper) || ...
                    check_wall_collision([potential_pos_x, potential_pos_y], avatar_radius, rect_lower)
                % If collision, do not update the position
                potential_pos_x = current_pos(1);
                potential_pos_y = current_pos(2);
            end
        end

        % Screen boundary enforcement
        potential_pos_x = max(screen_left, min(screen_right, potential_pos_x));
        potential_pos_y = max(screen_top, min(screen_bottom, potential_pos_y));

        new_pos = [potential_pos_x, potential_pos_y];
    end
end

function normalized = norm_joy(vec)
    magnitude = norm(vec);
    if magnitude > 0
        normalized = vec / magnitude;
    else
        normalized = vec;
    end
end