previous_score = 0
previous_health = 48
previous_boss_health = 48
previous_floor = 0
previous_xpos_even = 17415
previous_xpos_odd = 1297

function score_reward ()
    -- return delta of score 
    if data.score > previous_score then
        local delta = data.score - previous_score
        previous_score = data.score
        return delta * 0.001
    else
        return 0
    end
end


function health_reward ()
    -- if health resets (after dying) then reset previous_health too 
    if data.health > previous_health and data.health == 48 then
        previous_health = 48
    end
     -- return delta of health
    if data.health < previous_health then
        -- health goes to 0 after finishing the level, but this shouldn't be punished
        if data.boss_health <= 0 then
            return 0
        else
            local delta = data.health - previous_health
            previous_health = data.health
            return delta * 0.1
        end
    else
        return 0
    end
end


function boss_health_reward ()
    -- if boss_health resets (after dying) then reset previous_boss_health too 
    if data.boss_health > previous_boss_health and data.boss_health == 48 then
        previous_boss_health = 48
    end
     -- return delta of boss_health
    if data.boss_health < previous_boss_health then
        -- boss_health goes to 0 when health is 0 (after death), but this shouldn't be rewarded
        if data.boss_health == 0 and data.health == 0 then
            return 0
        else
            local delta = data.boss_health - previous_boss_health
            previous_boss_health = data.boss_health
            return delta * -0.1
        end
    else
      return 0
    end
end


function floor_reward ()
    -- return delta of floor 
    if data.floor > previous_floor then
        local delta = data.floor - previous_floor
        previous_floor = data.floor
        return delta * 50.0
    else
        return 0
    end
end


function x_pos_reward ()
    -- x_pos ranges from 257 to 18688 (leftmost to rightmost respectively).
    -- Floors 0, 2 and 4 start at 17415 and tick down as player moves left.
    -- Floors 1 and 3 start at 1297 and tick up as player moves right.

    if data.floor % 2 == 0 then  -- floors: 0, 2, 4
        local delta = previous_xpos_even - data.x_pos
        previous_xpos_even = data.x_pos
        return delta * 0.001
    else -- floors: 1, 3
        local delta = data.x_pos - previous_xpos_odd
        previous_xpos_odd = data.x_pos
        return delta * 0.001
    end
end


function sum_reward ()
    -- return score_reward() + health_reward() + boss_health_reward() + floor_reward() + x_pos_reward()
    return health_reward() + boss_health_reward() + x_pos_reward()
    -- return 0
end