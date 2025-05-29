function display_gray_screen(visual_opt, game_opt)
    % Define gray color (mid-gray)
    GRAY_COLOR = visual_opt.screen_color ;  % RGB for gray color
    
    % Clear the screen with the gray color
    Screen('FillRect', visual_opt.winPtr, GRAY_COLOR);
    
    % Flip the screen to show the gray color
    Screen('Flip', visual_opt.winPtr);
    
    % Start timing for the gray screen phase
    start_time = GetSecs();
    
    % Keep the gray screen visible for the same duration as the score screen
    while (GetSecs() - start_time) < game_opt.score_time
        % You can include a check here to ensure the time passes correctly.
        % For now, it will simply wait for the specified duration.
    end
end
