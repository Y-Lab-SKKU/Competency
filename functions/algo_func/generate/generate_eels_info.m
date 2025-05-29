function curr_trial_data = generate_eels_info(curr_trial_data, visual_opt, game_opt)
% generate_eels_info - Initializes eel-specific data and integrates it into the trial data.
%
% Syntax:
%   curr_trial_data = generate_eels_info(curr_trial_data, visual_opt, game_opt)
%
% Inputs:
%   curr_trial_data - Struct containing current trial data (must include trial_idx).
%   visual_opt      - Struct containing visual options (colors, window dimensions, etc.).
%   game_opt        - Struct containing game options. If game_opt.premade_eels is true,
%                     pre-generated eel data will be loaded from game_opt.eels_src.
%
% Outputs:
%   curr_trial_data - Updated trial data struct containing eel information.
%
% If pre-generated data is available (and game_opt.premade_eels is true),
% this function loads it from file and returns a structure equivalent to one generated on the fly.
% Otherwise, it generates the eel data.

    if game_opt.premade_eels
        % Construct filename using the trial index.
        eel_data_filename = fullfile(game_opt.eels_src, sprintf('trial_%03d.mat', curr_trial_data.trial_idx));
        if exist(eel_data_filename, 'file')
            loaded = load(eel_data_filename, 'curr_trial_data');
            
            % TODO: review if all are used ? 
            curr_trial_data.eels = loaded.curr_trial_data.eels;
            curr_trial_data.avtr_start_pos = loaded.curr_trial_data.avtr_start_pos;
            curr_trial_data.avtr_start_pos = loaded.curr_trial_data.avtr_start_pos;
            % For reporting, check if a swap occurred by comparing initial and final sides.
            swap_eels = any([curr_trial_data.eels.initial_side] ~= [curr_trial_data.eels.final_side]);
            fprintf('Loaded premade eel data for trial %d. Swap occurred: %d\n', curr_trial_data.trial_idx, swap_eels);
        else
            warning('Premade eel data for trial %d not found! Generating eels on the fly.', curr_trial_data.trial_idx);
            curr_trial_data = generate_eels_info_generate(curr_trial_data, visual_opt, game_opt);
        end
    else
        curr_trial_data = generate_eels_info_generate(curr_trial_data, visual_opt, game_opt);
    end

end

function curr_trial_data = generate_eels_info_generate(curr_trial_data, visual_opt, game_opt)
    % Ensure at least two competency options exist
    if numel(game_opt.competencies) < 2
        error('Need at least two competency values in game_opt.competencies.');
    end

    % Randomly select two distinct competencies
    chosen_competencies = game_opt.competencies(randperm(length(game_opt.competencies), 2));
    [comp_changes, dist_info] = generate_competency_changes(chosen_competencies, game_opt, curr_trial_data);

    % Randomly assign initial sides (1 = Left, 2 = Right) and determine swap
    sides = randperm(2); % (Assuming game_opt.n_eels is 2)
    swap_eels = rand() < game_opt.swap_eels_prob;
    eel_colors = game_opt.eel_colors(randperm(size(game_opt.eel_colors,1), game_opt.n_eels), :);

    % Define vertical position range
    h_range = [floor(visual_opt.wHgt/2 - visual_opt.eel_rnd_range), ceil(visual_opt.wHgt/2 + visual_opt.eel_rnd_range)];

    % Initialize eels array (preallocate struct)
    eels(game_opt.n_eels) = struct();

    for iE = 1:game_opt.n_eels
        eels(iE).initial_side = sides(iE);
        %eels(iE).final_side = swap_eels * (3 - sides(iE)) + ~swap_eels * sides(iE);
        eels(iE).eel_col = eel_colors(iE, :);

        % Determine horizontal range based on final side
        w_quarter = visual_opt.wWth / 4;
        w_range = [floor(w_quarter - visual_opt.eel_rnd_range), ceil(w_quarter + visual_opt.eel_rnd_range)];
        % if eels(iE).final_side == 2
        %     w_range = w_range + visual_opt.wWth / 2;
        % end

        % Assign position and generate fish locations
        eels(iE).eel_pos = [randi(w_range), randi(h_range)];
        eels(iE).fish_pos = generate_fish_locs(eels(iE).eel_pos, game_opt);

        % Assign competency and attributes
        eels(iE).potent = game_opt.electrical_field;
        idx = (sides(iE) == 2) + 1;
        eels(iE).comp_change = comp_changes(idx);
        eels(iE).dist_params = dist_info(idx);
        eels(iE).competency = chosen_competencies(idx);
        %eels(iE).final_competency = chosen_competencies(idx) + comp_changes(idx);
        
        % ----- Reliability Assignment -----
        % Build the key based on eel color RGB values
        color_key = sprintf('%d,%d,%d', eels(iE).eel_col(1), eels(iE).eel_col(2), eels(iE).eel_col(3));
        
        % Check if the key exists in the reliability map
        if isKey(game_opt.reliability_map, color_key)
            eels(iE).reliability = game_opt.reliability_map(color_key);
        else
            % Fallback if key not found - use the reliability based on which eel is more common
            if isequal(eels(iE).eel_col, [0, 0, 255])  % Blue eel
                eels(iE).reliability = game_opt.high_reliability;
                warning('Using fallback reliability for blue eel: %.2f', game_opt.high_reliability);
            elseif isequal(eels(iE).eel_col, [157, 0, 255])  % Purple eel
                eels(iE).reliability = game_opt.low_reliability;
                warning('Using fallback reliability for purple eel: %.2f', game_opt.low_reliability);
            else
                % If color doesn't match either blue or purple, assign randomly
                reliabilities = [game_opt.high_reliability, game_opt.low_reliability];
                eels(iE).reliability = reliabilities(randi(2));
                warning('Using random reliability (%.2f) for unknown eel color: [%d,%d,%d]', ...
                    eels(iE).reliability, eels(iE).eel_col(1), eels(iE).eel_col(2), eels(iE).eel_col(3));
            end
        end
    end

    % Print debug information
    for iE = 1:game_opt.n_eels
        if isequal(eels(iE).eel_col, [0, 0, 255])
            color_name = 'Blue';
        elseif isequal(eels(iE).eel_col, [157, 0, 255])
            color_name = 'Purple';
        else
            color_name = sprintf('Unknown [%d,%d,%d]', eels(iE).eel_col(1), eels(iE).eel_col(2), eels(iE).eel_col(3));
        end
        fprintf('%s eel reliability: %.2f\n', color_name, eels(iE).reliability);
    end

    % Store eel data and set avatar's starting position
    curr_trial_data.eels = eels;
    curr_trial_data.avtr_start_pos = [visual_opt.wWth/2, visual_opt.coordinate_window];
    
    if isempty(eels)
        error('Eel initialization failed: No eels were assigned.');
    end
end