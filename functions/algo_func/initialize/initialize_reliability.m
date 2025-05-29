function [game_opt, all_trials] = initialize_reliability(game_opt, all_trials, visual_opt)
    % Create a reliability mapping (using a containers.Map)
    % Assume game_opt.eel_colors is an N x 3 matrix (we use the first two colors)
    key1 = sprintf('%d,%d,%d', game_opt.eel_colors(1,1), game_opt.eel_colors(1,2), game_opt.eel_colors(1,3));
    key2 = sprintf('%d,%d,%d', game_opt.eel_colors(2,1), game_opt.eel_colors(2,2), game_opt.eel_colors(2,3));
    
    reliability_map = containers.Map;
    reliability_map(key1) = 0.15;
    reliability_map(key2) = 0.25;
    
    % 50/50 chance to swap reliabilities immediately at initialization
    if rand() < 0.5
        temp = reliability_map(key1);
        reliability_map(key1) = reliability_map(key2);
        reliability_map(key2) = temp;
        
        % Append initial swap (using trial index 0 to denote the initial swap)
        if isfield(all_trials, 'reliability_swaps')
            all_trials.reliability_swaps = [all_trials.reliability_swaps, 0];
        else
            all_trials.reliability_swaps = 0;
        end
        fprintf('Initial reliability swap occurred.\n');
    end
    
    game_opt.reliability_map = reliability_map;
    
    % Generate normally distributed random number using Box-Muller transform
    u1 = rand();
    u2 = rand();
    z = sqrt(-2 * log(u1)) * cos(2 * pi * u2);  % Standard normal distribution
    offset = round(game_opt.reliability_mu + z * game_opt.reliability_sigma);  % Scale and shift
    
    game_opt.next_reliability_swap = 1 + offset;
    
    %fprintf('Next swap trial: %d\n', game_opt.next_reliability_swap);
    all_trials.next_reliability_swap = game_opt.next_reliability_swap;
end
