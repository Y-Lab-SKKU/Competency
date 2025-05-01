
function [game_opt, all_trials] = update_reliability(game_opt, all_trials, trial_idx)
    % Check if it's time to swap reliability values
    if trial_idx >= game_opt.next_reliability_swap
        % Get keys corresponding to the two colors
        key1 = sprintf('%d,%d,%d', game_opt.eel_colors(1,1), game_opt.eel_colors(1,2), game_opt.eel_colors(1,3));
        key2 = sprintf('%d,%d,%d', game_opt.eel_colors(2,1), game_opt.eel_colors(2,2), game_opt.eel_colors(2,3));
        
        % Swap reliability values
        temp = game_opt.reliability_map(key1);
        game_opt.reliability_map(key1) = game_opt.reliability_map(key2);
        game_opt.reliability_map(key2) = temp;
        
        % Append the current trial index to the reliability_swaps list
        if isfield(all_trials, 'reliability_swaps')
            all_trials.reliability_swaps = [all_trials.reliability_swaps, trial_idx];
        else
            all_trials.reliability_swaps = trial_idx;
        end
        
        % Sample new offset for the next swap trial
        offset = round(normrnd(game_opt.reliability_mu, game_opt.reliability_sigma));
        game_opt.next_reliability_swap = trial_idx + offset;
        
        fprintf('Reliability swapped at trial %d. Next swap trial: %d\n', trial_idx, game_opt.next_reliability_swap);
        
        % Update the next_reliability_swap in all_trials
        all_trials.next_reliability_swap = game_opt.next_reliability_swap;
    end
end
