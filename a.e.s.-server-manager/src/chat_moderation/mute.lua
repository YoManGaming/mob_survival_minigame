local S = core.get_translator("server_manager")
local storage = core.get_mod_storage()
-- "pl_name" = {by = "name", expiration = <date in seconds>, reason = "reason"}
local muted =  core.deserialize(storage:get("muted")) or {}
local function format_remaining_time() end



--
-- API
--
function server_manager.mute(name, target_name, time, unit, reason)
    local mute_seconds

    if string.lower(unit) == "m" then
        mute_seconds = 60 * time
    elseif string.lower(unit) == "h" then
        mute_seconds = 60*60 * time
    else
        server_manager.warn_player(name, S(
            '@1 is not a valid unit',
            unit
        ))

        return
    end

    local expiration = os.time() + mute_seconds -- in seconds

    muted[target_name] = {
        by = name,
        expiration = expiration,
        reason = reason
    }

    server_manager.warn_server(S(
        '@1 has been muted by @2 for @3 (reason: @4)',
        target_name, name, time..unit, reason
    ))

    storage:set_string("muted", core.serialize(muted))
end



function server_manager.unmute(name, target_name)
    if not muted[target_name] then
        server_manager.warn_player(name, S(
            "@1 is not muted!",
            target_name
        ))
        return
    else
        muted[target_name] = nil

        server_manager.warn_server(S(
            '@1 has been unmuted by @2',
            target_name, name
        ))

        storage:set_string("muted", core.serialize(muted))
    end
end



function server_manager.is_muted(name)
    return muted[name]
end



--
-- CMDS
--
core.register_privilege("mute", {
    description = "It allows you to use /mute",
    give_to_singleplayer = false
})



-- MUTE
ChatCmdBuilder.new("mute", function(cmd)
    cmd:sub(":target :time:number :unit:alpha :reason:text", function(name, target_name, time, unit, reason)
        server_manager.mute(name, target_name, time, unit, reason)
    end)
end, {
  description = "mute <target> <time> <unit (m, h)> <reason>",
  privs = { mute = true }
})



-- UNMUTE
ChatCmdBuilder.new("unmute", function(cmd)
    cmd:sub(":target", function(name, target_name)
        server_manager.unmute(name, target_name)
    end)

end, {
  description = "unmute <target>",
  privs = { mute = true }
})



--
-- MUTE LOGIC
--
core.register_on_chat_message(function(name, message)
    if muted[name] then
        local remaining_seconds = muted[name].expiration - os.time()

        if remaining_seconds <= 0 then
            muted[name] = nil
            storage:set_string("muted", core.serialize(muted))
            return false
        end

        server_manager.warn_player(name, S(
            "You've been muted by @1 (reason: @2, remaining time: @3)",
            muted[name].by, muted[name].reason, format_remaining_time(remaining_seconds)
        ))

        return true
    else
        return false
    end
end)



core.register_on_chatcommand(function(name, command, params)
    if server_manager.blocked_cmds_when_muted[command] and muted[name] then
        local remaining_seconds = muted[name].expiration - os.time()

        if remaining_seconds <= 0 then
            muted[name] = nil
            storage:set_string("muted", core.serialize(muted))
            return false
        end

        server_manager.warn_player(name, S(
            "You've been muted by @1 (reason: @2, remaining time: @3)",
            muted[name].by, muted[name].reason, format_remaining_time(remaining_seconds)
        ))

        return true
    end
end)



--
-- LOCAL FUNCTIONS
--
function format_remaining_time(time)
    local floor = math.floor
    local mod = math.mod
    local days = floor(time/86400)
    local hours = floor((time % 86400)/3600)
    local minutes = floor((time % 3600)/60)
    local seconds = floor((time % 60))

    return string.format("%d:%02d:%02d:%02d", days, hours, minutes, seconds)
end
