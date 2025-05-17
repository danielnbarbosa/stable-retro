previous_mission = data.mission
previous_part = data.part
previous_screen = data.screen
previous_score = data.score
previous_enemy1_health = data.enemy1_health
previous_enemy2_health = data.enemy2_health
previous_x_pos = data.x_pos
previous_y_pos = data.y_pos
previous_x_pos_too_far01 = 0
previous_x_pos_too_far02 = 0
previous_x_pos_too_far03 = 0
previous_x_pos_player = 0

previous_lives = data.lives
previous_health = data.health

steps_to_reset_life = 40 * 4
died_n_steps_ago = 10000

in_stage3_2_7 = false
past_platforms = false


debug = true

-- The game has 4 missions.  Missions are divided into parts.  Parts are divided into sections.
-- Note that in the code everything is 0 indexed.
-- Mission 1 (parts-sections): 1-1, 1-2, 1-3, 1-4, 1-5, 2-1, 2-2
-- Mission 2 (parts-sections): 1-1, 1-2, 1-3, 1-4
-- Mission 3 (parts-sections): 1-1, 1-2, 1-3, 1-4, 1-5, 1-6, 2-1, 2-2, 2-3, 2-4, 3-1, 3-2, 3-3, 3-4, 3-5, 3-6, 4-1, 4-2
-- Mission 4 (parts-sections): TBD



---------------
--- Rewards ---
---------------

function mission_reward ()
    -- reward when mission increments
    if data.mission > previous_mission then
        local delta = data.mission - previous_mission
        previous_mission = data.mission
        if debug then print('mission_reward: ', delta * 50) end
        return delta * 50
    else
        return 0
    end
end


function part_reward ()
    -- reward when part increments
    if data.part == 0 then
        previous_part = 0
        return 0
    elseif data.part > previous_part then
        local delta = data.part - previous_part
        previous_part = data.part
        if debug then print('part_reward: ', delta * 50) end
        return delta * 50
    else
        return 0
    end
end


function screen_reward ()
    -- reward when screen increments
    if data.screen == 0 then
        previous_screen = 0
        return 0
    elseif data.screen > previous_screen then
        local delta = data.screen - previous_screen
        previous_screen = data.screen
        if debug then print('screen_reward: ', delta * 2) end
        return delta * 2
    else
        return 0
    end
end


function enemy1_health_reward ()
    -- reward when enemy1_health decrements
    local kill_bonus = 0

    -- print(data.enemy1_health, previous_enemy1_health)

     -- return delta of enemy1_health
    if data.enemy1_health < previous_enemy1_health and not died_recently then
        local delta = previous_enemy1_health - data.enemy1_health
        previous_enemy1_health = data.enemy1_health
        -- give an extra reward for killing them
        if data.enemy1_health == 0 then
            kill_bonus = 4
        end
        if debug then print('enemy1_health_reward: ', delta + kill_bonus) end
        return delta + kill_bonus
    else
        previous_enemy1_health = data.enemy1_health
        return 0
    end
end


function enemy2_health_reward ()
    -- reward when enemy2_health decrements
    local kill_bonus = 0

     -- return delta of enemy2_health
    if data.enemy2_health < previous_enemy2_health and not died_recently then
        local delta = previous_enemy2_health - data.enemy2_health
        previous_enemy2_health = data.enemy2_health
        -- give an extra reward for killing them
        if data.enemy2_health == 0 then
            kill_bonus = 4
        end
        if debug then print('enemy2_health_reward:', delta + kill_bonus) end
        return delta + kill_bonus
    else
        previous_enemy2_health = data.enemy2_health
        return 0
    end
end


function x_pos_reward ()
    -- for passing a mission
    if data.x_pos == 0 and not died_recently then
        previous_x_pos = 0
        return 0
    -- after dying, x_pos resets to start of scenario
    -- its briefly at 0 before resetting which is why there is the check
    elseif data.x_pos < previous_x_pos and data.x_pos ~= 0 and died_recently then
        previous_x_pos = data.x_pos
        return 0
    -- reward when x_pos increments
    elseif data.x_pos > previous_x_pos and not died_recently then
        local delta = data.x_pos - previous_x_pos
        previous_x_pos = data.x_pos
        if debug then print('x_pos_reward: ', delta * 0.03) end
        return delta * 0.03
    else
        return 0
    end
end


function x_pos_player_reward01 ()
    -- reward for moving player in a specific direction
    -- in stage 3-2-1 needs to move right through the (very painful) stalactites
    -- without a more granular reward will just not advance

    if data.mission == 2 and data.part == 1 and data.section == 0 and data.screen == 0 then
        if x_pos_player <= 104 then
            previous_x_pos_player = x_pos_player
            return 0
        elseif x_pos_player > previous_x_pos_player then
            local delta = x_pos_player - previous_x_pos_player
            previous_x_pos_player = x_pos_player
            if debug then print('x_pos_player_reward01: ', delta * 1) end
            return delta * 1
        else
            return 0
        end
    else
        return 0
    end
end


-----------------
--- Penalties ---
-----------------

function lives_reward ()
    -- keep track of when recently died to avoid incorrect rewards when new life starts

    if died_n_steps_ago < steps_to_reset_life then
        died_recently = true
    else
        died_recently = false
    end
    -- print(died_n_steps_ago, steps_to_reset_life, died_recently, data.x_pos, previous_x_pos)

    -- penalty when lives decrements
    if data.lives < previous_lives then
        local delta = data.lives - previous_lives
        previous_lives = data.lives
        died_n_steps_ago = 0
        if debug then print('lives_reward: ', delta * 10) end
        return delta * 10
    else
        died_n_steps_ago = died_n_steps_ago + 1
        return 0
    end
