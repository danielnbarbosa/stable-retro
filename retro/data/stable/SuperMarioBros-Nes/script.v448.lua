previous_xscrollLo = data.xscrollLo
previous_xscrollHi = data.xscrollHi
previous_progress = data.progress
previous_lives = data.lives
is_dying = false
is_looped = false
got_high_pipe_reward01 = false
got_high_pipe_reward02 = false
got_underwater_reward01 = false
got_underwater_reward02 = false

debug = false


-- REWARDS --

function xscrollLo_reward ()
    -- only give reward if ypos is above level of a pit
    -- this avoids harvesting reward on big jumps into air
    -- as seen in stages 1-3, 4-3 and 5-3
    if data.xscrollLo > previous_xscrollLo and data.yposHi <= 1 and data.yposLo <= 176 then
        local delta = data.xscrollLo - previous_xscrollLo
        local reward = (delta * 0.1)
        previous_xscrollLo = data.xscrollLo
        if debug then print('xscrollLo_reward: ', reward) end
        return reward
    else
        previous_xscrollLo = data.xscrollLo
        return 0
    end
end


function dying_penalty ()
    -- if hit by enemy
    if data.state == 11 and data.time ~= 0 and is_dying == false then
        local reward = -5
        if debug then print('dying_penalty: ', reward) end
        is_dying = true
        return reward
    -- if time runs out
    elseif data.state == 11 and data.time == 0 and is_dying == false then
        local reward = -5
        if debug then print('dying_penalty: ', reward) end
        print(string.format("!!!!!!!!!! TIMEOUT !!!!!!!!!!!!  World: %d-%d.  Xscroll: %d, %d.  Dst: %d", data.levelHi + 1, data.levelLo + 1, data.xscrollHi, data.xscrollLo, data.progress))
        is_dying = true
        return reward
    -- if fall into pit
    elseif data.state == 8 and data.yposHi == 1 and data.yposLo > 176 and is_dying == false then
        local reward = -12.5
        --- reduce the die_pit penalty to -5 on stage 8-4
        --- or else gets discouraged to try jumping over big pits
        if data.levelHi == 7 and data.levelLo == 3 then
            reward = -5
        end
        if debug then print('dying_penalty: ', reward) end
        is_dying = true
        return reward
    else
        return 0
    end
end


function stage4_4_penalty ()
    -- custom reward function for stage 4-4
    if data.levelHi == 3 and data.levelLo == 3 then
        -- loop check
        if data.state == 8 and is_looped then
            local reward = -12.5
            data.state = 6
            if debug then print('stage4_4_penalty: ', reward) end
            return reward

        -- second maze junction
        elseif ((data.xscrollHi == 5 and data.xscrollLo >= 210) or (data.xscrollHi == 6 and data.xscrollLo <= 20)) and (data.yposHi == 1 and data.yposLo <= 128) and data.state == 8 then
            local reward = -12.5
            data.state = 6
            if debug then print('stage4_4_penalty: ', reward) end
            return reward

        else
            return 0
        end
    else
        return 0
    end
end


function stage7_4_penalty ()
    -- custom reward function for stage 7-4
    if data.levelHi == 6 and data.levelLo == 3 then
        -- loop check
        if data.state == 8 and is_looped then
            local reward = -12.5
            data.state = 6
            if debug then print('stage7_4_penalty: ', reward) end
            return reward

        -- first maze junction
        elseif ((data.xscrollHi == 1 and data.xscrollLo >= 195) or (data.xscrollHi == 2 and data.xscrollLo <= 24)) and (data.yposHi == 1 and data.yposLo <= 112) and data.state == 8 then
            local reward = -12.5
            data.state = 6
            if debug then print('stage7_4_penalty: ', reward) end
            return reward
        
        else
            return 0
        end
    else
        return 0
    end
end


