previous_xscrollLo = data.xscrollLo
previous_xscrollHi = data.xscrollHi
previous_score = data.score
previous_levelLo = data.levelLo
previous_levelHi = data.levelHi
previous_lives = data.lives
is_dying = false
is_looped = false
got_high_pipe_reward01 = false
got_high_pipe_reward02 = false

debug = false


-- REWARDS --

function xscrollLo_reward ()
    -- only give reward if ypos is above level of a pit
    -- this avoids harvesting reward on big jumps into air
    -- as seen in stages 1-3, 4-3 and 5-3
    --
    -- also don't give reward if time is 0
    -- this avoids a little reward after dying on castle mazes (4-4, 7-4. 8-4)
    -- where we set time = 0 to trigger a soft done
    if data.xscrollLo > previous_xscrollLo and data.yposHi <= 1 and data.yposLo <= 176 and data.time ~= 0 then
        -- only give rewards when feet are on the ground
        -- this avoids harvesting reward on big jumps into air
        -- as seen in stages 1-3, 4-3 and 5-3
        -- have to make exception for underwater stages where float_state is often non zero while swimming
        if data.float_state == 0 or (data.levelHi == 1 and data.levelLo == 1) or (data.levelHi == 6 and data.levelLo == 1) then
            local delta = data.xscrollLo - previous_xscrollLo
            local reward = (delta * 0.1)
            previous_xscrollLo = data.xscrollLo
            if debug then print('xscrollLo_reward: ', reward) end
            return reward
        else
            return 0
        end
    else
        previous_xscrollLo = data.xscrollLo
        return 0
    end
end


