storage = minetest.get_mod_storage()
mob_survival.callbacks = {}

mcl_mobs.register_on_kill(function(mob_name, killer)
    mob_survival.track(mob_name, killer)
end)

-- SATLANTIS QUESTS API
function mob_survival.register_global_callback(func)
    table.insert(mob_survival.callbacks, func)
end


local function exec_global_callbacks(mob_name, killer)
    for i, callback in pairs(mob_survival.callbacks) do
        callback(mob_name, killer)
    end
end

-- LEADERBOARD API
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
    if not data then return end

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
    storage:set_string("highscores", "")
    return true
end

-- MOB KILLS QUESTS API
function mob_survival.register_tracker(mob_name, target, is_community)
    local trackers = minetest.deserialize(storage:get_string("trackers"))
    local tracker_progress = minetest.deserialize(storage:get_string("tracker_progress"))
    if not trackers then
        trackers = {}
    end
    if not tracker_progress then
        tracker_progress = {}
    end

    if is_community then
        trackers[mob_name.."|community"] = {is_community = true, target = target}
        tracker_progress[mob_name.."|community"] = {progress = 0, target = target, completed = false}
    else
        trackers[mob_name] = {is_community = false, target = target}
        tracker_progress[mob_name] = {}
    end

    -- Save Data
    storage:set_string("trackers", minetest.serialize(trackers))
    storage:set_string("tracker_progress", minetest.serialize(tracker_progress))
end

function mob_survival.remove_tracker(mob_name, is_community)
    local trackers = minetest.deserialize(storage:get_string("trackers"))
    local tracker_progress = minetest.deserialize(storage:get_string("tracker_progress"))
    if not trackers then
        trackers = {}
    end
    if not tracker_progress then
        tracker_progress = {}
    end

    local tracking_name
    if is_community then
        tracking_name = mob_name.."|community"
    else
        tracking_name = mob_name
    end

    tracker_progress[tracking_name] = nil
    trackers[tracking_name] = nil

    -- Save Data
    storage:set_string("trackers", minetest.serialize(trackers))
    storage:set_string("tracker_progress", minetest.serialize(tracker_progress))
end

local function startswith(string, start)
    return string:sub(1, #start) == start
end

function mob_survival.track(mob_name, player)
    local killer = player:get_player_name()
    exec_global_callbacks(mob_name, player)

    local trackers = minetest.deserialize(storage:get_string("trackers"))
    local tracker_progress = minetest.deserialize(storage:get_string("tracker_progress"))
    if not trackers then
        trackers = {}
    end
    if not tracker_progress then
        tracker_progress = {}
    end

    -- Is mob being tracked?
    local tracking_names = {}
    for k,v in pairs(trackers) do
        if startswith(k, mob_name) then
            table.insert(tracking_names, k)
        end
    end
    if tracking_names == {} then return end --Mob not found

    for _, tracking_name in pairs(tracking_names) do
        if trackers[tracking_name].is_community then
            if not tracker_progress[tracking_name].completed then
                tracker_progress[tracking_name].progress = tracker_progress[tracking_name].progress + 1
                if tracker_progress[tracking_name].progress == tracker_progress[tracking_name].target then
                    tracker_progress[tracking_name].completed = true
                end
            end
        else
            if tracker_progress[tracking_name][killer] then
                if not tracker_progress[tracking_name][killer].completed then
                    tracker_progress[tracking_name][killer] = {target = tracker_progress[tracking_name][killer].target, progress = tracker_progress[tracking_name][killer].progress + 1, completed=false}
                    if tracker_progress[tracking_name][killer].progress == tracker_progress[tracking_name][killer].target then
                        tracker_progress[tracking_name][killer].completed = true
                    end
                end
            else
                tracker_progress[tracking_name][killer] = {target = tracker_progress[tracking_name].target, progress = 1, completed = false}
                if tracker_progress[tracking_name][killer].progress == tracker_progress[tracking_name][killer].target then
                    tracker_progress[tracking_name][killer].completed = true
                end
            end
        end
    end

    -- Save data
    storage:set_string("trackers", minetest.serialize(trackers))
    storage:set_string("tracker_progress", minetest.serialize(tracker_progress))
end

function mob_survival.get_progress(mob_name, player)
    local trackers = minetest.deserialize(storage:get_string("trackers"))
    local tracker_progress = minetest.deserialize(storage:get_string("tracker_progress"))
    if not trackers then
        trackers = {}
    end
    if not tracker_progress then
        tracker_progress = {}
    end

    -- Is mob being tracked?
    if not player then
        if not trackers[mob_name.."|community"] then return end
    else
        if not trackers[mob_name] then return end
    end

    if not player then
        return tracker_progress[mob_name.."|community"]
    else
        return tracker_progress[mob_name][player]
    end
end