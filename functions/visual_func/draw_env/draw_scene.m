function draw_scene(avtr_curr_pos, current_eel_pos, fish_curr_pos, ...
    visual_opt, game_opt, side, data, eel_pot, ...
    loop_start_t, caught_fish_data, phase_str, curr_eel_color)
    
    phase_start_time = data.(phase_str).phase_start;
    
    % Draw corridor
    draw_corridor(visual_opt);
    
    % Draw fish battery
    draw_fish_battery(visual_opt, data.(phase_str).left_fish_caught, data.(phase_str).right_fish_caught, game_opt);
    
    % Draw eels if they exist
    if game_opt.n_eels >= 1
        if side == 1 || game_opt.n_eels == 2
            if ~isempty(current_eel_pos)
                draw_eel(current_eel_pos, curr_eel_color, game_opt.eel_sz, visual_opt, eel_pot, game_opt);
            end
        end
        if game_opt.n_eels == 2 && side == 2 
            if ~isempty(current_eel_pos)
                draw_eel(current_eel_pos, curr_eel_color, game_opt.eel_sz, visual_opt, eel_pot, game_opt);
            end
        end
    end
    
    % Calculate elapsed time for fish darkening
    current_time = GetSecs();
    elapsed_time = current_time - phase_start_time;
    % Compute darkening factor based on elapsed time relative to pursuit_time
    fish_darkening_factor = max(0, 1 - elapsed_time / game_opt.pursuit_time);
    % Scale the original fish color by the darkening factor (from full brightness to black)
    darkened_fish_color = round(visual_opt.color_fish * fish_darkening_factor);
    
    % Draw fish with darkened color
    draw_fishes(fish_curr_pos, visual_opt.color_fish, game_opt.fish_sz, visual_opt.winPtr);
       
    % Draw caught fish animations
    if ~isempty(caught_fish_data) && ~isempty(caught_fish_data.positions)
        draw_caught_fish(caught_fish_data, game_opt, visual_opt);
    end
    
    % Draw avatar
    draw_avatar(avtr_curr_pos, visual_opt.pursuit_color_avtr, game_opt.avatar_sz, visual_opt.winPtr);
    draw_timers(visual_opt, game_opt, phase_start_time, GetSecs(), side);

    % Flip screen and calculate frame time
    timestamp = Screen('Flip', visual_opt.winPtr);
    frame_time = timestamp - loop_start_t;
end