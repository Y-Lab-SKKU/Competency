% This script is used to test whether keyboard input is working correctly.
% Some newer versions of Psychtoolbox have issues with keyboard detection.
% Run this script if the avatar does not move in the game to verify keyboard functionality.

KbName('UnifyKeyNames');
disp('Press any key (ESC to quit).');

while true
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        pressed = find(keyCode);
        for i = 1:length(pressed)
            k = KbName(pressed(i));
            if strcmp(k, 'ErrorRollOver')
                continue;
            end
            fprintf('You pressed: %s\n', k);
            if strcmp(k, 'ESCAPE')
                return;
            end
        end
        KbReleaseWait;
    end
end
PsychtoolboxVersion
