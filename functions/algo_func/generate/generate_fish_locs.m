function fish_pos = generate_fish_locs(eel_pos, game_opt)
    %% Description:
    % Generates fish positions distributed across different distances and angles from the eel
    %
    % Input arguments:
    % - eel_pos: (1x2 array) The [x, y] coordinates of the eel's position
    % - game_opt: (struct) Structure containing game options
    %
    % Output arguments:
    % - fish_pos: (Nx2 array) The [x, y] coordinates of generated fish positions
    
    % Divide the circle into sectors to ensure spread
    n_sectors = 6; % Number of angular sectors
    n_distance_bands = 3; % Number of distance bands
    sector_size = 2 * pi / n_sectors;
    
    % Create distance bands
    min_r = game_opt.fish_init_min_r;
    max_r = game_opt.fish_init_max_r;
    band_size = (max_r - min_r) / n_distance_bands;
    
    % Initialize fish positions array
    fish_pos = zeros(game_opt.n_fishes, 2);
    
    % Distribute fish across sectors and distance bands
    fish_per_sector = ceil(game_opt.n_fishes / n_sectors);
    fish_count = 1;
    
    for sector = 1:n_sectors
        % Calculate base angle for this sector
        base_angle = (sector - 1) * sector_size;
        
        % Determine how many fish to place in this sector
        if fish_count > game_opt.n_fishes
            break;
        end
        
        n_fish_this_sector = min(fish_per_sector, game_opt.n_fishes - fish_count + 1);
        
        for f = 1:n_fish_this_sector
            % Randomly select a distance band
            distance_band = randi(n_distance_bands);
            min_dist = min_r + (distance_band - 1) * band_size;
            max_dist = min_r + distance_band * band_size;
            
            % Generate random distance within the selected band
            distance = min_dist + (max_dist - min_dist) * rand();
            
            % Generate random angle within the sector with some jitter
            angle = base_angle + (rand() * 0.8 + 0.1) * sector_size;
            
            % Convert to Cartesian coordinates
            fish_pos(fish_count, 1) = eel_pos(1) + distance * cos(angle);
            fish_pos(fish_count, 2) = eel_pos(2) + distance * sin(angle);
            
            fish_count = fish_count + 1;
        end
    end
    
    % Add some random jitter to prevent perfect alignment
    jitter_amount = min(band_size * 0.1, 10); % 10% of band size or max 10 units
    fish_pos = fish_pos + (rand(size(fish_pos)) - 0.5) * jitter_amount;
    
    % Ensure we only return the requested number of fish positions
    fish_pos = fish_pos(1:game_opt.n_fishes, :);
end

