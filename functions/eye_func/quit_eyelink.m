function quit_eyelink()
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    Eyelink('Shutdown');
end

