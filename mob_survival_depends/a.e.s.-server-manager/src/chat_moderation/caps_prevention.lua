local S = core.get_translator("server_manager")

local function infringements_auto_decrease() end
local function check_message() end

local min_infringements = server_manager.min_infringements_number_to_mute_for_caps
local mute_durations = server_manager.punishment_mute_durations
local infringements = {} -- "pl_name" = <number>
local punishments = {} -- "pl_name" = <number>
local last_infringment = {} -- "pl_name" = <date in seconds>



core.register_on_chat_message(function(name, msg)
    infringements[name] = infringements[name] or 0
    local arena = arena_lib.get_arena_by_player(name)

    if core.get_player_privs(name)["kick"] or (arena and not arena.in_queue) or server_manager.is_muted(name) then
        return false
    end

    if check_message(msg) then
        infringements[name] = infringements[name] + 1
        last_infringment[name] = server_manager.get_time_in_seconds()

        if infringements[name] == min_infringements - 1 then
            server_manager.warn_player(name, S("Don't abuse CAPS or you'll be muted!"))
        elseif infringements[name] >= min_infringements then
            punishments[name] = punishments[name] or 0

            if punishments[name] < #mute_durations then
                punishments[name] = punishments[name] + 1
            end

            local mute_duration = mute_durations[punishments[name]]
            server_manager.mute("Server", name, mute_duration, "m", "abusing CAPS")

            infringements[name] = 0

            return true
        end
    end
end)





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function infringements_auto_decrease()
    for name, count in pairs(infringements) do
        last_infringment[name] = last_infringment[name] or 0
        local time_since_last_infringment = server_manager.get_time_in_seconds() - last_infringment[name]

        if time_since_last_infringment > 60 then
            if count > 0 then
                infringements[name] = count - 1
            end
        end
    end

    core.after(1, function() infringements_auto_decrease() end)
end
infringements_auto_decrease()



-- checks messages for CAPITAL letters, catches NEarLY all caps messages too
function check_message(message)
    if #message <= 1 then return false end

	local capscounter = 0 -- used to count capital letters in messages
	local sensitivity = 30

	for i = 1, #message do
		local char = message:sub(i,i)
		-- replace anything that isn't a letter with a lower case "a"
		-- else it picks up spaces, numbers, and other special characters as capital letters
		char = char:gsub('%A', 'a')
		if char == char:upper() then
			capscounter = capscounter + 1
		end
	end
	-- if the percentage of CAPS letters in the message exceed the sensitivity setting, return true
	if capscounter > 1 and (capscounter * 100 / message:len()) >= sensitivity then
		return(true)
	end
end
