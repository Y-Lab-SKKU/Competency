function draw_eel(eel_pos, eel_color, obj_size, visual_opt, eel_pot, game_opt)
    %% Function to draw the eel and optionally display its potential radius.
    %
    % - eel_pos: Position [x, y]
    % - eel_color: RGB color (0-255)
    % - obj_size: Size of the eel
    % - visual_opt: Struct (visual options like visualize_pot, visualize_radius, alpha)
    % - eel_pot: Potential radius
    % - game_opt: Struct (game options like R for larger radius)

    %-----------------------------------------------------
    % 1) Visualize the eel's potential radius with correct transparency.
    %-----------------------------------------------------
    if isfield(visual_opt, 'visualize_pot') && visual_opt.visualize_pot
        if eel_pot > 0
            % Ensure alpha is between 0 (fully visible) and 1 (fully transparent)
            alpha = min(max(visual_opt.alpha, 0), 1);

            % Blend between eel_color and white (255,255,255)
            final_color = round((1 - alpha) * eel_color + alpha * [255, 255, 255]);

            % Define the bounding box for the circle
            destRect = [eel_pos(1)-eel_pot, eel_pos(2)-eel_pot, ...
                        eel_pos(1)+eel_pot, eel_pos(2)+eel_pot];

            % Draw the circular potential field
            Screen('FillOval', visual_opt.winPtr, final_color, destRect);
        end
    end

    %-----------------------------------------------------
    % 2) Draw the eel as a triangle.
    %-----------------------------------------------------
    angles = [pi/2, -pi/6, -5*pi/6]; % Equilateral triangle
    eel_vertices = [
        eel_pos(1) + obj_size * cos(angles(1)), eel_pos(2) - obj_size * sin(angles(1));
        eel_pos(1) + obj_size * cos(angles(2)), eel_pos(2) - obj_size * sin(angles(2));
        eel_pos(1) + obj_size * cos(angles(3)), eel_pos(2) - obj_size * sin(angles(3))
    ];

    % Draw the eel
    Screen('FillPoly', visual_opt.winPtr, eel_color, eel_vertices);

    %-----------------------------------------------------
    % 3) Visualize the larger radius R if enabled.
    %-----------------------------------------------------
    if game_opt.R > 0 && isfield(visual_opt, 'visualize_radius') && visual_opt.visualize_radius
        outline_color = [0, 100, 255, 128]; % Semi-transparent blue
        radius_rect = [eel_pos(1) - game_opt.R, eel_pos(2) - game_opt.R, ...
                       eel_pos(1) + game_opt.R, eel_pos(2) + game_opt.R];

        % Draw the outline circle
        Screen('FrameOval', visual_opt.winPtr, outline_color, radius_rect, 3);
    end
end
