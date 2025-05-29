
function generate_color_blank(visual_opt, screen_color)
    % generate_color_blank - Fills the screen with a specified color.
    %
    % Inputs:
    %   visual_opt  - Struct containing visual options, including window pointer.
    %   screen_color - Color to fill the screen with.
    %

    % Example implementation (assuming Psychtoolbox)
    Screen('FillRect', visual_opt.winPtr, screen_color);
    Screen('Flip', visual_opt.winPtr);
end

