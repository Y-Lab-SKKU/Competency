function fish_fut_pos = move_fishes(...
    fish_curr_pos, fish_prev_pos, eel_fut_pos, avtr_fut_pos, ...
    visual_opt, eel_potential, game_opt, eel_strength)


    
    %% Tunable Parameters
    
    % Gravitational pull parameters
    R              = game_opt.R;  % Larger radius around eel
    
    % Collision avoidance parameters
    fish_size       = game_opt.fish_sz;
    eel_size        = game_opt.eel_sz;
    fish_radius     = fish_size / 2;
    min_separation  = (eel_size + fish_size) * 0.75;  % Minimal separation from eel
    min_fish_separation = fish_size * 1.2;          % Minimal separation between fish
    
    %% Basic Parameters
    n_fishes     = size(fish_curr_pos, 1);
    fish_fut_pos = zeros(size(fish_curr_pos));
    
    %% Helper Functions
    
    % Clamp a vector to a maximum length
    function v_out = clamp_vec(v_in, max_len)
        mag = norm(v_in);
        if mag > max_len
            v_out = (v_in / mag) * max_len;
        else
            v_out = v_in;
        end
    end
    
    % Generate a random unit vector
    function v_rand = random_unit_vector()
        theta = 2 * pi * rand;
        v_rand = [cos(theta), sin(theta)];
    end
    
    % Compute the previous movement direction
    function dir_out = get_prev_direction(curr_pos, prev_pos)
        dir_out = [0, 0];
        if all(prev_pos > 0)
            delta = curr_pos - prev_pos;
            d = norm(delta);
            if d > 1e-6
                dir_out = delta / d;
            end
        end
    end
    
    % Avoid collisions with other fish
    function v_avoid = avoid_fish(f_idx, curr_pos)
        v_avoid = [0, 0];
        for j = 1:n_fishes
            if j == f_idx
                continue;
            end
            other_pos = fish_curr_pos(j, :);
            % Skip inactive fish
            if any(other_pos < 0)
                continue;
            end
            dist_f = norm(curr_pos - other_pos);
            if dist_f < min_fish_separation && dist_f > 0
                repulsion_dir = (curr_pos - other_pos) / dist_f;
                overlap = (min_fish_separation - dist_f) / min_fish_separation;
                v_avoid = v_avoid + (repulsion_dir * overlap);
            end
        end
    end
    
    % Repel from eel if within minimal distance
    function pos_out = repel_eel(pos_in)
        to_eel = pos_in - eel_fut_pos;
        d_eel = norm(to_eel);
        if d_eel < min_separation && d_eel > 0
            % Move fish just outside eel boundary
            push = (to_eel / d_eel) * min_separation;
            pos_out = eel_fut_pos + push;
        else
            pos_out = pos_in;
        end
    end
    
    %% Nested Helper Functions
    
    function side = determineEelSide(eel_pos, visual_opt)
        % Determine which side the eel is on: 'left' or 'right'
        corridor_center = visual_opt.wWth / 2;
        corridor_thickness = visual_opt.corridor_thickness;
        corridor_boundary_left = corridor_center - corridor_thickness;
        corridor_boundary_right = corridor_center + corridor_thickness;
        
        if eel_pos(1) < corridor_boundary_left
            side = 'left';
        elseif eel_pos(1) > corridor_boundary_right
            side = 'right';
        else
            side = 'left';  % Default to 'left' if eel is in the corridor
        end
    end
    
    function new_pos = handle_boundary_bounce(start_pos, proposed_pos, movement_vector, visual_opt, side, game_opt)
        % Prevent fish from crossing walls/corridors by adjusting positions.
        
        % Extract corridor parameters
        corridor_thickness = visual_opt.corridor_thickness;
        corridor_center    = visual_opt.wWth / 2;
        
        % Define corridor boundaries based on side
        if strcmp(side, 'left')
            corridor_boundary_left = corridor_center - corridor_thickness;
            % Fish on left should not cross into the corridor or beyond
            if proposed_pos(1) > corridor_boundary_left - game_opt.fish_sz
                % Reflect the movement vector horizontally
                movement_vector(1) = -movement_vector(1);
                proposed_pos = start_pos + movement_vector;
            end
        elseif strcmp(side, 'right')
            corridor_boundary_right = corridor_center + corridor_thickness;
            % Fish on right should not cross into the corridor or beyond
            if proposed_pos(1) < corridor_boundary_right + game_opt.fish_sz
                % Reflect the movement vector horizontally
                movement_vector(1) = -movement_vector(1);
                proposed_pos = start_pos + movement_vector;
            end
        end
        
        % Prevent fish from going beyond screen boundaries
        screen_width  = visual_opt.wWth;
        screen_height = visual_opt.wHgt;
        
        % Adjust for fish size to ensure fish stays entirely within screen
        if proposed_pos(1) < game_opt.fish_sz
            proposed_pos(1) = game_opt.fish_sz;
        elseif proposed_pos(1) > (screen_width - game_opt.fish_sz)
            proposed_pos(1) = screen_width - game_opt.fish_sz;
        end
        
        if proposed_pos(2) < game_opt.fish_sz
            proposed_pos(2) = game_opt.fish_sz;
        elseif proposed_pos(2) > (screen_height - game_opt.fish_sz)
            proposed_pos(2) = screen_height - game_opt.fish_sz;
        end
        
        new_pos = proposed_pos;
    end
    
    %% Main Loop: Update Each Fish
    for i = 1:n_fishes
        % Skip inactive fish
        if fish_curr_pos(i,1) < 0 && fish_curr_pos(i,2) < 0
            fish_fut_pos(i,:) = [-1, -1];
            continue;
        end

        % Current and previous positions
        f_pos = fish_curr_pos(i, :);
        f_prev = fish_prev_pos(i, :);
        
        % 1. Compute Previous Direction for Momentum
        dir_prev = get_prev_direction(f_pos, f_prev);
        
        % 2. Compute Distances
        d_eel     = norm(f_pos - eel_fut_pos);
        d_avatar  = norm(f_pos - avtr_fut_pos);
        
        
        % 3. Determine Speed Based on Eel Potential
        if d_eel <= eel_potential
            % Reduce speed based on eel competency (higher competency slows more)
            speed = game_opt.fast_spd * (1 - eel_strength);
        else
            speed = game_opt.fast_spd;  % Faster outside danger zone
        end

        
        % 4. Compute Movement Vectors
        % a. Gravitational Pull: If outside R, pull towards R, scaled with distance
        if d_eel > R
            pull_vec = eel_fut_pos - f_pos;
            mag_pull = norm(pull_vec);
            if mag_pull > 1e-6
                % The further beyond R, the stronger the pull
                v_grav = (pull_vec / mag_pull) * game_opt.grav_strength * (mag_pull - R);
            else
                v_grav = [0, 0];
            end
        else
            v_grav = [0, 0];
        end
        
        % b. Avatar avoidance (exponential)
        if  d_avatar > 1e-6
            % Compute repulsion strength exponentially based on distance
            repulsion_strength = game_opt.avatar_repulsion_strength * exp(- (d_avatar / game_opt.avatar_sigma));
            repulsion_dir = (f_pos - avtr_fut_pos) / d_avatar;
            v_avatar = repulsion_dir * repulsion_strength;
        else
            v_avatar = [0, 0];
        end
        
        % c. Momentum
        v_momentum = dir_prev;
        
        % d. Avoid Other Fish
        v_fishavoid = avoid_fish(i, f_pos);
        
        % e. Random Wandering (minimal to reduce jitter)
        v_rand = random_unit_vector();
        
        % 5. Combine Movement Vectors with Weights
        v_total = game_opt.w_grav * v_grav + ...
                  game_opt.w_avatar * v_avatar + ...
                  game_opt.w_momentum * v_momentum + ...
                  game_opt.w_avoidFish * v_fishavoid + ...
                  game_opt.w_rand * v_rand;
        
        % 6. Normalize and Clamp to Speed
        if norm(v_total) > 1e-6
            v_total = clamp_vec(v_total, 1);  % Normalize to unit vector
        else
            v_total = [0, 0];
        end

        movement_vec = v_total * speed;
        
        % 7. Compute Tentative New Position
        new_pos = f_pos + movement_vec;
        
        % 8. Repel from Eel if Necessary
        new_pos = repel_eel(new_pos);
        
        % 9. Handle Boundaries and Corridors
        side = determineEelSide(eel_fut_pos, visual_opt);
        new_pos = handle_boundary_bounce(f_pos, new_pos, movement_vec, visual_opt, side, game_opt);
        
        % 10. Assign New Position
        fish_fut_pos(i, :) = new_pos;
    end
end