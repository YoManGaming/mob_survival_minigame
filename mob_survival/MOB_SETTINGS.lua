--!
--! DON'T TOUCH THIS.
--!
--! if you want to modify any of these settings just edit the file in <YOUR_WORLD_FOLDER>/mob_survival/
--Add mobs with a given difficulty
mob_survival.mobdiffs = {}
mobdiffs["forgotten_monsters:meselord"] = 20
mobdiffs["forgotten_monsters:golem"] = 40
mobdiffs["forgotten_monsters:sking"] = 60
mobdiffs["forgotten_monsters:growler"] = 3
mobdiffs["forgotten_monsters:ssword"] = 2
mobdiffs["forgotten_monsters:skull_berserker"] = 2
mobdiffs["forgotten_monsters:skull"] = 1
mobdiffs["forgotten_monsters:sarchers"] = 1

--Add the total difficulty of all mobs that can spawn in a wave.
--The difficulty for each wave is total_mob_diff*wave_number.
--So for wave 3 and total_mob_diff 4, the total diff of mobs that can spawn is 12
mob_survival.total_mob_diff = 4