function save_directory = define_save(currentFolder, monkey)

    %% Define the saving path and filenames. 
    
    % Get current date and time for the directory name
    current_datetime = datetime('now', 'Format', 'yyyy-MM-dd');
    
    % Include the monkey's name in the directory name
    save_directory = fullfile(currentFolder, 'data', [char(current_datetime) '_' monkey]);
    
    % Create the directory if it doesn't exist
    if ~exist(save_directory, 'dir')
        mkdir(save_directory);
        disp([save_directory ' was created']);
    else
        disp([save_directory ' already exists']);
    end

end