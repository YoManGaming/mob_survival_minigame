-- This addon's purpose is to include advanced pathfinding features of VoxeLibre's mobs
-- into Mobs Redo API monsters, MC Mobs etc.
--
-- How to do it: I already copied Mobs Redo related mods under the satlantis game folder.
-- I will take VoxeLibres pathfinding code into same directory of this file,
-- change/adapt the code while making minimal changes in it.
-- Also, pathfinding related mcl_mobs class properties need to be implemented into the Mobs Redo
-- since path calculations stores states within the mcl_mobs class.

local path = minetest.get_modpath("smob_addons")

-- dofile(path .. "/mcl_movement.lua")
-- dofile(path .. "/mcl_pathfinding.lua")
-- dofile(path .. "/mcl_combat.lua")

-- add missing class properties for mobs.mob_class?