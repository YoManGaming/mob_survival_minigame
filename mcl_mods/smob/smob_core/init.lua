-- smob_core is guaranteed to called at startup first.
-- It is done by manuplating properties of game.conf file.
satlantis = {}

dofile(minetest.get_modpath(minetest.get_current_modname()).."/startup.lua")


