function [left_eel_curr_pos, right_eel_curr_pos, ...
          left_eel_original_competency,right_eel_original_competency , ...
          left_eel_original_potent, right_eel_original_potent, ...
          left_eel_color, right_eel_color, ...
          left_eel_rely, right_eel_rely] = ...
          check_eel_side_info(curr_trial_data, game_opt)

    % Determine which side to use (initial or final)
    if game_opt.use_only_initial_side
        side = curr_trial_data.eels(1).initial_side;
    else
        side = curr_trial_data.eels(1).final_side;
    end

    % Assign positions, competencies, and colors based on the side
    if side == 1 % 1 means left
        left_eel_curr_pos = curr_trial_data.eels(1).eel_pos;
        right_eel_curr_pos = curr_trial_data.eels(2).eel_pos;
        
        left_eel_original_competency = curr_trial_data.eels(1).competency;
        right_eel_original_competency = curr_trial_data.eels(2).competency;
        
        left_eel_original_potent = game_opt.electrical_field;
        right_eel_original_potent = game_opt.electrical_field;

        left_eel_color = curr_trial_data.eels(1).eel_col;
        right_eel_color = curr_trial_data.eels(2).eel_col;
        
        left_eel_rely = curr_trial_data.eels(1).reliability;
        right_eel_rely = curr_trial_data.eels(2).reliability;
    else % side == 2 means right
        left_eel_curr_pos = curr_trial_data.eels(2).eel_pos;
        right_eel_curr_pos = curr_trial_data.eels(1).eel_pos;
        
        left_eel_original_competency = curr_trial_data.eels(2).competency;
        right_eel_original_competency = curr_trial_data.eels(1).competency;
        
        left_eel_original_potent = game_opt.electrical_field;
        right_eel_original_potent = game_opt.electrical_field;

        left_eel_color = curr_trial_data.eels(2).eel_col;
        right_eel_color = curr_trial_data.eels(1).eel_col;
        
        left_eel_rely = curr_trial_data.eels(2).reliability;
        right_eel_rely = curr_trial_data.eels(1).reliability;

    end
end