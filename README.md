# Eel Selection Game

A MATLAB-based behavioral experiment for studying decision-making and learning in dynamic environments. The experiment presents participants with a game where they must choose between two types of eels (Blue and Purple) with different characteristics that affect gameplay and rewards.

## Overview

In this game, participants choose between two different colored eels (Blue and Purple) that have two hidden properties:

1. **Competency**: Controls how much the eel slows down nearby fish, making them easier to catch.
2. **Reliability**: Determines the probability of receiving a reward for each fish caught.

These properties switch periodically, requiring participants to adapt their strategies over time.

## Game Mechanics

- **Choice Phase**: Participants select one of the eels (Blue or Purple)
- **Pursuit Phase**: Participants control an avatar to catch fish
  - Fish slow down near eels based on the eel's competency
  - Each fish caught increases reward probability based on the eel's reliability
  - Participants can switch between sides through a gap in the central wall
- **Feedback Phase**: Rewards are determined and displayed
  - Higher score = extra monetary compensation for participants

## Installation

### Prerequisites

- MATLAB (R2019b or newer recommended)
- Psychtoolbox-3 ([installation instructions](http://psychtoolbox.org/download))
- For eye tracking: Eyelink Toolbox (included with Psychtoolbox)

### Setup

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/eel-selection-game.git
   ```

2. Add the project to your MATLAB path:
   ```matlab
   addpath(genpath('/path/to/eel-selection-game'))
   ```

## Running the Experiment

To run the experiment, simply execute the `main.m` script in MATLAB:

```matlab
main
```

You may need to modify parameters in the following files to match your experimental setup:
- `set_game_opt.m`: Game parameters (timing, rewards, eel properties)
- `set_device_opt.m`: Input device configuration (keyboard, joystick, eye tracking)
- `set_visual_opt.m`: Display settings (screen size, colors, visual properties)
- `initialize.m`: General initialization settings

### Parameters to Check

#### In `set_game_opt.m`:
- `game_opt.pursuit_time`: Duration of the pursuit phase (default: 7 seconds)
- `game_opt.avatar_speed`: Speed of the participant's avatar (default: 11 pixels/second)
- `game_opt.high_reliability` and `game_opt.low_reliability`: Reward probabilities per fish

#### In `set_device_opt.m`:
- `device_opt.KEYBOARD`: Enable/disable keyboard controls
- `device_opt.JOYSTICK`: Enable/disable joystick controls
- `device_opt.EYELINK`: Enable/disable eye tracking

#### In `initialize.m`:
- `test`: Set to `true` for testing mode (simplified setup), `false` for experimental mode
  - select test true for joystick and eyetracker to be disabled.
- `monkey`: Participant ID (for file naming and saving data)

## File Structure

```
eel-selection-game/
├── main.m                    # Main experiment script
├── initialize.m              # Initialization script
├── set_game_opt.m            # Game parameters configuration
├── set_device_opt.m          # Device configuration
├── set_visual_opt.m          # Visual display configuration
├── set_eyelink.m             # Eye tracking configuration
├── functions/                # Helper functions directory
│   ├── display_start_screen.m      # Display start screen
│   ├── display_break_screen.m      # Display break screen
│   ├── display_end_screen.m        # Display end screen
│   └── ...                         # Other helper functions
```

## Experiment Structure

The experiment consists of 350 trials divided into sessions of approximately 150 trials each, with breaks in between. Each trial follows this sequence:

1. **ITI Phase**: Brief interval between trials
2. **Choice Phase**: Participant selects an eel
3. **Pursuit Phase**: Participant catches fish
4. **Feedback Phase**: Reward is determined and displayed

## Key Dynamics

- **Competency Levels**: Two competency levels, high and low. 
- **Reliability Values**: High (0.25 per fish) or Low (0.10 per fish)
- **Switching Mechanism**: 
  - Competency switches every 7-10 trials
  - Reliability switches every 23-27 trials
  - Switches are independent of each other

## Customization

Modify the game parameters in `set_game_opt.m` to adjust:
- Timing parameters
- Reward structure
- Eel properties
- Fish behavior
- Avatar properties

## Data Storage

Data is saved in a directory structure defined in `initialize.m`. Each trial is saved as a separate .mat file containing all relevant information about the trial.
