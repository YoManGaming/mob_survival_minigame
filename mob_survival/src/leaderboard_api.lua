storage = minetest.get_mod_storage()

function mob_survival.check_record_and_set(pl_name, waves_survived)
    local data = minetest.deserialize(storage:get_string("highscores"))

    if not data then
        data = {}
    end

    local highscore_beaten

    if data[pl_name] then
        if waves_survived > data[pl_name] then
            highscore_beaten = data[pl_name]
            data[pl_name] = waves_survived
        end
    else
        data[pl_name] = waves_survived
        highscore_beaten = data[pl_name]
    end

    storage:set_string("highscores", minetest.serialize(data))

    return highscore_beaten
end

function mob_survival.get_highscore(pl_name)
    local data = minetest.deserialize(storage:get_string("highscores"))
    return data[pl_name]
end

local function compare(a,b)
    return a["score"] > b["score"]
end
  
function mob_survival.get_leaderboard()
    local data = minetest.deserialize(storage:get_string("highscores"))
    local leaderboard = {}
    for pl_name, score in pairs(data) do
        local playertable = {}
        playertable["player"] = pl_name
        playertable["score"] = score
        table.insert(leaderboard, playertable)
    end
    table.sort(leaderboard, compare)
    return leaderboard
end

function mob_survival.reset_leaderboard()
    storage:set_string(minetest.serialize({}))
    return true
end