end


function health_reward ()
    -- penalty when health decrements

    -- health temporarily drops to 0 and then back to 64 on transition to new part/mission
    -- this should't be punished or rewarded
    if data.health == 0 and data.x_pos == 0 and data.enemy1_health == 0 and data.enemy2_health == 0 then
        previous_health = 0
        return 0
    elseif data.health == 64 and data.x_pos == 0 and data.enemy1_health == 0 and data.enemy2_health == 0 then
        previous_health = 64
        return 0
     -- return delta of health
    elseif data.health < previous_health then
        local delta = data.health - previous_health
        previous_health = data.health
        if debug then print('health_reward: ', delta * 1) end
        return delta * 1
    else
        return 0
    end
end


function x_pos_too_far_reward01 ()
    -- penalty for going too far right in certain parts of the game
    -- after abobos in mission 3, part 1, section 6 don't keep going right
    -- needs to go into the caves instead
    if data.mission == 2 and data.part == 0 and data.section == 5 and data.x_pos > 1536 and data.x_pos > previous_x_pos_too_far01 then
        local delta = data.x_pos - previous_x_pos_too_far01
        previous_x_pos_too_far01 = data.x_pos
        if debug then print('x_pos_too_far_reward01: ', delta * -2.5) end
        return delta * -2.5
    else
        previous_x_pos_too_far01 = data.x_pos
        return 0
    end
end


function x_pos_too_far_reward02 ()
    -- penalty for going too far right in certain parts of the game
    -- after chintai in mission 3, part 2, section 4 don't keep going right
    -- needs to go into the door instead
    if data.mission == 2 and data.part == 1 and data.section == 3 and data.x_pos > 768 and data.x_pos > previous_x_pos_too_far02 then
        local delta = data.x_pos - previous_x_pos_too_far02
        previous_x_pos_too_far02 = data.x_pos
        if debug then print('x_pos_too_far_reward02: ', delta * -2.5) end
        return delta * -2.5
    else
        previous_x_pos_too_far02 = data.x_pos
        return 0
    end
end


function x_pos_too_far_reward03 ()
    -- penalty for going too far right in certain parts of the game
    -- after abobos in mission 3, part 3, section 6 don't keep going right
    -- needs to go into the cave instead
    if data.mission == 2 and data.part == 2 and data.section == 5 and data.x_pos > 768 and data.x_pos > previous_x_pos_too_far03 then
        local delta = data.x_pos - previous_x_pos_too_far03
        previous_x_pos_too_far03 = data.x_pos
        if debug then print('x_pos_too_far_reward03: ', delta * -2.5) end
        return delta * -2.5
    else
        previous_x_pos_too_far03 = data.x_pos
        return 0
    end
end

--------------
--- Unused ---
--------------

function score_reward ()
    -- reward when score increments
    if data.score > previous_score then
        local delta = data.score - previous_score
        previous_score = data.score
        return delta * 0.2
    else
        return 0
    end
end


function y_pos_reward ()
    -- reward when y_pos increments
    -- y_status:
    --   0 = down below
    --   1 = up top
    --   2 = climbing
    if data.y_pos == 0 then
        previous_y_pos = 0
        return 0
    elseif data.y_pos > previous_y_pos and data.y_status == 2 then
        local delta = data.y_pos - previous_y_pos
        previous_y_pos = data.y_pos
        return delta * 0.06
    else
        return 0
    end
end


function x_pos_player_reward02 ()
    -- penalty for falling off the platforms from stage 3-2-2 into stage 3-2-7
    -- needs to take the upper pathway and avoid the lower one which wraps back around

    if data.mission == 2 and data.part == 1 and data.section == 6 then
        if not in_stage3_2_7 then
            in_stage3_2_7 = true
            return -220
        else
            return 0
        end
    else
        in_stage3_2_7 = false
        return 0
    end
end


function x_pos_player_reward03 ()
    -- reward for moving player in a specific direction
    -- in stage 3-2-2 needs to jump right using the platforms
    -- as x_pos tracks the screen it doesn't provide reward until the end

    local x_pos_player = data.x_pos_player_mult * 254 + data.x_pos_player

    if data.mission == 2 and data.part == 1 and data.section == 1 then
        -- do not reward on life reset
        if previous_x_pos_player == 0 then
            previous_x_pos_player = x_pos_player
            return 0
        -- do not reward outside the platforms
        elseif x_pos_player <= 2 * 254 + 12 or x_pos_player > 2 * 254 + 236 then
            previous_x_pos_player = x_pos_player
            return 0
        -- do reward on the platforms but not if falling toward lower pathway
        elseif x_pos_player > previous_x_pos_player and data.y_pos >= 320 then
            local delta = x_pos_player - previous_x_pos_player
            previous_x_pos_player = x_pos_player
            return delta * 1
        else
            return 0
        end
    else
        return 0
    end
end


function x_pos_player_reward04 ()
    -- reward for getting past platforms on stage 3-2-2

    local x_pos_player = data.x_pos_player_mult * 254 + data.x_pos_player

    if data.mission == 2 and data.part == 1 and data.section == 1 and x_pos_player > 2 * 254 + 190 then
        if not past_platforms then
            past_platforms = true
            return 200
        else
            return 0
        end
    else
        past_platforms = false
        return 0
    end
end



function sum_reward ()
    return mission_reward() + part_reward() + screen_reward() + enemy1_health_reward() + enemy2_health_reward() + x_pos_reward() + lives_reward() + health_reward() + x_pos_too_far_reward01() + x_pos_too_far_reward02() + x_pos_too_far_reward03() + x_pos_player_reward01()
    -- return x_pos_reward() + lives_reward()
    -- return 0
end
