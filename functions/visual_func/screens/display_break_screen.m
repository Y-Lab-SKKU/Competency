% Function to display break screen
function display_break_screen(visual_opt, device_opt, current_session, total_sessions)
    % Create the break screen
    Screen('FillRect', visual_opt.winPtr, visual_opt.screen_color );
    
    % Display break text
    completed = current_session;
    remaining = total_sessions - current_session;
    
    breakText = sprintf('You have completed %d out of %d sessions.\n\nPlease take a short break.\n\nPress any key when you are ready to continue.', ...
        completed, total_sessions);
    
    DrawFormattedText(visual_opt.winPtr, breakText, 'center', 'center', [0,0, 0]);
    Screen('Flip', visual_opt.winPtr);
    
    % Wait for keypress to continue
    KbStrokeWait;
    
    % Recalibrate the eye tracker after the break if it's enabled
    % Recalibrate the eye tracker after the break if it's enabled
    if device_opt.EYELINK
        % Reinitialize the EyeLink (if needed)
        el = EyelinkInitDefaults(visual_opt.winPtr);  % Should already be initialized, but you can call it again if necessary

        % Perform the calibration process
        EyelinkDoTrackerSetup(el);  % This will trigger the calibration procedure

        % Start recording (after calibration)
        Eyelink('StartRecording');

        disp('Eyelink has been recalibrated and recording has started!');
    end

    
    % Display the start screen for the next session
    display_start_screen(visual_opt, device_opt);
end