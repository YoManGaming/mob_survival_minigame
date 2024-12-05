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
    return data
end