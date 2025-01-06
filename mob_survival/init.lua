mob_survival = {}
storage = minetest.get_mod_storage()

minetest.register_chatcommand("resetleaderboard", {
  description = "Reset the leaderboard for all players!",
  privs = "server",
  func = function(name, param)
    mob_survival.reset_leaderboard()
    return true, "Leaderboard successfully reset!"
  end,
})

arena_lib.register_minigame("mob_survival", {
    name = "Mob Survival",
    prefix = "[Mob Survival] ",
    teams = {
        "Players",
      },
    teams_color_overlay = {
        "blue"
      },
    temp_properties = {
      diff = 1,
      wave_cleared = false,
      shopkeeper = nil,
      seconds = 0,
      players_on_start = {},
      moblist = {}
    },
    spectator_properties = {
      diff_on_elim = 0
    },  
    is_team_chat_default = false,
    end_when_too_few = false,
    show_nametags = true,
    regenerate_map = true,
    spectate_mode = "blind",
    min_players = 1,
    hotbar = {
        slots = 8,
        background_image = "arenalib_gui_hotbar2.png"
      },
    }
)

local function set_player_hungers()
  for _, player in pairs(minetest.get_connected_players()) do
    if not arena_lib.is_player_in_arena(player:get_player_name()) then
      mcl_hunger.set_hunger(player, 20)
    end
  end

  minetest.after(0.5, function()
    set_player_hungers()
  end)
end

mob_survival.path = minetest.get_modpath(minetest.get_current_modname())

dofile(mob_survival.path.."/src/files_loader.lua")
dofile(mob_survival.path.."/src/api.lua")
dofile(mob_survival.path.."/src/shop.lua")
dofile(mob_survival.path.."/src/shopkeeper.lua")
dofile(mob_survival.path.."/src/leaderboardzombie.lua")
dofile(mob_survival.path.."/src/arena_manager.lua")

--Do lobby stuff
set_player_hungers()


local function wait_for_playerconnect()
  local any_player_joined = false
  for _, player in pairs(minetest.get_connected_players()) do
    any_player_joined = true
  end
  if any_player_joined then
    minetest.after(3, function()
      if storage:get_string("leaderboardzombie") ~= "" then
        local pos = minetest.deserialize(storage:get_string("leaderboardzombie"))
        minetest.add_entity(pos, "mob_survival:leaderboardzombie", "check")
      end
    end)
  else
    minetest.after(5, function()
      wait_for_playerconnect()
    end)
  end
end

wait_for_playerconnect()