local S = core.get_translator("server_manager")
local original_properties = {}  -- "pl_name" = {propeties...}



function server_manager.spectate(spectator_name, target_name)
	if original_properties[spectator_name] then
		server_manager.warn_player(spectator_name, S("You are already spectating someone"))
		return false
	end

	local spectator = core.get_player_by_name(spectator_name)
	local target = core.get_player_by_name(target_name)

	if not target then
		server_manager.warn_player(spectator_name, S("Could not find target player"))
		return false
	end

	if spectator_name == target_name then
		server_manager.warn_player(spectator_name, S("You can't spectate yourself"))
		return false
	end

	original_properties[spectator_name] = table.copy(spectator:get_properties())
	original_properties[spectator_name]._pos = spectator:get_pos()

	spectator:set_nametag_attributes({text = " ", bgcolor = {a=0, r=0, g=0, b=0}})
	spectator:set_properties({
		visual_size = {x=0, y=0, z=0},
		pointable = false,
		makes_footstep_sound = false
	})

	core.after(0, function ()
		spectator:set_attach(target)
	end)
end



function server_manager.stop_spectating(spectator_name)
	if not original_properties[spectator_name] then
		server_manager.warn_player(spectator_name, S("You are not spectating anyone"))
		return false
	end

	local spectator = core.get_player_by_name(spectator_name)
	local old_pos = original_properties[spectator_name]._pos

	spectator:set_detach()
	spectator:set_pos(old_pos)
	spectator:set_properties(original_properties[spectator_name])
	original_properties[spectator_name] = nil

	core.after(0, function ()  -- mt has bugs...
		spectator:set_pos(old_pos)
	end)

	roles.update_nametag(spectator_name)
end



function server_manager.is_spectating(pl_name)
	return original_properties[pl_name] ~= nil
end