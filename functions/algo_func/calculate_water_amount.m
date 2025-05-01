function water_amount = calculate_water_amount(device_opt, reward_duration)
    if device_opt.ARDUINO
        water_amount = device_opt.water_per_second * reward_duration;
    else
        water_amount = nan;
    end
    
end
