--!
--! DON'T TOUCH THIS.
--!
--! if you want to modify any of these settings just edit the file in <YOUR_WORLD_FOLDER>/mob_survival/
--Set gold addition for each round.
mob_survival.gold_addition = {
	[1] = 50,
	[2] = 50,
	[3] = 50,
	[4] = 75,
	[5] = 75,
	[6] = 100,
	[7] = 100,
	[8] = 100,
	[9] = 150,
	[10] = 150,
	[11] = 175,
	[12] = 175,
	[13] = 200,
	[14] = 200,
	[15] = 200
}

mob_survival.mob_kills_gold = {
	["mobs_mc:iron_golem"] = 15,
	["mobs_mc:vindicator"] = 10,
	["mobs_mc:evoker"] = 10,
	["mobs_mc:witherskeleton"] = 7,
	["mobs_mc:skeleton"] = 5,
	["mobs_mc:spider"] = 3,
	["mobs_mc:villager_zombie"] = 3,
	["mobs_mc:zombie"] = 3
}

mob_survival.shop_items = {
	--Add items to the shop. Format: ["itemname"] = <price>
	["rangedweapons:aa12"] = 150,
	["rangedweapons:ak47"] = 200,
	["rangedweapons:scar"] = 350,
	["rangedweapons:milkor"] = 500,
	["farming:bread"] = 100, --price for 10
	["rangedweapons:762mm"] = 75, --price for 10
	["rangedweapons:shell"] = 50,
	["rangedweapons:9mm"] = 50,
	["rangedweapons:40mm"] = 150,
	["3d_armor:chestplate_bronze"] = 200, --Price for armor set
	["3d_armor:chestplate_steel"] = 300,
	["3d_armor:chestplate_nether"] = 400
}

mob_survival.start_items = {
	--Add items to the shop. Format: ["itemname"] = <amount>. Guns should always be 1
	["rangedweapons:makarov"] = 1,
	["farming:bread"] = 20,
	["rangedweapons:9mm"] = 50,
	["rangedweapons:shell"] = 50,
	["rangedweapons:762mm"] = 50
}