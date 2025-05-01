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
