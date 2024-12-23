server_manager = {}

---@type table
roles = {
	---@type table<string, role>
	def = {}
}

local modpath = core.get_modpath("server_manager")
local srcpath = modpath .. "/src"

dofile(modpath .. "/SETTINGS.lua")
dofile(modpath .. "/ROLES.lua")
dofile(srcpath .. "/database.lua")

dofile(srcpath .. "/utils.lua")
dofile(srcpath .. "/player_spectating.lua")
dofile(srcpath .. "/broadcast.lua")
dofile(srcpath .. "/build.lua")
dofile(srcpath .. "/bypass_userlimit.lua")
dofile(srcpath .. "/commands.lua")
dofile(srcpath .. "/nodes.lua")
dofile(srcpath .. "/items.lua")
dofile(srcpath .. "/player_manager.lua")
dofile(srcpath .. "/privs.lua")
dofile(srcpath .. "/accounts_ip.lua")
dofile(srcpath .. "/lessblocks.lua")

dofile(srcpath .. "/roles/roles_database.lua")
dofile(srcpath .. "/roles/roles_api.lua")
dofile(srcpath .. "/roles/roles_chat_prefix.lua")
dofile(srcpath .. "/roles/roles_player_manager.lua")
dofile(srcpath .. "/roles/roles_cmds.lua")

dofile(srcpath .. "/afk.lua")

dofile(srcpath .. "/chat_moderation/caps_prevention.lua")
dofile(srcpath .. "/chat_moderation/chat_log.lua")
dofile(srcpath .. "/chat_moderation/flood_prevention.lua")
dofile(srcpath .. "/chat_moderation/mute.lua")
