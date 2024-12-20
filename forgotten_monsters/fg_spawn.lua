forgotten_monsters.daytime = core.settings:get_bool("forgotten_monsters.daytime", true)

local skull_spawns = {

"group:stone",
"group:soil",
"group:leaves",
"group:dirt",
"group:ash",
"group:crumbly",

}


--[[
-- caso venha desovar dentro de alguma casa com node do grupo de pedra
local skull_spawn_caves = {
	"group:stone",
	"group:crumbly"
}
]]



--  SKULLS : ===========================================================================

local max_light_skull = 7


if forgotten_monsters.daytime then -- Opção para não surgir de dia ..

   max_light_skull = 14
	
end

local random = math.random
function forgotten_monsters.spawn_monster(monster)
	local rand = random(1, 3)
	local pos = {}
	if rand == 1 then
		pos.x = random(-42, 18)
		pos.y = 10
		pos.z = random(-85, -49)
	elseif rand == 2 then
		pos.x = random(42, 35)
		pos.y = 18
		pos.z = random(-71, 20)
	else
		pos.x = random(27, 0)
		pos.y = 8
		pos.z = random(7, -20)
	end

	local def = mobs:add_mob(pos, {
		name = monster,
		child = false,
		ignore_count = true -- ignores mob count per map area
	})
	return def
end

if not core.get_modpath("mcl_core") then -- Algumas caveiras não deverar surgir no mcl , arqueira e normal


mobs:spawn({
	name = "forgotten_monsters:sarchers",
	nodes = skull_spawns,
	neighbors = "air",
	min_light = 0,
	max_light = max_light_skull,
	chance = 7000,
	--min_height = 0,
	max_height = 200,
})


mobs:spawn({
	name = "forgotten_monsters:skull",
	nodes = skull_spawns,
	neighbors = "air",
	min_light = 0,
	max_light = max_light_skull,
	chance = 8000,
	--min_height = 0,
	max_height = 200,
	active_object_count = 1,

})


end



mobs:spawn({
	name = "forgotten_monsters:skull_berserker",
	nodes = skull_spawns,
	neighbors = "air",
	min_light = 0,
	max_light = max_light_skull,
	chance = 7000,
	--min_height = 0,
	--max_height = 200,
	max_height = 200,
})





mobs:spawn({
	name = "forgotten_monsters:ssword",
	nodes = skull_spawns,
	neighbors = "air",
	min_light = 0,
	max_light = max_light_skull,
	chance = 7000,
	--min_height = 0,
	--max_height = 200,
	max_height = 200,
})




-- OUTROS : =============================================================================
mobs:spawn({
	name = "forgotten_monsters:growler",
	nodes = "air",
	neighbors = {"group:leaves"},
	min_light = 14,
	interval = 60, 
	chance = 50000, 
	min_height = 0,
	max_height = 200,
	day_toggle = true, 
	active_object_count = 1, 
})


mobs:spawn({
	name = "forgotten_monsters:hungry",
	nodes = {"group:soil"},
	neighbors = "air",
	min_light = 14,
	--interval = 30, -- 60
	chance = 9000,
	min_height = 0,
	max_height = 200,
})


mobs:spawn({
	name = "forgotten_monsters:spectrum",
	nodes = {"air"},
	interval = 60,
	chance = 60000,
	active_object_count = 1,
	min_light = 0,
	max_light = 7,
})

-- BOSSES : ==========================================================================
-- Agora devem ser sumonados, devido a diferença de altura e nodes entre jogos ;)

--[[
mobs:spawn({
	name = "forgotten_monsters:meselord",
	nodes = {"air"},
	max_light = 7,
	interval = 60,
  chance = 150000,
	max_height = -550,
	min_height = -650,
})




mobs:spawn({
	name = "forgotten_monsters:golem",
	nodes = {"group:stone"},
	max_light = 7,
	interval = 60,
        chance = 150000,
	max_height = -750,
	min_height = -850,
})


mobs:spawn({
	name = "forgotten_monsters:sking",
	nodes = {"default:cobble","default:mossycobble", "default:chest"},
	max_light = 7,
	interval = 60,
  	chance = 150000,
	max_height = -1100,

})

]]

