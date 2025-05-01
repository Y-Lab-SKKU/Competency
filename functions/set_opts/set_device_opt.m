function device_opt = set_device_opt(monkey, test)
    % Initialize device options
    device_opt = initialize_device_options(test);
    
    % Configure keyboard if enabled
    if device_opt.KEYBOARD
        device_opt = configure_keyboard(device_opt);
    end
    
    % Configure joystick if enabled
    if device_opt.JOYSTICK
        device_opt = configure_joystick(device_opt);
    end
    
    % Set additional parameters
    device_opt.minInput = 0.5;  % joystick drift threshold
    device_opt.min_t_scale = 1/1000; % 1ms scale
    
    
end

function device_opt = initialize_device_options(test)
    if test
        device_opt.KEYBOARD = true;
        device_opt.JOYSTICK = false;
        device_opt.EYELINK = false;
    else
        device_opt.KEYBOARD = true;
        device_opt.JOYSTICK = true;
        device_opt.EYELINK = true;
    end
end




