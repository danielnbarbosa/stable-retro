previous_xscrollLo = data.xscrollLo
previous_score = data.score
previous_levelLo = data.levelLo
previous_levelHi = data.levelHi
previous_lives = data.lives

debug = false


function xscrollLo_reward ()
    if data.xscrollLo > previous_xscrollLo then
        local delta = data.xscrollLo - previous_xscrollLo
        local reward = delta * 0.1
        previous_xscrollLo = data.xscrollLo
        if debug then print('xscrollLo_reward: ', reward) end
        return reward
    else
        previous_xscrollLo = data.xscrollLo
        return 0
    end
end


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


function ypos_penalty ()
    -- this acts like a dying penalty
    if data.yposHi == 1 and data.yposLo >= 200 and data.yposLo < 204 then
        local reward = -21
        if debug then print('ypos_penalty: ', reward) end
        return reward
    else
        return 0
    end
end


function step_penalty ()
    local reward = -0.02
    if debug then print('step_penalty: ', reward) end
    return reward
end


function sum_reward ()
    return xscrollLo_reward() + score_reward() + levelLo_reward() + levelHi_reward() + lives_reward() + ypos_penalty() + step_penalty()
end
