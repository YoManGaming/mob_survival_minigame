--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### VINDICATOR
--###################


mcl_mobs.register_mob("mobs_mc:vindicator", {
	description = S("Vindicator"),
	type = "monster",
	spawn_class = "hostile",
	physical = false,
	pathfinding = 1,
	hp_min = 24,
	hp_max = 24,
	xp_min = 6,
	xp_max = 6,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_vindicator.b3d",
	head_swivel = "head.control",
	bone_eye_height = 2.2,
	head_eye_height = 2.2,
	curiosity = 10,
  textures = {
      {
          "mobs_mc_vindicator.png",
          "blank.png", --no hat
          "default_tool_steelaxe.png",
          -- TODO: Glow when attacking (mobs_mc_vindicator.png)
      },
  },
	visual_size = {x=2.75, y=2.75},
	makes_footstep_sound = true,
	damage = 13,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	attack_type = "dogfight",
	attack_npcs = true,
	drops = {
		{name = "rangedweapons:762mm", chance = 1, min = 3, max = 8},
		{name = "rangedweapons:9mm", chance = 1, min = 3, max = 8},
		{name = "rangedweapons:shell", chance = 1, min = 3, max = 8}
	},
	-- TODO: sounds
	animation = {
		stand_speed = 25,
		stand_start = 40,
		stand_end = 59,
		walk_speed = 25,
		walk_start = 0,
		walk_end = 40,
		run_speed = 25,
		punch_speed = 25,
		punch_start = 90,
		punch_end = 110,
		die_speed = 15,
		die_start = 170,
		die_end = 180,
		die_loop = false,
	},
	view_range = 16,
	fear_height = 4,
	can_despawn=false,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:vindicator", S("Vindicator"), "#959b9b", "#275e61", 0)
mcl_mobs:non_spawn_specific("mobs_mc:vindicator","overworld",0,7)
