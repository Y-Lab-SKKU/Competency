function [comp_changes, dist_info] = generate_competency_changes(eel_competencies, game_opt, data)
    % generate_competency_changes - Generates competency changes based on initial eel competencies.
    %
    % Inputs:
    %   eel_competencies - Array of initial competencies for each eel (0 to 1 scale).
    %   game_opt         - Struct containing game options.
    %   data             - Struct containing experimental data.
    %
    % Outputs:
    %   comp_changes  - Array of competency changes for each eel.
    %   dist_info     - Struct containing min and max change limits for each eel.

    % Determine which competency is larger and which is smaller
    [max_comp, max_idx] = max(eel_competencies);
    [min_comp, min_idx] = min(eel_competencies);

    % Initialize outputs
    comp_changes = zeros(1, 2);
    dist_info = struct('min_change', {}, 'max_change', {});

    % Define fixed change limits
    min_increase = game_opt.min_increase;    % The weaker eel can increase or stay the same
    max_increase = game_opt.max_increase;    % Maximum possible increase for the weaker eel
    min_decrease = game_opt.min_decrease;    % The stronger eel can decrease or stay the same (negative)
    max_decrease = game_opt.max_decrease;    % Maximum possible decrease for the stronger eel(negative)

    % Generate competency changes
    for i = 1:2
        if i == max_idx
            % More competent eel: can decrease or stay the same (negative or zero)
            min_change = -max_decrease; % most negative change possible
            max_change = -min_decrease; % least negative change possible (zero if min_decrease is zero)
        else
            % Less competent eel: can increase or stay the same (positive or zero)
            min_change = min_increase; % least positive change possible (zero if min_increase is zero)
            max_change = max_increase; % most positive change possible
        end

        % Store limits
        dist_info(i).min_change = min_change;
        dist_info(i).max_change = max_change;

        % Generate a random change within the defined limits
        comp_changes(i) = min_change + (max_change - min_change) * rand();
    end
end