previous_score = 0
previous_health = 48
previous_boss_health = 48
previous_stage = 0
previous_xpos = 0

-- floor_status
-- 1 = get ready
-- 2 = floor active
-- 3 = floor finished
-- 5 = cut scene


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
    if data.health > previous_health then
        previous_health = data.health
    end
     -- return delta of health
     -- health goes to 0 after finishing the stage, but this shouldn't be punished
    if data.health < previous_health and data.floor_status == 2 then
        local delta = data.health - previous_health
        previous_health = data.health
        return delta * 0.1
    else
        return 0
    end
end


function boss_health_reward ()
    -- if boss_health resets (after dying) then reset previous_boss_health too
    -- also applies to boss slowly healing
    if data.boss_health > previous_boss_health then
        previous_boss_health = data.boss_health
    end
     -- return delta of boss_health
     -- boss_health goes to 0 when health is 0 (after death), but this shouldn't be rewarded
    if data.boss_health < previous_boss_health and data.floor_status == 2 then
        local delta = data.boss_health - previous_boss_health
        previous_boss_health = data.boss_health
        return delta * -0.1
    else
      return 0
    end
end


function stage_reward ()
    -- return delta of stage
    local stage = data.dragon * 5 + data.floor
    if stage > previous_stage then
        local delta = stage - previous_stage
        previous_stage = stage
        return delta * 10.0
    else
        return 0
    end
end



function x_pos_reward ()
    -- x_pos ranges from 257 to 18688 (leftmost to rightmost respectively).
    -- Floors 0, 2 and 4 start at 17415 and tick down as player moves left.
    -- Floors 1 and 3 start at 1297 and tick up as player moves right.

    if data.floor_status ~= 2 then
        previous_xpos = data.x_pos
        return 0
    elseif data.floor % 2 == 0 then  -- floors: 0, 2, 4
        local delta = previous_xpos - data.x_pos
        previous_xpos = data.x_pos
        return delta * 0.001
    elseif data.floor % 2 == 1 then -- floors: 1, 3
        local delta = data.x_pos - previous_xpos
        previous_xpos = data.x_pos
        return delta * 0.001
    else
        return 0
    end

end


function sum_reward ()
    return health_reward() + boss_health_reward() + x_pos_reward() + stage_reward()
    -- return health_reward()
end