local S = core.get_translator("server_manager")
local function teleport_to_player() end
local function print_report() end

core.unregister_chatcommand("admin")



local cmd_tp = chatcmdbuilder.register("tp", {
	description = "tp <player> [to_player]",
	privs = { teleport = true  }
})

cmd_tp:sub(":target", function(name, target_name)
	core.chat_send_player(name, teleport_to_player(name, target_name))
end)

cmd_tp:sub(":playername :target", function(name, pl_name, target_name)
	core.chat_send_player(name, teleport_to_player(pl_name, target_name))
end)



--== Reporting ==--

local function redirect_on_matrix(pl_name)
	server_manager.warn_player(pl_name, S("Do you want to report someone? Join our Matrix community: #arcadeemulationserver:matrix.org (you need a client like Element)"))
end

local cmd_report = chatcmdbuilder.register("report", {
})


cmd_report:sub(":target:username :message:text", function(name, target_name, msg)
	redirect_on_matrix(name)
end)

cmd_report:sub(":target:username", function(name, target_name, msg)
	redirect_on_matrix(name)
end)

cmd_report:sub("", function(name, target_name, msg)
	redirect_on_matrix(name)
end)




--== Spectating ==--

local cmd_spectate = chatcmdbuilder.register("spectate", {
	description = S("/spectate <player>"),
	privs = { kick = true  }
})

local cmd_unspectate = chatcmdbuilder.register("unspectate", {
	description = S("/unspectate"),
 privs = { kick = true  }
})

cmd_spectate:sub(":target:username", function(name, target_name)
	server_manager.spectate(name, target_name)
end)


cmd_unspectate:sub("", function(name)
	server_manager.stop_spectating(name)
end)



--== Blocking cmds ==--

core.register_on_chatcommand(function(name, command, params)
    if not core.check_player_privs(name, "server") then
        if server_manager.blocked_cmds[command] then
            server_manager.warn_player(name, S("Admins have blocked this command"))
            return true
        end
    end
end)



--== Local Functions ==--

function teleport_to_player(name, target_name)
	if name == target_name then
		return "One does not teleport to oneself."
	end
	local teleportee = core.get_player_by_name(name)
	if not teleportee then
		return S("Cannot get teleportee with name @1.", name)
	end
	if teleportee:get_attach() then
		return S("Cannot teleport, @1 is attached to an object!", name)
	end
	local target = core.get_player_by_name(target_name)
	if not target then
		return S("Cannot get target player with name @1.", target_name)
	end

	local p = target:get_pos()
	teleportee:set_pos(p)
	return S("Teleporting @1 to @2 at @3.", name, target_name,
    core.pos_to_string(p, 1))
end



function print_report(name, report)
	core.chat_send_player(name, "\t- ".."["..report.date.."] "..S("@1 REPORTED @2 FOR @3", report.reporter, report.reported, report.reason))
end