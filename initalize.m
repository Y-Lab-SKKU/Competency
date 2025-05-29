function [visual_opt, device_opt, game_opt, eye_opt, save_directory] = initalize()

    %% 0) clear all;
    clear;
    close all;
    clc;
        
    %% 1) Add all subdirectory;
    % Get the directory where this m-file is located
    currentFolder = fileparts(mfilename('fullpath'));
    
    % Add the current folder to the path
    addpath(currentFolder);

    % Only recursively add the functions folder
    functionsFolder = fullfile(currentFolder, 'functions');
    addpath(genpath(functionsFolder));
    
    % Display a message confirming that the paths have been added
    disp(['Added ', currentFolder, ' and its subdirectories to the path.']);


    test = false;    
    
    if ismac
        disp('Running on macOS');
        username = getenv('USER');  % Works on macOS and Linux
        test = true; % false (2nd floor) | true (at home, desk)
        monkey = 'MARIA'; 
    elseif ispc
        disp('Running on Windows');
        username = getenv('USERNAME');
        % Prompt the user for their name and save it in 'monkey'
        monkey = input('Enter username: ', 's');
    else
        disp('Running on another OS');
        username = "OTHER";
    end

        % Define the save path and filenames
    save_directory = define_save(currentFolder, monkey);
    
    %% 2) Set visual_opt, game_opt, device_opt
    device_opt = set_device_opt(monkey, test);
    visual_opt = set_visual_opt(monkey);
    game_opt = set_game_opt();

        
    %% 3) Eyelink related.
    eye_opt = set_eyelink(visual_opt, test);
    
    metadata = struct();
    metadata.game_opt = game_opt;
    metadata.device_opt = device_opt;
    metadata.visual_opt = visual_opt; 
    
    % Save the metadata 
    full_file_path = fullfile(save_directory, ['metadata', '.mat']);
    save(full_file_path, 'metadata');

  
end

