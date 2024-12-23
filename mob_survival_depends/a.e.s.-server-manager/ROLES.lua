local S = core.get_translator("server_manager")

---@alias role_name string
---@alias role_ref role_name | {role_name: string, expiry_date: number}

---@class (exact) role
---@field internal_name string the internal role name, used to index the role in the mod
---@field name string the readable name of the role. It supports translations
---@field prefix string the string that will be concatenated to the player's name in chat and in their nametag
---@field prefix_color string the prefix color (e.g. "#00000" for black)
---@field duration number the amount of days after which this role wille expire
---@field equippable boolean if true the prefix will be equippable and showed next to the static role
---@field static boolean if true the prefix will always be shown forcibly
---@field also_unlocks table<number, role_ref> if specified these roles will be unlocked when this role is unlocked
---@field privs table<number, string> if specified these privileges will be granted when this role is unlocked


--[[
	ROLE TEMPLATE:
	roles.def["test_role"] = {
		internal_name = "test_role",
    name = "Test role",
    prefix = "[Test role]",
		prefix_color = "#00000",
		duration = 30,  -- in days
		equippable = false,
		static = true,
		also_unlocks = {"test_role2", "test_role3", ...},
		privs = {"priv1", "priv2",...},
	}
]]


-- the default role that will be assigned to players, this can't be removed or renamed.
-- If no other static roles have been unlocked, this will be the displayed one. The default
-- privs are always applied to anyone.
roles.def["default"] = {
	internal_name = "default"
}

roles.def["admin"] = {
    internal_name = "admin",
    name = S("Admin"),
    prefix = "[" .. S("Admin") .. "]",
    prefix_color = "#f4b41b",
    static = true,
}


roles.def["mod"] = {
	  internal_name = "mod",  -- must be the same as the key
	  prefix = "[Moderator]",
	  prefix_color = "#8aebf1",
	  static = true,  -- if true the prefix will always be shown forcibly
	  privs = {"ban", "kick", "mute"},  -- if specified these privileges will be granted when this role is unlocked
}


roles.def["blchampion"] = {
    internal_name = "blchampion",
    name = S("BL Champion"),
    prefix = "[" .. S("BL Champion") .. "]",
    prefix_color = "#c1f3f4",
    equippable = true,
}


roles.def["arcadechampion"] = {
    internal_name = "arcadechampion",
    name = S("Arcade Champion"),
    prefix = "[" .. S("Arcade Champion") .."]",
    prefix_color = "#c1f3f4",
    equippable = true,
}


roles.def["videomaker"] = {
    internal_name = "videomaker",
    name = S("Videomaker"),
    prefix = "[" .. S("Videomaker") .. "]",
    prefix_color = "#ffaeb6",
    duration = 180, -- 6 months
    static = true,
}
