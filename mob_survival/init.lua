mob_survival = {}

arena_lib.register_minigame("mob_survival", {
    name = "Mob Survival",
    prefix = "[Mob Survival] ",
    teams = {
        "Players",
      },
    teams_color_overlay = {
        "blue"
      },
    is_team_chat_default = true,
    min_players = 1,
    hotbar = {
        slots = 8,
        background_image = "arenalib_gui_hotbar2.png"
      },
    properties = {
        spectator_jail = {x = -2, y = 29, z = -34}
      }
      
    }
)

mob_survival.path = minetest.get_modpath(minetest.get_current_modname())

dofile(mob_survival.path.."/src/arena_manager.lua")
dofile(mob_survival.path.."/src/files_loader.lua")
dofile(mob_survival.path.."/src/leaderboard_api.lua")
dofile(mob_survival.path.."/src/shop.lua")
dofile(mob_survival.path.."/src/shopkeeper.lua")