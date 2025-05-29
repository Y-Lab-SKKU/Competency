
function check_duration(start_t, duration, min_t_scale)
% CHECK_DURATION - Waits until a specific duration has elapsed
% 
% Inputs:
%   start_t    - Start time from GetSecs()
%   duration   - Target duration in seconds (typically 1/refresh_rate)
%   min_t_scale - How frequent we check time.

    while GetSecs()-start_t < duration
        WaitSecs(min_t_scale);
    end

end



