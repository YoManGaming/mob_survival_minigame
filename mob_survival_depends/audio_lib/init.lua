local version = "1.1.0"
local modpath = minetest.get_modpath("audio_lib")
local srcpath = modpath .. "/src"

audio_lib = {}

dofile(srcpath .. "/api.lua")
dofile(srcpath .. "/commands.lua")
dofile(srcpath .. "/player_manager.lua")
dofile(srcpath .. "/settings.lua")
dofile(srcpath .. "/HUD/hud_accessibility.lua")
dofile(srcpath .. "/GUI/gui_settings.lua")
dofile(srcpath .. "/tests/bgm.lua")
--dofile(srcpath .. "/tests/custom_types.lua")
dofile(srcpath .. "/tests/sfx.lua")

minetest.register_on_mods_loaded(function()
  dofile(srcpath .. "/register/MTG.lua")
end)

minetest.log("action", "[AUDIO_LIB] Mod initialised, running version " .. version)
