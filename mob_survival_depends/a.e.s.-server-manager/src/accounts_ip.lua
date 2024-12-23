ChatCmdBuilder.new("accounts", function(cmd)
	cmd:sub(":target", function(name, target_name)
		if not core.get_player_by_name(target_name) then
			server_manager.warn_player(name, target_name.." isn't online")
			return
		end

		local accounts = {}
		local original_ip = core.get_player_information(target_name).address

		for _, obj in ipairs(core.get_connected_players()) do
			local name = obj:get_player_name()
			local ip = core.get_player_information(name).address

			if original_ip == ip then
				table.insert(accounts, name)
			end
		end

		core.chat_send_player(name, target_name.."'s accounts: "..table.concat(accounts, ", "))
	end)
end, {
	description = "accounts <player>: it prints out all the connected players with the same ip",
	privs = { kick = true  }
})