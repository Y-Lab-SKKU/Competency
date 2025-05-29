function visual_opt = set_visual_opt(monkey)
    % SET_VISUAL_OPT - Configures visual options for the experiment.
    %
    % Input:
    %   monkey - String indicating the monkey name (e.g., 'SOJU').
    %
    % Output:
    %   visual_opt - Struct containing all visual configuration parameters.

    %% 1) Color Options
    visual_opt.screen_color = [211, 211, 211]; % White background
    visual_opt.choice_color_avtr = [204, 153, 0]; % Cyan for avatar during choice phase
    visual_opt.pursuit_color_avtr = [239, 191, 4]; % Gold for avatar during pursuit phase
    visual_opt.color_avtr_gray = [137, 137, 137]; % Gray for inactive avatar
    
    visual_opt.color_fish = [255, 165, 0]; % Orange for fish
    visual_opt.catch_animation_frames = 30; % Frames for caught fish animation

    %% 2) Monitor and Window Setup
    Screen('Preference', 'SkipSyncTests', 1); % Skip sync tests for faster setup

    % Adjust screen number for specific monkey
    if ~strcmp(monkey, 'MARIA')
        screen_number = max(Screen('Screens')) - 1 ; % Primary screen
    elseif strcmp(monkey, 'MARIA')
        screen_number = max(Screen('Screens')); % Primary screen 
    end
    
    

    % Open window and get properties
    [visual_opt.winPtr, ~] = Screen('OpenWindow', screen_number, visual_opt.screen_color);
    visual_opt.refresh_rate = Screen('NominalFrameRate', visual_opt.winPtr);
    fprintf('Monitor refresh rate: %.2f Hz\n', visual_opt.refresh_rate);

    % Store window dimensions and center
    [visual_opt.wWth, visual_opt.wHgt] = Screen('WindowSize', visual_opt.winPtr);
    visual_opt.screen_center = [visual_opt.wWth / 2, visual_opt.wHgt / 2];

    %% 3) Corridor and Game Boundaries
    safe_plase = 300; % Safe margin from top and bottom
    visual_opt.coordinate_window = safe_plase + (visual_opt.wHgt - 2 * safe_plase) * rand; % Random vertical position

    % Corridor properties
    visual_opt.corridor_color = [0, 0, 0]; % Black corridor
    visual_opt.corridor_thickness = 50; % Thickness of corridor walls
    visual_opt.gap_size = 200; % Gap size in corridor

    % Corridor coordinates
    visual_opt.corridor_coord = [
        visual_opt.wWth / 2 - visual_opt.corridor_thickness, ...
        visual_opt.coordinate_window - visual_opt.corridor_thickness; % Lower left of upper corridor
        visual_opt.wWth / 2 - visual_opt.corridor_thickness, ...
        visual_opt.coordinate_window + visual_opt.corridor_thickness; % Upper left of lower corridor
        visual_opt.wWth / 2 + visual_opt.corridor_thickness, 1; % Upper right of upper corridor
        visual_opt.wWth / 2 + visual_opt.corridor_thickness, visual_opt.wHgt % Lower right of lower corridor
    ];

    % Left and right boundaries
    visual_opt.left_boundary = struct(...
        'left', 0, ...
        'right', visual_opt.wWth / 2 - visual_opt.corridor_thickness, ...
        'top', safe_plase, ...
        'bottom', visual_opt.wHgt - safe_plase, ...
        'window_top', visual_opt.coordinate_window - visual_opt.gap_size / 2, ...
        'window_bottom', visual_opt.coordinate_window + visual_opt.gap_size / 2 ...
    );

    visual_opt.right_boundary = struct(...
        'left', visual_opt.wWth / 2 + visual_opt.corridor_thickness, ...
        'right', visual_opt.wWth, ...
        'top', safe_plase, ...
        'bottom', visual_opt.wHgt - safe_plase ...
    );

    % Calculate corridor centers
    [visual_opt.left_center, visual_opt.right_center] = calculateCorridorCenters(...
        visual_opt.wWth, visual_opt.wHgt, visual_opt.corridor_thickness);

    %% 4) Game Visual Elements
    % Eel movement range
    visual_opt.eel_rnd_range = 50; % Maximum random movement for eels

    % Score "battery" display
    visual_opt.SQUARE_SIZE = 40; % Size of each square in pixels
    visual_opt.GAP = 4; % Gap between squares
    visual_opt.MARGIN = 100; % Margin from edges

    % Timer bar properties
    visual_opt.time_bar_height = 20; % Height of the timer bar
    visual_opt.initial_time_color = [0, 255, 0]; % Green for initial time
    visual_opt.bonus_time_color = [0, 191, 255]; % Blue for bonus time
    visual_opt.time_background_color = [100, 100, 100]; % Gray for empty bar

    %% 5) Debugging and Visualization Flags
    visual_opt.show_timer_from_start = true; % Show timer from the start
    visual_opt.visualize_pot = true; % Visualize eel potentials
    visual_opt.alpha = 0.7; % 0 to 1 where 0 is not visual and 1 is fully visual 
    visual_opt.visualize_radius = false; % Visualize radius
end

function [left_center, right_center] = calculateCorridorCenters(wWth, wHgt, corridor_thickness)
    % CALCULATECORRIDORCENTERS - Calculates centers of left and right sides.
    %
    % Inputs:
    %   wWth - Window width.
    %   wHgt - Window height.
    %   corridor_thickness - Thickness of corridor walls.
    %
    % Outputs:
    %   left_center - [x, y] coordinates of the left side center.
    %   right_center - [x, y] coordinates of the right side center.

    left_x = (0 + (wWth / 2 - corridor_thickness)) / 2; % Left side center x
    right_x = ((wWth / 2 + corridor_thickness) + wWth) / 2; % Right side center x
    center_y = wHgt / 2; % Center y (same for both sides)

    left_center = [left_x, center_y];
    right_center = [right_x, center_y];
end