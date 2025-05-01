function display_end_screen(visual_opt)
    % Define the background color (white or any color you prefer)
    BACKGROUND_COLOR = [255, 255, 255] / 2;  % White background
    
    % Clear the screen with the chosen background color
    Screen('FillRect', visual_opt.winPtr, BACKGROUND_COLOR);
    
    % Define the message to be displayed
    end_message = 'Thank you for participating!\n\nThe experiment is now over.\n\nPress any key to exit.';
    
    % Set text properties
    textColor = [255, 255, 255];  % Black text color
    textSize = 48;  % Font size
    Screen('TextSize', visual_opt.winPtr, textSize);
    
    % Calculate the text bounds to center the message on the screen
    textBounds = Screen('TextBounds', visual_opt.winPtr, end_message);
    textX = (visual_opt.wWth - textBounds(3)) / 2;  % Center horizontally
    textY = (visual_opt.wHgt - textBounds(4)) / 2;  % Center vertically
    
    % Draw the message on the screen
    DrawFormattedText(visual_opt.winPtr, end_message, textX, textY, textColor);
    
    % Flip the screen to show the message
    Screen('Flip', visual_opt.winPtr);
    
    % Wait for the participant to press any key to exit
    KbStrokeWait;  % Wait for a key press
    
    % Close the screen after the key press
    Screen('CloseAll');
end