function levelLo_reward ()
    -- big reward for finishing a level
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
    -- big reward for finishing a level
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
    if data.state == 11 and data.time ~= 0 and is_dying == false then
        local reward = -5
        if debug then print('dying_penalty: ', reward) end
        is_dying = true
        return reward
    -- if time runs out
    elseif data.state == 11 and data.time == 0 and is_dying == false then
        local reward = -5
        if debug then print('dying_penalty: ', reward) end
        --- print('!!!!!!!!!! TIMEOUT !!!!!!!!!!!!', data.levelHi + 1, '-', data.levelLo + 1)
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
    -- defines deathboxes to guide the maze navigation
    -- need to add -5 from timeout to penalty specified below
    if data.levelHi == 3 and data.levelLo == 3 then
        -- first maze junction
        -- xscroll between 0,175 and 1,226.  ypos between 1,140 and 1,176.
        if ((data.xscrollHi == 0 and data.xscrollLo >= 175) or (data.xscrollHi == 1 and data.xscrollLo <= 226)) and (data.yposHi == 1 and data.yposLo >= 140 and data.yposLo <= 176) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage4_4_penalty: ', reward) end
            return reward

        -- second maze junction
        -- xscroll between 5,244 and 6,20.  ypos less than 1,128.
        elseif ((data.xscrollHi == 5 and data.xscrollLo >= 244) or (data.xscrollHi == 6 and data.xscrollLo <= 20)) and (data.yposHi == 1 and data.yposLo <= 128) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage4_4_penalty: ', reward) end
            return reward

        -- after taking first junction the world can still loop if mario jumps in certain places
        -- if xscrollHi goes to 255 while up above this indicates it looped
        elseif (data.xscrollHi == 255) and (data.yposHi == 1 and data.yposLo <= 64) and data.time ~= 0 then
            local reward = 0
            data.time = 0
            if debug then print('stage4_4_penalty: ', reward) end
            return reward

        -- after taking second junction the world can still loop if mario jumps in certain places
        -- if xscrollHi goes to 3 while down below this indicates it looped
        elseif (data.xscrollHi == 3 and data.xscrollLo >= 190) and (data.yposHi == 1 and data.yposLo >= 156 and data.yposLo <= 176) and data.time ~= 0 then
            local reward = 0
            data.time = 0
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
    -- defines deathboxes to guide the maze navigation
    -- need to add -5 from timeout to penalty specified below
    if data.levelHi == 6 and data.levelLo == 3 then
        -- first maze junction
        -- xscroll between 1,226 and 2,24.  ypos less than 1,112.
        if ((data.xscrollHi == 1 and data.xscrollLo >= 195) or (data.xscrollHi == 2 and data.xscrollLo <= 24)) and (data.yposHi == 1 and data.yposLo <= 112) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage7_4_penalty: ', reward) end
            return reward

        -- second maze junction
        -- xscroll between 2,245 and 3,50.  ypos between 1,156 and 1,176.
        elseif ((data.xscrollHi == 2 and data.xscrollLo >= 245) or (data.xscrollHi == 3 and data.xscrollLo <= 50)) and (data.yposHi == 1 and data.yposLo >= 156 and data.yposLo <= 176) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage7_4_penalty: ', reward) end
            return reward
        -- xscroll between 3,40 and 3,90.  ypos between 1,28 and 1,64.
        elseif (data.xscrollHi == 3 and data.xscrollLo >= 40 and data.xscrollLo <= 90) and (data.yposHi == 1 and data.yposLo >= 28 and data.yposLo <= 64) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage7_4_penalty: ', reward) end
            return reward

        -- third maze junction
         -- xscroll between 4,50 and 4,80.  ypos between 1,142 and 1,176.
        elseif (data.xscrollHi == 4 and data.xscrollLo >= 50 and data.xscrollLo <= 80) and (data.yposHi == 1 and data.yposLo >= 142 and data.yposLo <= 176) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage7_4_penalty: ', reward) end
            return reward

        -- world can still loop if mario jumps in certain places.
        -- xscroll between 0,131 and 0,191.  ypos is 1,64.
        elseif (data.xscrollHi == 0 and data.xscrollLo >= 131 and data.xscrollLo <= 181) and (data.yposHi == 1 and data.yposLo <= 64) and data.enemy_present == 0 and data.time ~= 0 then
            local reward = 0
            data.time = 0
            if debug then print('stage7_4_penalty: ', reward) end
            return reward

        -- fourth maze junction
         -- xscroll between 5,194 and 6.140.  ypos between 1,110 and 1,176.
        elseif ((data.xscrollHi == 5 and data.xscrollLo >= 194) or (data.xscrollHi == 6 and data.xscrollLo <= 140)) and (data.yposHi == 1 and data.yposLo >= 110 and data.yposLo <= 176) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage7_4_penalty: ', reward) end
            return reward

        -- fifth maze junction
        -- xscroll between 7,94 and 7,230.  ypos less than 1,64.
        elseif (data.xscrollHi == 7 and data.xscrollLo >= 94 and data.xscrollLo <= 230) and (data.yposHi == 1 and data.yposLo <= 64) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage7_4_penalty: ', reward) end
            return reward
        -- xscroll between 7,91 and 7,190.  ypos between 1,140 and 1,176.
        elseif (data.xscrollHi == 7 and data.xscrollLo >= 91 and data.xscrollLo <= 190) and (data.yposHi == 1 and data.yposLo >= 140 and data.yposLo <= 176) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage7_4_penalty: ', reward) end
            return reward

        -- sixth maze junction
        -- xscroll between 7,230 and 8,78.  ypos between 1,140 and 1,176.
        elseif ((data.xscrollHi == 7 and data.xscrollLo >= 230) or (data.xscrollHi == 8 and data.xscrollLo <= 78)) and (data.yposHi == 1 and data.yposLo >= 140 and data.yposLo <= 176) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage7_4_penalty: ', reward) end
            return reward

        -- world can still loop if mario jumps in certain places.
        -- xscroll between 4,150 and 4,250.  ypos is 1,64.
        elseif (data.xscrollHi == 4 and data.xscrollLo >= 150 and data.xscrollLo <= 250) and (data.yposHi == 1 and data.yposLo <= 64) and is_looped == true and data.time ~= 0 then
            local reward = 0
            data.time = 0
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
    -- defines deathboxes to guide the maze navigation
    -- need to add -5 from timeout to penalty specified below
    if data.levelHi == 7 and data.levelLo == 3 then

        ------- section 1 -------
        -- don't go in second pipe
        if (data.xscrollHi == 2 or data.xscrollHi == 3) and (data.yposHi == 1 and data.yposLo == 144) and data.state == 3 and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

       -- don't loop
        elseif (data.xscrollHi == 1 and data.xscrollLo >= 28 and data.xscrollLo <= 68) and (data.yposHi == 1 and data.yposLo <= 128) and data.enemy_present == 0 and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage8_4_penalty: ', reward) end
            return reward


        ------- section 2 -------
        -- don't go in second pipe
        elseif (data.xscrollHi == 7 or data.xscrollHi == 8) and (data.yposHi == 1 and data.yposLo == 144) and data.state == 3 and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

        -- get up to block
        elseif data.xscrollHi == 9 and (data.yposHi == 1 and data.yposLo == 112) and data.float_state == 0 and got_high_pipe_reward01 == false then
            local reward = 20
            got_high_pipe_reward01 = true
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

        -- get up to high pipe
        elseif data.xscrollHi == 9 and (data.yposHi == 1 and data.yposLo == 64) and data.float_state == 0 and got_high_pipe_reward02 == false then
            local reward = 20
            got_high_pipe_reward02 = true
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

       -- don't loop
        elseif (data.xscrollHi == 9 and data.xscrollLo >= 90 and data.xscrollLo <= 120) and (data.yposHi == 1 and data.yposLo <= 176) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage8_4_penalty: ', reward) end
            return reward


        ------- section 3 -------
        -- don't go in second pipe
        elseif (data.xscrollHi == 12 or data.xscrollHi == 13) and (data.yposHi == 1 and data.yposLo == 80) and data.state == 3 and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

       -- don't loop
        elseif (data.xscrollHi == 14 and data.xscrollLo >= 70 and data.xscrollLo <= 120) and (data.yposHi == 1 and data.yposLo <= 176) and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage8_4_penalty: ', reward) end
            return reward


        ------- section 5 -------
        -- don't go in first pipe
        elseif data.xscrollHi == 16 and (data.yposHi == 1 and data.yposLo == 144) and data.state == 3 and data.time ~= 0 then
            local reward = -7.5
            data.time = 0
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

        -- if beat bowswer need a reward for finishing the game
        elseif data.xscrollHi == 18 and data.xscrollLo == 255 then
            local reward = 100
            if debug then print('stage8_4_penalty: ', reward) end
            return reward

        else
            return 0
        end
    else
        return 0
    end
