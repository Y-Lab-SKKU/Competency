function is_colliding = check_box_collision(avtr_pos, avtr_size, box_rect)
    % CHECK_BOX_COLLISION - Performs a simple AABB collision check.
    % Treats the avatar as a square.
    %
    % Inputs:
    %   avtr_pos   - [x, y] coordinates of the avatar's center.
    %   avtr_size  - Diameter of the avatar (used to define its square bounds).
    %   box_rect   - [left, top, right, bottom] of the target box.
    %
    % Outputs:
    %   is_colliding - Boolean, true if colliding, false otherwise.

    avtr_radius = avtr_size / 2;

    % Avatar's square bounds
    avtr_left   = avtr_pos(1) - avtr_radius;
    avtr_right  = avtr_pos(1) + avtr_radius;
    avtr_top    = avtr_pos(2) - avtr_radius;
    avtr_bottom = avtr_pos(2) + avtr_radius;

    % Box's bounds (already in [left, top, right, bottom] format)
    box_left   = box_rect(1);
    box_top    = box_rect(2);
    box_right  = box_rect(3);
    box_bottom = box_rect(4);

    % Check for overlap
    if (avtr_right > box_left && ...
        avtr_left < box_right && ...
        avtr_bottom > box_top && ...
        avtr_top < box_bottom)
        is_colliding = true;
    else
        is_colliding = false;
    end
end 