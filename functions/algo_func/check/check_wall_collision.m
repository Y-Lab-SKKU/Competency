% Helper function to check collision between a circle and a rectangle.
% circle_center: [x, y] of the circle's center
% radius: circle radius
% rect: [rx, ry, rx+w, ry+h] representing the rectangle (left, top, right, bottom)
function collision = check_wall_collision(circle_center, radius, rect)
    % Unpack circle center
    cx = circle_center(1);
    cy = circle_center(2);
    
    % Unpack rectangle
    rx1 = rect(1);
    ry1 = rect(2);
    rx2 = rect(3);
    ry2 = rect(4);
    
    % Find the closest point on the rectangle to the circle center
    closestX = max(rx1, min(cx, rx2));
    closestY = max(ry1, min(cy, ry2));
    
    % Calculate the distance between the circle's center and this closest point
    dx = cx - closestX;
    dy = cy - closestY;
    distance = sqrt(dx^2 + dy^2);
    
    % If the distance is less than the circle's radius, there is an overlap
    collision = (distance < radius);
end
