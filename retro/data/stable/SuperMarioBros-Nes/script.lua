previous_xscrollLo = data.xscrollLo
previous_score = data.score
previous_levelLo = data.levelLo
previous_levelHi = data.levelHi
previous_lives = data.lives
is_dying = false
stuck_counter = 0

debug = false


function xscrollLo_reward ()
    -- only give reward if ypos is above level of a pit
    -- this avoids harvesting reward on big jumps into air
    -- as seen in stages 1-3, 4-3 and 5-3
    if data.xscrollLo > previous_xscrollLo and data.yposHi <= 1 and data.yposLo <= 176 then
        local delta = data.xscrollLo - previous_xscrollLo
        local reward = delta * 0.1
        previous_xscrollLo = data.xscrollLo
        stuck_counter = 0
        if debug then print('xscrollLo_reward: ', reward) end
        return reward
    else
        previous_xscrollLo = data.xscrollLo
        return 0
    end
end


function levelLo_reward ()
    if data.levelLo > previous_levelLo then
        local delta = data.levelLo - previous_levelLo
        local reward = delta * 100
        previous_levelLo = data.levelLo
        if debug then print('levelLo_reward: ', reward) end
        return reward
    else
        previous_levelLo = data.levelLo
        return 0
    end
end


function levelHi_reward ()
    if data.levelHi > previous_levelHi then
        local delta = data.levelHi - previous_levelHi
        local reward = delta * 100
        previous_levelHi = data.levelHi
        if debug then print('levelHi_reward: ', reward) end
        return reward
    else
        previous_levelHi = data.levelHi
        return 0
    end
end


function lives_reward ()
    if data.lives > previous_lives then
        local delta = data.lives - previous_lives
        local reward = delta * 100
        previous_lives = data.lives
        if debug then print('lives_reward: ', reward) end
        return reward
    else
        return 0
    end
end


function lives_tracker ()
    if data.lives < previous_lives then
        previous_lives = data.lives
        is_dying = false
    end
    return 0
end


function dying_penalty ()
    -- if hit by enemy
    if data.state == 11 and is_dying == false then
        local reward = -5
        if debug then print('dying_penalty: ', reward) end
        is_dying = true
        return reward
    -- if fall into pit
    elseif data.state == 8 and data.yposHi == 1 and data.yposLo > 176 and is_dying == false then
        local reward = -12.5
        if debug then print('dying_penalty: ', reward) end
        is_dying = true
        return reward
    else
        return 0
    end
end


function step_penalty ()
    local reward = -0.02
    stuck_counter = stuck_counter + 1
    -- print(stuck_counter)
    if debug then print('step_penalty: ', reward) end
    return reward
end


function stuck_penalty ()
    -- penalize if not making forward progress after some time
    -- should help with checkpoints on 1-3, 4-3 and 5-3
    -- as well as exit pipes in 2-2 and 7-2
    if stuck_counter > 500 then
        local reward = -0.1
        if debug then print('stuck_penalty: ', reward) end
        return reward
    else
        return 0
    end
end


function sum_reward ()
    return xscrollLo_reward() + levelLo_reward() + levelHi_reward() + lives_reward() + dying_penalty() + step_penalty() + lives_tracker()
end













-- UNUSED


function score_reward ()
    if data.score > previous_score then
        local delta = data.score - previous_score
        local reward = delta * 0.1
        previous_score = data.score
        if debug then print('score_reward: ', reward) end
        return reward
    else
        return 0
    end
end


function lives_penalty ()
    if data.lives < previous_lives then
        local delta = data.lives - previous_lives
        local reward = delta * 21
        previous_lives = data.lives
        if debug then print('lives_penalty: ', reward) end
        return reward
    else
        return 0
    end
end


function velocity_penalty ()
    -- 24 is max walk speed, 40 is max run
    if data.velocity > 24 then
        local reward = (data.velocity - 24) * -0.004
        if debug then print('velocity_penalty: ', reward) end
        return reward
    else
        return 0
    end
end