function draw_avatar(obj_center, obj_color, obj_size, winPtr)
    %% This function is to draw avatar
    avtr_pos = [obj_center(1) - obj_size, obj_center(2) - obj_size, ...
        obj_center(1) + obj_size, obj_center(2) + obj_size];
    Screen('FillOval', winPtr, obj_color, avtr_pos);
end

