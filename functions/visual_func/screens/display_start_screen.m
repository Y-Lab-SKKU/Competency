function display_start_screen( visual_opt, device_opt)
    % display_start_screen displays instructions to start the experiment
    % and waits until the participant either presses SPACE or moves the
    % joystick straight upward.
    %
    % Inputs:
    %   data       - structure to record phase timing information.
    %   visual_opt - structure with visual settings (e.g., winPtr, wWth, wHgt).
    %   game_opt   - structure with game parameters.
    %   device_opt - structure with device options including:
    %                   JOYSTICK   (boolean flag)
    %                   minInput   (minimum input threshold)
    %
    % Output:
    %   data       - updated data structure with start phase timing.
    
    % Record phase start time

    
    % Define background color (gray) similar to your score screen
    SCREEN_COLOR = visual_opt.screen_color ;
    Screen('FillRect', visual_opt.winPtr, SCREEN_COLOR);
    
    % Instruction text
    instruction_text = 'Move joystick straight up or press SPACE to start';
    
    % Set text properties
    Screen('TextSize', visual_opt.winPtr, 40);
    text_color = [0,0, 0];
    
    % Draw the instruction text at the center of the screen
    DrawFormattedText(visual_opt.winPtr, instruction_text, 'center', 'center', text_color);
    Screen('Flip', visual_opt.winPtr);
    
    % Define joystick criteria for a "straight up" movement.
    % Here we assume upward movement gives a negative y value.
    joystickUpThreshold = -0.9;  % upward means y < -0.9 after normalization
    horizontalDeadZone = 0.2;    % allow little horizontal deviation for "straight" up
    
    % Wait until either space is pressed or joystick moved straight up
    while true
        % Check for keyboard input
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName('space'))
            break;
        end
        
        % Initialize joystick vector
        joy_vec = [0, 0];
        
        % Get joystick input using JoyMEX if enabled
        if device_opt.JOYSTICK
            [joy_temp, ~] = JoyMEX(0);
            % Consider only the first two axes (horizontal and vertical)
            joy_temp = joy_temp(1:2);
            if norm(joy_temp) >= device_opt.minInput
                joy_vec = joy_vec + joy_temp;
            end
        end
        
        % Apply dead zone and normalization
        if norm(joy_vec) < device_opt.minInput  % deadzone
            joy_vec = [0, 0];
            isJoyMoved = false;
        else
            joy_vec = norm_joy(joy_vec);  % norm_joy should normalize the vector
            isJoyMoved = true;
        end
        
        % Check if joystick is moved "straight up"
        if isJoyMoved && (abs(joy_vec(1)) < horizontalDeadZone) && (joy_vec(2) < joystickUpThreshold)
            break;
        end
        
        % Small delay to avoid busy waiting
        WaitSecs(0.01);
    end

end
