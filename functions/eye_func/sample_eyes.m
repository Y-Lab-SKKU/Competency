function eye_data = sample_eyes(eye_opt)
    
    %% This function is recurrently called to sample eye at 
    %   every frame rate. 
    %   Input argument:
    %       eye_opt: struct. Eye related information.

    if eye_opt.eyelink_on
        eyesample = Eyelink('NewestFloatSample');
        eye_data.eyeX = eyesample.gx(eye_opt.eye_side);
        eye_data.eyeY = eyesample.gy(eye_opt.eye_side);
        eye_data.eyePupSz = eyesample.pa(eye_opt.eye_side);
    else
        eye_data.eyeX = 0;
        eye_data.eyeY = 0;
        eye_data.eyePupSz = 0;
    end
end

