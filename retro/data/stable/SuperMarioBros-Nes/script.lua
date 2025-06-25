previous_xscrollLo = data.xscrollLo
previous_score = data.score
previous_levelLo = data.levelLo
previous_levelHi = data.levelHi
previous_lives = data.lives
is_dying = false
stuck_counter = 0

debug = false


-- REWARDS --

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


function pipe_reward ()
    -- reward for entering a horizontal pipe
    -- should help finish 2-2 and 7-2 faster
    -- also takes effect at end of 1-2
    -- given there are ~50 steps where the condition is true
    -- this will give ~25 reward in total
    if data.state == 2 then
        local reward = 0.5
        if debug then print('pipe_reward: ', reward) end
        return reward
    else
        return 0
    end
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


function stage4_4_penalty ()
    if data.levelHi == 3 and data.levelLo == 3 then
        -- first maze junction
        -- xscroll between 0,175 and 1,226.  ypos between 1,140 and 1,176.
        if ((data.xscrollHi == 0 and data.xscrollLo >= 175) or (data.xscrollHi == 1 and data.xscrollLo <= 226)) and (data.yposHi == 1 and data.yposLo >= 140 and data.yposLo <= 176) then
            local reward = -12.5
            if debug then print('stage4_4_penalty: ', reward) end
            return reward

        -- second maze junction
        -- xscroll between 5,244 and 6,20.  ypos less than 1,128.
        elseif ((data.xscrollHi == 5 and data.xscrollLo >= 244) or (data.xscrollHi == 6 and data.xscrollLo <= 20)) and (data.yposHi == 1 and data.yposLo <= 128) then
            local reward = -12.5
            if debug then print('stage4_4_penalty: ', reward) end
            return reward

        -- after taking first junction the world can still loop if mario jumps in certain places
        -- if xscrollHi goes to 255 while up above this indicates it looped
        elseif (data.xscrollHi == 255) and (data.yposHi == 1 and data.yposLo == 64) then
            local reward = -5
            if debug then print('stage4_4_penalty: ', reward) end
            return reward

        -- after taking second junction the world can still loop if mario jumps in certain places
        -- if xscrollHi goes to 3 while down below this indicates it looped
        elseif (data.xscrollHi == 3 and data.xscrollLo >= 190) and (data.yposHi == 1 and data.yposLo == 176) then
            local reward = -5
            if debug then print('stage4_4_penalty: ', reward) end
            return reward

        else
            return 0
        end
    else
        return 0
    end
end



-- TRACKERS --

function lives_tracker ()
    if data.lives < previous_lives then
        previous_lives = data.lives
        is_dying = false
    end
    return 0
end




-- DONES --

function stage4_4_done ()
    if data.levelHi == 3 and data.levelLo == 3 then
        -- first maze junction
        -- xscroll between 0,175 and 1,226.  ypos between 1,140 and 1,176.
        if ((data.xscrollHi == 0 and data.xscrollLo >= 175) or (data.xscrollHi == 1 and data.xscrollLo <= 226)) and (data.yposHi == 1 and data.yposLo >= 140 and data.yposLo <= 176) then
            return true

        -- second maze junction
        -- xscroll between 5,244 and 6,20.  ypos less than 1,128.
        elseif ((data.xscrollHi == 5 and data.xscrollLo >= 244) or (data.xscrollHi == 6 and data.xscrollLo <= 20)) and (data.yposHi == 1 and data.yposLo <= 128) then
            return true

        -- after taking first junction the world can still loop if mario jumps in certain places
        -- if xscrollHi goes to 255 while up above this indicates it looped
        elseif (data.xscrollHi == 255) and (data.yposHi == 1 and data.yposLo == 64) then
            return true

        -- after taking second junction the world can still loop if mario jumps in certain places
        -- if xscrollHi goes to 3 while down below this indicates it looped
        elseif (data.xscrollHi == 3 and data.xscrollLo >= 190) and (data.yposHi == 1 and data.yposLo == 176) then
            return true

        else
            return false
        end
    else
        return false
    end
end


function lives_done ()
    if data.lives == -1 then
        return true
    else
        return false
    end
end


function stage_done ()
    -- stop at stage 7-4
    if data.levelHi == 6 and data.levelLo == 3 then
        return true
    else
        return false
    end
end




-- CALLED --

function sum_reward ()
    return xscrollLo_reward() + levelLo_reward() + levelHi_reward() + pipe_reward() + dying_penalty() + lives_tracker() + stage4_4_penalty()
end


function any_done ()
    return lives_done() or stage4_4_done() or stage_done()
end















-- UNUSED --

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


function stuck_penalty ()
    -- penalize if not making forward progress after some time
    -- helps avoid running out the clock at checkpoints on 1-3, 4-3 and 5-3
    -- doesn't work for exit pipes on 2-2 and 7-2
    -- on 7-2 is quickly killed by octopus anyway
    if stuck_counter > 400 then
        local reward = -0.1
        if debug then print('stuck_penalty: ', reward) end
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


function stuck_tracker ()
    -- scroll_lock is 1 at end of -4 stages (bowser)
    -- and also end of 2-2 and 7-2 (underwater)
    if data.state == 8 and is_dying == false and data.scroll_lock == 0 then
        stuck_counter = stuck_counter + 1
    else
        stuck_counter = 0
    end
    --print(stuck_counter, data.state, is_dying, data.yposHi, data.yposLo, data.scroll_lock)
    return 0
end