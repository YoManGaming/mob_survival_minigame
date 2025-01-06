local S = core.get_translator("server_manager")
local afk_time = server_manager.time_after_player_gets_afk -- in seconds



function server_manager.check_afk()
	local afk_players = afk_indicator.get_all_longer_than(afk_time)

	for pl_name, duration in pairs(afk_players) do
		if not arena_lib.is_player_in_arena(pl_name) then
			local player = core.get_player_by_name(pl_name)
			player:set_nametag_attributes({
				text = core.colorize("#cfc6b8", "[AFK] " .. pl_name)
			})
		end
	end

	core.after(1, server_manager.check_afk)
end
server_manager.check_afk()



local old_update = afk_indicator.update
function afk_indicator.update(pl_name)
	if not arena_lib.is_player_in_arena(pl_name) then
		roles.update_nametag(pl_name)
	end

	old_update(pl_name)
end



core.register_chatcommand("afk", {
	func = function (name)
		afk_indicator.last_updates[name] = -afk_time
		if not arena_lib.is_player_in_arena(name) then
			core.chat_send_player(name, S("You're now AFK"))
		else
			server_manager.warn_player(name, S("You can't go AFK while playing!"))
		end
	end
})


core.register_on_player_receive_fields(function (player, formname, fields)
	afk_indicator.update(player:get_player_name())
end)