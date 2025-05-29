
function collision = check_circle_square_collision(circle_pos, circle_radius, square_center, half_size)
% CIRCLE_SQUARE_COLLISION determines whether a circle and axis-aligned square overlap
%
%   circle_pos:   [x, y] center of the circle
%   circle_radius: radius of the circle
%   square_center: [x, y] center of the square
%   half_size:     half the length of one side of the square
%
% Returns: true (1) if they overlap, otherwise false (0).

    % Compute the square's boundaries
    left   = square_center(1) - half_size;
    right  = square_center(1) + half_size;
    top    = square_center(2) - half_size;
    bottom = square_center(2) + half_size;

    % Find the closest point on or in the square to the circle center
    closest_x = max(left, min(circle_pos(1), right));
    closest_y = max(top,  min(circle_pos(2), bottom));

    % Calculate the distance from the circle center to this closest point
    distance_x = circle_pos(1) - closest_x;
    distance_y = circle_pos(2) - closest_y;
    distance_sq = distance_x^2 + distance_y^2;

    % If the distance is <= the circle's radius, there's a collision
    collision = distance_sq <= (circle_radius^2);
end