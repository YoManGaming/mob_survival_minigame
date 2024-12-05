collectible_skins = {}
collectible_skins.SETTINGS = {}

local version = "1.1.2"
local modpath = minetest.get_modpath("collectible_skins")
local srcpath = modpath .. "/src"

-- TODO: remove after https://github.com/minetest/modtools/issues/2
local S = minetest.get_translator("collectible_skins")

S("Collectible Skins")
S("Wear and unlock custom skins")

dofile(modpath .. "/libs/chatcmdbuilder.lua")

dofile(srcpath .. "/_load.lua")
dofile(srcpath .. "/api.lua")
dofile(srcpath .. "/callbacks.lua")
dofile(srcpath .. "/commands.lua")
dofile(srcpath .. "/items.lua")
dofile(srcpath .. "/player_manager.lua")
dofile(srcpath .. "/privs.lua")
dofile(srcpath .. "/utils.lua")
dofile(srcpath .. "/deps/3d_armor.lua")
dofile(srcpath .. "/GUI/gui_collection.lua")

minetest.log("action", "[COLLECTIBLE SKINS] Mod initialised, running version " .. version)
