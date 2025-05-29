function device_opt = configure_keyboard(device_opt)
    KbName('UnifyKeyNames');
    device_opt.upKey = KbName('UpArrow');
    device_opt.downKey = KbName('DownArrow');
    device_opt.leftKey = KbName('LeftArrow');
    device_opt.rightKey = KbName('RightArrow');
end
