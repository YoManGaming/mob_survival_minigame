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


Configuration files
----------------
All controls are re-bindable using settings.
Some can be changed in the key config dialog in the settings tab.

Leaderboard API
-----

`mob_survival.get_leaderboard`: Get the leaderboard of this minigame sorted on the best score.
```lua
Output example:
{
  [1] = {player = "YoManGaming101", score = 10}
  [2] = {player = "YoManGamingTest", score = 7}
  [3] = {player = "Duhneeno", score = 6}
}
```.

For each wave survived you get gold, with which you can buy better items from the shop.
