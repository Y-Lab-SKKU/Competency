function data = concatenate_pos_data(data, avtr_pos, eel_pos, fish_pos, eye_pos, phase_str)
    % Convert input strings to valid field names
    phase_str = matlab.lang.makeValidName(phase_str);

    % Create a substructure for the phase if it doesn't exist
    if ~isfield(data, phase_str)
        data.(phase_str) = struct();
    end

    % Check and add other position data if not -1
    if nargin >= 2 && ~isequal(avtr_pos, -1)
        data.(phase_str).avtr_pos = avtr_pos;
    end
    
    if nargin >= 3 && ~isequal(eel_pos, -1)
        data.(phase_str).eel_pos = eel_pos;
    end
    
    if nargin >= 4 && ~isequal(fish_pos, -1)
        data.(phase_str).fish_pos = fish_pos;
    end
    
    % Assign eye position data
    data.(phase_str).eye_pos = eye_pos;
end