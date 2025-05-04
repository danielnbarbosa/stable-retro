previous_mission = 0
previous_part = 0
previous_section = 0
previous_score = 0
previous_enemy1_health = 0
previous_enemy2_health = 0

previous_lives = 2
previous_health = 64

-- The game has 4 missions.  Missions are divided into parts.  Parts are divided into sections.
-- Note that in the code everything is 0 indexed.
-- Mission 1 (parts-sections): 1-1, 1-2, 1-3, 1-4, 2-1
-- Mission 2 (parts-sections): 1-1, 1-2, 1-3, 1-4
-- Mission 3 (parts-sections): TBD
-- Mission 4 (parts-sections): TBD

-- Rewards

function mission_reward ()
    -- reward when mission increments
    if data.mission > previous_mission then
        local delta = data.mission - previous_mission
        previous_mission = data.mission
        return delta * 500
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
        return delta * 500
    else
        return 0
    end
end


function section_reward ()
    -- reward when section increments
    if data.section == 0 then
        previous_section = 0
        return 0
    elseif data.section > previous_section then
        local delta = data.section - previous_section
        previous_section = data.section
        return delta * 500
    else
        return 0
    end
end


function enemy1_health_reward ()
    -- reward when enemy1_health decrements
    local kill_bonus = 0

    -- when a new enemy arrives, reset previous_enemy1_health
    if data.enemy1_health > 0 and previous_enemy1_health == 0 then
        previous_enemy1_health = data.enemy1_health
        return 0
     -- return delta of enemy1_health
    elseif data.enemy1_health < previous_enemy1_health then
        local delta = previous_enemy1_health - data.enemy1_health
        previous_enemy1_health = data.enemy1_health
        -- give an extra reward for killing them
        if data.enemy1_health == 0 then
            kill_bonus = 20
        end
        return delta * 5 + kill_bonus
    else
        return 0
    end
end


function enemy2_health_reward ()
    -- reward when enemy2_health decrements
    local kill_bonus = 0

    -- when a new enemy arrives, reset previous_enemy2_health
    if data.enemy2_health > 0 and previous_enemy2_health == 0 then
        previous_enemy2_health = data.enemy2_health
        return 0
     -- return delta of enemy2_health
    elseif data.enemy2_health < previous_enemy2_health then
        local delta = previous_enemy2_health - data.enemy2_health
        previous_enemy2_health = data.enemy2_health
        -- give an extra reward for killing them
        if data.enemy2_health == 0 then
            kill_bonus = 20
        end
        return delta * 5 + kill_bonus
    else
        return 0
    end
end


function score_reward ()
    -- reward when score increments
    if data.score > previous_score then
        local delta = data.score - previous_score
        previous_score = data.score
        return delta * 1
    else
        return 0
    end
end


-- Penalties

function lives_reward ()
    -- penalty when lives decrements
    if data.lives < previous_lives then
        local delta = data.lives - previous_lives
        previous_lives = data.lives
        return delta * 200
    else
        return 0
    end
end


function health_reward ()
    -- penalty when health decrements

    -- if health goes to 0 then reset previous_health too
    -- this covers issues like time running out, falling off cliff, and transitioning to next part
    -- NOTE: this means getting beat to death won't be penalized for the final decrement to 0
    -- but this should be covered by the large lives penalty
    if data.health == 0 then
        previous_health = 0
        return 0
     -- return delta of health
    elseif data.health < previous_health then
        local delta = data.health - previous_health
        previous_health = data.health
        return delta * 5
    else
        return 0
    end
end



function sum_reward ()
    return mission_reward() + part_reward() + section_reward() + enemy1_health_reward() + enemy2_health_reward() + lives_reward() + health_reward()
    -- return enemy1_health_reward() + enemy2_health_reward()
    -- return 0
end