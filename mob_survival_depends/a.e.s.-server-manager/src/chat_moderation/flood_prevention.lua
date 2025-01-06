local S = core.get_translator("server_manager")
-- TODO: disattiva su quikbild

local min_delay = server_manager.min_delay_between_messages -- in seconds
local min_infringements = server_manager.min_infringements_number_to_mute_for_flood
local mute_durations = server_manager.punishment_mute_durations
local infringements = {} -- "pl_name" = <number>
local punishments = {} -- "pl_name" = <number>
local last_infringment = {} -- "pl_name" = <date in seconds>



core.register_on_chat_message(function(name, msg)
    local log = server_manager.chat_logs[name] or {}
    infringements[name] = infringements[name] or 0
    local arena = arena_lib.get_arena_by_player(name)

    if core.get_player_privs(name)["kick"] or (arena and not arena.in_queue) or server_manager.is_muted(name) then
        return false
    end

    if #log >= 2 then
        local msgs_delay = log[#log].date - log[#log-1].date

        if msgs_delay < min_delay then
            infringements[name] = infringements[name] + 1
            last_infringment[name] = server_manager.get_time_in_seconds()

            if infringements[name] < min_infringements then
                server_manager.warn_player(name, S("Write slower or you'll be muted!"))
            else
                punishments[name] = punishments[name] or 0

                if punishments[name] < #mute_durations then
                    punishments[name] = punishments[name] + 1
                end

                local mute_duration = mute_durations[punishments[name]]
                server_manager.mute("Server", name, mute_duration, "m", "flooding")

                infringements[name] = 0

                return true
            end
        end
    end
end)



local function infringements_auto_decrease()
    for name, count in pairs(infringements) do
        last_infringment[name] = last_infringment[name] or 0
        local time_since_last_infringment = server_manager.get_time_in_seconds() - last_infringment[name]

        if time_since_last_infringment > 10 * min_delay then
            if count > 0 then
                infringements[name] = count - 1
            end
        end
    end

    core.after(1, function() infringements_auto_decrease() end)
end
infringements_auto_decrease()