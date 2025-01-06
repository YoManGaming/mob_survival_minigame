local times = {.75,.5,.25}
local crackytimes = {times[1]*1.5,times[2]*1.5,times[3]*1.5}


core.register_craftitem("server_manager:magic_pickaxe",{
	stack_max = 1,
	description = "Magic Pickaxe\nCan break every node efficiently",
	inventory_image = "servermanager_magic_pick.png",
	wield_image = "servermanager_magic_pick.png",
	tool_capabilities = {
		 full_punch_interval = 1.0,
		 max_drop_level = 0,
		 groupcaps = {
			  crumbly = {times = times, maxlevel = 3},
			  cracky = {times = crackytimes, maxlevel = 3},
			  snappy = {times = {.1,.1,.1}, maxlevel = 3},
			  choppy = {times = times, maxlevel = 3},
		 },
	},
})
