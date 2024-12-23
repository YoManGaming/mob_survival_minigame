smartphone_custom = {}
local mod_path = minetest.get_modpath("smartphone_custom")

dofile(mod_path.."/src/smartphone_formspec.lua")

local function test_include()
	dofile(mod_path.."/src/test/test_apps.lua")
end

--test_include()