function stage8_4_penalty ()
    -- custom reward function for stage 8-4
    -- defines deathboxes and checkpoints to guide the maze navigation
    if data.levelHi == 7 and data.levelLo == 3 then

        ------- section 1 -------
        -- don't loop, die
        if (data.xscrollHi == 0 or data.xscrollHi == 1) and (data.xpos >= 90 and data.xpos < 130) and (data.yposHi == 1 and data.yposLo <= 128) and data.enemy_present == 0 and data.state == 8 then
            local reward = -12.5
            data.state = 6
            if debug then print('stage8_4_penalty: ', reward) end
            return reward


        ------- section 2 -------
        -- get on top of block
        elseif data.xscrollHi == 9 and (data.yposHi == 1 and data.yposLo == 112) and data.float_state == 0 and got_high_pipe_reward01 == false then
            local reward = 20
            got_high_pipe_reward01 = true
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

        -- get on top of high pipe
        elseif data.xscrollHi == 9 and (data.yposHi == 1 and data.yposLo == 64) and data.float_state == 0 and got_high_pipe_reward02 == false then
            local reward = 20
            got_high_pipe_reward02 = true
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

        -- don't loop, die
        elseif (data.xscrollHi == 9 and data.xpos >= 166 and data.xpos <= 216) and (data.yposHi == 1 and data.yposLo <= 176) and data.state == 8 then
            local reward = -12.5
            data.state = 6
            if debug then print('stage8_4_penalty: ', reward) end
            return reward


        ------- section 3 -------
       -- don't loop, die
        elseif (data.xscrollHi == 14 and data.xpos >= 140 and data.xpos <= 190) and (data.yposHi == 1 and data.yposLo <= 176) and data.state == 8 then
            local reward = -12.5
            data.state = 6
            if debug then print('stage8_4_penalty: ', reward) end
            return reward


        ------- section 4 -------
        -- get in front of corridor
        elseif data.xscrollHi == 1 and data.xscrollLo >= 243 and (data.yposHi == 1 and data.yposLo >= 100) and data.swimming == 1 and got_underwater_reward01 == false then
            local reward = 20
            got_underwater_reward01 = true
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

        -- get in front of pipe
        elseif data.xscrollHi == 3 and data.xscrollLo >= 128 and (data.yposHi == 1 and data.yposLo >= 97) and data.swimming == 1 and got_underwater_reward02 == false then
            local reward = 20
            got_underwater_reward02 = true
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

        ------- section 5 -------
        -- if beat bowswer need a big reward for finishing the game
        elseif data.xscrollHi == 18 and data.xscrollLo == 255 then
            local reward = 1000
            if debug then print('stage8_4_penalty: ', reward) end
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

function progress_tracker ()
    -- if progress is incrementing or at the start of the stage
    if data.progress > previous_progress or (data.xscrollHi == 0 and data.xscrollLo == 0) then
        previous_progress = data.progress
        is_looped = false
    elseif data.progress < previous_progress then
        previous_progress = data.progress
        is_looped = true
    end
    return 0
end

function checkpoint_tracker ()
    -- if die after passing a checkpoint, restart at begining of the stage
    if data.state == 6 then
        data.xscrollHi = 0
    end
    return 0
end




-- DONES --

function lives_done ()
    if data.lives == -1 then
        return true
    else
        return false
    end
end


function stage_done ()
    -- stop at stage 8-1
    if data.levelHi == 7 and data.levelLo == 0 then
        return true
    else
        return false
    end
end


function game_done ()
    -- finished the game
    if data.levelHi == 7 and data.levelLo == 3 and data.xscrollHi == 18 and data.xscrollLo == 255 then
        return true
    else
        return false
    end
end






-- CALLED --

function sum_reward ()
    return xscrollLo_reward() + dying_penalty() + lives_tracker() + progress_tracker() + checkpoint_tracker() + stage4_4_penalty() + stage7_4_penalty() + stage8_4_penalty()
end


function any_done ()
    return lives_done() or game_done()
end
