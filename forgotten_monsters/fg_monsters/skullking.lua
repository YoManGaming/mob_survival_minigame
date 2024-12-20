---- SKULL KING  ( BOSS FINAL ) ------------------------------------------------------------------------------------------------------
-- sound attack : https://freesound.org/people/TomRonaldmusic/sounds/607201/
-- sound hummer : https://freesound.org/people/TomRonaldmusic/sounds/607201/

 local last_attack = 0
 

mobs:register_mob("forgotten_monsters:sking", {
	--nametag = "Skull King Boss" ,
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 4,
	damage = 15,
	hp_min = 700,
	hp_max = 700,
	armor = 80,
	visual = "mesh",
	visual_size = {x = 12, y = 12},
	mesh = "skull_king.b3d",
	collisionbox = {-0.4, -0, -0.4, 0.4, 1.8, 0.4},
	--rotate = 180,
	textures = {
		{"skull_king.png"},
	},
	--glow = 3,
	blood_texture = "buried_bone.png",
	makes_footstep_sound = true,
	sounds = {
		attack = "skullking",
		death = "falling_bones",
	},
	-----------------------
	pathfinding = 1,
	fear_height = 6,
	stepheight = 3,

	walk_velocity = 2,
	run_velocity = 6,
	walk_chance = 50,
	stand_chance = 50,

	jump = true,
	jump_height = 3,
	floats = 0,
	view_range = 35,
	-------------------------
	drops = {
		{name = "rangedweapons:9mm", chance = 1, min = 10, max = 20},
		{name = "rangedweapons:shell", chance = 1, min = 10, max = 15},
		{name = "rangedweapons:762mm", chance = 1, min = 5, max = 15},
	},
	water_damage = 0,
	lava_damage = 1,
	light_damage = 0,
	animation = {
		speed_normal = 15,
		speed_run = 25,
		stand_start = 0,
		stand_end = 10,
		walk_start = 20,
		walk_end = 60,
		run_start = 70,
		run_end = 90,
		punch_start = 100,
		punch_end =120,
		punch_speed = 15,


	},

       
        --[[
	on_spawn = function ()
	--core.chat_send_all ("The Skull King is reborn...")
	end,
	]]
	
	
	custom_attack = function(self, to_attack)
	
	 local current_time = core.get_us_time() -- tempo atual mas emmicro segundos
	 
	  if current_time - last_attack >= 4 * (10^6)  then 
		last_attack = current_time 
		
	        
	   	for _, player in ipairs(core.get_connected_players()) do
				     
				     
			local attached = self.attack:get_attach()
			local pp = player:get_pos()

			if attached then
			self.attack = attached
			end
			

			self.attack:punch(self.object, 5.0, {
		        full_punch_interval=5.0,
		        damage_groups={fleshy=15}, 
		        })
		                		
		        
		    self.object:set_animation({x=100, y=120},15, 1, false)      				
			self.attack:set_pos({x=pp.x+5,y=pp.y+2,z=pp.z})     
			core.sound_play("air_impact", {pos = pos, gain = 0.5})

			core.after(1 , function ()
				self.object:set_animation({x=20, y=60},15, 1, false)   
                
				local pos =  self.object:get_pos()
			
			end)
				   
		 end
	    end
	
	end,
	
	
	on_die = function(self, pos) 
	
		--[[
			for _,players in pairs(core.get_objects_inside_radius(pos,40)) do 
					if players:is_player() then -- SE PLAYER
						
					end
				end

		]]
		
	

	    core.add_particlespawner({
            amount = 50, 
            time = 1, 
            minpos = {x = pos.x - 2, y = pos.y, z = pos.z - 2},
            maxpos = {x = pos.x + 2, y = pos.y + 2, z = pos.z + 2},
            minvel = {x = -3, y = -3, z = -3}, 
            maxvel = {x = 3, y = 3, z = 3}, 
            minacc = {x = 0, y = -1, z = 0},
            maxacc = {x = 0, y = -1, z = 0}, 
            minexptime = 3, 
            maxexptime = 6, 
            minsize = 2,
            maxsize = 6,
            collisiondetection = false,
            vertical = false, 
            texture = "part_spawn_king.png", 
            glow = 7, 
        })

	end
})



mobs:register_egg("forgotten_monsters:sking", "Skull King", "skull_king_egg.png", 0)

