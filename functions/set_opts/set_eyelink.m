function eye_opt = set_eyelink(visual_opt, test)

    %% This function initialize eyelink
    %   Input arguments:
    %       visual_opt: struct that contains visual information. 

    eye_opt.eye_side = 2; % 1: left; 2: right.


    if ~ test
        eye_opt.eyelink_on = true;

        el = EyelinkInitDefaults(visual_opt.winPtr);
        EyelinkInit(0); % WHAT DOES ZERO STANDS FOR?
        Eyelink('command' , 'add_file_preamble_text ''Recorded by Eyelink Trial game experiment''');
        Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, visual_opt.wWth-1, visual_opt.wHgt-1);
        Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, visual_opt.wWth-1, visual_opt.wHgt-1);
        Eyelink('command', 'calibration_type = HV9');
        Eyelink('command', 'generate_default_targets = YES');
        EyelinkDoTrackerSetup(el);
        Eyelink('StartRecording');
        disp('Eyelink is on!');
    else
        eye_opt.eyelink_on = false;

        disp('Eyelink is not being used.')
    end 
end

