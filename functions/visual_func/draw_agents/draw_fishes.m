function draw_fishes(obj_center, obj_color, obj_size, winPtr)
    %% THIS FUNCTION IS TO DRAW FISHES

    % Get the number of fishes
    n_fishes = size(obj_center, 1);
    
    % Loop through each fish and draw it
    for nF = 1:n_fishes
        % Check if the fish position includes -1 
        % this means that the avatar has caught the fish
        if any(obj_center(nF, :) == -1)
            continue; % Skip this iteration if -1 is found
        end
        
        % Calculate the coordinates for the current fish
        fish_coord = [
            obj_center(nF, 1) - obj_size, ...
            obj_center(nF, 2) - obj_size, ...
            obj_center(nF, 1) + obj_size, ...
            obj_center(nF, 2) + obj_size
        ];
        
        % Draw the fish using FillRect with the darkened color
        Screen('FillRect', winPtr, obj_color, fish_coord);
    end
end