Mob survival minigame for Luanti (Minetest Game)
==========================
Mob survival is a minigame where mobs spawn in waves and players have to shoot the mobs to get to the next wave.


Table of Contents
------------------

1. [Installation](#Installation)
2. [Configuration files](#Configuration-files)
3. [Leaderboard API](#Leaderboard-API)


Installation
----------------------
GNU/Linux:
1. `sudo snap install minetest`: Install minetest for Linux.
2. Then download minetest_game and sftp the folder to `~/snap/minetest/1934/.minetest/games`
3. Then move to your home directory with using `cd`
4. Then use the command `nano start.sh` and paste the code below in it:
```bash
cd ~/snap/minetest/1934/mods/mob_survival_minigame
git pull

minetest --server --gameid minetest_game --worldname mob_survival
```
5. Then run the command `sudo chmod +x start.sh`
6. Then sftp the world folder mob_survival to `~/snap/minetest/1934/.minetest/worlds`

7. Then you can start the minetest server with `~/start.sh`

Configuration files
----------------
The configuration files of mob_survival are located in:
`~/snap/minetest/1934/worlds/mob_survival/mob_survival`

`SHOP_SETTINGS.lua`:
In this configuration file, it should look like this:
```lua
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

mob_survival.shop_items = {
	--Add items to the shop. Format: ["itemname"] = <price>
	["rangedweapons:aa12"] = 150,
	["rangedweapons:ak47"] = 200,
	["rangedweapons:scar"] = 350,
	["farming:bread"] = 25, --price for 10
	["rangedweapons:762mm"] = 75, --price for 10
	["rangedweapons:shell"] = 50,
	["rangedweapons:9mm"] = 50,
	["3d_armor:chestplate_bronze"] = 200, --Price for armor set
	["3d_armor:chestplate_steel"] = 300,
	["3d_armor:chestplate_nether"] = 400
}
```
In this file, you can configure the settings for the shop. There are 2 parts of the minigame you can configure here:
`mob_survival.gold_addition`: Set the amount of gold that is given after each wave that is cleared. If you want to give 100 gold for 3 consecutive rounds, you need to define every single round.
Every round after the last round defined, defaults to the last round. So for this example, round 16 also gives 200 gold.
`mob_survival.shop_items`: Here you can add items to the item shop.
When buying bread, the system defaults to giving 10 bread. The same goes with ammo. For armor, the system defaults to giving the whole armor set.

`MOB_SETTINGS.lua`:
In this configuration file, it should look like this:
```lua
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
```
`mob_survival.mobdiffs`: Add mobs with a custom difficulty to kill here.
`mob_survival.total_mob_diff`: Configure how much total diff there should be for each wave.
Each wave gets harder. As you can see in the config example, this variable gets multiplied by the wave number to determine the difficulty of the wave.
Arena_manager always makes sure that the total difficulty of all the mobs that will get spawned, equals to the total wave difficulty.
To help arena_manager with this, make sure you always have a mob with diff = 1.


Leaderboard API
-----

`mob_survival.get_leaderboard()`: Get the leaderboard of this minigame sorted on the best score.
```lua
Output example:
{
  [1] = {player = "YoManGaming101", score = 10}
  [2] = {player = "YoManGamingTest", score = 7}
  [3] = {player = "Duhneeno", score = 6}
}
```
