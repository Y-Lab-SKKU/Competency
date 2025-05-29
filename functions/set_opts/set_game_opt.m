function game_opt = set_game_opt()
    % SET_GAME_OPT - Configures game options for the experiment.
    %
    % Output:
    %   game_opt - Struct containing all game configuration parameters.
    
    
    game_opt.premade_eels = true; % if true we will load the eels and use those 
    game_opt.eels_src = './pre_generate_data/data/five_comps';
    
    % Updated reliability values - percentage per fish caught
    game_opt.high_reliability = 0.25;  % 25% per fish for high reliability eel
    game_opt.low_reliability = 0.10;   % 10% per fish for low reliability eel
   
    %% Timing Parameters
    game_opt.ITI_time = 0.5;            % Inter-Trial Interval time (seconds)
    game_opt.PV_time = 2;               % Time for presenting the visual (seconds)
    game_opt.pursuit_time = 7;          % Duration of pursuit phase (seconds)
    game_opt.choice_time = 10;        	% Time allowed for making a choice (seconds)
    game_opt.report_time = 15;          % Time allowed for reporting eel state (seconds)
    game_opt.score_time = 1.5;          % Duration for displaying the score (seconds)
    
    %TIME TRACKING Buffer 
    game_opt.buffer_t = 1 / 500;        % Buffer time for frame drop (seconds)
    
    %% Reward Parameters
    game_opt.reward_duration = 2;       % Duration of reward (seconds)
    game_opt.short_reward_duration = 1; % Duration of short reward (seconds)
    game_opt.reward_value = 1; % humans
    
    %% Eel Configuration

    % Electrical Field Parameters
    game_opt.use_only_initial_side = false; % if false during choice and pursuit we use final (might be swaped) 
    game_opt.swap_eels_prob = 0.3;      % probability of swaping eels side 
    game_opt.electrical_field = 250;    % Eelectrical eel around the eel
    game_opt.competencies = [0.4, 0.55, 0.7, 0.9]; % Competency values determine how much the eel slows down the fish. 
                                        % A higher competency (0.9) means the fish retains more speed (more slowing).
                                        % A lower competency (0.1) means the fish slows down less.
                                        % The effect applies when the fish is within the eel's danger radius.
    
    game_opt.n_eels = 2;                % Number of eels in the game
    game_opt.eel_sz = 30;               % Size of eels (pixels)
    game_opt.eel_spd = 1;               % Speed of the eel (pixels/second)
    game_opt.eel_spd_passive_view = 1.2;
      
    game_opt.eel_colors = [
            0, 0, 255;         % Blue
            157, 0, 255         % Purple
        ];
        
    % Initialize which eel starts with which reliability
    % This can be adjusted based on your experimental design
    game_opt.start_reliability = containers.Map({'blue','purple'}, {game_opt.high_reliability, game_opt.low_reliability});
    
    % Create a reliability map based on RGB color values for on-the-fly generation
    game_opt.reliability_map = containers.Map();
    % Blue eel (RGB: 0, 0, 255)
    blue_key = sprintf('%d,%d,%d', game_opt.eel_colors(1,1), game_opt.eel_colors(1,2), game_opt.eel_colors(1,3));
    % Purple eel (RGB: 157, 0, 255)
    purple_key = sprintf('%d,%d,%d', game_opt.eel_colors(2,1), game_opt.eel_colors(2,2), game_opt.eel_colors(2,3));
    
    % Initial assignment (can be randomized or fixed based on experimental design)
    game_opt.reliability_map(blue_key) = game_opt.high_reliability;
    game_opt.reliability_map(purple_key) = game_opt.low_reliability;

    game_opt.reliability_mu = 15;
    % mu of the distribution of the trial where reliability will switch 
    game_opt.reliability_sigma = 5;
    % Define fixed change limits for change in eel competency
    game_opt.min_increase = 0;          % The weaker eel can stay the same or increase
    game_opt.max_increase = 0.2;        % Maximum possible increase for the weaker eel
    game_opt.min_decrease = 0.2;       % Maximum possible decrease for the stronger eel
    game_opt.max_decrease = 0;          % The stronger eel can stay the same or decrease
    
    %% Passive View Eel Initialization Settings
    game_opt.margin        = 300;       % Offset from screen edges and corridor boundaries
    game_opt.jistter_amount = 50;      % Maximum random jitter to avoid perfect alignment
    game_opt.passive_view_electrical_field = 250;
    
    %% Fish Configuration
   
    game_opt.n_fishes = 6;              % Total number of fish
    game_opt.n_fish_to_catch = 3;       % Maximum number of fish that can be caught
    game_opt.fish_sz = 25;              % Size of fish (pixels)
    game_opt.fish_init_min_r = min(game_opt.electrical_field) - game_opt.eel_sz; % Minimum initialization distance (pixels)
    game_opt.fish_init_max_r = max(game_opt.electrical_field) + game_opt.eel_sz; % Maximum initialization distance (pixels)
    game_opt.passive_view_radius  = 200;% raidus where the fish can move in PV
    game_opt.fast_spd = 11;             % Speed of the fish when moving quickly (pixels/second)
    game_opt.R = 600;                   % Larger radius around eel (pixels) where fish can move in pursuit
    
    % Gravitational pull parameters
    game_opt.R              =  max(game_opt.electrical_field) + 50;        % Larger radius around eel;  % Larger radius around eel
    game_opt.grav_strength  = 0.2;                                          % Base strength for gravitational pull
    
    % Avatar avoidance parameters
    game_opt.avatar_sigma   = 30;               % Controls the sharpness of exponential repulsion
    game_opt.avatar_repulsion_strength = 10;    % Scaling factor for avatar repulsion
    
    % Weights for movement vectors
    game_opt.w_grav       = 0.3;        % Weight for gravitational pull towards R
    game_opt.w_avatar     = 0.5;          % Weight for avatar avoidance (exponential)
    game_opt.w_momentum   = 0.6;        % Weight for maintaining previous direction
    game_opt.w_avoidFish  = 0.3;        % Weight for avoiding other fish
    game_opt.w_rand       = 0.1;        % Weight for random wandering
    
    %% Avatar Configuration
    game_opt.avatar_sz = 30;            % Avatar size (pixels)
    game_opt.avatar_offset = 100;        % Offset for avatar at the pursuit phase (pixels)
    game_opt.avatar_speed = 11;         % Avatar speed (pixels/second)
    
    game_opt.boost_pxls = 150; % number of pixels person is boosted towards choosen side
end