function display_side = check_avatar_side(avatar_pos, visual_opt, game_opt)
    % Input arguments:
    % avatar_pos: [1 x 2]
    % visual_opt: Structure containing visual options
    % game_opt: Structure containing game options
    % Output arguments:
    % display_side: integer indicating the side (-1 for middle, 1 for left, 2 for right)
    
    % Calculate corridor width
    corridor_width = visual_opt.corridor_coord(3, 1) - visual_opt.corridor_coord(1, 1);
    
    % Define a narrower middle area (adjust the factor as needed)
    % Using 0.8 as a factor will make the middle area 80% of the original width
    middle_width_factor = 0.8;
    
    % Calculate the narrower bounds for middle region
    middle_left_bound = visual_opt.corridor_coord(1, 1) + (1 - middle_width_factor)/2 * corridor_width;
    middle_right_bound = visual_opt.corridor_coord(3, 1) - (1 - middle_width_factor)/2 * corridor_width;
    
    % Check sides using the narrower middle definition
    sideL = avatar_pos(1) + game_opt.avatar_sz < middle_left_bound;
    sideR = avatar_pos(1) - game_opt.avatar_sz > middle_right_bound;
    sideM = avatar_pos(1) + game_opt.avatar_sz >= middle_left_bound && ...
            avatar_pos(1) - game_opt.avatar_sz <= middle_right_bound;
 
    % Initialize display_side with a default value
    display_side = -1;  % Default to middle position
 
    % Check position and assign appropriate value
    if sideM
        display_side = -1;  % Middle
    elseif sideL
        display_side = 1;   % Left
    elseif sideR
        display_side = 2;   % Right
    end
end