end


function checkpoint_penalty ()
    -- mario is unable to proceed from checkpoints at 1-3, 4-3 and 5-3
    -- if on one of these level and he dies past a checkpoint, restart at start of level instead of the checkpoint
    if (data.levelHi == 0 or data.levelHi == 3 or data.levelHi == 4) and data.levelLo == 2 and data.xscrollHi >= 4 and data.state == 6 then
        data.xscrollHi = 0
        return 0
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


function xscrollHi_tracker ()
    if data.xscrollHi > previous_xscrollHi or data.xscrollHi == 0 then
        previous_xscrollHi = data.xscrollHi
        is_looped = false
    elseif data.xscrollHi < previous_xscrollHi then
        previous_xscrollHi = data.xscrollHi
        is_looped = true
    end
    --print(previous_xscrollHi, data.xscrollHi, data.xscrollLo, is_looped)
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
    -- stop at stage 8-4
    if data.levelHi == 7 and data.levelLo == 3 then
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
    return xscrollLo_reward() + levelLo_reward() + levelHi_reward() + pipe_reward() + dying_penalty() + lives_tracker() + xscrollHi_tracker() + stage4_4_penalty() + stage7_4_penalty() + stage8_4_penalty() + checkpoint_penalty()
end


function any_done ()
    return lives_done() or game_done()
end















-- UNUSED --


function xpos_reward ()
    -- give reward for first 40 steps before xscroll kicks in
    if data.xpos > previous_xpos and previous_xpos < 80 then
        local delta = data.xpos - previous_xpos
        local reward = (delta * 0.1)
        previous_xpos = data.xpos
        if debug then print('xpos_reward: ', reward) end
        return reward
    else
        return 0
    end
end


