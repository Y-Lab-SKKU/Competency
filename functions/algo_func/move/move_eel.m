function [eel_fut_pos, game_opt] = move_eel(eel_curr_pos, fish_curr_pos, game_opt, visual_opt)
    % move_eels - Computes the future position of the eel based on fish positions and
    % a tendency to remain near a side-specific center point.
    %
    % If the candidate move (a weighted blend of chasing fish and moving toward the side
    % center) is outside the allowed circle, then:
    %   1. The algorithm repeatedly selects one random fish from the full set to compute
    %      a candidate move (using only that fish and the center direction).
    %   2. If one of these moves falls inside the allowed circle, it is used.
    %   3. Otherwise, the candidate move that minimizes the overshoot is scaled so that
    %      the eel lands exactly on the allowed boundary.
    %
    % Inputs:
    %   eel_curr_pos  - Current [x, y] position of the eel.
    %   fish_curr_pos - Matrix of fish positions (each row is an [x, y] coordinate).
    %   game_opt      - Struct containing game options (including eel speed, eel_spd).
    %   visual_opt    - Struct containing visual options (including screen dimensions,
    %                   corridor coordinates, etc.).
    %
    % Outputs:
    %   eel_fut_pos   - The computed future position of the eel.
    %   game_opt      - Updated game options (if modified).

    % --- Define centers and allowed radius ---
    left_center  = [visual_opt.wWth/4, visual_opt.wHgt/2];
    right_center = [visual_opt.wWth*3/4, visual_opt.wHgt/2];
    allowed_radius = min(visual_opt.wWth/4, visual_opt.wHgt/2) * 0.7;

    % Determine the side (left/right/center) and select the corresponding center point.
    side = determineEelSide(eel_curr_pos, visual_opt);
    if strcmp(side, 'right')
        center_point = right_center;
    else
        center_point = left_center;
    end

    % Compute the normalized direction from the eel to the center point.
    center_dir = center_point - eel_curr_pos;
    if norm(center_dir) > 0
        center_dir = center_dir / norm(center_dir);
    end

    % --- Compute the candidate move using all fish ---
    % Calculate the direction toward the average fish position.
    fish_dir = mean(fish_curr_pos, 1) - eel_curr_pos;
    if norm(fish_dir) > 0
        fish_dir = fish_dir / norm(fish_dir);
    end

    % Blend the fish direction and the center direction.
    chase_weight = 0.7;   % Weight for chasing fish.
    center_weight = 0.3;  % Weight for moving toward the center.
    combined_dir = (chase_weight * fish_dir) + (center_weight * center_dir);
    if norm(combined_dir) > 0
        combined_dir = combined_dir / norm(combined_dir);
    end

    % The intended step length.
    L = game_opt.eel_spd;
    candidate_move = eel_curr_pos + L * combined_dir;

    % Check if the candidate move is inside the allowed circle.
    if norm(candidate_move - center_point) <= allowed_radius
        eel_fut_pos = candidate_move;
    else
        % --- The candidate move is outside the allowed circle. ---
        % Now try repeatedly selecting one random fish and computing a candidate move.
        max_attempts = 50;
        valid_move_found = false;
        best_overshoot = Inf;  % Track the minimal overshoot (distance outside allowed circle)
        best_combined = [];    % Best combined direction corresponding to the minimal overshoot
        attempts = 0;
        while attempts < max_attempts
            % Randomly select one fish from the full set.
            idx = randi(size(fish_curr_pos,1));
            selected_fish = fish_curr_pos(idx,:);
            
            % Compute direction toward the selected fish.
            fish_dir_new = selected_fish - eel_curr_pos;
            if norm(fish_dir_new) > 0
                fish_dir_new = fish_dir_new / norm(fish_dir_new);
            end
            
            % Compute new combined direction using the selected fish and center direction.
            new_combined = (chase_weight * fish_dir_new) + (center_weight * center_dir);
            if norm(new_combined) > 0
                new_combined = new_combined / norm(new_combined);
            end
            
            candidate_move = eel_curr_pos + L * new_combined;
            if norm(candidate_move - center_point) <= allowed_radius
                % Found a candidate move that lies within the allowed circle.
                eel_fut_pos = candidate_move;
                valid_move_found = true;
                break;
            else
                % Compute how far outside the circle this move is.
                overshoot = norm(candidate_move - center_point) - allowed_radius;
                if overshoot < best_overshoot
                    best_overshoot = overshoot;
                    best_combined = new_combined;
                end
            end
            attempts = attempts + 1;
        end
        
        if ~valid_move_found
            % --- Final adjustment: scale the best candidate move so it lands exactly on the boundary ---
            % Let v = L * best_combined be the candidate displacement vector.
            P = eel_curr_pos;
            v = L * best_combined;
            C = center_point;
            d = P - C;
            a = dot(v, v);
            b = 2 * dot(d, v);
            c = dot(d, d) - allowed_radius^2;
            disc = b^2 - 4 * a * c;
            if disc >= 0 && a > 0
                % Choose the smallest positive t in [0,1] such that P + t*v lies on the boundary.
                t1 = (-b - sqrt(disc)) / (2 * a);
                t2 = (-b + sqrt(disc)) / (2 * a);
                t_boundary = 1;
                if t1 >= 0 && t1 <= 1
                    t_boundary = t1;
                elseif t2 >= 0 && t2 <= 1
                    t_boundary = t2;
                end
                eel_fut_pos = P + t_boundary * v;
            else
                % As a last resort, if scaling fails, do not move.
                eel_fut_pos = eel_curr_pos;
            end
        end
    end
end

function side = determineEelSide(eel_pos, visual_opt)
    % determineEelSide - Determines whether the eel is on the left, right, or center of the corridor.
    %
    % Inputs:
    %   eel_pos    - The [x, y] position of the eel.
    %   visual_opt - Struct containing visual options, including corridor_coord.
    %
    % Output:
    %   side       - A string: 'left', 'right', or 'center'.
    
    if eel_pos(1) < visual_opt.corridor_coord(1, 1)
        side = 'left';
    elseif eel_pos(1) > visual_opt.corridor_coord(3, 1)
        side = 'right';
    else
        side = 'center'; % Eel is exactly in the middle corridor
    end
end
