--!
--! DON'T TOUCH THIS.
--!
--! if you want to modify any of these settings just edit the file in <YOUR_WORLD_FOLDER>/mob_survival/
--Add mobs with a given difficulty
mob_survival.mobdiffs = {}
mob_survival.mobdiffs["mobs_mc:enderdragon"] = 200
mob_survival.mobdiffs["mobs_mc:wither"] = 200
mob_survival.mobdiffs["mobs_mc:iron_golem"] = 20
mob_survival.mobdiffs["mobs_mc:blaze"] = 10
mob_survival.mobdiffs["mobs_mc:ghast"] = 10
mob_survival.mobdiffs["mobs_mc:pillager"] = 5
mob_survival.mobdiffs["mobs_mc:vindicator"] = 5
mob_survival.mobdiffs["mobs_mc:evoker"] = 5
mob_survival.mobdiffs["mobs_mc:witch"] = 5
mob_survival.mobdiffs["mobs_mc:witherskeleton"] = 3
mob_survival.mobdiffs["mobs_mc:skeleton"] = 2
mob_survival.mobdiffs["mobs_mc:spider"] = 2
mob_survival.mobdiffs["mobs_mc:villager_zombie"] = 1
mob_survival.mobdiffs["mobs_mc:zombie"] = 1

--Add the total difficulty of all mobs that can spawn in a wave.
--The difficulty for each wave is total_mob_diff*wave_number.
--So for wave 3 and total_mob_diff 4, the total diff of mobs that can spawn is 12
mob_survival.total_mob_diff = 6