function checkpoint_done ()
    -- mario is unable to proceed from checkpoints at 1-3, 4-3 and 5-3
    -- if we are at one of these checkpoints just end the episode
    if (data.levelHi == 0 or data.levelHi == 3 or data.levelHi == 4) and data.levelLo == 2 and data.time == 300 and data.xscrollHi == 4 then
        return true
    else
        return false
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
        elseif (data.xscrollHi == 255) and (data.yposHi == 1 and data.yposLo <= 64) then
            return true

        -- after taking second junction the world can still loop if mario jumps in certain places
        -- if xscrollHi goes to 3 while down below this indicates it looped
        elseif (data.xscrollHi == 3 and data.xscrollLo >= 190) and (data.yposHi == 1 and data.yposLo >= 156 and data.yposLo <= 176) then
            return true

        else
            return false
        end
    else
        return false
    end
end


function stage7_4_done ()
    if data.levelHi == 6 and data.levelLo == 3 then
        -- first maze junction
        -- xscroll between 1,226 and 2,24.  ypos less than 1,112.
        if ((data.xscrollHi == 1 and data.xscrollLo >= 195) or (data.xscrollHi == 2 and data.xscrollLo <= 24)) and (data.yposHi == 1 and data.yposLo <= 112) then
            return true

        -- second maze junction
        -- xscroll between 2,245 and 3,50.  ypos between 1,156 and 1,176.
        elseif ((data.xscrollHi == 2 and data.xscrollLo >= 245) or (data.xscrollHi == 3 and data.xscrollLo <= 50)) and (data.yposHi == 1 and data.yposLo >= 156 and data.yposLo <= 176) then
            return true
        -- xscroll between 3,40 and 3,90.  ypos between 1,28 and 1,64.
        elseif (data.xscrollHi == 3 and data.xscrollLo >= 40 and data.xscrollLo <= 90) and (data.yposHi == 1 and data.yposLo >= 28 and data.yposLo <= 64) then
            return true

        -- third maze junction
         -- xscroll between 4,50 and 4,80.  ypos between 1,142 and 1,176.
        elseif (data.xscrollHi == 4 and data.xscrollLo >= 50 and data.xscrollLo <= 80) and (data.yposHi == 1 and data.yposLo >= 142 and data.yposLo <= 176) then
            return true

        -- world can still loop if mario jumps in certain places.
        -- xscroll between 0,131 and 0,191.  ypos is 1,64.
        elseif (data.xscrollHi == 0 and data.xscrollLo >= 131 and data.xscrollLo <= 181) and (data.yposHi == 1 and data.yposLo <= 64) and data.enemy_present == 0 then
            return true

        -- fourth maze junction
         -- xscroll between 5,194 and 6.140.  ypos between 1,110 and 1,176.
        elseif ((data.xscrollHi == 5 and data.xscrollLo >= 194) or (data.xscrollHi == 6 and data.xscrollLo <= 140)) and (data.yposHi == 1 and data.yposLo >= 110 and data.yposLo <= 176) then
            return true

        -- fifth maze junction
        -- xscroll between 7,94 and 7,230.  ypos less than 1,64.
        elseif (data.xscrollHi == 7 and data.xscrollLo >= 94 and data.xscrollLo <= 230) and (data.yposHi == 1 and data.yposLo <= 64) then
            return true
        -- xscroll between 7,91 and 7,190.  ypos between 1,140 and 1,176.
        elseif (data.xscrollHi == 7 and data.xscrollLo >= 91 and data.xscrollLo <= 190) and (data.yposHi == 1 and data.yposLo >= 140 and data.yposLo <= 176) then
            return true

        -- sixth maze junction
        -- xscroll between 7,230 and 8,78.  ypos between 1,140 and 1,176.
        elseif ((data.xscrollHi == 7 and data.xscrollLo >= 230) or (data.xscrollHi == 8 and data.xscrollLo <= 78)) and (data.yposHi == 1 and data.yposLo >= 140 and data.yposLo <= 176) then
            return true

        -- world can still loop if mario jumps in certain places.
        -- xscroll between 4,150 and 4,250.  ypos is 1,64.
        elseif (data.xscrollHi == 4 and data.xscrollLo >= 150 and data.xscrollLo <= 250) and (data.yposHi == 1 and data.yposLo <= 64) and is_looped == true then
            return true

        else
            return false
        end
    else
        return false
    end
end