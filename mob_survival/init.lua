mob_survival = {}

--set world spawn
minetest.register_chatcommand("setspawn", {
  description = "Set server spawnpoint",
  privs = "server",
  params = "[save]",
  func = function(name, param)
          local player = minetest.get_player_by_name(name)
          if not player then
                  return false, "Must be in-game!"
          end

          local pos = player:get_pos()
          if param == "save" then                          
                  return true, minetest.pos_to_string(pos)
          end
          return false, "Use /setspawn save"
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
  for player in minetest.get_connected_players() do
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
dofile(mob_survival.path.."/src/travelguide.lua")
dofile(mob_survival.path.."/src/arena_manager.lua")

set_player_hungers()