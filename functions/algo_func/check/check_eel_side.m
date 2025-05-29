function side = check_eel_side(eel_pos, visual_opt)
    % Check if the eel is on the left or right side of the corridor
    if eel_pos(1) < visual_opt.corridor_coord(1, 1)
        side = 'left';
    elseif eel_pos(1) > visual_opt.corridor_coord(3, 1)
        side = 'right';
    else
        side = 'center'; % Eel is exactly in the middle corridor
    end
end