function draw_caught_fish(caught_fish_data, game_opt, visual_opt)
    caught_color = [0, 255, 0];  % Green color for caught fish
    fish_width = game_opt.fish_sz;
    fish_height = game_opt.fish_sz/2;
    
    for i = 1:size(caught_fish_data.positions, 1)
        pos = caught_fish_data.positions(i,:);
        % Calculate rectangle bounds
        rect = [pos(1) - fish_width/2, pos(2) - fish_height/2, ...
                pos(1) + fish_width/2, pos(2) + fish_height/2];
        
        % Optional: Add fade-out effect based on remaining frames
        alpha = caught_fish_data.frames_remaining(i) / visual_opt.catch_animation_frames;
        current_color = caught_color * alpha;
        
        % Draw the caught fish
        Screen('FillRect', visual_opt.winPtr, current_color, rect);
    end
end
