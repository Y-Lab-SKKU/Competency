function [fish_pos, caught_count, caught_fish_data] = check_catch(fish_pos, ...
    avatar_pos, game_opt, caught_fish_data, current_frame, visual_opt)
% CHECK_CATCH checks if the avatar (circle) intersects any fish (square)
%   fish_pos:        Nx2 array of fish positions [x, y]
%   avatar_pos:      [x, y] center for the avatar circle
%   game_opt:        struct with avatar_sz, fish_sz, etc.
%   caught_fish_data struct tracking positions, frames_remaining, frame_caught
%   current_frame:   current frame number
%   visual_opt:      struct with catch_animation_frames, etc.
%
% Returns:
%   updated fish_pos (caught fish are marked as [-1, -1])
%   caught_count (how many fish got caught this frame)
%   caught_fish_data (updated for animations)

    % Initialize caught_count
    caught_count = 0;
    
    % Radius of avatar circle
    avatar_radius = game_opt.avatar_sz;
    
    % "Half-size" of the fish square. 
    % If your fish is drawn from (x - obj_size) to (x + obj_size), 
    % then half_size = fish_sz. 
    fish_half_size = game_opt.fish_sz;

    % If caught_fish_data doesn't exist, initialize it
    if isempty(caught_fish_data)
        caught_fish_data = struct('positions', [], 'frames_remaining', [], 'frame_caught', []);
    end
    
    % Loop through each fish position
    for i = 1:size(fish_pos, 1)
        % Skip already caught fish
        if fish_pos(i, 1) == -1 && fish_pos(i, 2) == -1
            continue;
        end
        
        % Check collision between a circle (avatar) and a square (fish).
        if check_circle_square_collision(avatar_pos, avatar_radius, fish_pos(i,:), fish_half_size)
            % Store the caught fish position and animation data
            caught_fish_data.positions(end+1,:) = fish_pos(i,:);
            caught_fish_data.frames_remaining(end+1) = visual_opt.catch_animation_frames;
            caught_fish_data.frame_caught(end+1) = current_frame;
            
            % Mark fish as caught by setting position to [-1, -1]
            fish_pos(i,:) = [-1, -1];
            caught_count = caught_count + 1;
        end
    end
    
    % Update remaining frames for existing caught fish animations
    if ~isempty(caught_fish_data.frames_remaining)
        caught_fish_data.frames_remaining = caught_fish_data.frames_remaining - 1;
        
        % Remove completed animations
        remove_idx = caught_fish_data.frames_remaining <= 0;
        caught_fish_data.positions(remove_idx,:) = [];
        caught_fish_data.frames_remaining(remove_idx) = [];
        caught_fish_data.frame_caught(remove_idx) = [];
    end
end
